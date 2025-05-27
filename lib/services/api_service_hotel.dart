import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../views/hotel/hotel/guests/guests_controller.dart';
import '../views/hotel/search_hotels/booking_hotel/booking_controller.dart';
import '../views/hotel/search_hotels/search_hotel_controller.dart';

class ApiServiceHotel extends GetxService {
  late final Dio dio;
  static const String _apiKey = 'VyBZUyOkbCSNvvDEMOV2==';
  static const String _baseUrl = 'http://uat-apiv2.giinfotech.ae/api/v2';
  ApiServiceHotel() {
    dio = Dio(BaseOptions(baseUrl: _baseUrl));
    if (!Get.isRegistered<SearchHotelController>()) {
      Get.put(SearchHotelController());
    }
  }

  /// Helper: Sets default headers for API requests.
  Options _defaultHeaders() {
    return Options(
      headers: {
        'apikey': _apiKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }

  /// Helper: Formats date strings to 'yyyy-MM-dd'.
  String _formatDate(String isoDate) {
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(isoDate));
    } catch (e) {
      print('Date formatting error: $e');
      return isoDate; // Fallback to the original format if parsing fails.
    }
  }

  Future<List<dynamic>> fetchCities(String cityKeyword) async {
    var headers = {'Cookie': 'PHPSESSID=n2sduu2sfi2p57nhr9h8fc74p0'};

    var dio = Dio();
    try {
      var response = await dio.request(
        'https://readyflights.pk/api/getDestination.php?keyword=$cityKeyword',
        options: Options(method: 'GET', headers: headers),
      );

      if (response.statusCode == 200) {
        // Print raw response data type for debugging
        print('Response data type: ${response.data.runtimeType}');
        print('Raw response: ${response.data}');

        // Handle string response that needs to be parsed as JSON
        if (response.data is String) {
          try {
            var decodedData = json.decode(response.data);
            if (decodedData is Map &&
                decodedData['status'] == 200 &&
                decodedData['data'] != null) {
              return decodedData['data'] as List;
            } else if (decodedData is List) {
              return decodedData;
            } else {
              print('Unexpected JSON structure: $decodedData');
              return [];
            }
          } catch (e) {
            print('JSON parsing error: $e');
            return [];
          }
        }
        // Handle Map response structure
        else if (response.data is Map) {
          if (response.data['status'] == 200 && response.data['data'] != null) {
            return response.data['data'] as List;
          } else {
            print('Unexpected Map structure: ${response.data}');
            return [];
          }
        }
        // Handle direct List response
        else if (response.data is List) {
          return response.data as List;
        }
        // Fallback for unexpected response types
        else {
          print('Unexpected response type: ${response.data.runtimeType}');
          return [];
        }
      } else {
        print('Error: ${response.statusMessage}');
        return [];
      }
    } catch (e) {
      print('Exception occurred in fetchCities: $e');
      return [];
    }
  } // Fetches hotels based on search parameters.

  Future<void> fetchHotels({
    required String destinationCode,
    required String countryCode,
    required String nationality,
    required String currency,
    required String checkInDate,
    required String checkOutDate,
    required List<Map<String, dynamic>> rooms,
  }) async {
    final searchController = Get.find<SearchHotelController>();

    final requestBody = {
      "SearchParameter": {
        "DestinationCode": destinationCode,
        "CountryCode": countryCode,
        "Nationality": nationality,
        "Currency": currency,
        "CheckInDate": _formatDate(checkInDate),
        "CheckOutDate": _formatDate(checkOutDate),
        "Rooms": {
          "Room":
              rooms
                  .map(
                    (room) => {
                      "RoomIdentifier": room["RoomIdentifier"],
                      "Adult": room["Adult"],
                    },
                  )
                  .toList(),
        },
        "TassProInfo": {"CustomerCode": "4805", "RegionID": "123"},
      },
    };

    print('Fetching Hotels with Request: ${json.encode(requestBody)}');
    try {
      final response = await dio.post(
        '/hotel/Search',
        data: requestBody,
        options: _defaultHeaders(),
      );

      if (response.statusCode == 200) {
        print("hotel reponse :${response.data}");
        final data = response.data;
        final hotels = data['hotels']?['hotel'] ?? [];
        final sessionId = data['generalInfo']?['sessionId'];
        final destinationCode = data['audit']?['destination']['code'];

        searchController.sessionId.value = sessionId ?? '';
        searchController.destinationCode.value = destinationCode ?? '';
        searchController.hotels.value =
            hotels.map<Map<String, dynamic>>((hotel) {
              return {
                'name': hotel['name'] ?? 'Unknown Hotel',
                'price': hotel['minPrice']?.toString() ?? '0',
                'address':
                    hotel['hotelInfo']?['add1'] ?? 'Address not available',
                'image':
                    hotel['hotelInfo']?['image'] ??
                    'assets/img/cardbg/broken-image.png',
                'rating':
                    double.tryParse(
                      hotel['hotelInfo']?['starRating']?.toString() ?? '0',
                    ) ??
                    3.0,
                'latitude': hotel['hotelInfo']?['lat'] ?? 0.0,
                'longitude': hotel['hotelInfo']?['lon'] ?? 0.0,
                'hotelCode': hotel['code'] ?? '',
                'hotelCity': hotel['hotelInfo']?['city'] ?? '',
              };
            }).toList();

        print('Successfully updated hotel data');
      } else {
        print('API Error: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error Fetching Hotels: $e');
    }
  }

  /// Fetch room details.
  Future<void> fetchRoomDetails(String hotelCode, String sessionId) async {
    final guestsController = Get.find<GuestsController>();

    List<Map<String, dynamic>> rooms =
        guestsController.rooms.asMap().entries.map((entry) {
          final index = entry.key;
          final room = entry.value;
          return {
            "RoomIdentifier": index + 1,
            "Adult": room.adults.value,
            if (room.children.value > 0) "child": room.children.value,
          };
        }).toList();

    final requestBody = {
      "SessionId": sessionId,
      "SearchParameter": {
        "HotelCode": hotelCode,
        "Currency": "AED",
        "Rooms": {"Room": rooms},
      },
    };

    print('Fetching Room Details with Request: $requestBody');
    try {
      final response = await dio.post(
        '/hotel/RoomDetails',
        data: requestBody,
        options: _defaultHeaders(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final hotelInfo = data['hotel']?['hotelInfo'];
        final roomData = data['hotel']['rooms']?['room'];
        print(roomData);

        if (hotelInfo != null) {
          final searchController = Get.find<SearchHotelController>();
          searchController.hotelName.value = hotelInfo['name'];
          searchController.image.value = hotelInfo['image'];
          searchController.roomsdata.value = roomData;
          print('Successfully updated room data');
        } else {
          print('No room information available');
        }
      } else {
        print('API Error: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error Fetching Room Details: $e');
    }
  }

  /// Pre-book a room.
  Future<Map<String, dynamic>?> prebook({
    required String sessionId,
    required String hotelCode,
    required int groupCode,
    required String currency,
    required List<String> rateKeys,
  }) async {
    final requestBody = {
      "SessionId": sessionId,
      "SearchParameter": {
        "HotelCode": hotelCode,
        "GroupCode": groupCode,
        "Currency": currency,
        "RateKeys": {"RateKey": rateKeys},
      },
    };

    print('Prebooking with Request: ${json.encode(requestBody)}');
    try {
      final response = await dio.post(
        '/hotel/PreBook',
        data: requestBody,
        options: _defaultHeaders(),
      );

      if (response.statusCode == 200) {
        print('Prebook Successful: ${response.data}');

        // Extract and print the condition list
        final data = response.data as Map<String, dynamic>;
        final hotel = data['hotel'] as Map<String, dynamic>?;
        if (hotel != null) {
          final rooms = hotel['rooms'] as Map<String, dynamic>?;
          if (rooms != null) {
            final roomList = rooms['room'] as List<dynamic>?;
            if (roomList != null && roomList.isNotEmpty) {
              for (int i = 0; i < roomList.length; i++) {
                final room = roomList[i] as Map<String, dynamic>;
                final policies = room['policies'] as Map<String, dynamic>?;
                if (policies != null) {
                  final policyList = policies['policy'] as List<dynamic>?;
                  if (policyList != null) {
                    for (int j = 0; j < policyList.length; j++) {
                      final policy = policyList[j] as Map<String, dynamic>;
                      final conditions = policy['condition'] as List<dynamic>?;
                      if (conditions != null) {
                        print(
                          'Room ${i + 1} Policy ${j + 1} Conditions: $conditions',
                        );
                      }
                    }
                  }
                }
              }
            }
          }
        }

        return data;
      } else {
        print('Prebook Failed: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error in Prebooking: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getCancellationPolicy({
    required String sessionId,
    required String hotelCode,
    required int groupCode,
    required String currency,
    required List<String> rateKeys,
  }) async {
    final requestBody = {
      "SessionId": sessionId,
      "SearchParameter": {
        "HotelCode": hotelCode,
        "GroupCode": groupCode,
        "Currency": currency,
        "RateKeys": {"RateKey": rateKeys},
      },
    };

    print(
      'Fetching Cancellation Policy with Request: ${json.encode(requestBody)}',
    );
    try {
      final response = await dio.post(
        '/hotel/CancellationPolicy',
        data: requestBody,
        options: _defaultHeaders(),
      );

      if (response.statusCode == 200) {
        print('Cancellation Policy Response: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        print('Cancellation Policy Failed: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error fetching cancellation policy: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getPriceBreakup({
    required String sessionId,
    required String hotelCode,
    required int groupCode,
    required String currency,
    required List<String> rateKeys,
  }) async {
    final requestBody = {
      "SessionId": sessionId,
      "SearchParameter": {
        "HotelCode": hotelCode,
        "GroupCode": groupCode,
        "Currency": currency,
        "RateKeys": {"RateKey": rateKeys},
      },
    };

    print('Fetching Price Breakup with Request: ${json.encode(requestBody)}');
    try {
      final response = await dio.post(
        '/hotel/PriceBreakup',
        data: requestBody,
        options: _defaultHeaders(),
      );

      if (response.statusCode == 200) {
        print('Price Breakup Response: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        print('Price Breakup Failed: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error fetching price breakup: $e');
    }
    return null;
  }

  Future<bool> bookHotel(Map<String, dynamic> requestBody) async {
    final BookingController bookingcontroller = Get.put(BookingController());

    // Update to HTTPS if supported, or keep HTTP if that's what the server requires
    const String bookingEndpoint =
        'https://onerooftravel.net/mobile_thankyou.php';

    try {
      // Log the request for debugging
      print('\n=== SENDING BOOKING REQUEST ===');
      print('Endpoint: $bookingEndpoint');
      print('Request Body: ${json.encode(requestBody)}');

      final response = await dio.post(
        bookingEndpoint,
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) {
            return status! < 500;
          },
          // Enable following redirects
          followRedirects: true,
          // Maximum number of redirects to follow
          maxRedirects: 5,
        ),
      );

      // Log the response
      print('\n=== BOOKING RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.data != null) {
          // Extract and store booking number
          if (response.data is Map && response.data['BookingNO'] != null) {
            String bookingStr = response.data['BookingNO'].toString();
            bookingStr = bookingStr.replaceAll('SHBK-', '');
            bookingcontroller.booking_num.value = int.tryParse(bookingStr) ?? 0;
            print(
              'Booking number stored: ${bookingcontroller.booking_num.value}',
            );
          }

          if (response.data is Map) {
            if (response.data['status'] == 'success' ||
                response.data['Success'] == 1 ||
                response.data['success'] == true ||
                response.data['code'] == 200) {
              return true;
            }
          } else if (response.data.toString().toLowerCase().contains(
            'success',
          )) {
            return true;
          }
        }
        return true; // Return true if we get 200 but can't determine more specific success
      } else {
        print('Booking failed with status: ${response.statusCode}');
        print('Error message: ${response.statusMessage}');
        return false;
      }
    } on DioException catch (e) {
      print('\n=== BOOKING ERROR ===');
      print('DioError Type: ${e.type}');
      print('Error Message: ${e.message}');
      if (e.response != null) {
        print('Error Response: ${e.response?.data}');
        print('Error Status Code: ${e.response?.statusCode}');
      }
      return false;
    } catch (e) {
      print('\n=== UNEXPECTED ERROR ===');
      print('Error: $e');
      return false;
    }
  }
}
