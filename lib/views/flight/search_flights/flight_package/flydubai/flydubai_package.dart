// ignore_for_file: dead_code, empty_catches

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/views/flight/search_flights/flydubai/flydubai_controller.dart';
import 'package:ready_flights/views/flight/search_flights/flydubai/flydubai_model.dart';
import '../../../../../services/api_service_sabre.dart';
import '../../../../../utility/colors.dart';
import '../../../form/flight_booking_controller.dart';
import '../../flydubai/flydubai_return_flight.dart';
import '../../review_flight/flydubai_review_flight.dart';
import '../../search_flight_utils/widgets/flydubai_flight_card.dart';

class FlyDubaiPackageSelectionDialog extends StatelessWidget {
  final FlydubaiFlight flight;
  final bool isReturnFlight;
  final RxBool isLoading = false.obs;

  // Cache for margin data and calculated prices
  final Rx<Map<String, dynamic>> marginData = Rx<Map<String, dynamic>>({});
  final Map<String, RxDouble> finalPrices = {};

  FlyDubaiPackageSelectionDialog({
    super.key,
    required this.flight,
    required this.isReturnFlight,
  });

  final flyDubaiController = Get.find<FlydubaiFlightController>();
  late final FlightBookingController flightBookingController;

  @override
  Widget build(BuildContext context) {
    // Pre-fetch margin data when dialog opens
    _prefetchMarginData();
    flightBookingController = Get.find<FlightBookingController>();

    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.background,
        surfaceTintColor: TColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isReturnFlight
              ? 'Select Return Flight Package'
              : 'Select Flight Package',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildFlightInfo(),
          Expanded(
            child: _buildPackagesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightInfo() {
    return FlyDubaiFlightCard(flight: flight, showReturnFlight: false);
  }

  Future<void> _prefetchMarginData() async {
    try {
      if (marginData.value.isEmpty) {
        final apiService = Get.find<ApiServiceSabre>();
        marginData.value = await apiService.getMargin();
      }

      // Pre-calculate prices for all fare options
      final fareOptions = flyDubaiController.getFareOptionsForFlight(flight);
      for (var option in fareOptions) {
        final String packageKey = '${option.cabin}-${option.fareTypeName}';

        if (!finalPrices.containsKey(packageKey)) {
          final apiService = Get.find<ApiServiceSabre>();

          final marginedBasePrice = apiService.calculatePriceWithMargin(
            option.baseFareAmountIncludingTax,
            marginData.value,
          );

          final totalPrice = marginedBasePrice;

          finalPrices[packageKey] = totalPrice.obs;
        }
      }
    } catch (e) {
      print('DEBUG: Error in _prefetchMarginData: $e');
    }
  }

  Widget _buildPackagesList() {
    // Get fare options for the selected flight
    final List<FlydubaiFlightFare> fareOptions = flyDubaiController.getFareOptionsForFlight(flight);

    // Handle empty state
    if (fareOptions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'No packages available for this flight',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Please select another flight',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
          child: Text(
            'Available Packages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: fareOptions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildVerticalPackageCard(fareOptions[index], flight, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalPackageCard(FlydubaiFlightFare package, FlydubaiFlight flight, int index) {
    final headerColor = TColors.primary;
    final isSoldOut = package.seatsAvailable <= 0;
    final price = finalPrices['${package.cabin}-${package.fareTypeName}']?.value ??
        package.baseFareAmountIncludingTax;

    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  headerColor,
                  headerColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.fareTypeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TColors.white,
                        ),
                      ),
                      if (isSoldOut)
                        const Text(
                          'SOLD OUT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      if (package.seatsAvailable <= 3 && package.seatsAvailable > 0)
                        Text(
                          '${package.seatsAvailable} seats left',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: TColors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: TColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: TColors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${package.currency} ${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: TColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Package details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // First row
                _buildPackageDetail(
                  Icons.work_outline_rounded,
                  'Hand Baggage',
                  '7 KG',
                ),
                const SizedBox(height: 12),
                _buildPackageDetail(
                  Icons.luggage,
                  'Checked Baggage',
                  getBaggageInfo(package.fareTypeName),
                ),

                const SizedBox(height: 12),

                // Second row
                _buildPackageDetail(
                  Icons.restaurant_rounded,
                  'Meal',
                  _getMealInfo(package.fareTypeName),
                ),
                const SizedBox(height: 12),
                _buildPackageDetail(
                  Icons.airline_seat_recline_normal,
                  'Cabin',
                  getCabinDisplayName(package.cabin),
                ),

                const SizedBox(height: 12),

                // Third row
                _buildPackageDetail(
                  Icons.event_seat,
                  'Seat Selection',
                  _getSeatSelectionInfo(package.fareTypeName),
                ),
                const SizedBox(height: 12),
                _buildPackageDetail(
                  Icons.swap_horiz_rounded,
                  'Change Fee',
                  _getChangeFeeDisplay(package.fareTypeName),
                  details: flight.changeFeeDetails,
                ),

                const SizedBox(height: 12),

                _buildPackageDetail(
                  Icons.money_off_rounded,
                  'Refund Fee',
                  _getRefundFeeDisplay(package.fareTypeName),
                  details: flight.refundFeeDetails,
                ),

                const SizedBox(height: 16),

                // Button
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isSoldOut || isLoading.value
                        ? null
                        : () => onSelectPackage(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSoldOut ? Colors.grey : TColors.primary,
                      foregroundColor: TColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(TColors.white),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getButtonText(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    if (isReturnFlight) {
      return 'Complete Selection';
    } else {
      return 'Select Package';
    }
  }

  String getBaggageInfo(String fareTypeName) {
    switch (fareTypeName.toUpperCase()) {
      case 'LITE':
        return '0 KG';
      case 'VALUE':
        return '20 KG';
      case 'FLEX':
        return '30 KG';
      case 'BUSINESS':
        return '40 KG';
      default:
        return '20 KG';
    }
  }

  String getCabinDisplayName(String cabin) {
    switch (cabin.toUpperCase()) {
      case 'ECONOMY':
        return 'Economy';
      case 'BUSINESS':
        return 'Business';
      default:
        return 'Economy';
    }
  }

  String _getMealInfo(String fareTypeName) {
    switch (fareTypeName.toUpperCase()) {
      case 'LITE':
        return 'Purchase onboard';
      case 'VALUE':
        return 'Included';
      case 'FLEX':
        return 'Premium meal';
      case 'BUSINESS':
        return 'Gourmet dining';
      default:
        return 'Included';
    }
  }

  String _getSeatSelectionInfo(String fareTypeName) {
    switch (fareTypeName.toUpperCase()) {
      case 'LITE':
        return 'Fee applies';
      case 'VALUE':
        return 'Standard seats free';
      case 'FLEX':
        return 'Premium seats free';
      case 'BUSINESS':
        return 'All seats included';
      default:
        return 'Standard selection';
    }
  }

  String _getChangeFeeDisplay(String fareTypeName) {
    switch (fareTypeName.toUpperCase()) {
      case 'LITE':
        return 'Not permitted';
      case 'VALUE':
        return 'AED 150';
      case 'FLEX':
        return 'Free (>12h)';
      case 'BUSINESS':
        return 'Free (>12h)';
      default:
        return 'Fee applies';
    }
  }

  String _getRefundFeeDisplay(String fareTypeName) {
    switch (fareTypeName.toUpperCase()) {
      case 'LITE':
        return 'Non-refundable';
      case 'VALUE':
        return 'AED 200';
      case 'FLEX':
        return 'Free (>24h)';
      case 'BUSINESS':
        return 'Free (>24h)';
      default:
        return 'Fee applies';
    }
  }

  Widget _buildPackageDetail(IconData icon, String title, String value,
      {List<Map<String, dynamic>>? details, bool showInfoIcon = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: TColors.background, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: TColors.grey,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: TColors.text,
                        ),
                      ),
                    ),
                    if (showInfoIcon && details != null && details.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showFeeDetailsDialog(title, details),
                        child: const Icon(
                          Icons.help_outline,
                          size: 18,
                          color: TColors.primary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Update the onSelectPackage method in FlyDubaiPackageSelectionDialog
  void onSelectPackage(int selectedPackageIndex) async {
    try {
      isLoading.value = true;

      // Get all fare options for this flight
      final List<FlydubaiFlightFare> fareOptions =
      flyDubaiController.getFareOptionsForFlight(flight);

      // Get the selected fare option
      final selectedFareOption = fareOptions[selectedPackageIndex];

      // Revalidate flight pricing before proceeding
      final revalidationSuccess = await flyDubaiController.revalidateFlightBeforeReview(
        flight: flight,
        selectedFare: selectedFareOption,
        isReturnFlight: isReturnFlight,
      );

      if (!revalidationSuccess) {
        Get.snackbar(
          'Price Update Required',
          'Flight prices have changed. Please review the updated pricing.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Refresh the package list to show updated prices
        await _prefetchMarginData();
        isLoading.value = false;
        return;
      }

      // Check if this is a one-way flight or we need to select a return flight
      final tripType = flightBookingController.tripType.value;

      if (tripType == TripType.oneWay || isReturnFlight) {
        // For one-way trip or if this is already the return flight selection
        Get.back(); // Close the package selection dialog

        // Store the selected flight and package
        if (isReturnFlight) {
          flyDubaiController.selectedReturnFlight = flight;
          flyDubaiController.selectedReturnFareOption = selectedFareOption;
        } else {
          flyDubaiController.selectedOutboundFlight = flight;
          flyDubaiController.selectedOutboundFareOption = selectedFareOption;
        }

        // Navigate to review page
        Get.snackbar(
          'Success',
          isReturnFlight
              ? 'Return flight package selected. Proceeding to booking details.'
              : 'Flight package selected. Proceeding to booking details.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        Get.to(() => FlyDubaiReviewTripPage(
          flight: flight,
          isReturn: isReturnFlight,
        ));
      } else {
        // For round trip, show return flights after selecting outbound package
        Get.back(); // Close the package selection dialog

        // Store the selected outbound flight and package
        flyDubaiController.selectedOutboundFlight = flight;
        flyDubaiController.selectedOutboundFareOption = selectedFareOption;

        // Show success message
        Get.snackbar(
          'Outbound Selected',
          'Outbound flight package selected. Now select your return flight.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Show return flights
        _showReturnFlights();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'This flight package is no longer available. Please select another option.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
  void _showReturnFlights() {
    final returnFlights = flyDubaiController.getReturnFlights();

    if (returnFlights.isEmpty) {
      Get.snackbar(
        'No Return Flights',
        'No return flights found for your search criteria.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Navigate to return flights page
    Get.to(
          () => FlyDubaiReturnFlightsPage(returnFlights: returnFlights),
      transition: Transition.rightToLeft,
    );
  }

  void _showFeeDetailsDialog(String title, List<Map<String, dynamic>> details) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      title.toLowerCase().contains('change')
                          ? Icons.swap_horiz_rounded
                          : Icons.money_off_rounded,
                      color: TColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Fee details list
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                child: SingleChildScrollView(
                  child: Column(
                    children: details.map((detail) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: TColors.background3.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TColors.primary.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Time icon and condition
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: TColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.access_time_rounded,
                                      color: TColors.primary,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _formatConditionText(detail['condition'] ?? ''),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: TColors.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Amount
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: TColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                detail['amount'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: TColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: TColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  String _formatConditionText(String condition) {
    switch (condition.toLowerCase()) {
      case 'any time':
        return 'Any time before departure';
      case '>24h':
        return 'More than 24 hours before';
      case '<24h':
        return 'Within 24 hours';
      case '>12h':
        return 'More than 12 hours before';
      case '<12h':
        return 'Within 12 hours';
      case '<0':
        return 'Time is <0 hour(s)';
      case '<48':
        return 'Time is <48 hour(s)';
      case '>48':
        return 'Time is >48 hour(s)';
      default:
        if (condition.contains('>')) {
          final hours = condition.replaceAll('>', '').trim();
          return 'More than $hours hours before';
        } else if (condition.contains('<')) {
          final hours = condition.replaceAll('<', '').trim();
          return 'Within $hours hours';
        }
        return condition;
    }
  }


}