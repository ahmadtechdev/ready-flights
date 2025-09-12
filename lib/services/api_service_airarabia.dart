import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:xml2json/xml2json.dart';

class ApiServiceAirArabia {
  final Dio _dio = Dio();

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

      print("AirArabia Packages Request *********************");
      print(data);

      final response = await _dio.request(
        'https://onerooftravel.net/api/get-air-arabia-package',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      print("*************** AirArabia Packages Response *********");
      // print(response);

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

  /// Converts XML string to JSON (Map)


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
  // Add this method to your ApiServiceAirArabia class

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

    print("AirArabia Package Revalidation Request *********************");
    print(jsonEncode(data));

    final response = await _dio.request(
      'https://onerooftravel.net/api/air-arabia-package-revalidate',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    
print("*************** AirArabia Package Revalidation Response 1 *********");
    print(jsonEncode(response.data));
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
}