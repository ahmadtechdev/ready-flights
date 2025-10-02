import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:xml2json/xml2json.dart';

class ApiServiceAirArabia {
  final Dio _dio = Dio();

  // Helper method to print full request details
  void printFullRequest(String methodName, String url, Map<String, dynamic> headers, Map<String, dynamic> data) {
    print("===============================================");
    print("$methodName - FULL REQUEST DETAILS");
    print("===============================================");
    print("URL: $url");
    print("Method: POST");
    print("Headers:");
    headers.forEach((key, value) {
      print("  $key: $value");
    });
    print("Request Body:");
    debugPrint(const JsonEncoder.withIndent('  ').convert(data), wrapWidth: 1024);
    print("===============================================");
  }
  Future<Map<String, dynamic>> searchFlights({
    required int type,
    required String origin,
    required String destination,
    required String depDate,
    required int adult,
    required int child,
    required int infant,
    required String cabin,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };

      final data = {
        "type": type.toString(),
        "origin": origin,
        "destination": destination,
        "depDate": depDate,
        "adult": adult.toString(),
        "child": child.toString(),
        "infant": infant.toString(),
        "stop": "0", // Air Arabia doesn't support stop filter
        "cabin": cabin,
      };

      print("AirArabia Request *********************");
      print(data);
      final response = await _dio.request(
        'https://onerooftravel.net/api/new-air-arabia-flights',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      // printDebugData('Air Arabia Response', response);
      print("*************** Response Arabia*********");
      print(response);
      if (response.statusCode == 200) {
        // Ensure the response is parsed as Map
        if (response.data is String) {
          return jsonDecode(response.data) as Map<String, dynamic>;
        }
        print("*************** Response Arabia*********");
        print(response);
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load Air Arabia flights: ${response.statusMessage}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFlightPackages({
    required int type,
    required int adult,
    required int child,
    required int infant,
    required List<Map<String, dynamic>> sector,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Cookie': 'PHPSESSID=f6e1vveq1sr0h15f4t4k31u4f6'
      };

      final data = {
        "type": type,
        "adult": adult,
        "child": child,
        "infant": infant,
        "sector": sector,
      };

      // Print full request details
      printFullRequest(
        "GET FLIGHT PACKAGES", 
        'https://onerooftravel.net/api/get-air-arabia-package',
        headers,
        data
      );

      print("AirArabia Packages Request *********************");
      print("Request URL: https://onerooftravel.net/api/get-air-arabia-package");
      print("Request Headers:");
      headers.forEach((key, value) {
        print("  $key: $value");
      });
      print("Request Payload:");
      debugPrint(jsonEncode(data), wrapWidth: 1024);
      print("***************************************************");

      final response = await _dio.request(
        'https://onerooftravel.net/api/get-air-arabia-package',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      print("*************** AirArabia Packages Response *********");
      print("Response Status Code: ${response.statusCode}");
      print("Response Headers:");
      response.headers.forEach((key, value) {
        print("  $key: $value");
      });
      print("Response Body:");
      debugPrint(jsonEncode(response.data), wrapWidth: 1024);
      print("****************************************************");

      if (response.statusCode == 200) {
        // Ensure the response is parsed as Map
        if (response.data is String) {
          return jsonDecode(response.data) as Map<String, dynamic>;
        }
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load Air Arabia packages: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error getting Air Arabia packages: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> revalidateAirArabiaPackage({
    required int type,
    required int adult,
    required int child,
    required int infant,
    required List<Map<String, dynamic>> sector,
    required Map<String, dynamic> fare,
    required int csId,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Cookie': 'PHPSESSID=u1gagb79trmq6famf6dbsnt7a6'
      };

      final data = {
        "type": type,
        "adult": adult,
        "child": child,
        "infant": infant,
        "sector": sector,
        "fare": fare,
        // "cs_id": csId,
      };

      // Print full request details
      printFullRequest(
        "REVALIDATE PACKAGE", 
        'https://onerooftravel.net/api/air-arabia-package-revalidate',
        headers,
        data
      );

      print("AirArabia Package Revalidation Request *********************");
      print("Request URL: https://onerooftravel.net/api/air-arabia-package-revalidate");
      print("Request Headers:");
      headers.forEach((key, value) {
        print("  $key: $value");
      });
      print("Request Payload:");
      debugPrint(jsonEncode(data), wrapWidth: 1024);
      print("*************************************************************");

      final response = await _dio.request(
        'https://onerooftravel.net/api/air-arabia-package-revalidate',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      print("*************** AirArabia Package Revalidation Response *********");
      print("Response Status Code: ${response.statusCode}");
      print("Response Headers:");
      response.headers.forEach((key, value) {
        print("  $key: $value");
      });
      print("Response Body:");
      debugPrint(jsonEncode(response.data), wrapWidth: 1024);
      print("***************************************************************");

      if (response.statusCode == 200) {
        print("*************** AirArabia Package Revalidation Response *********");
        print(jsonEncode(response.data));
        if (response.data is String) {
          return jsonDecode(response.data) as Map<String, dynamic>;
        }
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to revalidate Air Arabia package: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error revalidating Air Arabia package: $e');
      rethrow;
    }
  }

// Updated createAirArabiaBooking method in ApiServiceAirArabia class
// Updated createAirArabiaBooking method parameters in ApiServiceAirArabia class
Future<Map<String, dynamic>> createAirArabiaBooking({
  required String email,
  required String finalKey,
  required String echoToken,
  required String transactionIdentifier,
  required String jsession,
  required int adults,
  required int child,
  required int infant,
  required List<int> stopsSector,
  required String bkIdArray,
  required String bkIdArray3,
  required List<List<String>> adultBaggage,           // CORRECTED TYPE: 2D array
  required List<List<List<String>>> adultMeal,        // CORRECTED TYPE: 3D array  
  required List<List<List<String>>> adultSeat,        // CORRECTED TYPE: 3D array
  required List<dynamic> childBaggage,
  required List<dynamic> childMeal,
  required List<dynamic> childSeat,
  required String bookerName,
  required String countryCode,
  required String simCode,
  required String city,
  required String address,
  required String phone,
  required String remarks,
  required double marginPer,
  required double marginVal,
  required double finalPrice,
  required double totalPrice,
  required String flightType,
  required int csId,
  required String csName,
  required List<Map<String, dynamic>> adultPassengers,
  required List<Map<String, dynamic>> childPassengers,
  required List<Map<String, dynamic>> infantPassengers,
  required List<Map<String, dynamic>> flightDetails,
}) async {
  try {
    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'PHPSESSID=trfun4hl59lq621fvrhus9oti5'
    };

    final data = {
      "email": email,
      "final_key": finalKey,
      "EchoToken": echoToken,
      "TransactionIdentifier": transactionIdentifier,
      "jsession": jsession,
      "adults": adults,
      "child": child,
      "infant": infant,
      "stops_sector": stopsSector,
      "bk_id_array": bkIdArray,
      "bk_id_array3": bkIdArray3,
      "adult_baggage": adultBaggage,    // Now correctly 2D array
      "adult_meal": adultMeal,          // Now correctly 3D array
      "adult_seat": adultSeat,          // Now correctly 3D array
      "child_baggage": childBaggage,
      "child_meal": childMeal,
      "child_seat": childSeat,
      "booker_name": bookerName,
      "country_code": countryCode,
      "sim_code": simCode,
      "city": city,
      "address": address,
      "phone": phone,
      "remarks": remarks,
      "margin_per": marginPer,
      "margin_val": marginVal,
      "final_price": finalPrice,
      "total_price": totalPrice,
      "flight_type": flightType,
      "cs_id": csId,
      "cs_name": csName,
      "adult_passengers": adultPassengers,
      "child_passengers": childPassengers,
      "infant_passengers": infantPassengers,
      "flight_details": flightDetails,
    };

    print("AirArabia Booking Request *********************");
    debugPrint(jsonEncode(data), wrapWidth: 1024);

    final response = await _dio.request(
      'https://onerooftravel.net/api/air-arabia-create-booking',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    print("******** AirArabia Booking Response ********");
    debugPrint(jsonEncode(response.data), wrapWidth: 1024);

    if (response.statusCode == 200) {
      if (response.data is String) {
        return jsonDecode(response.data) as Map<String, dynamic>;
      }
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create Air Arabia booking: ${response.statusMessage}');
    }
  } catch (e) {
    print('Error creating Air Arabia booking: $e');
    rethrow;
  }
}

Map<String, dynamic> _convertXmlToJson(String xmlString) {
    try {
      final transformer = Xml2Json();
      transformer.parse(xmlString);
      final jsonString = transformer.toGData();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // print('Error converting XML to JSON: $e');
      return {'error': 'Failed to parse XML response'};
    }
  }

  void printDebugData(String label, dynamic data) {
    // print('--- DEBUG: $label ---');

    if (data is String && data.trim().startsWith('<')) {
      // Handle XML string
      // print('Raw XML:\n$data');

      try {
        // Convert XML to JSON
        final jsonData = _convertXmlToJson(data);
        printJsonPretty(jsonData);
      } catch (e) {
        if (kDebugMode) {
          print('Error converting XML to JSON: $e');
        }
      }
    } else if (data is String) {
      // Plain string
      // print('Plain String:\n$data');
    } else {
      // JSON/Map or other object
      printJsonPretty(data);
    }

    // print('--- END DEBUG: $label ---\n');
  }

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
}