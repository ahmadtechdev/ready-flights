// all_flight_booking_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ready_flights/b2b/all_flight_booking/model.dart';

import '../../views/users/login/login_api_service/login_api.dart';
import 'all_flight_booking.dart';


class AllFlightBookingController extends GetxController {
  // Get the auth controller instance
  final AuthController _authController = Get.find<AuthController>();

  // Date filter variables
  final Rx<DateTime> fromDate =
      DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  // Loading state
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Statistics
  final RxInt totalBookings = 0.obs;
  final RxInt confirmedBookings = 0.obs;
  final RxInt onHoldBookings = 0.obs;
  final RxInt cancelledBookings = 0.obs;
  final RxInt errorBookings = 0.obs;

  // Booking data
  final RxList<BookingModel> allBookings = <BookingModel>[].obs;
  final RxList<BookingModel> filteredBookings = <BookingModel>[].obs;

  // Search controller
  final TextEditingController searchController = TextEditingController();
  final RxString searchTerm = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Set initial date range (last 30 days)
    fromDate.value = DateTime.now().subtract(const Duration(days: 30));
    toDate.value = DateTime.now();

    // Load bookings
    loadBookings();

    // Add listener to search controller
    searchController.addListener(() {
      searchTerm.value = searchController.text;
      filterBookings();
    });
  }

  // Format date to API format (YYYY-MM-DD)
  String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Load bookings from API
  Future<void> loadBookings() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _authController.getFlightsBookings(
        fromDate: formatDateForApi(fromDate.value),
        toDate: formatDateForApi(toDate.value),
      );

      if (result['success'] == true) {
        // Parse bookings from API response
        final data = result['data']['data'] as List<dynamic>;
        allBookings.value =
            data.map((item) => BookingModel.fromJson(item)).toList();

        // Update statistics
        updateStats();

        // Apply filters
        filterBookings();
      } else {
        hasError.value = true;
        errorMessage.value = result['message'] ?? 'Failed to load bookings';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Update statistics based on the current bookings
  void updateStats() {
    int confirmed = 0;
    int onHold = 0;
    int cancelled = 0;
    int error = 0;

    for (var booking in allBookings) {
      switch (booking.flightStatus) {
        case '2':
          confirmed++;
          break;
        case '1':
          onHold++;
          break;
        case '3':
          cancelled++;
          break;
        case '0':
          error++;
          break;
      }
    }

    confirmedBookings.value = confirmed;
    onHoldBookings.value = onHold;
    cancelledBookings.value = cancelled;
    errorBookings.value = error;
    totalBookings.value = allBookings.length;
  }

  // Filter bookings based on date range and search term
  void filterBookings() {
    String term = searchTerm.value.toLowerCase();

    filteredBookings.value =
        allBookings.where((booking) {
          // Check if booking matches search term (if any)
          bool matchesSearch =
              term.isEmpty ||
              booking.bookingId.toLowerCase().contains(term) ||
              booking.pnr.toLowerCase().contains(term) ||
              booking.supplier.toLowerCase().contains(term) ||
              booking.passengerNames.toLowerCase().contains(term) ||
              booking.status.toLowerCase().contains(term);

          return matchesSearch;
        }).toList();
  }

  // Date picker for from date
  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != fromDate.value) {
      fromDate.value = picked;
      loadBookings(); // Reload data with new date range
    }
  }

  // Date picker for to date
  Future<void> selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != toDate.value) {
      toDate.value = picked;
      loadBookings(); // Reload data with new date range
    }
  }

  // View details of a booking
  void viewBookingDetails(BookingModel booking) {
    // Navigate to booking details screen
    Get.snackbar(
      'View Booking',
      'Viewing details for booking ${booking.bookingId}',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Implement navigation to booking details screen
  }

  // Print ticket - Updated to use the PDF generator
  void printTicket(BookingModel booking) {
    try {
      // Generate and print PDF for the booking
      FlightPdfGenerator.generateAndPrintPdf(booking);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate ticket: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Retry loading data after error
  void retryLoading() {
    loadBookings();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
