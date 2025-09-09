import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../views/flight/booking_flight/booking_flight_controller.dart';

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
        printJsonPretty(responseData);
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


  // Add these methods to your ApiServiceFlyDubai class

// Add to cart function
  Future<Map<String, dynamic>> addToCart({
    required List<String> bookingIds,
    required Map<String, dynamic> flightData,
  }) async {
    try {
      if (_accessToken == null) {
        final authSuccess = await authenticate();
        if (!authSuccess) {
          return {
            'success': false,
            'error': 'Authentication failed',
            'details': 'Could not authenticate with FlyDubai API'
          };
        }
      }

      print('=== FLYDUBAI ADD TO CART STARTED ===');
      print('Booking IDs: $bookingIds');

      // Parse the flight data and build the request
      final requestBody = _buildAddToCartRequest(bookingIds, flightData);

      print("+++++++++++++++++++Add top cart Request+++++++++++++++++++++++");
      printJsonPretty(requestBody);

      // Log the request
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      print('Add to Cart Request: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/order/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
          'Cookie': 'visid_incap_3059742=mt0fc3JTQDStXbDmAKotlet1zGUAAAAAQUIPAAAAAAA/4nh9vwd+842orxzMj3FS',
          'Accept-Encoding': 'gzip, deflate',
        },
        body: json.encode(requestBody),
      );

      print("+++++++++++++++++++Add top cart Response+++++++++++++++++++++++");
      printJsonPretty(response.body);

      print('Add to Cart Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Add to Cart successful');
        return {
          'success': true,
          'data': responseData,
        };
      } else if (response.statusCode == 401) {
        // Token expired
        _accessToken = null;
        final authSuccess = await authenticate();
        if (authSuccess) {
          return await addToCart(bookingIds: bookingIds, flightData: flightData);
        }
      }

      return {
        'success': false,
        'error': 'Add to Cart failed with status: ${response.statusCode}',
        'response': response.body,
      };
    } catch (e) {
      print('Add to Cart error: $e');
      return {
        'success': false,
        'error': 'Add to Cart failed: $e',
      };
    }
  }

// Build add to cart request
  Map<String, dynamic> _buildAddToCartRequest(
      List<String> bookingIds, Map<String, dynamic> flightData) {

    // Safely extract nested data with proper null checks
    final retrieveResult = flightData['RetrieveFareQuoteDateRangeResponse']?['RetrieveFareQuoteDateRangeResult'];
    if (retrieveResult == null) {
      throw Exception('Invalid flight data structure: Missing RetrieveFareQuoteDateRangeResult');
    }

    // Handle different possible structures for these arrays
    final basicArray = _extractArray(retrieveResult['FlightSegments']?['FlightSegment']);
    final legDetails = _extractArray(retrieveResult['LegDetails']?['LegDetail']);
    final segmentDetails = _extractArray(retrieveResult['SegmentDetails']?['SegmentDetail']);
    final taxDetails = _extractArray(retrieveResult['TaxDetails']?['TaxDetail']);

    final List<Map<String, dynamic>> originDestinations = [];

    for (int i = 0; i < bookingIds.length; i++) {
      final bk = bookingIds[i];
      final bkIdArray = bk.split('_');

      if (bkIdArray.length < 2) {
        print('Invalid booking ID format: $bk');
        continue;
      }

      final main = int.tryParse(bkIdArray[0]) ?? 0;
      final fare = int.tryParse(bkIdArray[1]) ?? 0;

      // Safely access the basic array
      dynamic arrayStart;
      if (basicArray is List && basicArray.isNotEmpty) {
        arrayStart = main < basicArray.length ? basicArray[main] : (basicArray.isNotEmpty ? basicArray[0] : null);
      } else if (basicArray is Map) {
        arrayStart = basicArray;
      }

      if (arrayStart == null) {
        print('No flight segment found for booking ID: $bk');
        continue;
      }

      final lfid1 = arrayStart['LFID'];
      final flightLegDetail = _extractArray(arrayStart['FlightLegDetails']?['FlightLegDetail']);

      // Find segment details
      Map<String, dynamic> segmentInfo = {};
      if (segmentDetails is List && segmentDetails.isNotEmpty) {
        for (final item in segmentDetails) {
          if (item is Map && item['LFID'] == lfid1) {
            segmentInfo = {
              'odID': lfid1,
              'origin': item['Origin'] ?? '',
              'destination': item['Destination'] ?? '',
              'flightNum': item['FlightNum'] ?? '',
              'depDate': item['DepartureDate'] ?? '',
              'isPromoApplied': false,
            };
            break;
          }
        }
      }

      // Safely access fare types
      final fareTypes = _extractArray(arrayStart['FareTypes']?['FareType']);
      if (fareTypes == null || (fareTypes is List && fare >= fareTypes.length)) {
        print('Invalid fare index: $fare for booking ID: $bk');
        continue;
      }

      final fareArray = fareTypes is List ? fareTypes[fare] : fareTypes;
      final fareTypeId = fareArray['FareTypeID'];
      final fareTypeName = fareArray['FareTypeName'];

      final fareInfos = _extractArray(fareArray['FareInfos']?['FareInfo']);
      final List<Map<String, dynamic>> paxFareInfos = [];
      final List<String> paxIds = [];

      if (fareInfos != null) {
        final fareInfosList = fareInfos is List ? fareInfos : [fareInfos];

        for (int pe = 0; pe < fareInfosList.length; pe++) {
          final fares = fareInfosList[pe];
          final paxList = _extractArray(fares['Pax']);

          if (paxList == null || (paxList is List && paxList.isEmpty)) {
            continue;
          }

          final fareData = paxList is List ? paxList[0] : paxList;
          final id = fareData['ID']?.toString() ?? '1';
          final fareId = fareData['FareID'];
          final fbCode = fareData['FBCode'] ?? '';
          final cabin = fareData['Cabin'] ?? 'ECONOMY';

          // Safely get fare class from booking codes
          String fareClass = 'Y';
          final bookingCodes = _extractArray(fareData['BookingCodes']?['Bookingcode']);
          if (bookingCodes != null) {
            final bookingCodesList = bookingCodes is List ? bookingCodes : [bookingCodes];
            if (pe < bookingCodesList.length && bookingCodesList[pe] is Map) {
              fareClass = bookingCodesList[pe]['RBD']?.toString() ?? 'Y';
            } else if (bookingCodesList.isNotEmpty && bookingCodesList[0] is Map) {
              fareClass = bookingCodesList[0]['RBD']?.toString() ?? 'Y';
            }
          }

          final ptcId = fareData['PTCID'] ?? 1;
          final originalFare = (fareData['DisplayFareAmt'] as num?)?.toDouble() ?? 0.0;
          final baseFareAmtInclTax = (fareData['BaseFareAmtInclTax'] as num?)?.toDouble() ?? 0.0;
          final seatsAvailable = fareData['SeatsAvailable'] ?? 0;
          final infantSeatsAvailable = fareData['InfantSeatsAvailable'] ?? 0;
          final hashCode = fareData['hashcode']?.toString() ?? '';
          final ruleId = fareData['RuleId']?.toString() ?? '';
          final fareCarrier = fareData['FareCarrier']?.toString() ?? 'FZ';

          final applicableTaxDetails = _extractArray(fareData['ApplicableTaxDetails']?['ApplicableTaxDetail']);

          paxIds.add(id);

          final List<Map<String, dynamic>> taxDetailsList = [];
          if (applicableTaxDetails != null) {
            final taxDetailsListRaw = applicableTaxDetails is List ? applicableTaxDetails : [applicableTaxDetails];

            for (int ap = 0; ap < taxDetailsListRaw.length; ap++) {
              final taxDetail = taxDetailsListRaw[ap];
              if (taxDetail is! Map) continue;

              final taxId = taxDetail['TaxID'];
              final amt = (taxDetail['Amt'] as num?)?.toDouble() ?? 0.0;
              final initiatingTaxId = taxDetail['InitiatingTaxID'];

              String taxCode = '';
              if (taxDetails != null) {
                final taxDetailsList = taxDetails is List ? taxDetails : [taxDetails];
                for (final tax in taxDetailsList) {
                  if (tax is Map && tax['TaxID'] == taxId) {
                    taxCode = tax['TaxCode']?.toString() ?? '';
                    break;
                  }
                }
              }

              taxDetailsList.add({
                'amt': amt,
                'taxCode': taxCode,
                'taxID': taxId,
              });
            }
          }

          paxFareInfos.add({
            'applicableTaxDetails': taxDetailsList,
            'fareID': fareId,
            'ID': id,
            'FBC': fbCode,
            'fareClass': fareClass,
            'cabin': cabin,
            'baseFare': originalFare,
            'ruleID': ruleId,
            'originalFare': originalFare,
            'totalFare': baseFareAmtInclTax,
            'PTC': ptcId,
            'seatAvailability': seatsAvailable,
            'infantAvailability': infantSeatsAvailable,
            'secureHash': hashCode,
            'fareCarrier': fareCarrier,
          });
        }
      }

      final List<Map<String, dynamic>> segmentDetailsList = [];
      if (flightLegDetail != null) {
        final flightLegDetailList = flightLegDetail is List ? flightLegDetail : [flightLegDetail];

        for (int j = 0; j < flightLegDetailList.length; j++) {
          final leg = flightLegDetailList[j];
          if (leg is! Map) continue;

          final pfid = leg['PFID'];
          final departureDate2 = leg['DepartureDate']?.toString() ?? '';

          // Get cabin from first fare info if available
          String cabin = 'ECONOMY';
          if (paxFareInfos.isNotEmpty) {
            cabin = paxFareInfos[0]['cabin'] ?? 'ECONOMY';
          }

          if (legDetails != null) {
            final legDetailsList = legDetails is List ? legDetails : [legDetails];

            for (final fld in legDetailsList) {
              if (fld is! Map) continue;

              final fldPfid = fld['PFID'];
              final fldDepartureDate = fld['DepartureDate']?.toString() ?? '';

              if (fldPfid == pfid && fldDepartureDate == departureDate2) {
                // Get fare class from first pax fare info
                String fareClass = 'Y';
                if (paxFareInfos.isNotEmpty) {
                  fareClass = paxFareInfos[0]['fareClass'] ?? 'Y';
                }

                final oaFlight = fld['OperatingCarrier']?.toString() != 'FZ';

                // Ensure paxIds is not empty
                final effectivePaxIds = paxIds.isNotEmpty ? paxIds : ['1'];
                print(effectivePaxIds);
                print("Pax Id's");

                segmentDetailsList.add({
                  'segmentID': pfid,
                  'origin': fld['Origin'] ?? '',
                  'destination': fld['Destination'] ?? '',
                  'depDate': fld['DepartureDate'] ?? '',
                  'arrDate': fld['ArrivalDate'] ?? '',
                  'bookingCodes': [
                    {
                      'fareClass': fareClass,
                      'cabin': cabin,
                      'paxID': effectivePaxIds,
                    }
                  ],
                  'OAFlight': oaFlight,
                  'operCarrier': fld['OperatingCarrier'] ?? 'FZ',
                  'operFlightNum': fld['FlightNum'] ?? '',
                  'mrktCarrier': fld['MarketingCarrier'] ?? 'FZ',
                  'mrktFlightNum': fld['MarketingFlightNum'] ?? '',
                });
                break;
              }
            }
          }
        }
      }

      // Ensure we have at least one segment detail
      if (segmentDetailsList.isEmpty && segmentInfo.isNotEmpty) {
        // Create a basic segment detail from segment info
        segmentDetailsList.add({
          'segmentID': segmentInfo['odID'],
          'origin': segmentInfo['origin'],
          'destination': segmentInfo['destination'],
          'depDate': segmentInfo['depDate'],
          'arrDate': segmentInfo['depDate'], // Fallback to dep date
          'bookingCodes': [
            {
              'fareClass': 'Y',
              'cabin': 'ECONOMY',
              'paxID': paxIds.isNotEmpty ? paxIds : ['1'],
            }
          ],
          'OAFlight': false,
          'operCarrier': 'FZ',
          'operFlightNum': segmentInfo['flightNum'] ?? '',
          'mrktCarrier': 'FZ',
          'mrktFlightNum': segmentInfo['flightNum'] ?? '',
        });
      }

      originDestinations.add({
        ...segmentInfo,
        'fareBrand': [
          {
            'fareBrandID': fareTypeId,
            'fareBrandName': fareTypeName,
            'fareInfos': [
              {
                'paxFareInfos': paxFareInfos.isNotEmpty ? paxFareInfos : [
                  {
                    'applicableTaxDetails': [],
                    'fareID': 1,
                    'ID': '1',
                    'FBC': '',
                    'fareClass': 'Y',
                    'cabin': 'ECONOMY',
                    'baseFare': 0.0,
                    'ruleID': '',
                    'originalFare': 0.0,
                    'totalFare': 0.0,
                    'PTC': 1,
                    'seatAvailability': 0,
                    'infantAvailability': 0,
                    'secureHash': '',
                    'fareCarrier': 'FZ',
                  }
                ],
              }
            ],
          }
        ],
        'segmentDetails': segmentDetailsList,
      });
    }

    return {
      'currency': 'PKR',
      'IATA': '2730402T',
      'inventoryFilterMethod': 0,
      'securityGUID': '',
      'originDestinations': originDestinations.isNotEmpty ? originDestinations : [
        {
          'odID': 0,
          'origin': '',
          'destination': '',
          'flightNum': '',
          'depDate': '',
          'isPromoApplied': false,
          'fareBrand': [
            {
              'fareBrandID': 0,
              'fareBrandName': '',
              'fareInfos': [
                {
                  'paxFareInfos': [
                    {
                      'applicableTaxDetails': [],
                      'fareID': 0,
                      'ID': '1',
                      'FBC': '',
                      'fareClass': 'Y',
                      'cabin': 'ECONOMY',
                      'baseFare': 0.0,
                      'ruleID': '',
                      'originalFare': 0.0,
                      'totalFare': 0.0,
                      'PTC': 1,
                      'seatAvailability': 0,
                      'infantAvailability': 0,
                      'secureHash': '',
                      'fareCarrier': 'FZ',
                    }
                  ],
                }
              ],
            }
          ],
          'segmentDetails': [
            {
              'segmentID': 0,
              'origin': '',
              'destination': '',
              'depDate': '',
              'arrDate': '',
              'bookingCodes': [
                {
                  'fareClass': 'Y',
                  'cabin': 'ECONOMY',
                  'paxID': ['"1"'],
                }
              ],
              'OAFlight': false,
              'operCarrier': 'FZ',
              'operFlightNum': '',
              'mrktCarrier': 'FZ',
              'mrktFlightNum': '',
            }
          ],
        }
      ],
    };
  }

// Helper method to safely extract arrays from potentially different structures
  dynamic _extractArray(dynamic data) {
    if (data == null) return null;

    if (data is List) {
      return data;
    } else if (data is Map) {
      // If it's a map with numeric keys, convert to list
      if (data.keys.every((key) => key is String && int.tryParse(key) != null)) {
        final sortedKeys = data.keys.map((k) => int.parse(k)).toList()..sort();
        return sortedKeys.map((key) => data[key.toString()]).toList();
      }
      return data;
    }

    return [data];
  }

// Revalidate flight pricing
  Future<Map<String, dynamic>> revalidateFlight({
    required String bookingId,
    required Map<String, dynamic> flightData,
  }) async {
    try {
      // For FlyDubai, revalidation is typically done through addToCart
      // which returns updated pricing information
      final result = await addToCart(
        bookingIds: [bookingId],
        flightData: flightData,
      );

      if (result['success'] == true) {
        return {
          'success': true,
          'updatedPrice': _extractUpdatedPrice(result['data']),
          'cartData': result['data'],
        };
      }

      return result;
    } catch (e) {
      print('Revalidation error: $e');
      return {
        'success': false,
        'error': 'Revalidation failed: $e',
      };
    }
  }

// Extract updated price from addToCart response
  double _extractUpdatedPrice(Map<String, dynamic> cartData) {
    try {
      // Navigate through the response structure to find the total fare
      final flightGroups = cartData['flightGroups'];
      if (flightGroups is List && flightGroups.isNotEmpty) {
        final fareBrands = flightGroups[0]['fareBrands'];
        if (fareBrands is List && fareBrands.isNotEmpty) {
          final fareInfos = fareBrands[0]['fareInfos'];
          if (fareInfos is List && fareInfos.isNotEmpty) {
            final paxFareInfos = fareInfos[0]['paxFareInfos'];
            if (paxFareInfos is List && paxFareInfos.isNotEmpty) {
              return paxFareInfos[0]['totalFare']?.toDouble() ?? 0.0;
            }
          }
        }
      }

      // Alternative path
      final originDestinations = cartData['originDestinations'];
      if (originDestinations is List && originDestinations.isNotEmpty) {
        final fareBrands = originDestinations[0]['fareBrands'];
        if (fareBrands is List && fareBrands.isNotEmpty) {
          final fareInfos = fareBrands[0]['fareInfos'];
          if (fareInfos is List && fareInfos.isNotEmpty) {
            final paxFareInfos = fareInfos[0]['paxFareInfos'];
            if (paxFareInfos is List && paxFareInfos.isNotEmpty) {
              return paxFareInfos[0]['totalFare']?.toDouble() ?? 0.0;
            }
          }
        }
      }

      return 0.0;
    } catch (e) {
      print('Error extracting updated price: $e');
      return 0.0;
    }
  }



// Update the createPNR method in ApiServiceFlyDubai
  Future<Map<String, dynamic>> createPNR({
    required List<TravelerInfo> adults,
    required List<TravelerInfo> children,
    required List<TravelerInfo> infants,
    required String clientEmail,
    required String clientPhone,
    required String countryCode,
    required String simCode,
    required String city,
    required String flightType,
    required List<Map<String, dynamic>> segmentArray,
    required Map<String, dynamic> cartData,
  }) async {
    try {
      print('=== CREATING PNR FOR FLYDUBAI ===');
      print('Adults: ${adults.length}, Children: ${children.length}, Infants: ${infants.length}');
      print('Client Email: $clientEmail, Phone: $clientPhone');
      print('Country Code: $countryCode, SIM Code: $simCode');
      print('City: $city, Flight Type: $flightType');
      print('Segment Array: ${segmentArray.length} segments');

      if (_accessToken == null) {
        final authSuccess = await authenticate();
        if (!authSuccess) {
          return {
            'success': false,
            'error': 'Authentication failed',
            'details': 'Could not authenticate with FlyDubai API'
          };
        }
      }

      // Build the PNR request body
      final requestBody = _buildPNRRequest(
        adults: adults,
        children: children,
        infants: infants,
        clientEmail: clientEmail,
        clientPhone: clientPhone,
        countryCode: countryCode,
        simCode: simCode,
        city: city,
        flightType: flightType,
        segmentArray: segmentArray,
        cartData: cartData,
      );

      print('PNR Request Body:');
      printJsonPretty(requestBody);

      // Log the request to file (simulating PHP behavior)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      print('PNR Request Timestamp: $timestamp');

      final response = await http.post(
        Uri.parse('$baseUrl/cp/summaryPNR?accural=true'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
          'Cookie': 'visid_incap_3059742=mt0fc3JTQDStXbDmAKotlet1zGUAAAAAQUIPAAAAAAA/4nh9vwd+842orxzMj3FS',
          'Accept-Encoding': 'gzip, deflate',
        },
        body: json.encode(requestBody),
      );

      print('PNR Creation Response Status: ${response.statusCode}');
      print('PNR Creation Response Body:');
      printJsonPretty(response.body);

      // Log response to file (simulating PHP behavior)
      print('PNR Response Timestamp: $timestamp');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('✅ PNR created successfully');

        // Check for success in response
        final success = responseData['Success'] == true ||
            responseData['ConfirmationNumber'] != null;

        return {
          'success': success,
          'data': responseData,
          'confirmationNumber': responseData['ConfirmationNumber']?.toString(),
          'message': success ? 'PNR created successfully' : 'PNR creation failed',
          'rawResponse': responseData,
        };
      } else if (response.statusCode == 401) {
        // Token expired
        print('❌ Token expired, re-authenticating...');
        _accessToken = null;
        final authSuccess = await authenticate();
        if (authSuccess) {
          return await createPNR(
            adults: adults,
            children: children,
            infants: infants,
            clientEmail: clientEmail,
            clientPhone: clientPhone,
            countryCode: countryCode,
            simCode: simCode,
            city: city,
            flightType: flightType,
            segmentArray: segmentArray,
            cartData: cartData,
          );
        }
        return {
          'success': false,
          'error': 'Re-authentication failed',
          'response': response.body,
        };
      }

      return {
        'success': false,
        'error': 'PNR creation failed with status: ${response.statusCode}',
        'response': response.body,
      };
    } catch (e, stackTrace) {
      print('❌ PNR creation error: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'error': 'PNR creation failed: $e',
      };
    }
  }
// Update the _buildPNRRequest method
  Map<String, dynamic> _buildPNRRequest({
    required List<TravelerInfo> adults,
    required List<TravelerInfo> children,
    required List<TravelerInfo> infants,
    required String clientEmail,
    required String clientPhone,
    required String countryCode,
    required String simCode,
    required String city,
    required String flightType,
    required List<Map<String, dynamic>> segmentArray,
    required Map<String, dynamic> cartData,
  }) {
    try {
      print('Building PNR request...');

      // Build passengers array
      final List<Map<String, dynamic>> passengers = [];
      int personId = 0;

      // Process adults
      for (int i = 0; i < adults.length; i++) {
        personId++;
        final adult = adults[i];
        final isPrimary = i == 0;

        // Calculate age
        final age = _calculateAge(adult.dateOfBirthController.text);

        // Get gender code (M/F)
        final gender = adult.genderController.text.substring(0, 1).toUpperCase();

        // Get nationality code
        final nationality = adult.nationalityCountry.value?.countryCode ?? "PK";

        final passenger = {
          "PersonOrgID": -personId,
          "FirstName": adult.firstNameController.text,
          "LastName": adult.lastNameController.text,
          "MiddleName": "",
          "Age": age,
          "DOB": "${adult.dateOfBirthController.text}T00:00:00",
          "Gender": gender,
          "Title": adult.titleController.text,
          "NationalityLaguageID": 1,
          "RelationType": "Self",
          "WBCID": 1,
          "PTCID": 1, // Adult passenger type
          "TravelsWithPersonOrgID": -personId,
          "MarketingOptIn": true,
          "UseInventory": false,
          "Nationality": nationality,
          "ProfileId": -2147483648,
          "IsPrimaryPassenger": isPrimary,
          "DocumentInfos": [
            {
              "DocType": "1",
              "DocNumber": adult.passportCnicController.text,
              "IssuingCountry": nationality,
              "ExpiryDate": adult.passportExpiryController.text.isNotEmpty
                  ? "${adult.passportExpiryController.text}T00:00:00"
                  : "2030-12-31T00:00:00" // Default expiry if empty
            }
          ]
        };

        if (isPrimary) {
          passenger["Address"] = {
            "Address1": city,
            "Address2": city,
            "City": city,
            "State": "",
            "Postal": "12123233",
            "Country": "PK",
            "CountryCode": countryCode,
            "AreaCode": "",
            "PhoneNumber": clientPhone,
            "Display": ""
          };

          passenger["ContactInfos"] = [
            {
              "Key": null,
              "ContactID": 0,
              "PersonOrgID": -1,
              "ContactField": clientPhone,
              "ContactType": 2,
              "Extension": "",
              "CountryCode": countryCode,
              "PhoneNumber": clientPhone,
              "Display": "",
              "PreferredContactMethod": false,
              "ValidatedContact": false
            },
            {
              "Key": null,
              "ContactID": 0,
              "PersonOrgID": -1,
              "ContactField": clientEmail,
              "ContactType": 4,
              "Extension": "",
              "CountryCode": countryCode,
              "PhoneNumber": clientPhone,
              "Display": "",
              "PreferredContactMethod": true,
              "ValidatedContact": false
            }
          ];
        } else {
          passenger["Address"] = {
            "Address1": "",
            "Address2": "",
            "City": "",
            "State": "",
            "Postal": "12123233",
            "Country": "PK",
            "CountryCode": countryCode,
            "AreaCode": "",
            "PhoneNumber": "",
            "Display": ""
          };
          passenger["ContactInfos"] = [];
        }

        passengers.add(passenger);
      }

      // Process children
      for (int i = 0; i < children.length; i++) {
        personId++;
        final child = children[i];

        // Calculate age
        final age = _calculateAge(child.dateOfBirthController.text);

        // Get gender code
        final gender = child.genderController.text.substring(0, 1).toUpperCase();

        // Get nationality code
        final nationality = child.nationalityCountry.value?.countryCode ?? "PK";

        passengers.add({
          "PersonOrgID": -personId,
          "FirstName": child.firstNameController.text,
          "LastName": child.lastNameController.text,
          "MiddleName": "",
          "Age": age,
          "DOB": "${child.dateOfBirthController.text}T00:00:00",
          "Gender": gender,
          "Title": child.titleController.text,
          "NationalityLaguageID": 1,
          "RelationType": "Self",
          "WBCID": 1,
          "PTCID": 6, // Child passenger type
          "TravelsWithPersonOrgID": -1,
          "MarketingOptIn": true,
          "UseInventory": false,
          "Address": {
            "Address1": "",
            "Address2": "",
            "City": "",
            "State": "",
            "Postal": "12123233",
            "Country": "PK",
            "CountryCode": countryCode,
            "AreaCode": "",
            "PhoneNumber": "",
            "Display": ""
          },
          "Nationality": nationality,
          "ProfileId": -2147483648,
          "IsPrimaryPassenger": false,
          "ContactInfos": [],
          "DocumentInfos": [
            {
              "DocType": "1",
              "DocNumber": child.passportCnicController.text,
              "IssuingCountry": nationality,
              "ExpiryDate": child.passportExpiryController.text.isNotEmpty
                  ? "${child.passportExpiryController.text}T00:00:00"
                  : "2030-12-31T00:00:00"
            }
          ]
        });
      }

      // Process infants
      for (int i = 0; i < infants.length; i++) {
        personId++;
        final infant = infants[i];

        // Calculate age
        final age = _calculateAge(infant.dateOfBirthController.text);

        // Get gender code
        final gender = infant.genderController.text.substring(0, 1).toUpperCase();

        // Get nationality code
        final nationality = infant.nationalityCountry.value?.countryCode ?? "PK";

        passengers.add({
          "PersonOrgID": -personId,
          "FirstName": infant.firstNameController.text,
          "LastName": infant.lastNameController.text,
          "MiddleName": "",
          "Age": age,
          "DOB": "${infant.dateOfBirthController.text}T00:00:00",
          "Gender": gender,
          "Title": infant.titleController.text,
          "NationalityLaguageID": 1,
          "RelationType": "Self",
          "WBCID": 1,
          "PTCID": 5, // Infant passenger type
          "TravelsWithPersonOrgID": -(i + 1), // Travels with corresponding adult
          "MarketingOptIn": true,
          "UseInventory": false,
          "Address": {
            "Address1": "",
            "Address2": "",
            "City": "",
            "State": "",
            "Postal": "12123233",
            "Country": "PK",
            "CountryCode": countryCode,
            "AreaCode": "",
            "PhoneNumber": "",
            "Display": ""
          },
          "Nationality": nationality,
          "ProfileId": -2147483648,
          "IsPrimaryPassenger": false,
          "ContactInfos": [],
          "DocumentInfos": [
            {
              "DocType": "1",
              "DocNumber": infant.passportCnicController.text,
              "IssuingCountry": nationality,
              "ExpiryDate": infant.passportExpiryController.text.isNotEmpty
                  ? "${infant.passportExpiryController.text}T00:00:00"
                  : "2030-12-31T00:00:00"
            }
          ]
        });
      }

      // Build segments from cart data and segment array
      final List<Map<String, dynamic>> segments = _buildSegmentsFromCartData(
          cartData,
          adults.length,
          segmentArray
      );

      // Format phone numbers for the request
      final formattedPhone = clientPhone.replaceAll(RegExp(r'[^0-9]'), '');
      final formattedSimCode = simCode.replaceAll(RegExp(r'[^0-9]'), '');

      return {
        "ActionType": "GetSummary",
        "ReservationInfo": {
          "SeriesNumber": "299",
          "ConfirmationNumber": ""
        },
        "CarrierCodes": [
          {
            "AccessibleCarrierCode": "FZ"
          }
        ],
        "ClientIPAddress": "",
        "SecurityToken": "",
        "SecurityGUID": "",
        "HistoricUserName": username,
        "CarrierCurrency": "PKR",
        "DisplayCurrency": "PKR",
        "IATANum": "2730402T",
        "User": username,
        "ReceiptLanguageID": "1",
        "Address": {
          "Address1": city,
          "Address2": city,
          "City": city,
          "Postal": "10967",
          "PhoneNumber": formattedPhone,
          "Country": "PK",
          "CountryCode": countryCode,
          "State": "",
          "Display": ""
        },
        "ContactInfos": null,
        "Passengers": passengers,
        "Segments": segments,
        "Payments": []
      };
    } catch (e, stackTrace) {
      print('Error building PNR request: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
// Helper method to calculate age from date of birth
  int _calculateAge(String dobString) {
    try {
      final dob = DateTime.parse(dobString);
      final now = DateTime.now();
      return now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1);
    } catch (e) {
      return 25; // Default age if parsing fails
    }
  }

// Update the _buildSegmentsFromCartData method
  List<Map<String, dynamic>> _buildSegmentsFromCartData(
      Map<String, dynamic> cartData,
      int passengerCount,
      List<Map<String, dynamic>> segmentArray
      ) {
    final List<Map<String, dynamic>> segments = [];

    try {
      print('Building segments from cart data and segment array...');
      print('Segment array: ${segmentArray.length} items');

      // If we have segment array from the controller, use it
      if (segmentArray.isNotEmpty) {
        for (final segment in segmentArray) {
          segments.add({
            "PersonOrgID": -(segment['pax'] ?? 1),
            "FareInformationID": segment['fareID'] ?? 1,
            "SpecialServices": segment['extra'] != null
                ? _buildSpecialServices(segment['extra'], segment['pax'] ?? 1)
                : [],
            "Seats": segment['extra'] != null
                ? _buildSeats(segment['extra'], segment['pax'] ?? 1)
                : []
          });
        }
      } else {
        // Fallback: create basic segments from cart data
        print('No segment array provided, creating basic segments...');

        // Extract flight groups from cart data
        final flightGroups = cartData['flightGroups'] as List?;
        if (flightGroups != null && flightGroups.isNotEmpty) {
          for (final flightGroup in flightGroups) {
            final fareBrands = flightGroup['fareBrands'] as List?;
            if (fareBrands != null && fareBrands.isNotEmpty) {
              for (final fareBrand in fareBrands) {
                final fareInfos = fareBrand['fareInfos'] as List?;
                if (fareInfos != null && fareInfos.isNotEmpty) {
                  for (final fareInfo in fareInfos) {
                    final paxFareInfos = fareInfo['paxFareInfos'] as List?;
                    if (paxFareInfos != null && paxFareInfos.isNotEmpty) {
                      for (int i = 0; i < paxFareInfos.length; i++) {
                        final paxFareInfo = paxFareInfos[i];
                        segments.add({
                          "PersonOrgID": -(i + 1),
                          "FareInformationID": paxFareInfo['fareID'] ?? 1,
                          "SpecialServices": [],
                          "Seats": []
                        });
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error building segments from cart data: $e');
    }

    // Fallback: create basic segments if extraction fails
    if (segments.isEmpty) {
      print('Creating fallback segments...');
      for (int i = 0; i < passengerCount; i++) {
        segments.add({
          "PersonOrgID": -(i + 1),
          "FareInformationID": 1,
          "SpecialServices": [],
          "Seats": []
        });
      }
    }

    print('Built ${segments.length} segments');
    return segments;
  }

// Helper methods for special services and seats
  List<Map<String, dynamic>> _buildSpecialServices(Map<String, dynamic> extra, int paxId) {
    final List<Map<String, dynamic>> services = [];

    try {
      // Handle baggage
      if (extra['baggage'] != null && extra['baggage'].toString().isNotEmpty) {
        final baggageItems = extra['baggage'].toString().split('!!');
        if (baggageItems.length >= 7) {
          services.add({
            "ServiceID": 1,
            "CodeType": baggageItems[0],
            "SSRCategory": 99,
            "LogicalFlightID": int.parse(baggageItems[1]),
            "DepartureDate": baggageItems[2],
            "Amount": double.parse(baggageItems[3]),
            "OverrideAmount": false,
            "CurrencyCode": baggageItems[4],
            "Commissionable": false,
            "Refundable": false,
            "ChargeComment": baggageItems[5],
            "PersonOrgID": -paxId,
            "AlreadyAdded": false,
            "PhysicalFlightID": int.parse(baggageItems[6]),
            "secureHash": ""
          });
        }
      }

      // Handle meals
      if (extra['meal'] is List) {
        for (final meal in extra['meal']) {
          if (meal != null && meal.toString().isNotEmpty) {
            final mealItems = meal.toString().split('!!');
            if (mealItems.length >= 7) {
              services.add({
                "ServiceID": 1,
                "CodeType": mealItems[0],
                "SSRCategory": 121,
                "LogicalFlightID": int.parse(mealItems[1]),
                "DepartureDate": mealItems[2],
                "Amount": double.parse(mealItems[3]),
                "OverrideAmount": false,
                "CurrencyCode": mealItems[4],
                "Commissionable": false,
                "Refundable": false,
                "ChargeComment": mealItems[5],
                "PersonOrgID": -paxId,
                "AlreadyAdded": false,
                "PhysicalFlightID": int.parse(mealItems[6]),
                "secureHash": ""
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error building special services: $e');
    }

    return services;
  }

  List<Map<String, dynamic>> _buildSeats(Map<String, dynamic> extra, int paxId) {
    final List<Map<String, dynamic>> seats = [];

    try {
      // Handle seats
      if (extra['seat'] is List) {
        for (final seat in extra['seat']) {
          if (seat != null && seat.toString().isNotEmpty) {
            final seatItems = seat.toString().split('!!');
            if (seatItems.length >= 9) {
              seats.add({
                "PersonOrgID": -paxId,
                "LogicalFlightID": int.parse(seatItems[1]),
                "PhysicalFlightID": int.parse(seatItems[6]),
                "DepartureDate": seatItems[2],
                "SeatSelected": seatItems[8],
                "RowNumber": seatItems[7]
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error building seats: $e');
    }

    return seats;
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