import 'package:get/get.dart';

import '../../../hotel/hotel_date_controller.dart';

class SelectRoomController extends GetxController {
  var totalPrice = 0.0.obs;

  // Store prebook API response
  final Rx<Map<String, dynamic>> prebookResponse = Rx<Map<String, dynamic>>({});

  // Observable lists to store policy details for each room
  final RxList<List<Map<String, dynamic>>> roomsPolicyDetails =
      RxList<List<Map<String, dynamic>>>([]);

  // Observable maps to store room details
  final RxMap<int, String> roomNames = RxMap<int, String>({});
  final RxMap<int, String> roomMeals = RxMap<int, String>({});
  final RxMap<int, String> roomRateTypes = RxMap<int, String>({});
  final RxMap<int, double> roomPrices = RxMap<int, double>({});

  // Method to store prebook response data
  void storePrebookResponse(Map<String, dynamic> response) {
    prebookResponse.value = response;

    // Extract and store room details
    if (response['hotel']?['rooms']?['room'] != null) {
      final rooms = response['hotel']['rooms']['room'] as List;

      roomsPolicyDetails.clear();
      roomNames.clear();
      roomMeals.clear();
      roomRateTypes.clear();
      // Don't clear roomPrices here as they might be set separately

      for (var i = 0; i < rooms.length; i++) {
        final room = rooms[i];

        // Store room name, meal and rate type
        roomNames[i] = room['roomName'] ?? '';
        roomMeals[i] = room['meal'] ?? '';
        roomRateTypes[i] = room['rateType'] ?? '';

        // Extract policy details
        if (room['policies']?['policy'] != null) {
          List<Map<String, dynamic>> policyDetails = [];

          for (var policy in room['policies']['policy']) {
            if (policy['condition'] != null) {
              for (var condition in policy['condition']) {
                policyDetails.add({
                  "from_date": condition['fromDate'] ?? '',
                  "to_date": condition['toDate'] ?? '',
                  "timezone": condition['timezone'] ?? '',
                  "from_time": condition['fromTime'] ?? '',
                  "to_time": condition['toTime'] ?? '',
                  "percentage": condition['percentage'] ?? '',
                  "nights": condition['nights'] ?? '',
                  "fixed": condition['fixed'] ?? '',
                  "applicableOn": condition['applicableOn'] ?? '',
                });
              }
            }
          }

          if (roomsPolicyDetails.length <= i) {
            roomsPolicyDetails.add(policyDetails);
          } else {
            roomsPolicyDetails[i] = policyDetails;
          }
        }

        // If price is available in the response, update it
        if (room['price'] != null && room['price']['net'] != null) {
          double roomPrice = 0.0;
          try {
            roomPrice = double.parse(room['price']['net'].toString());
          } catch (e) {
            print('Error parsing room price: $e');
          }
          updateRoomPrice(i, roomPrice);
        }
      }
    }

    // Recalculate total price after update
    calculateTotalPrice();
  }

  // Method to update the price for a specific room
  void updateRoomPrice(int roomIndex, double price) {
    roomPrices[roomIndex] = price;
    calculateTotalPrice();
  }

  // Method to calculate the total price of all selected rooms
  void calculateTotalPrice() {
    double total = 0.0;
    roomPrices.forEach((key, value) {
      total += value;
    });
    totalPrice.value = total;
  }

  // Method to update room data when a room is selected
  void updateSelectedRoom(int roomIndex, dynamic roomData) {
    // Update room details
    roomNames[roomIndex] = roomData['roomName'] ?? '';
    roomMeals[roomIndex] = roomData['meal'] ?? '';
    roomRateTypes[roomIndex] = roomData['rateType'] ?? '';

    // Update room price
    double roomPrice = 0.0;
    if (roomData['price'] != null && roomData['price']['net'] != null) {
      try {
        roomPrice = double.parse(roomData['price']['net'].toString());
      } catch (e) {
        print('Error parsing room price: $e');
      }
    }

    // Get the number of nights from the controller or parameter
    int nights = Get.find<HotelDateController>().nights.value;

    // Multiply price by nights to get total price for this room
    roomPrice *= nights;

    // Update the room price and recalculate total
    updateRoomPrice(roomIndex, roomPrice);
  }

  // Method to get policy details for a specific room
  List<Map<String, dynamic>> getPolicyDetailsForRoom(int roomIndex) {
    if (roomIndex < roomsPolicyDetails.length) {
      return roomsPolicyDetails[roomIndex];
    }
    return [];
  }

  // Method to get room name for a specific room
  String getRoomName(int roomIndex) {
    return roomNames[roomIndex] ?? '';
  }

  // Method to get meal plan for a specific room
  String getRoomMeal(int roomIndex) {
    return roomMeals[roomIndex] ?? '';
  }

  // Method to get rate type for a specific room
  String getRateType(int roomIndex) {
    return roomRateTypes[roomIndex] ?? '';
  }

  // Method to get price for a specific room
  double getRoomPrice(int roomIndex) {
    return roomPrices[roomIndex] ?? 0.0;
  }

  // Method to clear all stored data
  void clearData() {
    prebookResponse.value = {};
    roomsPolicyDetails.clear();
    roomNames.clear();
    roomMeals.clear();
    roomRateTypes.clear();
    roomPrices.clear();
    totalPrice.value = 0.0;
  }
}
