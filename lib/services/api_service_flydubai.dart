import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      print('Authenticating with FlyDubai API...');
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

      print('FlyDubai Auth Response Status: ${response.statusCode}');
      print('FlyDubai Auth Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = json.decode(response.body);
        if (tokenData.containsKey('access_token')) {
          _accessToken = tokenData['access_token'];
          print('FlyDubai Authentication successful');
          return true;
        }
      }

      print('FlyDubai Authentication failed');
      return false;
    } catch (e) {
      print('FlyDubai Authentication error: $e');
      return false;
    }
  }

  // Search FlyDubai flights
  Future<Map<String, dynamic>> searchFlights({
    required int type,
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
      print('=== FLYDUBAI API SEARCH STARTED ===');
      print('Trip Type: $type (${_getTripTypeName(type)})');
      print('Raw depDate: "$depDate"');

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

      if (type == 2 && multiCitySegments != null && multiCitySegments.isNotEmpty) {
        // Multi-city search
        print('Processing multi-city search with ${multiCitySegments.length} segments');
        searchParams = _buildMultiCityRequest(
          segments: multiCitySegments,
          passengers: adult + child + infant,
          cabin: cabin,
        );
      } else if (type == 1) {
        // Round-trip search
        print('Processing round-trip search');

        // Parse dates - handle different possible formats
        List<String> datesList = [];

        if (depDate.contains(',')) {
          datesList = depDate.split(',').map((d) => d.trim()).where((d) => d.isNotEmpty).toList();
        } else {
          // If no comma, might be a single date - this shouldn't happen for round-trip
          datesList = [depDate.trim()];
        }

        print("Date parsing - split result: $datesList");

        if (datesList.length < 2) {
          return {
            'error': 'Round-trip requires both departure and return dates. Parsed: $datesList from "$depDate"',
            'flights': [],
            'success': false
          };
        }

        try {
          final outboundDate = DateTime.parse(datesList[0]);
          final returnDate = DateTime.parse(datesList[1]);

          print("Successfully parsed dates - Outbound: $outboundDate, Return: $returnDate");

          searchParams = _buildRoundTripRequest(
            origin: origin.trim(),
            destination: destination.trim(),
            outboundDate: outboundDate,
            returnDate: returnDate,
            passengers: adult + child + infant,
            cabin: cabin,
          );
        } catch (e) {
          return {
            'error': 'Invalid date format in round-trip request: $e. Dates: $datesList',
            'flights': [],
            'success': false
          };
        }
      } else {
        // One-way search
        print('Processing one-way search');
        final cleanDepDate = depDate.trim();

        try {
          final outboundDate = DateTime.parse(cleanDepDate);

          searchParams = _buildOneWayRequest(
            origin: origin.trim(),
            destination: destination.trim(),
            outboundDate: outboundDate,
            passengers: adult + child + infant,
            cabin: cabin,
          );
        } catch (e) {
          return {
            'error': 'Invalid date format for one-way: $e. Date: "$cleanDepDate"',
            'flights': [],
            'success': false
          };
        }
      }

      if (searchParams == null) {
        return {
          'error': 'Could not build search parameters for FlyDubai',
          'flights': [],
          'success': false
        };
      }

      // Make API request
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

      print('FlyDubai Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("++++++++++++++++++Fly Dubai Response ++++++++++++++++++");
        // printJsonPretty(responseData);
        return {
          'success': true,
          'flights': responseData,
          'airline': 'FlyDubai',
          'source': 'flydubai_api',
          'tripType': _getTripTypeName(type),
        };
      } else if (response.statusCode == 401) {
        // Token expired
        _accessToken = null;
        final authSuccess = await authenticate();
        if (authSuccess) {
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
        }
      }

      return {
        'error': 'FlyDubai API returned status: ${response.statusCode}',
        'flights': [],
        'success': false
      };

    } catch (e) {
      print('FlyDubai API search error: $e');
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
    print('Building one-way request: $origin -> $destination on ${outboundDate.toIso8601String()}');

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
    print('Building round-trip request: $origin -> $destination on ${outboundDate.toIso8601String()}, return on ${returnDate.toIso8601String()}');

    // PASSENGER ARRAY BUILDING - Similar to PHP version
    String passengerArray = '';
    if (passengers > 0) {
      passengerArray = '''
    {
      "PassengerTypeID": 1,
      "TotalSeatsRequired": "$passengers"
    }''';
    }

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
            {
              "PassengerTypeID": 1,
              "TotalSeatsRequired": passengers.toString()
            }
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
            {
              "PassengerTypeID": 1,
              "TotalSeatsRequired": passengers.toString()
            }
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
    print('Building multi-city request with ${segments.length} segments');

    final List<Map<String, dynamic>> fareQuoteDetails = [];

    for (var segment in segments) {
      final departureDate = DateTime.parse(segment['date']!);
      print('Adding segment: ${segment['from']} -> ${segment['to']} on ${segment['date']}');

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
      case 0:
        return 'One-Way';
      case 1:
        return 'Round-Trip';
      case 2:
        return 'Multi-City';
      default:
        return 'Unknown';
    }
  }

  // Test API connection
  Future<Map<String, dynamic>> testConnection() async {
    try {
      print('=== TESTING FLYDUBAI API CONNECTION ===');

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
      print('FlyDubai API test failed: $e');
      return {
        'success': false,
        'error': 'Test failed',
        'details': e.toString()
      };
    }
  }

  /// Prints JSON nicely with chunking
  void printJsonPretty(dynamic jsonData) {
    const int chunkSize = 1000;
    final jsonString = const JsonEncoder.withIndent(' ').convert(jsonData);

    for (int i = 0; i < jsonString.length; i += chunkSize) {
      final chunk = jsonString.substring(
        i,
        i + chunkSize < jsonString.length ? i + chunkSize : jsonString.length,
      );
      print(chunk);
    }
  }
}