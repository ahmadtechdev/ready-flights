import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../views/users/login/login_api_service/login_api.dart';
import 'model.dart';


class AllGroupBookingController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final fromDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final toDate = DateTime.now().obs;
  final selectedGroupCategory = 'All'.obs;
  final selectedStatus = 'All'.obs;

  // Define dynamic group categories and status options
  final groupCategories =
      <String>['All', 'UAE', 'KSA', 'Oman', 'UK', 'UMRAH', 'Others'].obs;
  final statusOptions = <String>['All', 'CONFIRMED', 'CANCELLED', 'HOLD'].obs;

  final isLoading = false.obs;
  final bookings = <BookingModel>[].obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  void updateFromDate(DateTime date) {
    fromDate.value = date;
  }

  void updateToDate(DateTime date) {
    toDate.value = date;
  }

  void updateGroupCategory(String category) {
    selectedGroupCategory.value = category;
  }

  void updateStatus(String status) {
    selectedStatus.value = status;
  }

  Future<void> fetchBookings() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Format dates for API request (YYYY-MM-DD)
      final fromDateStr = DateFormat('yyyy-MM-dd').format(fromDate.value);
      final toDateStr = DateFormat('yyyy-MM-dd').format(toDate.value);

      // Call the API through AuthController
      final result = await _authController.getGroupBookings(
        fromDate: fromDateStr,
        toDate: toDateStr,
      );

      if (result['success'] == true && result['data'] != null) {
        final apiData = result['data'];
        parseBookingsFromApi(apiData);
      } else {
        hasError.value = true;
        errorMessage.value = result['message'] ?? 'Failed to fetch bookings';
        bookings.clear();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An error occurred: $e';
      bookings.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void parseBookingsFromApi(Map<String, dynamic> apiData) {
    bookings.clear();

    if (apiData['data'] != null && apiData['data'] is List) {
      final List bookingsList = apiData['data'] as List;
      // Set to track unique categories and statuses from API
      final Set<String> uniqueCategories = {'All'};
      final Set<String> uniqueStatuses = {'All'};

      for (var bookingData in bookingsList) {
        try {
          // Parse dates
          DateTime departureDate;
          DateTime createdAt;

          try {
            // Parse departure date (format: "Fri 04 Apr 2025")
            departureDate = DateFormat(
              'EEE dd MMM yyyy',
            ).parse(bookingData['departure_date']);
          } catch (e) {
            // Fallback to current date if parsing fails
            departureDate = DateTime.now();
          }

          try {
            // Parse created_at date (format: "Fri 28 Mar 2025 11:03")
            createdAt = DateFormat(
              'EEE dd MMM yyyy HH:mm',
            ).parse(bookingData['created_at']);
          } catch (e) {
            // Fallback to current date if parsing fails
            createdAt = DateTime.now();
          }

          // Parse passenger status
          final passengers = bookingData['passengers'] ?? {};
          final hold = passengers['hold'] ?? {};
          final confirmed = passengers['confirmed'] ?? {};
          final cancelled = passengers['cancelled'] ?? {};

          final passengerStatus = PassengerStatus(
            holdAdults: int.tryParse(hold['adults'] ?? '0') ?? 0,
            holdChild: int.tryParse(hold['childs'] ?? '0') ?? 0,

            holdInfant: int.tryParse(hold['infants'] ?? '0') ?? 0,
            holdTotal:
                (int.tryParse(hold['adults'] ?? '0') ?? 0) +
                (int.tryParse(hold['childs'] ?? '0') ?? 0) +
                (int.tryParse(hold['infants'] ?? '0') ?? 0),

            confirmAdults: int.tryParse(confirmed['adults'] ?? '0') ?? 0,
            confirmChild: int.tryParse(confirmed['childs'] ?? '0') ?? 0,
            confirmInfant: int.tryParse(confirmed['infants'] ?? '0') ?? 0,
            confirmTotal:
                (int.tryParse(confirmed['adults'] ?? '0') ?? 0) +
                (int.tryParse(confirmed['childs'] ?? '0') ?? 0) +
                (int.tryParse(confirmed['infants'] ?? '0') ?? 0),

            cancelledAdults: int.tryParse(cancelled['adults'] ?? '0') ?? 0,
            cancelledChild: int.tryParse(cancelled['childs'] ?? '0') ?? 0,
            cancelledInfant: int.tryParse(cancelled['infants'] ?? '0') ?? 0,
            cancelledTotal:
                (int.tryParse(cancelled['adults'] ?? '0') ?? 0) +
                (int.tryParse(cancelled['childs'] ?? '0') ?? 0) +
                (int.tryParse(cancelled['infants'] ?? '0') ?? 0),
          );

          // Determine country from group_name
          String country = 'Unknown';
          final groupName = (bookingData['group_cat'] ?? '').toUpperCase();

          if (groupName.contains('UAE')) {
            country = 'UAE';
          } else if (groupName.contains('KSA')) {
            country = 'KSA';
          } else if (groupName.contains('OMAN')) {
            country = 'Oman';
          } else if (groupName.contains('UK')) {
            country = 'UK';
          } else if (groupName.contains('UMRAH')) {
            country = 'UMRAH';
          }

          // Add category to unique categories set
          uniqueCategories.add(country);

          // Add status to unique statuses set
          final status = bookingData['status'] ?? 'UNKNOWN';
          uniqueStatuses.add(status.toUpperCase());

          // Create booking model
          final booking = BookingModel(
            id: int.tryParse(bookingData['booking_no'] ?? '0') ?? 0,
            pnr: 'PNR# ${bookingData['booking_no'] ?? ''}',
            bkf: 'BK# ${bookingData['booking_no'] ?? ''}',
            agt: 'AGT# ${apiData['agent_id'] ?? ''}',
            createdDate: createdAt,
            airline: bookingData['airline'] ?? '',
            route: bookingData['group_name'] ?? '',
            country: country,
            flightDate: departureDate,
            passengerStatus: passengerStatus,
            price:
                double.tryParse(
                  bookingData['total_price']?.toString() ?? '0',
                ) ??
                0,
            status: status,
          );

          bookings.add(booking);
        } catch (e) {
          print('Error parsing booking: $e');
        }
      }

      // Update group categories based on API data
      final baseCategories = ['All', 'UAE', 'KSA', 'Oman', 'UK', 'UMRAH'];
      final apiCategories = uniqueCategories.toList();

      // Make sure we always have our base categories first, then Others if needed
      final newCategories = baseCategories.toList();
      if (apiCategories.any((cat) => !baseCategories.contains(cat))) {
        newCategories.add('Others');
      }

      // Only update group categories if there's a change to avoid UI flicker
      if (!listEquals(groupCategories, newCategories)) {
        groupCategories.value = newCategories;
      }

      // Update status options based on API data
      final baseStatuses = ['All', 'CONFIRMED', 'CANCELLED', 'HOLD'];
      final apiStatuses =
          uniqueStatuses
              .toList()
              .map((status) => status.toUpperCase())
              .toList();

      final newStatuses = [...baseStatuses];
      for (var status in apiStatuses) {
        if (!baseStatuses.contains(status) && status != 'ALL') {
          newStatuses.add(status);
        }
      }

      // Only update status options if there's a change
      if (!listEquals(statusOptions, newStatuses)) {
        statusOptions.value = newStatuses;
      }
    }

    // Apply filters
    filterBookings();
  }

  bool listEquals(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  // void filterBookings() {
  //   if (selectedGroupCategory.value == 'All' && selectedStatus.value == 'All') {
  //     return; // No filtering needed
  //   }

  //   final filteredBookings = <BookingModel>[];

  //   for (var booking in List<BookingModel>.from(bookings)) {
  //     bool matchesCountry = selectedGroupCategory.value == 'All' ||
  void filterBookings() {
    if (selectedGroupCategory.value == 'All' && selectedStatus.value == 'All') {
      return; // No filtering needed
    }

    final filteredBookings = <BookingModel>[];

    for (var booking in List<BookingModel>.from(bookings)) {
      bool matchesCountry =
          selectedGroupCategory.value == 'All' ||
          booking.country == selectedGroupCategory.value;

      bool matchesStatus =
          selectedStatus.value == 'All' ||
          booking.status.toUpperCase() == selectedStatus.value.toUpperCase();

      if (matchesCountry && matchesStatus) {
        filteredBookings.add(booking);
      }
    }

    // Update the bookings list with filtered results
    bookings.value = filteredBookings;
  }
}
