// import 'package:dio/dio.dart';
// import 'package:get/get.dart';
//
// class MarginServiceFlight extends GetxService {
//   late final Dio dio;
//
//   static const String _marginApiBaseUrl = 'https://agent1.pk/group_api';
//   static const String _marginUserId = 'Group-121';
//   static const String _marginUsername = 'travelocity';
//
// // Add these methods to the ApiServiceFlight class
//   Future<String> _generateMarginToken() async {
//     try {
//       print("tok");
//       final response = await dio.post(
//         '$_marginApiBaseUrl/generate_token.php',
//         options: Options(
//           headers: {
//             'Userid': _marginUserId,
//             'Username': _marginUsername,
//             'Content-Type': 'application/json',
//           },
//         ),
//         data: {
//           "req_type": "get_margin",
//         },
//       );
//       print("tok repsonse");
//       print(response.data);
//       if (response.statusCode == 200 && response.data['token'] != null) {
//         return response.data['token'];
//       } else {
//         throw Exception('Failed to generate margin token');
//       }
//     } catch (e) {
//       throw Exception('Error generating margin token: $e');
//     }
//   }
//
//   Future<Map<String, dynamic>> getMargin() async {
//     try {
//       print("mag chec");
//
//       final token = await _generateMarginToken();
//
//       print("mag check");
//       print(token);
//
//       final response = await dio.post(
//         '$_marginApiBaseUrl/sastay_restapi.php',
//         options: Options(
//           headers: {
//             'Userid': _marginUserId,
//             'Username': _marginUsername,
//             'Authorization': token,
//             'Content-Type': 'application/json',
//           },
//         ),
//         data: {
//           "req_type": "get_margin",
//           "keyword": "karac", // This seems to be required based on your example
//         },
//       );
//
//       print("mag response");
//       print(response.data);
//
//       if (response.statusCode == 200) {
//         return response.data['response'] ?? {};
//       } else {
//         throw Exception('Failed to get margin: ${response.statusMessage}');
//       }
//     } catch (e) {
//       throw Exception('Error getting margin: $e');
//     }
//   }
//
//   double calculatePriceWithMargin(double basePrice, Map<String, dynamic> marginData) {
//     final marginVal = marginData['margin_val'];
//     final marginPer = marginData['margin_per'];
//
//     if (marginVal != null && marginVal != 'N/A') {
//       // Fixed margin value
//       return basePrice + double.parse(marginVal);
//     } else if (marginPer != null && marginPer != 'N/A') {
//       // Percentage margin
//       final percentage = double.parse(marginPer);
//       return basePrice * (1 + (percentage / 100));
//     }
//
//     // If no margin data is available, return the base price
//     return basePrice;
//   }
//
//
//
// }