import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

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
        'https://onerooftravel.net/api/search/air-arabia-flights',
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
}