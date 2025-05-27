// controllers/all_hotel_booking_controller.dart
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../views/users/login/login_api_service/login_api.dart';
import 'model.dart';


class AllHotelBookingController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  var bookings = <HotelBookingModel>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  var fromDate = DateTime.now().subtract(Duration(days: 30)).obs;
  var toDate = DateTime.now().obs;

  var totalReceipt = "0.00".obs;
  var totalPayment = "0.00".obs;
  var closingBalance = "0.00".obs;

  @override
  void onInit() {
    super.onInit();
    fetchHotelBookings();
  }

  Future<void> fetchHotelBookings() async {
    isLoading.value = true;
    errorMessage.value = '';
    bookings.clear();

    try {
      final result = await _authController.getHotelBookings();

      if (result['success'] == true && result['data'] != null) {
        // Check the data structure and handle accordingly
        var responseData;

        if (result['data'] is Map && result['data']['data'] != null) {
          // If data is a Map with a 'data' key containing the array
          responseData = result['data']['data'] as List<dynamic>;
        } else if (result['data'] is List) {
          // If data is directly a List
          responseData = result['data'] as List<dynamic>;
        } else {
          throw Exception('Unexpected data structure from API');
        }

        double totalReceiptValue = 0.0;
        double totalPaymentValue = 0.0;
        final List<HotelBookingModel> processedBookings = [];

        for (int i = 0; i < responseData.length; i++) {
          final booking = responseData[i];
          final bookingDetail = booking['BookingDetail'];
          final guestsDetail = booking['GuestsDetail'] as List<dynamic>;

          // Calculate serial number
          final serialNumber = (i + 1).toString();

          // Generate booking number (using om_id or another identifier)
          final bookingId = bookingDetail['om_id']?.toString() ?? '';
          final bookingNumber = "ONETRVL-${bookingId.padLeft(4, '0')}";

          // Format booking date
          DateTime bookingDate;
          try {
            bookingDate = DateTime.parse(bookingDetail['om_ordate'] ?? '');
          } catch (e) {
            bookingDate = DateTime.now();
          }
          final formattedDate = DateFormat(
            'EEE, dd MMM yyyy',
          ).format(bookingDate);

          // Process guests
          final List<String> guestNames = [];
          for (final guest in guestsDetail) {
            final String title = guest['od_gtitle'] ?? '';
            final String firstName = guest['od_gfname'] ?? '';
            final String lastName = guest['od_glname'] ?? '';
            guestNames.add('$title $firstName $lastName');
          }
          final guestName = guestNames.join(', ');

          // Get destination and hotel name
          final destination =
              bookingDetail['om_destination'] ?? 'Unknown Location';
          final hotel = bookingDetail['om_hname'] ?? 'Unknown Hotel';

          // Get status
          String status = 'Pending';
          if (bookingDetail['om_status'] == '1') {
            status = 'Confirmed';
          } else if (bookingDetail['om_status'] == '2') {
            status = 'Cancelled';
          } else if (bookingDetail['om_status'] == '0') {
            status = 'On Request';
          }

          // Format check-in/check-out dates
          DateTime checkInDate;
          DateTime checkOutDate;
          try {
            checkInDate = DateTime.parse(bookingDetail['om_chindate'] ?? '');
            checkOutDate = DateTime.parse(bookingDetail['om_choutdate'] ?? '');
          } catch (e) {
            checkInDate = DateTime.now();
            checkOutDate = DateTime.now().add(Duration(days: 1));
          }

          final formattedCheckIn = DateFormat(
            'EEE, dd MMM yyyy',
          ).format(checkInDate);
          final formattedCheckOut = DateFormat(
            'EEE, dd MMM yyyy',
          ).format(checkOutDate);
          final checkinCheckout = '$formattedCheckIn - $formattedCheckOut';

          // Format price
          final buyingPrice =
              double.tryParse(bookingDetail['buying_price'] ?? '0') ?? 0.0;
          final sellingPrice =
              double.tryParse(bookingDetail['selling_price'] ?? '0') ?? 0.0;
          final currencySymbol = '\$';
          final localCurrency = 'PKR';
          final price =
              '$currencySymbol ${buyingPrice.toStringAsFixed(2)} $localCurrency: ${sellingPrice.toStringAsFixed(0)}';

          totalReceiptValue += sellingPrice;
          totalPaymentValue += buyingPrice;

          // Calculate cancellation deadline based on check-in date
          String cancellationDeadline;
          final currentDate = DateTime.now();
          final daysUntilCheckin = checkInDate.difference(currentDate).inDays;

          if (daysUntilCheckin < 0) {
            cancellationDeadline = 'Non-Refundable';
          } else if (daysUntilCheckin <= 1) {
            cancellationDeadline = 'Non-Refundable';
          } else {
            final cancellationDate = checkInDate.subtract(Duration(days: 1));
            final formattedCancellation = DateFormat(
              'EEE, dd MMM yyyy',
            ).format(cancellationDate);
            cancellationDeadline =
                '$formattedCancellation ($daysUntilCheckin Days left)';
          }

          final hotelBooking = HotelBookingModel(
            serialNumber: serialNumber,
            bookingNumber: bookingNumber,
            date: formattedDate,
            bookerName: bookingDetail['om_bfname'] ?? 'Unknown',
            guestName: guestName,
            destination: destination,
            hotel: hotel,
            status: status,
            checkinCheckout: checkinCheckout,
            price: price,
            cancellationDeadline: cancellationDeadline,
          );

          processedBookings.add(hotelBooking);
        }

        // Update the bookings list and financial summary
        bookings.assignAll(processedBookings);

        // Format financial summary
        final formatter = NumberFormat('#,##0.00', 'en_US');
        totalReceipt.value = formatter.format(totalReceiptValue);
        totalPayment.value = formatter.format(totalPaymentValue);
        closingBalance.value = formatter.format(
          totalReceiptValue - totalPaymentValue,
        );
      } else {
        errorMessage.value =
            result['message'] ?? 'Failed to load hotel bookings';
      }
    } catch (e) {
      errorMessage.value =
          'An error occurred while fetching hotel bookings: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void updateDateRange(DateTime from, DateTime to) {
    fromDate.value = from;
    toDate.value = to;
    // You could implement date filtering here
    // For now, we'll just refresh the data
    fetchHotelBookings();
  }

  // Helper method to filter bookings by date if needed
  List<HotelBookingModel> getFilteredBookings() {
    // This would filter the bookings based on from/to dates
    // For now, we'll return all bookings
    return bookings;
  }

  // Add to all_hotel_booking_controller.dart
  // Update this method in all_hotel_booking_controller.dart
  // Update this method in all_hotel_booking_controller.dart
  Future<Map<String, dynamic>> getBookingDataForPdf(
    String bookingNumber,
  ) async {
    try {
      // Find the booking object from our local list
      final booking = bookings.firstWhere(
        (b) => b.bookingNumber == bookingNumber,
        orElse: () => throw Exception('Booking not found'),
      );

      // Extract booking ID from the booking number (assuming format ONETRVL-0001)
      final String bookingIdRaw = bookingNumber.split('-').last;
      // Remove leading zeros to match possible different formats in the API
      final String bookingId = bookingIdRaw.replaceFirst(RegExp('^0+'), '');

      // Get the raw API response
      final result = await _authController.getHotelBookings();

      // Handle different response structures
      List<dynamic> responseData;
      if (result['data'] is Map && result['data']['data'] != null) {
        responseData = result['data']['data'] as List<dynamic>;
      } else if (result['data'] is List) {
        responseData = result['data'] as List<dynamic>;
      } else {
        throw Exception('Unexpected data structure from API');
      }

      // Find the matching booking with more flexible matching
      final bookingData = responseData.firstWhere(
        (b) {
          String apiId = b['BookingDetail']['om_id']?.toString() ?? '';
          // Remove leading zeros for comparison if needed
          String normalizedApiId = apiId.replaceFirst(RegExp('^0+'), '');
          return normalizedApiId == bookingId || apiId == bookingId;
        },
        orElse: () {
          // If no exact match found, try to use the first booking data as fallback
          if (responseData.isNotEmpty) {
            print('No exact match found. Using first booking as fallback.');
            return responseData.first;
          }
          throw Exception('Original booking data not found');
        },
      );

      // Calculate adult and child counts
      int adultCount = 0;
      int childCount = 0;

      List<dynamic> guestDetails = bookingData['GuestsDetail'] ?? [];
      for (var guest in guestDetails) {
        String guestFor = guest['od_gfor']?.toString() ?? '';
        if (guestFor.toLowerCase().contains('adult')) {
          adultCount++;
        } else if (guestFor.toLowerCase().contains('child')) {
          childCount++;
        }
      }

      // Extract room type and board basis from rateKey if available
      String roomType = 'Standard Room';
      String boardBasis = 'Bed & Breakfast';

      String rateKey =
          bookingData['BookingDetail']['rate_key']?.toString() ?? '';
      if (rateKey.isNotEmpty) {
        // Extract room type
        RegExp roomTypeRegex = RegExp(r'\|(.*?)\|');
        var matches = roomTypeRegex.allMatches(rateKey);
        for (var match in matches) {
          if (match.group(1) != null) {
            String extracted = match.group(1)!;
            if (extracted.length < 20 && !extracted.contains(',')) {
              // Basic validation
              roomType = extracted;
              break;
            }
          }
        }

        // Extract board basis (common codes: BB, FB, HB, AI)
        RegExp boardBasisRegex = RegExp(r'\|(BB|FB|HB|AI|RO)\|');
        var bbMatches = boardBasisRegex.allMatches(rateKey);
        for (var match in bbMatches) {
          if (match.group(1) != null) {
            String code = match.group(1)!;
            switch (code) {
              case 'BB':
                boardBasis = 'Bed & Breakfast';
                break;
              case 'FB':
                boardBasis = 'Full Board';
                break;
              case 'HB':
                boardBasis = 'Half Board';
                break;
              case 'AI':
                boardBasis = 'All Inclusive';
                break;
              case 'RO':
                boardBasis = 'Room Only';
                break;
              default:
                boardBasis = 'Bed & Breakfast';
            }
            break;
          }
        }
      }

      // Parse dates correctly
      DateTime? checkInDate;
      DateTime? checkOutDate;
      try {
        checkInDate = DateTime.parse(
          bookingData['BookingDetail']['om_chindate'],
        );
        checkOutDate = DateTime.parse(
          bookingData['BookingDetail']['om_choutdate'],
        );
      } catch (e) {
        print('Date parsing error: $e');
        // Use fallback dates if necessary
      }

      return {
        'bookingNumber': booking.bookingNumber,
        'hotelName': booking.hotel,
        'destination': booking.destination,
        'checkInDate':
            checkInDate != null ? checkInDate.toIso8601String() : 'N/A',
        'checkOutDate':
            checkOutDate != null ? checkOutDate.toIso8601String() : 'N/A',
        'nights': bookingData['BookingDetail']['om_nights'] ?? '1',
        'rooms': bookingData['BookingDetail']['om_trooms'] ?? '1',
        'guestDetails': bookingData['GuestsDetail'] ?? [],
        'bookerName': booking.bookerName,
        'price': booking.price,
        'status': booking.status,
        'specialRequests': bookingData['BookingDetail']['om_spreq'] ?? 'None',
        'adultCount': adultCount,
        'childCount': childCount,
        'roomType': roomType,
        'boardBasis': boardBasis,
        'rawBookingData': bookingData, // For debugging if needed
      };
    } catch (e) {
      print('PDF generation error details: $e');
      throw Exception('Failed to prepare booking data for PDF: $e');
    }
  }
}
