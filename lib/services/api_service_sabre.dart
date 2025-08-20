// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/flight/search_flights/booking_flight/airblue/booking_flight_controller.dart';
import '../views/flight/search_flights/sabre/sabre_flight_models.dart';
import 'api_service_airblue.dart';

class ApiServiceSabre extends GetxService {
  late final Dio dio;
  // Initialize directly instead of using late
  final AirBlueFlightApiService flightShoppingService = AirBlueFlightApiService();

  static const String _baseUrl = 'https://api.havail.sabre.com';
  static const String _tokenKey = 'flight_api_token';
  static const String _tokenExpiryKey = 'flight_token_expiry';

  // Add a property to store the airline map
  final Rx<Map<String, AirlineInfo>> airlineMap = Rx<Map<String, AirlineInfo>>({});
  // Add a method to get the airline map
  Map<String, AirlineInfo> getAirlineMap() {
    return airlineMap.value;
  }
  // Initialize airline data when service starts
  @override
  void onInit() {
    super.onInit();
    // Fetch airline data when service initializes
    fetchAirlineData().then((data) {
      airlineMap.value = data;
    });
  }


  // Cabin class mapping
  static const Map<String, String> _cabinClassMapping = {
    'ECONOMY': 'Economy',
    'PREMIUM ECONOMY': 'PremiumEconomy',
    'BUSINESS': 'Business',
    'FIRST': 'First',
  };

  String _mapCabinClass(String cabin) {
    return _cabinClassMapping[cabin.toUpperCase()] ?? 'Economy';
  }

  ApiServiceSabre() {
    dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      validateStatus: (status) => true,
    ));
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().add(const Duration(minutes: 55));
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String());
  }

  Future<String?> getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryTimeStr = prefs.getString(_tokenExpiryKey);

    if (token != null && expiryTimeStr != null) {
      final expiryTime = DateTime.parse(expiryTimeStr);
      if (DateTime.now().isBefore(expiryTime)) {
        return token;
      }
    }
    return null;
  }

  // Add to ApiServiceFlight class
  Future<String> generateToken() async {
    try {
      final response = await dio.post(
        '/v2/auth/token',
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization':
                'Basic VmpFNk5EY3pNVGcxT2paTlJEZzZRVUU9OlUxTlhVa1ZUT1RBPQ==',
            'grant_type': 'client_credentials'
          },
        ),
        // data: {'grant_type': 'client_credentials'},
      );


      if (response.statusCode == 200 && response.data['access_token'] != null) {
        final token = response.data['access_token'];
        await _storeToken(token);
        return token;
      } else {
        throw Exception('Failed to generate token');
      }
    } catch (e) {
      throw Exception('Error generating token: $e');
    }
  }

  // Sabre 0
  // AirBlue 1

  Future<Map<String, dynamic>> searchFlights({
    required int type,
    required String origin,
    required String destination,
    required String depDate,
    required int adult,
    required int child,
    required int infant,
    required int stop,
    required String cabin,
    required int flight,
  }) async {
    try {


      if(flight==0){
        final token = await getValidToken() ?? await generateToken();
        // Original Sabre API call
        final sabreResponse = await _searchFlightsWithSabre(
          type: type,
          origin: origin,
          destination: destination,
          depDate: depDate,
          adult: adult,
          child: child,
          infant: infant,
          stop: stop,
          cabin: cabin,
          token: token,
        );

        return sabreResponse;
      }else if(flight==1){
        // New Air Blue API call with same parameters
        try {


          final airBlueResponse = await _searchFlightsWithAirBlue(
            type: type,
            origin: origin,
            destination: destination,
            depDate: depDate,
            adult: adult,
            child: child,
            infant: infant,
            stop: stop.toString(), // Convert int to string as Air Blue expects string
            cabin: cabin,
          );

          printJsonPretty(airBlueResponse);

          // Here you would normally process the Air Blue response and merge with Sabre results
          // For now, we're just logging it to console
          return airBlueResponse;
        } catch (airBlueError) {
          // If Air Blue API fails, just log the error but continue with Sabre results
        }
      }




        return {};
    } catch (e) {
      // print('Error in searchFlights: $e');
      throw Exception('Error searching flights: $e');
    }
  }
  Future<Map<String, dynamic>> _searchFlightsWithSabre({
    required int type,
    required String origin,
    required String destination,
    required String depDate,
    required int adult,
    required int child,
    required int infant,
    required int stop,
    required String cabin,
    required String token,
  }) async {
    try {
      final originArray = origin.split(',');
      final destinationArray = destination.split(',');
      final depDateArray = depDate.split(',');

      final mappedCabin = _mapCabinClass(cabin);

      List<Map<String, dynamic>> passengers = [];
      List<Map<String, dynamic>> originDestinations = [];

      if (type == 0) {
        // One-way trip
        originDestinations.add({
          "RPH": "1",
          "DepartureDateTime": "${depDateArray[1]}T00:00:01",
          "OriginLocation": {"LocationCode": originArray[1].toUpperCase()},
          "DestinationLocation": {
            "LocationCode": destinationArray[1].toUpperCase()
          }
        });
      } else if (type == 1) {
        // Return trip
        originDestinations.addAll([
          {
            "RPH": "1",
            "DepartureDateTime": "${depDateArray[1]}T00:00:01",
            "OriginLocation": {"LocationCode": originArray[1].toUpperCase()},
            "DestinationLocation": {
              "LocationCode": destinationArray[1].toUpperCase()
            }
          },
          {
            "RPH": "2",
            "DepartureDateTime": "${depDateArray[2]}T00:00:01",
            "OriginLocation": {
              "LocationCode": destinationArray[1].toUpperCase()
            },
            "DestinationLocation": {
              "LocationCode": originArray[1].toUpperCase()
            }
          }
        ]);
      } else if (type == 2) {
        // Multi-city trip
        for (int i = 1; i < depDateArray.length; i++) {
          if (i < originArray.length && i < destinationArray.length) {
            originDestinations.add({
              "RPH": "$i",
              "DepartureDateTime": "${depDateArray[i]}T00:00:01",
              "OriginLocation": {"LocationCode": originArray[i].toUpperCase()},
              "DestinationLocation": {
                "LocationCode": destinationArray[i].toUpperCase()
              }
            });
          }
        }
      }

      if (adult > 0) passengers.add({"Code": "ADT", "Quantity": adult});
      if (child > 0) passengers.add({"Code": "CHD", "Quantity": child});
      if (infant > 0) passengers.add({"Code": "INF", "Quantity": infant});

      final requestBody = {
        "OTA_AirLowFareSearchRQ": {
          "ResponseType": "OTA",
          "ResponseVersion": "4.3.0",
          "Version": "4.3.0",
          "OriginDestinationInformation": originDestinations,
          "POS": {
            "Source": [
              {
                "PseudoCityCode": "6MD8",
                "RequestorID": {
                  "CompanyName": {"Code": "TN"},
                  "ID": "1",
                  "Type": "1"
                }
              }
            ]
          },
          "TPA_Extensions": {
            "IntelliSellTransaction": {
              "RequestType": {"Name": "50ITINS"}
            }
          },
          "TravelPreferences": {
            "ValidInterlineTicket": true,
            "CabinPref": [
              {"Cabin": mappedCabin, "PreferLevel": "Preferred"}
            ],
            "VendorPref": [{}],
            "TPA_Extensions": {
              "DataSources": {
                "ATPCO": "Enable",
                "LCC": "Enable",
                "NDC": "Enable"
              },
              "NumTrips": {"Number": 50},
              "NDCIndicators": {
                "MultipleBrandedFares": {"Value": true},
                "MaxNumberOfUpsells": {"Value": 6}
              },
              "TripType": {
                "Value": type == 1 ? "Return" : (type == 2 ? "Other" : "OneWay")
              }
            },
            "MaxStopsQuantity": stop
          },
          "TravelerInfoSummary": {
            "SeatsRequested": [adult + child],
            "AirTravelerAvail": [
              {"PassengerTypeQuantity": passengers}
            ],
            "PriceRequestInformation": {
              "TPA_Extensions": {
                "BrandedFareIndicators": {
                  "MultipleBrandedFares": true,
                  "ReturnBrandAncillaries": true,
                  "UpsellLimit": 4,
                  "ParityMode": "Leg",
                  "ParityModeForLowest": "Leg",
                  "ItinParityFallbackMode": "LegParity",
                  "ItinParityBrandlessLeg": true
                }
              }
            }
          }
        }
      };

      final response = await dio.post(
        '/v3/offers/shop',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
        ),
        data: requestBody,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to model_controllers flights: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching flights with Sabre: $e');
    }
  }



  // Helper method to model_controllers flights with Air Blue
  Future<Map<String, dynamic>> _searchFlightsWithAirBlue({
    required int type,
    required String origin,
    required String destination,
    required String depDate,
    required int adult,
    required int child,
    required int infant,
    required String stop,
    required String cabin,
  }) async {
    try {
      // Format parameters for Air Blue API
      // Air Blue expects comma-prefixed strings for origin, destination, and depDate
      String formattedOrigin = origin;
      String formattedDestination = destination;
      String formattedDepDate = depDate;

      // Ensure they start with comma
      if (!formattedOrigin.startsWith(',')) formattedOrigin = ',$formattedOrigin';
      if (!formattedDestination.startsWith(',')) formattedDestination = ',$formattedDestination';
      if (!formattedDepDate.startsWith(',')) formattedDepDate = ',$formattedDepDate';

      return await flightShoppingService.airBlueFlightSearch(
        type: type,
        origin: formattedOrigin,
        destination: formattedDestination,
        depDate: formattedDepDate,
        adult: adult,
        child: child,
        infant: infant,
        stop: stop,
        cabin: cabin,
      );
    } catch (e) {
      throw Exception('Error searching flights with Air Blue: $e');
    }
  }

  // Add to ApiServiceFlight class in api_service_sabre.dart

  Future<Map<String, dynamic>> checkFlightAvailability({
    required int type,
    required List<Map<String, dynamic>> flightSegments,
    required Map<String, dynamic> requestBody,
    required int adult,
    required int child,
    required int infant,
    bool isNDC = false, // Add this parameter
  }) async {
    try {
      final token = await getValidToken() ?? await generateToken();
      print("token:");
      print(token);

      print("availability request");
      printJsonPretty(requestBody);

      final String endpoint;
      final Map<String, dynamic> requestData;

      if (isNDC) {
        // Handle NDC validation
        endpoint = '/v1/offers/price';
        requestData = {
          "query": [
            {
              "offerItemId": requestBody['offerItemId'] ?? [],
            }
          ],
          "params": {
            "formOfPayment": requestBody['formOfPayment'] ?? [],
          },
        };
      } else {
        // Handle standard validation
        endpoint = '/v4/shop/flights/revalidate';
        requestData = requestBody;
      }

      final response = await dio.post(
        endpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
        ),
        data: requestData,
      );

      print("availability request data");
      printJsonPretty(requestData);

      print("availability response");
      printJsonPretty(response.data);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to check flight availability: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking flight availability: $e');
    }
  }

  /// Helper function to print large JSON data in readable format
  /// Prints JSON nicely with chunking
  void printJsonPretty(dynamic jsonData) {
    const int chunkSize = 1000;
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    for (int i = 0; i < jsonString.length; i += chunkSize) {
      final chunk = jsonString.substring(
        i,
        i + chunkSize < jsonString.length ? i + chunkSize : jsonString.length,
      );
      if (kDebugMode) {
        print(chunk);
      }
    }
  }

  Future<Map<String, AirlineInfo>> fetchAirlineData() async {
    Map<String, AirlineInfo> tempAirlineMap = {};

    try {
      var response = await dio.request(
        'https://agent1.pk/api.php?type=airlines',
        options: Options(
          method: 'GET',
        ),
      );

      if (response.statusCode == 200) {
        var data = response.data['data'];
        for (var item in data) {
          // Clean and format the logo URL
          String logoUrl = item['logo'];

          // Remove any escaped characters like \t, \n, etc.
          logoUrl = logoUrl.replaceAll(RegExp(r'^\t+'), '');
          // print(logoUrl);

          // // Ensure URL starts with https://
          // if (!logoUrl.startsWith('http://') && !logoUrl.startsWith('https://')) {
          //   logoUrl = 'https://' + logoUrl;
          // }

          tempAirlineMap[item['code']] = AirlineInfo(
            item['name'],
            logoUrl,
          );
        }
        // Update the stored airlineMap
        airlineMap.value = tempAirlineMap;

        // Log a few URLs for debugging
        if (tempAirlineMap.isNotEmpty) {
          tempAirlineMap.entries.take(3).forEach((entry) {
          });
        }
      } else {
      }
    } catch (e) {
    }

    return tempAirlineMap;
  }


  static const String _marginApiBaseUrl = 'https://agent1.pk/group_api';
  static const String _marginUserId = 'Group-121';
  static const String _marginUsername = 'travelocity';

// Add these methods to the ApiServiceFlight class
  Future<String> _generateMarginToken() async {
    try {
      final response = await dio.post(
        '$_marginApiBaseUrl/generate_token.php',
        options: Options(
          headers: {
            'Userid': _marginUserId,
            'Username': _marginUsername,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "req_type": "get_margin",
        },
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        return response.data['token'];
      } else {
        throw Exception('Failed to generate margin token');
      }
    } catch (e) {
      throw Exception('Error generating margin token: $e');
    }
  }

  Future<Map<String, dynamic>> getMargin() async {
    try {
      final token = await _generateMarginToken();

      final response = await dio.post(
        '$_marginApiBaseUrl/sastay_restapi.php',
        options: Options(
          headers: {
            'Userid': _marginUserId,
            'Username': _marginUsername,
            'Authorization': token,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "req_type": "get_margin",
          "keyword": "karac", // This seems to be required based on your example
        },
      );

      if (response.statusCode == 200) {
        return response.data['response'] ?? {};
      } else {
        throw Exception('Failed to get margin: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error getting margin: $e');
    }
  }

  double calculatePriceWithMargin(double basePrice, Map<String, dynamic> marginData) {
    final marginVal = marginData['margin_val'];
    final marginPer = marginData['margin_per'];



    if (marginVal != null && marginVal != 'N/A') {
      // Fixed margin value
      return basePrice + double.parse(marginVal);
    } else if (marginPer != null && marginPer != 'N/A') {
      // Percentage margin
      final percentage = double.parse(marginPer);
      return basePrice * (1 + (percentage / 100));
    }
    // If no margin data is available, return the base price
    return basePrice;
  }



  Future<void> createPNRRequest({
    required SabreFlight flight,
    required List<TravelerInfo> adults,
    required List<TravelerInfo> children,
    required List<TravelerInfo> infants,
    required String bookerEmail,
    required String bookerPhone,
  }) async {
    print("flight ndc check");
    print(flight.isNDC);
    try {
      if (flight.isNDC) {
        // Handle NDC PNR creation
        await _createNDCPNRRequest(
          flight: flight,
          adults: adults,
          children: children,
          infants: infants,
          bookerEmail: bookerEmail,
          bookerPhone: bookerPhone,
        );
      } else {
        // Handle standard PNR creation (existing logic)
        await _createStandardPNRRequest(
          flight: flight,
          adults: adults,
          children: children,
          infants: infants,
          bookerEmail: bookerEmail,
          bookerPhone: bookerPhone,
        );
      }
    } catch (e) {
      print('Error in createPNRRequest: $e');
      throw Exception('Error creating PNR: $e');
    }
  }

  Future<void> _createStandardPNRRequest({
    required SabreFlight flight,
    required List<TravelerInfo> adults,
    required List<TravelerInfo> children,
    required List<TravelerInfo> infants,
    required String bookerEmail,
    required String bookerPhone,
  }) async {
    // Extract necessary information from the flight and travelers
    final List<Map<String, dynamic>> passengers = [];
    final List<Map<String, dynamic>> flightSegments = [];

    // Add adults
    for (var i = 0; i < adults.length; i++) {
      final adult = adults[i];
      passengers.add({
        "NameNumber": "${i + 1}.1",
        "NameReference": "", // Empty string for adults
        "PassengerType": "ADT",
        "GivenName": "${adult.firstNameController.text.trim()} ${adult.titleController.text}",
        "Surname": adult.lastNameController.text.trim(),
        "DateOfBirth": adult.dateOfBirthController.text,
        "PassportNumber": adult.passportCnicController.text.trim(),
        "PassportExpiry": adult.passportExpiryController.text,
      });
    }

    // Add children
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      passengers.add({
        "NameNumber": "${adults.length + i + 1}.1",
        "NameReference": "C${(i + 4).toString().padLeft(2, '0')}",
        "PassengerType": "CNN",
        "GivenName": "${child.firstNameController.text.trim()} ${child.titleController.text}",
        "Surname": child.lastNameController.text.trim(),
        "DateOfBirth": child.dateOfBirthController.text,
        "PassportNumber": child.passportCnicController.text.trim(),
        "PassportExpiry": child.passportExpiryController.text,
      });
    }

    // Add infants
    for (var i = 0; i < infants.length; i++) {
      final infant = infants[i];
      passengers.add({
        "NameNumber": "${i + 1}.1",
        "NameReference": "I${(i + 12).toString().padLeft(2, '0')}",
        "PassengerType": "INF",
        "Infant": true,
        "GivenName": "${infant.firstNameController.text.trim()} ${infant.titleController.text}",
        "Surname": infant.lastNameController.text.trim(),
        "DateOfBirth": infant.dateOfBirthController.text,
        "PassportNumber": infant.passportCnicController.text.trim(),
        "PassportExpiry": infant.passportExpiryController.text,
      });
    }

    // Add flight segments
    var segmentIndex = 0;
    for (var leg in flight.legSchedules) {
      for (var schedule in leg['schedules']) {
        flightSegments.add({
          "DepartureDateTime": schedule['departure']['dateTime'],
          "FlightNumber": schedule['carrier']['marketingFlightNumber'].toString(),
          "NumberInParty": passengers.length.toString(),
          "ResBookDesigCode": flight.segmentInfo[segmentIndex].bookingCode,
          "Status": "NN",
          "DestinationLocation": {
            "LocationCode": schedule['arrival']['airport'],
          },
          "MarketingAirline": {
            "Code": schedule['carrier']['marketing'],
            "FlightNumber": schedule['carrier']['marketingFlightNumber'].toString(),
          },
          "OriginLocation": {
            "LocationCode": schedule['departure']['airport'],
          },
        });
        segmentIndex++;
      }
    }

    // Extract FareBasis codes from flight data
    final List<Map<String, dynamic>> fareBasisCodes = [];
    for (var leg in flight.legSchedules) {
      if (leg['fareBasisCode'] != null) {
        fareBasisCodes.add({
          "FareBasis": {
            "Code": leg['fareBasisCode'],
          },
          "RPH": "${fareBasisCodes.length + 1}",
        });
      }
    }

    // Get the first adult's phone and email
    final firstAdultPhone = adults.isNotEmpty ? adults[0].phoneController.text : bookerPhone;
    final firstAdultCountry = adults.isNotEmpty ? adults[0].phoneCountry.toString() : "92";
    final firstAdultEmail = adults.isNotEmpty ? adults[0].emailController.text : bookerEmail;

    // Format phone with 00 + countryCode + number (without leading 0)
    String formatPhone(String phone, String countryCode) {
      phone = phone.replaceAll(RegExp(r'\D'), '');
      if (phone.startsWith('0')) {
        phone = phone.substring(1);
      }
      return '00952$phone';
    }

    final formattedPhone = formatPhone(firstAdultPhone, firstAdultCountry);

    List<Map<String, String>> passengerType = [];

    if (adults.isNotEmpty) {
      passengerType.add({
        "Code": "ADT",
        "Quantity": adults.length.toString(),
      });
    }

    if (children.isNotEmpty) {
      passengerType.add({
        "Code": "CNN",
        "Quantity": children.length.toString(),
      });
    }

    if (infants.isNotEmpty) {
      passengerType.add({
        "Code": "INF",
        "Quantity": infants.length.toString(),
      });
    }

    // Create the request body for standard PNR
    final requestBody = {
      "CreatePassengerNameRecordRQ": {
        "haltOnAirPriceError": true,
        "haltOnInvalidMCT": true,
        "targetCity": "6MD8",
        "version": "2.5.0",
        "TravelItineraryAddInfo": {
          "AgencyInfo": {
            "Ticketing": {
              "TicketType": "7T-A",
            },
          },
          "CustomerInfo": {
            "ContactNumbers": {
              "ContactNumber": passengers
                  .where((passenger) => passenger["PassengerType"] != "INF")
                  .map((passenger) => {
                "NameNumber": passenger["NameNumber"],
                "Phone": formattedPhone,
                "PhoneUseType": "M"
              })
                  .toList(),
            },
            "Email": passengers
                .where((passenger) => passenger["PassengerType"] != "INF")
                .map((passenger) => {
              "Address": firstAdultEmail,
              "NameNumber": passenger["NameNumber"]
            })
                .toList(),
            "PersonName": passengers.asMap().entries.map((entry) {
              int index = entry.key + 1;
              var passenger = entry.value;
              return {
                "NameNumber": "$index.1",
                "NameReference": passenger["NameReference"],
                "PassengerType": passenger["PassengerType"],
                if (passenger["PassengerType"] == "INF") "Infant": true,
                "GivenName": passenger["GivenName"],
                "Surname": passenger["Surname"],
              };
            }).toList(),
          },
        },
        "AirBook": {
          "OriginDestinationInformation": {
            "FlightSegment": flightSegments,
          },
          "RetryRebook": {
            "Option": true,
          },
          "HaltOnStatus": [
            {"Code": "HL"}, {"Code": "HN"}, {"Code": "HX"}, {"Code": "LL"},
            {"Code": "NN"}, {"Code": "NO"}, {"Code": "PN"}, {"Code": "UC"},
            {"Code": "UN"}, {"Code": "US"}, {"Code": "UU"},
          ],
          "RedisplayReservation": {
            "NumAttempts": 10,
            "WaitInterval": 500,
          },
        },
        "AirPrice": [
          {
            "PriceRequestInformation": {
              "Retain": true,
              "OptionalQualifiers": {
                "PricingQualifiers": {
                  "CommandPricing": fareBasisCodes,
                  "ItineraryOptions": {
                    "SegmentSelect": fareBasisCodes.map((code) => {
                      "Number": code["RPH"],
                      "RPH": code["RPH"],
                    }).toList(),
                  },
                  "PassengerType": passengerType,
                },
              },
            },
          },
        ],
        "SpecialReqDetails": {
          "SpecialService": {
            "SpecialServiceInfo": {
              "AdvancePassenger": passengers.map((passenger) {
                return {
                  "Document": {
                    "IssueCountry": "PK",
                    "NationalityCountry": "PK",
                    "ExpirationDate": passenger["PassportExpiry"],
                    "Number": passenger["PassportNumber"],
                    "Type": "P",
                  },
                  "PersonName": {
                    "GivenName": passenger["GivenName"],
                    "MiddleName": "",
                    "Surname": passenger["Surname"],
                    "DateOfBirth": passenger["DateOfBirth"],
                    "DocumentHolder": true,
                    "Gender": passenger["PassengerType"] == "INF" ? "M" : "F",
                    "LapChild": passenger["PassengerType"] == "INF",
                    "NameNumber": passenger["NameNumber"],
                  },
                };
              }).toList(),
              "Service": [
                ...passengers
                    .where((passenger) => passenger["PassengerType"] != "INF")
                    .map((passenger) => [
                  {
                    "SSR_Code": "CTCM",
                    "PersonName": {
                      "NameNumber": passenger["NameNumber"],
                    },
                    "Text": formattedPhone,
                  },
                  {
                    "SSR_Code": "CTCE",
                    "PersonName": {
                      "NameNumber": passenger["NameNumber"],
                    },
                    "Text": firstAdultEmail.replaceAll('@', '//'),
                  },
                ])
                    .expand((x) => x)
                    .toList(),
                ...passengers
                    .where((passenger) => passenger["PassengerType"] == "INF")
                    .map((passenger) => {
                  "SSR_Code": "INFT",
                  "PersonName": {
                    "NameNumber": passenger["NameNumber"],
                  },
                  "Text":
                  "${passenger["Surname"]}/${passenger["GivenName"].split(' ')[0]}${passenger["GivenName"].split(' ').length > 1 ? passenger["GivenName"].split(' ')[1] : ''}/${passenger["DateOfBirth"]}"
                })
                    .toList(),
              ],
            },
          },
        },
        "PostProcessing": {
          "ARUNK": {
            "keepSegments": true,
            "priorPricing": true,
          },
          "EndTransaction": {
            "Email": {
              "Ind": true,
            },
            "Source": {
              "ReceivedFrom": "AryanB2B",
            },
          },
          "PostBookingHKValidation": {
            "waitInterval": 200,
            "numAttempts": 4,
          },
          "WaitForAirlineRecLoc": {
            "waitInterval": 200,
            "numAttempts": 4,
          },
          "RedisplayReservation": {
            "waitInterval": 1000,
          },
        },
      },
    };

    // Print the request body
    print('Standard PNR Request Body:');
    printJsonPretty(requestBody);

    // Make the API call
    final token = await getValidToken() ?? await generateToken();
    final response = await dio.post(
      '/v2.5.0/passenger/records?mode=create',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Conversation-ID': '2021.01.DevStudio',
        },
      ),
      data: requestBody,
    );

    if (response.statusCode == 200) {
      print("Standard PNR Response:");
      printJsonPretty(response.data);
      handlePnrResponse(response.data);
    } else {
      print("Standard PNR Error Response:");
      printJsonPretty(response.data);
      throw Exception('Failed to create standard PNR: ${response.statusCode}');
    }
  }

  Future<void> _createNDCPNRRequest({
    required SabreFlight flight,
    required List<TravelerInfo> adults,
    required List<TravelerInfo> children,
    required List<TravelerInfo> infants,
    required String bookerEmail,
    required String bookerPhone,
  }) async {
    try {
      // Extract offer information from flight data
      print("flight pricing info array check:");
      print(flight.pricingInforArray[0]['offerId']);
      print(flight.pricingInforArray[0]['offer']['offerId']);
      print(flight.pricingInforArray[0]['fare']['passengerInfoList'][0]['passengerInfo']['offerItemId']);
      print("----------------");

      final offerId = flight.pricingInforArray.isNotEmpty
          ? flight.pricingInforArray[0]['offer']['offerId']
          : 'default-offer-id';

      final offerItemId = flight.pricingInforArray.isNotEmpty
          ? flight.pricingInforArray[0]['fare']['passengerInfoList'][0]['passengerInfo']['offerItemId']
          : 'default-offer-item-id';

      // Build contact infos for all passengers
      List<Map<String, dynamic>> contactInfos = [];
      List<Map<String, dynamic>> passengers = [];
      List<Map<String, dynamic>> secureFlightList = [];
      List<Map<String, dynamic>> serviceList = [];

      int passengerIndex = 1;

      // Process Adults
      for (int i = 0; i < adults.length; i++) {
        final adult = adults[i];
        final firstName = adult.firstNameController.text.trim();
        final lastName = adult.lastNameController.text.trim();
        final title = adult.titleController.text.trim().isEmpty ? 'Mr' : adult.titleController.text.trim();
        final dob = adult.dateOfBirthController.text.isEmpty ? '1990-01-01' : adult.dateOfBirthController.text;
        final passportNumber = adult.passportCnicController.text.trim();
        final passportExpiry = adult.passportExpiryController.text.isEmpty ? '2030-12-31' : adult.passportExpiryController.text;
        final nationality = adult.nationalityController?.text.trim() ?? 'PK';
        final gender = adult.genderController.text.startsWith('M') ? 'M' : 'F';

        // Format email for SSR (like web version)
        final formattedEmail = bookerEmail
            .replaceAll('@', '//')
            .replaceAll('_', '..')
            .replaceAll('-', './');

        // Contact info
        contactInfos.add({
          "id": "CI-$passengerIndex",
          "emailAddresses": [
            {
              "address": bookerEmail
            }
          ],
          "phones": [
            {
              "number": bookerPhone.replaceAll(RegExp(r'\D'), '')
            }
          ]
        });

        // Passenger info
        passengers.add({
          "contactInfoRefId": "CI-$passengerIndex",
          "birthdate": dob,
          "givenName": "$firstName $title",
          "id": "Passenger$passengerIndex",
          "surname": lastName,
          "typeCode": "ADT",
          "identityDocuments": [
            {
              "id": "ID-1",
              "documentNumber": passportNumber,
              "documentTypeCode": "passport",
              "issuingCountryCode": nationality,
              "placeOfIssue": "GB",
              "citizenshipCountryCode": "PK",
              "residenceCountryCode": "PK",
              "titleName": title,
              "givenName": "$lastName $title",
              "middleName": "GEORGE",
              "surname": firstName,
              "suffixName": "Jr.",
              "birthdate": dob,
              "genderCode": gender,
              "issueDate": "2025-07-05",
              "expiryDate": passportExpiry,
              "hostCountryCode": "PK"
            }
          ]
        });

        // Secure flight info
        secureFlightList.add({
          "SegmentNumber": "A",
          "PersonName": {
            "DateOfBirth": dob,
            "Gender": gender,
            "NameNumber": "$passengerIndex.1",
            "GivenName": "$firstName $title",
            "Surname": lastName
          }
        });

        // Service requests
        serviceList.addAll([
          {
            "SSR_Code": "CTCM",
            "PersonName": {
              "NameNumber": "$passengerIndex.1"
            },
            "Text": bookerPhone
          },
          {
            "SSR_Code": "CTCE",
            "PersonName": {
              "NameNumber": "$passengerIndex.1"
            },
            "Text": formattedEmail
          }
        ]);

        passengerIndex++;
      }

      // Process Children
      for (int i = 0; i < children.length; i++) {
        final child = children[i];
        final firstName = child.firstNameController.text.trim();
        final lastName = child.lastNameController.text.trim();
        final title = child.titleController.text.trim().isEmpty ? 'Ms' : child.titleController.text.trim();
        final dob = child.dateOfBirthController.text.isEmpty ? '2015-01-01' : child.dateOfBirthController.text;
        final passportNumber = child.passportCnicController.text.trim();
        final passportExpiry = child.passportExpiryController.text.isEmpty ? '2030-12-31' : child.passportExpiryController.text;
        final nationality = child.nationalityController?.text.trim() ?? 'PK';
        final gender = child.genderController.text.startsWith('M') ? 'M' : 'F';

        final formattedEmail = bookerEmail
            .replaceAll('@', '//')
            .replaceAll('_', '..')
            .replaceAll('-', './');

        contactInfos.add({
          "id": "CI-$passengerIndex",
          "emailAddresses": [
            {
              "address": bookerEmail
            }
          ],
          "phones": [
            {
              "number": bookerPhone.replaceAll(RegExp(r'\D'), '')
            }
          ]
        });

        passengers.add({
          "contactInfoRefId": "CI-$passengerIndex",
          "birthdate": dob,
          "givenName": "$firstName $title",
          "id": "Passenger$passengerIndex",
          "surname": lastName,
          "typeCode": "CHD",
          "identityDocuments": [
            {
              "id": "ID-1",
              "documentNumber": passportNumber,
              "documentTypeCode": "PT", // Note: Different from adult
              "issuingCountryCode": nationality,
              "placeOfIssue": "GB",
              "citizenshipCountryCode": nationality,
              "residenceCountryCode": nationality,
              "titleName": title,
              "givenName": "$lastName $title",
              "middleName": "GEORGE",
              "surname": firstName,
              "suffixName": "Jr.",
              "birthdate": dob,
              "genderCode": gender,
              "issueDate": "2025-07-05",
              "expiryDate": passportExpiry,
              "hostCountryCode": nationality
            }
          ]
        });

        secureFlightList.add({
          "SegmentNumber": "A",
          "PersonName": {
            "DateOfBirth": dob,
            "Gender": gender,
            "NameNumber": "$passengerIndex.1",
            "GivenName": "$firstName $title",
            "Surname": lastName
          }
        });

        serviceList.addAll([
          {
            "SSR_Code": "CTCM",
            "PersonName": {
              "NameNumber": "$passengerIndex.1"
            },
            "Text": bookerPhone
          },
          {
            "SSR_Code": "CTCE",
            "PersonName": {
              "NameNumber": "$passengerIndex.1"
            },
            "Text": formattedEmail
          }
        ]);

        passengerIndex++;
      }

      // Process Infants
      for (int i = 0; i < infants.length; i++) {
        final infant = infants[i];
        final firstName = infant.firstNameController.text.trim();
        final lastName = infant.lastNameController.text.trim();
        final title = infant.titleController.text.trim().isEmpty ? 'Ms' : infant.titleController.text.trim();
        final dob = infant.dateOfBirthController.text.isEmpty ? '2023-01-01' : infant.dateOfBirthController.text;
        final passportNumber = infant.passportCnicController.text.trim();
        final passportExpiry = infant.passportExpiryController.text.isEmpty ? '2030-12-31' : infant.passportExpiryController.text;
        final nationality = infant.nationalityController?.text.trim() ?? 'PK';

        final formattedEmail = bookerEmail
            .replaceAll('@', '//')
            .replaceAll('_', '..')
            .replaceAll('-', './');

        contactInfos.add({
          "id": "CI-$passengerIndex",
          "emailAddresses": [
            {
              "address": bookerEmail
            }
          ],
          "phones": [
            {
              "number": bookerPhone.replaceAll(RegExp(r'\D'), '')
            }
          ]
        });

        passengers.add({
          "contactInfoRefId": "CI-$passengerIndex",
          "birthdate": dob,
          "givenName": firstName, // Note: No title for infants in web version
          "id": "Passenger$passengerIndex",
          "surname": lastName,
          "typeCode": "INF",
          "passengerRefId": "CI-1", // Reference to first adult
          "identityDocuments": [
            {
              "id": "ID-1",
              "documentNumber": passportNumber,
              "documentTypeCode": "PT",
              "issuingCountryCode": nationality,
              "placeOfIssue": "GB",
              "citizenshipCountryCode": nationality,
              "residenceCountryCode": nationality,
              "titleName": title,
              "givenName": "$lastName $title",
              "middleName": "GEORGE",
              "surname": firstName,
              "suffixName": "Jr.",
              "birthdate": dob,
              "genderCode": "M", // Default for infants in web version
              "issueDate": "2025-07-05",
              "expiryDate": passportExpiry,
              "hostCountryCode": nationality
            }
          ]
        });

        // Format date for infant SSR (matching web version format)
        final dobFormatted = DateTime.parse(dob);
        final dobSSR = '${dobFormatted.year.toString().substring(2)}${dobFormatted.month.toString().padLeft(2, '0')}${dobFormatted.day.toString().padLeft(2, '0')}';

        secureFlightList.add({
          "SegmentNumber": "A",
          "PersonName": {
            "DateOfBirth": dob,
            "Gender": "MI", // Infant gender code
            "NameNumber": "${i + 1}.1", // Different numbering for infants
            "GivenName": "$firstName $title",
            "Surname": lastName
          }
        });

        serviceList.add({
          "SSR_Code": "INFT",
          "PersonName": {
            "NameNumber": "${i + 1}.1"
          },
          "Text": "$lastName/$firstName$title/${dobSSR.toUpperCase()}"
        });

        passengerIndex++;
      }

      // Create the complete request body matching web structure
      final requestBody = {
        "transactionOptions": {
          "requestType": "STATELESS",
          "commitTransaction": true,
          "movePassengerDetails": true,
          "intialIgnore": true // Keep the typo as in web version
        },
        "contactInfos": contactInfos,
        "createOrders": [
          {
            "offerId": offerId,
            "selectedOfferItems": [
              {
                "id": offerItemId
              }
            ]
          }
        ],
        "passengers": passengers,
        "SpecialReqDetails": {
          "SpecialService": {
            "SpecialServiceInfo": {
              "SecureFlight": secureFlightList,
              "Service": serviceList
            }
          }
        },
        "PostProcessing": {
          "RedisplayReservation": {
            "waitInterval": 100
          },
          "EndTransaction": {
            "Email": {
              "Ind": true
            },
            "Source": {
              "ReceivedFrom": "ReadyFlights"
            }
          }
        }
      };

      print('NDC PNR Request Body:');
      printJsonPretty(requestBody);

      // Convert to JSON string manually (like web version)
      final jsonPayload = jsonEncode(requestBody);
      print('JSON Payload String:');
      print(jsonPayload);

      // Make the API call
      final token = await getValidToken() ?? await generateToken();
      final response = await dio.post(
        '/v1/orders/create',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          responseType: ResponseType.json, // Ensure JSON response
        ),
        data: jsonPayload, // Send as JSON string
      );

      if (response.statusCode == 200) {
        print("NDC PNR Response:");
        printJsonPretty(response.data);

        final responseData = response.data;
        if (responseData['order'] != null && responseData['order']['id'] != null) {
          final orderId = responseData['order']['id'];
          final pnrLocator = responseData['order']['pnrLocator'];

          print('NDC Order created successfully:');
          print('Order ID: $orderId');
          print('PNR Locator: $pnrLocator');
        } else {
          print('NDC PNR creation response format unexpected');
        }
      } else {
        print("NDC PNR Error Response:");
        printJsonPretty(response.data);
        throw Exception('Failed to create NDC PNR: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in NDC PNR creation: $e');
      throw Exception('Error creating NDC PNR: $e');
    }
  }

  void handlePnrResponse(Map<String, dynamic> pnrResponse) async {
    final pnrData = pnrResponse['CreatePassengerNameRecordRS'];
    if (pnrData['ApplicationResults']['status'] == 'Complete') {
      final itineraryRefId = pnrData['ItineraryRef']['ID'];
      print('ItineraryRef ID: $itineraryRefId');

      try {
        final bookingDetails = await ApiServiceSabre().getBooking(itineraryRefId);
        print('Booking Details: $bookingDetails');
      } catch (e) {
        print('Error fetching booking details: $e');
      }
    } else {
      print('PNR creation status is not complete.');
    }
  }

  Future<Map<String, dynamic>> getBooking(String pnrId) async {
    try {
      // Get the valid token or generate a new one if necessary
      final token = await getValidToken() ?? await generateToken();

      // Prepare the request body
      final requestBody = {
        "confirmationId": pnrId,
      };

      // Print the request body for debugging
      print('Get Booking Request Body:');
      printJsonPretty(requestBody);

      // Make the API call
      final response = await dio.post(
        '/v1/trip/orders/getBooking',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: requestBody,
      );

      // Print the response for debugging
      print('Get Booking Response:');
      print(response);
      printJsonPretty(response.data);

      if (response.statusCode == 200) {
        // Return the response data if the request is successful
        return response.data;
      } else {
        // Handle errors
        throw Exception('Failed to get booking details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getBooking: $e');
      throw Exception('Error getting booking details: $e');
    }
  }



// ************************************* Air BLue


}


