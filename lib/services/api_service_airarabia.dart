import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:xml2json/xml2json.dart';

import '../views/flight/search_flights/airarabia/airarabia_flight_model.dart';

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



      final response = await _dio.request(
        'https://onerooftravel.net/api/model_controllers/air-arabia-flights',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        // Ensure the response is parsed as Map
        if (response.data is String) {
          return jsonDecode(response.data) as Map<String, dynamic>;
        }
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load Air Arabia flights: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error in Air Arabia API: $e');
      rethrow;
    }
  }

  // New method for Air Arabia fare prices
  Future getAirArabiaFare({
    required AirArabiaFlight sectorType, // flight array
    required int adult,
    required int child,
    required int infant,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };

      print("check");
      print(sectorType.json);

      final data = {
        "sector_type": sectorType.json,
        "adult": adult,
        "child": child,
        "infant": infant,
        "type": 0, // Always 0 as per requirements
      };

      // Print request data
      print('=== AIR ARABIA FARE API REQUEST ===');
      print('URL: https://onerooftravel.net/api/fare/air-araibia-fare');
      print('Method: GET');
      print('Headers: $headers');
      print('Request Data:');
      print(data);
      print('=====================================');

      final response = await _dio.request(
        'https://onerooftravel.net/api/fare/air-araibia-fare',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      // Print response data
      print('=== AIR ARABIA FARE API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data:');
      printDebugData('Air Arabia Fare Response', response.data);
      print('====================================');

      if (response.statusCode == 200) {
        print(response.data);
        // Ensure the response is parsed as Map
        if (response.data is String) {
          return response.data ;
        }
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load Air Arabia fare: ${response.statusMessage}');
      }
    } catch (e) {
      print('=== AIR ARABIA FARE API ERROR ===');
      print('Error: $e');
      print('=================================');
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
    // final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    for (int i = 0; i < jsonData.length; i += chunkSize) {
      final chunk = jsonData.substring(
        i,
        i + chunkSize < jsonData.length ? i + chunkSize : jsonData.length,
      );
      if (kDebugMode) {
        print(chunk);
      }
    }
  }

}