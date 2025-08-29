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