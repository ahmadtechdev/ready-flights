import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class ApiServiceFlyDubai {
  // FlyDubai API credentials and constants
  static const String clientId = 'TravelocityPK_FZ_P';
  static const String clientSecret = '57F2F0BE34296098FB0E147194462A60';
  static const String username = 'apitravelocityp';
  static const String password = 'Ag3n@tPk!FLyDuB@1';
  static const String baseUrl = 'https://api.flydubai.com/res/v3';

  // Access token for API calls
  String? _accessToken;

  // Authenticate with FlyDubai API
  Future<bool> authenticate() async {
    try {
      developer.log('Authenticating with FlyDubai API...');

      final String bodyString = 'client_id=$clientId&client_secret=$clientSecret&grant_type=password&password=${Uri.encodeComponent(password)}&scope=res&username=$username';

      final response = await http.post(
        Uri.parse('$baseUrl/authenticate'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': 'visid_incap_3059742=mt0fc3JTQDStXbDmAKotlet1zGUAAAAAQUIPAAAAAAA/4nh9vwd+842orxzMj3FS',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: bodyString,
      );

      developer.log('FlyDubai Auth Response Status: ${response.statusCode}');
      developer.log('FlyDubai Auth Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = json.decode(response.body);
        if (tokenData.containsKey('access_token')) {
          _accessToken = tokenData['access_token'];
          developer.log('FlyDubai Authentication successful');
          return true;
        }
      }

      developer.log('FlyDubai Authentication failed');
      return false;
    } catch (e) {
      developer.log('FlyDubai Authentication error: $e');
      return false;
    }
  }

  // Search FlyDubai flights
  Future<Map<String, dynamic>> searchFlights({
    required int type, // 0 = one-way, 1 = round-trip, 2 = multi-city
    required String origin,
    required String destination,
    required String depDate,
    required int adult,
    required int child,
    required int infant,
    required String cabin,
    List<Map<String, String>>? multiCitySegments,
  }) async {
    try {
      developer.log('=== FLYDUBAI API SEARCH STARTED ===');
      developer.log('Trip Type: $type (${_getTripTypeName(type)})');

      // Authenticate first if needed
      if (_accessToken == null) {
        final authSuccess = await authenticate();
        if (!authSuccess) {
          return {
            'error': 'FlyDubai authentication failed',
            'flights': [],
            'success': false
          };
        }
      }

      Map<String, dynamic>? searchParams;

      // Handle different trip types
      if (type == 2 && multiCitySegments != null && multiCitySegments.isNotEmpty) {
        // Multi-city search
        developer.log('Processing multi-city search with ${multiCitySegments.length} segments');
        searchParams = _buildMultiCityRequest(
          segments: multiCitySegments,
          passengers: adult + child + infant,
          cabin: cabin,
        );
      } else if (type == 1) {
        // Round-trip search
        developer.log('Processing round-trip search');
        final dates = depDate.replaceAll(',', '').split(',');
        if (dates.length < 2) {
          return {
            'error': 'Round-trip requires both departure and return dates',
            'flights': [],
            'success': false
          };
        }

        final outboundDate = DateTime.parse(dates[0].trim());
        final returnDate = DateTime.parse(dates[1].trim());

        searchParams = _buildRoundTripRequest(
          origin: origin.replaceAll(',', '').trim(),
          destination: destination.replaceAll(',', '').trim(),
          outboundDate: outboundDate,
          returnDate: returnDate,
          passengers: adult + child + infant,
          cabin: cabin,
        );
      } else {
        // One-way search
        developer.log('Processing one-way search');
        final cleanOrigin = origin.replaceAll(',', '').trim();
        final cleanDestination = destination.replaceAll(',', '').trim();
        final cleanDepDate = depDate.replaceAll(',', '').trim();

        final outboundDate = DateTime.parse(cleanDepDate);

        searchParams = _buildOneWayRequest(
          origin: cleanOrigin,
          destination: cleanDestination,
          outboundDate: outboundDate,
          passengers: adult + child + infant,
          cabin: cabin,
        );
      }

      if (searchParams == null) {
        return {
          'error': 'Invalid search parameters for FlyDubai',
          'flights': [],
          'success': false
        };
      }

      developer.log('FlyDubai Search Parameters: ${json.encode(searchParams)}');

      // Make the API request
      final response = await http.post(
        Uri.parse('$baseUrl/pricing/flightswithfares'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
          'Cookie': 'visid_incap_3059742=mt0fc3JTQDStXbDmAKotlet1zGUAAAAAQUIPAAAAAAA/4nh9vwd+842orxzMj3FS',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: json.encode(searchParams),
      );

      developer.log('FlyDubai Search Response Status: ${response.statusCode}');
      developer.log('FlyDubai Search Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        return {
          'success': true,
          'flights': responseData,
          'airline': 'FlyDubai',
          'source': 'flydubai_api',
          'tripType': _getTripTypeName(type),
        };
      } else if (response.statusCode == 401) {
        // Token expired, try to re-authenticate
        _accessToken = null;
        final authSuccess = await authenticate();
        if (authSuccess) {
          // Retry the search once
          return await searchFlights(
            type: type,
            origin: origin,
            destination: destination,
            depDate: depDate,
            adult: adult,
            child: child,
            infant: infant,
            cabin: cabin,
            multiCitySegments: multiCitySegments,
          );
        } else {
          return {
            'error': 'FlyDubai re-authentication failed',
            'flights': [],
            'success': false
          };
        }
      } else {
        return {
          'error': 'FlyDubai API returned status: ${response.statusCode}',
          'flights': [],
          'success': false
        };
      }
    } catch (e) {
      developer.log('FlyDubai API search error: $e');
      return {
        'error': 'FlyDubai search failed: $e',
        'flights': [],
        'success': false
      };
    }
  }

  // Build one-way search request
  Map<String, dynamic> _buildOneWayRequest({
    required String origin,
    required String destination,
    required DateTime outboundDate,
    required int passengers,
    required String cabin,
  }) {
    developer.log('Building one-way request: $origin -> $destination on ${outboundDate.toIso8601String()}');

    final fareQuoteDetail = {
      "Origin": origin,
      "Destination": destination,
      "PartyConfig": "",
      "UseAirportsNotMetroGroups": "true",
      "UseAirportsNotMetroGroupsAsRule": "true",
      "UseAirportsNotMetroGroupsForFrom": "true",
      "UseAirportsNotMetroGroupsForTo": "true",
      "DateOfDepartureStart": "${outboundDate.toIso8601String().substring(0, 10)}T00:00:00",
      "DateOfDepartureEnd": "${outboundDate.toIso8601String().substring(0, 10)}T23:59:59",
      "FareQuoteRequestInfos": {
        "FareQuoteRequestInfo": [
          {"PassengerTypeID": 1, "TotalSeatsRequired": passengers.toString()}
        ]
      },
      "FareTypeCategory": "1"
    };

    return {
      "RetrieveFareQuoteDateRange": {
        "RetrieveFareQuoteDateRangeRequest": {
          "SecurityGUID": "",
          "CarrierCodes": {
            "CarrierCode": [
              {"AccessibleCarrierCode": "FZ"}
            ]
          },
          "ChannelID": "OTA",
          "CountryCode": "PK",
          "ClientIPAddress": "",
          "HistoricUserName": username,
          "CurrencyOfFareQuote": "PKR",
          "PromotionalCode": "FAREBRANDS",
          "IataNumberOfRequestor": "2730402T",
          "FullInBoundDate": "${outboundDate.day.toString().padLeft(2, '0')}/${outboundDate.month.toString().padLeft(2, '0')}/${outboundDate.year}",
          "FullOutBoundDate": "${outboundDate.day.toString().padLeft(2, '0')}/${outboundDate.month.toString().padLeft(2, '0')}/${outboundDate.year}",
          "CorporationID": "-2147483648",
          "FareFilterMethod": "NoCombinabilityRoundtripLowestFarePerFareType",
          "FareGroupMethod": "WebFareTypes",
          "InventoryFilterMethod": "Available",
          "FareQuoteDetails": {
            "FareQuoteDetailDateRange": [fareQuoteDetail]
          }
        }
      }
    };
  }

  // Build round-trip search request
  Map<String, dynamic> _buildRoundTripRequest({
    required String origin,
    required String destination,
    required DateTime outboundDate,
    required DateTime returnDate,
    required int passengers,
    required String cabin,
  }) {
    developer.log('Building round-trip request: $origin -> $destination on ${outboundDate.toIso8601String()}, return on ${returnDate.toIso8601String()}');

    final fareQuoteDetails = [
      {
        "Origin": origin,
        "Destination": destination,
        "PartyConfig": "",
        "UseAirportsNotMetroGroups": "true",
        "UseAirportsNotMetroGroupsAsRule": "true",
        "UseAirportsNotMetroGroupsForFrom": "true",
        "UseAirportsNotMetroGroupsForTo": "true",
        "DateOfDepartureStart": "${outboundDate.toIso8601String().substring(0, 10)}T00:00:00",
        "DateOfDepartureEnd": "${outboundDate.toIso8601String().substring(0, 10)}T23:59:59",
        "FareQuoteRequestInfos": {
          "FareQuoteRequestInfo": [
            {"PassengerTypeID": 1, "TotalSeatsRequired": passengers.toString()}
          ]
        },
        "FareTypeCategory": "1"
      },
      {
        "Origin": destination,
        "Destination": origin,
        "PartyConfig": "",
        "UseAirportsNotMetroGroups": "true",
        "UseAirportsNotMetroGroupsAsRule": "true",
        "UseAirportsNotMetroGroupsForFrom": "true",
        "UseAirportsNotMetroGroupsForTo": "true",
        "DateOfDepartureStart": "${returnDate.toIso8601String().substring(0, 10)}T00:00:00",
        "DateOfDepartureEnd": "${returnDate.toIso8601String().substring(0, 10)}T23:59:59",
        "FareQuoteRequestInfos": {
          "FareQuoteRequestInfo": [
            {"PassengerTypeID": 1, "TotalSeatsRequired": passengers.toString()}
          ]
        },
        "FareTypeCategory": "1"
      }
    ];

    return {
      "RetrieveFareQuoteDateRange": {
        "RetrieveFareQuoteDateRangeRequest": {
          "SecurityGUID": "",
          "CarrierCodes": {
            "CarrierCode": [
              {"AccessibleCarrierCode": "FZ"}
            ]
          },
          "ChannelID": "OTA",
          "CountryCode": "PK",
          "ClientIPAddress": "",
          "HistoricUserName": username,
          "CurrencyOfFareQuote": "PKR",
          "PromotionalCode": "FAREBRANDS",
          "IataNumberOfRequestor": "2730402T",
          "FullInBoundDate": "${returnDate.day.toString().padLeft(2, '0')}/${returnDate.month.toString().padLeft(2, '0')}/${returnDate.year}",
          "FullOutBoundDate": "${outboundDate.day.toString().padLeft(2, '0')}/${outboundDate.month.toString().padLeft(2, '0')}/${outboundDate.year}",
          "CorporationID": "-2147483648",
          "FareFilterMethod": "NoCombinabilityRoundtripLowestFarePerFareType",
          "FareGroupMethod": "WebFareTypes",
          "InventoryFilterMethod": "Available",
          "FareQuoteDetails": {
            "FareQuoteDetailDateRange": fareQuoteDetails
          }
        }
      }
    };
  }

  // Build multi-city search request
  Map<String, dynamic> _buildMultiCityRequest({
    required List<Map<String, String>> segments,
    required int passengers,
    required String cabin,
  }) {
    developer.log('Building multi-city request with ${segments.length} segments');

    final List<Map<String, dynamic>> fareQuoteDetails = [];

    for (var segment in segments) {
      final departureDate = DateTime.parse(segment['date']!);
      developer.log('Adding segment: ${segment['from']} -> ${segment['to']} on ${segment['date']}');

      fareQuoteDetails.add({
        "Origin": segment['from'],
        "Destination": segment['to'],
        "PartyConfig": "",
        "UseAirportsNotMetroGroups": "true",
        "UseAirportsNotMetroGroupsAsRule": "true",
        "UseAirportsNotMetroGroupsForFrom": "true",
        "UseAirportsNotMetroGroupsForTo": "true",
        "DateOfDepartureStart": "${departureDate.toIso8601String().substring(0, 10)}T00:00:00",
        "DateOfDepartureEnd": "${departureDate.toIso8601String().substring(0, 10)}T23:59:59",
        "FareQuoteRequestInfos": {
          "FareQuoteRequestInfo": [
            {"PassengerTypeID": 1, "TotalSeatsRequired": passengers.toString()}
          ]
        },
        "FareTypeCategory": "1"
      });
    }

    return {
      "RetrieveFareQuoteDateRange": {
        "RetrieveFareQuoteDateRangeRequest": {
          "SecurityGUID": "",
          "CarrierCodes": {
            "CarrierCode": [
              {"AccessibleCarrierCode": "FZ"}
            ]
          },
          "ChannelID": "OTA",
          "CountryCode": "PK",
          "ClientIPAddress": "",
          "HistoricUserName": username,
          "CurrencyOfFareQuote": "PKR",
          "PromotionalCode": "FAREBRANDS",
          "IataNumberOfRequestor": "2730402T",
          "FullInBoundDate": segments.last['date']!.split('-').reversed.join('/'),
          "FullOutBoundDate": segments.first['date']!.split('-').reversed.join('/'),
          "CorporationID": "-2147483648",
          "FareFilterMethod": "NoCombinabilityRoundtripLowestFarePerFareType",
          "FareGroupMethod": "WebFareTypes",
          "InventoryFilterMethod": "Available",
          "FareQuoteDetails": {
            "FareQuoteDetailDateRange": fareQuoteDetails
          }
        }
      }
    };
  }

  // Helper method to get trip type name
  String _getTripTypeName(int type) {
    switch (type) {
      case 0: return 'One-Way';
      case 1: return 'Round-Trip';
      case 2: return 'Multi-City';
      default: return 'Unknown';
    }
  }

  // Test API connection
  Future<Map<String, dynamic>> testConnection() async {
    try {
      developer.log('=== TESTING FLYDUBAI API CONNECTION ===');

      final authSuccess = await authenticate();
      if (!authSuccess) {
        return {
          'success': false,
          'error': 'Authentication failed',
          'details': 'Could not authenticate with FlyDubai API'
        };
      }

      // Test with a simple one-way search
      final testResult = await searchFlights(
        type: 0, // One-way
        origin: 'DXB',
        destination: 'KHI',
        depDate: DateTime.now().add(Duration(days: 30)).toIso8601String().split('T')[0],
        adult: 1,
        child: 0,
        infant: 0,
        cabin: 'Economy',
      );

      return {
        'success': testResult['success'] ?? false,
        'error': testResult['error'],
        'details': 'FlyDubai API test completed'
      };

    } catch (e) {
      developer.log('FlyDubai API test failed: $e');
      return {
        'success': false,
        'error': 'Test failed',
        'details': e.toString()
      };
    }
  }
}