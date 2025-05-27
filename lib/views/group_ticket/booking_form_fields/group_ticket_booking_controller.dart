import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/api_service_group_tickets.dart';
import '../../../utility/colors.dart';
import '../flight_pkg/pkg_model.dart';
import 'model.dart';

class GroupTicketBookingController extends GetxController {
  final Rx<BookingData> bookingData =
      BookingData(
        groupId: 0,
        groupName: '',
        sector: '',
        availableSeats: 1,
        adults: 1,
        children: 0,
        infants: 0,
        adultPrice: 0,
        childPrice: 0,
        infantPrice: 0,
        groupPriceDetailId: 0,
      ).obs;

  final GroupTicketingController apiController = Get.put(
    GroupTicketingController(),
  );
  final formKey = GlobalKey<FormState>();
  final RxBool isFormValid = false.obs;

  List<String> adultTitles = ['Mr', 'Mrs', 'Ms'];
  List<String> childTitles = ['Mstr', 'Miss'];
  List<String> infantTitles = ['INF'];

  /// Initializes booking data from flight model
  void initializeFromFlight(GroupFlightModel flight, int groupId) async {
    print("check 2");
    print(groupId);
    bookingData.update((val) {
      if (val == null) return;

      val.groupId = groupId;
      val.groupName =
          '${flight.airline}-${flight.origin}-${flight.destination}';
      val.sector = '${flight.origin}-${flight.destination}';
      val.adultPrice = flight.price.toDouble();
      val.childPrice = flight.price.toDouble();
      val.infantPrice = flight.price.toDouble();
      val.groupPriceDetailId = flight.groupPriceDetailId;
      val.availableSeats = flight.seats;
    });
    //
    // // Then fetch and update available seats
    // await fetchAndUpdateAvailableSeats(groupId);
  }

  // Future<void> fetchAndUpdateAvailableSeats(int groupId) async {
  //   print("check 3");
  //   print(groupId);
  //   try {
  //     final availableSeats = await apiController.fetchAvailableSeats(groupId);
  //     bookingData.update((val) {
  //       if (val != null) {
  //         val.availableSeats = availableSeats;
  //       }
  //     });
  //   } catch (e) {
  //     showErrorSnackbar('Failed to fetch available seats');
  //     bookingData.update((val) {
  //       if (val != null) {
  //         val.availableSeats = 0; // Set to 0 if there's an error
  //       }
  //     });
  //   }
  // }

  /// Validates the form and updates isFormValid
  void validateForm() {
    isFormValid.value = formKey.currentState?.validate() ?? false;
  }

  /// Submits the booking to the API
  Future<void> submitBooking() async {
    if (!isFormValid.value) {
      showErrorSnackbar('Please fill in all required fields correctly.');
      return;
    }

    try {
      final passengers =
          bookingData.value.passengers
              .map(
                (passenger) => {
                  'firstName': passenger.firstName,
                  'lastName': passenger.lastName,
                  'title': passenger.title,
                  'passportNumber': passenger.passportNumber,
                  'dateOfBirth': passenger.dateOfBirth?.toIso8601String(),
                  'passportExpiry': passenger.passportExpiry?.toIso8601String(),
                },
              )
              .toList();

      final result = await apiController.saveBooking(
        groupId: bookingData.value.groupId,
        agentName: 'Oneroof Travels',
        agencyName: 'Oneroof Travels',
        email: 'usama@travelnetwork.com',
        mobile: '+923137358881',
        adults: bookingData.value.adults,
        children:
            bookingData.value.children > 0 ? bookingData.value.children : null,
        infants:
            bookingData.value.infants > 0 ? bookingData.value.infants : null,
        passengers: passengers,
        groupPriceDetailId: bookingData.value.groupPriceDetailId,
      );

      if (result['success'] == true) {
        showSuccessSnackbar(result['message']);
        // Navigate to success screen
        // Get.to(() => BookingSuccessScreen());
      } else {
        showErrorSnackbar(result['message']);
      }
    } catch (e) {
      showErrorSnackbar('An error occurred while processing your booking');
    }
  }

  // Passenger count management
  // ========================

  void incrementAdults() {
    if (bookingData.value.totalPassengers < bookingData.value.availableSeats) {
      var updatedData = BookingData(
        groupId: bookingData.value.groupId,
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults + 1,
        children: bookingData.value.children,
        infants: bookingData.value.infants,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
        groupPriceDetailId: bookingData.value.groupId,
      );
      bookingData.value = updatedData;
    } else {
      Get.snackbar(
        'Error',
        'Cannot add more passengers. Available seats limit reached.',
        backgroundColor: TColors.red.withOpacity(0.1),
        colorText: TColors.red,
      );
    }
  }

  void decrementAdults() {
    if (bookingData.value.adults > 1) {
      // At least one adult required
      var updatedData = BookingData(
        groupId: bookingData.value.groupId,
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults - 1,
        children: bookingData.value.children,
        infants: bookingData.value.infants,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
        groupPriceDetailId: bookingData.value.groupId,
      );
      bookingData.value = updatedData;
    }
  }

  void incrementChildren() {
    if (bookingData.value.totalPassengers < bookingData.value.availableSeats) {
      var updatedData = BookingData(
        groupId: bookingData.value.groupId,
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults,
        children: bookingData.value.children + 1,
        infants: bookingData.value.infants,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
        groupPriceDetailId: bookingData.value.groupId,
      );
      bookingData.value = updatedData;
    } else {
      Get.snackbar(
        'Error',
        'Cannot add more passengers. Available seats limit reached.',
        backgroundColor: TColors.red.withOpacity(0.1),
        colorText: TColors.red,
      );
    }
  }

  void decrementChildren() {
    if (bookingData.value.children > 0) {
      var updatedData = BookingData(
        groupId: bookingData.value.groupId,
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults,
        children: bookingData.value.children - 1,
        infants: bookingData.value.infants,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
        groupPriceDetailId: bookingData.value.groupId,
      );
      bookingData.value = updatedData;
    }
  }

  void incrementInfants() {
    if (bookingData.value.totalPassengers < bookingData.value.availableSeats) {
      var updatedData = BookingData(
        groupId: bookingData.value.groupId,
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults,
        children: bookingData.value.children,
        infants: bookingData.value.infants + 1,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
        groupPriceDetailId: bookingData.value.groupId,
      );
      bookingData.value = updatedData;
    } else {
      Get.snackbar(
        'Error',
        'Cannot add more passengers. Available seats limit reached.',
        backgroundColor: TColors.red.withOpacity(0.1),
        colorText: TColors.red,
      );
    }
  }

  void decrementInfants() {
    if (bookingData.value.infants > 0) {
      var updatedData = BookingData(
        groupId: bookingData.value.groupId,
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults,
        children: bookingData.value.children,
        infants: bookingData.value.infants - 1,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
        groupPriceDetailId: bookingData.value.groupId,
      );
      bookingData.value = updatedData;
    }
  }

  /// Updates passenger count for a given type (adult/child/infant)
  void updatePassengerCount(String type, {bool increment = true}) {
    if (increment && _isSeatLimitReached()) {
      _showSeatLimitError();
      return;
    }

    bookingData.update((val) {
      if (val == null) return;

      switch (type) {
        case 'adult':
          _updateAdultCount(val, increment);
          break;
        case 'child':
          _updateChildCount(val, increment);
          break;
        case 'infant':
          _updateInfantCount(val, increment);
          break;
      }
    });
  }

  bool _isSeatLimitReached() {
    return bookingData.value.totalPassengers >=
        bookingData.value.availableSeats;
  }

  void _updateAdultCount(BookingData val, bool increment) {
    if (increment) {
      val.adults++;
      val.passengers.add(Passenger(title: 'Mr'));
    } else if (val.adults > 1) {
      val.adults--;
      val.passengers.removeWhere((p) => adultTitles.contains(p.title));
    }
  }

  void _updateChildCount(BookingData val, bool increment) {
    if (increment) {
      val.children++;
      val.passengers.add(Passenger(title: 'Mstr'));
    } else if (val.children > 0) {
      val.children--;
      val.passengers.removeWhere((p) => childTitles.contains(p.title));
    }
  }

  void _updateInfantCount(BookingData val, bool increment) {
    if (increment) {
      val.infants++;
      val.passengers.add(Passenger(title: 'INF'));
    } else if (val.infants > 0) {
      val.infants--;
      val.passengers.removeWhere((p) => infantTitles.contains(p.title));
    }
  }

  // Individual increment/decrement methods (maintained for backward compatibility)
  // ============================================================================

  // void incrementAdults() => updatePassengerCount('adult', increment: true);
  // void decrementAdults() => updatePassengerCount('adult', increment: false);
  // void incrementChildren() => updatePassengerCount('child', increment: true);
  // void decrementChildren() => updatePassengerCount('child', increment: false);
  // void incrementInfants() => updatePassengerCount('infant', increment: true);
  // void decrementInfants() => updatePassengerCount('infant', increment: false);

  // Helper methods
  // =============

  void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: TColors.red.withOpacity(0.1),
      colorText: TColors.red,
    );
  }

  void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
    );
  }

  void _showSeatLimitError() {
    showErrorSnackbar(
      'Cannot add more passengers. Available seats limit reached.',
    );
  }
}
