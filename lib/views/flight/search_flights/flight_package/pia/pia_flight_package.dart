// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utility/colors.dart';
import '../../review_flight/pia_review_flight.dart';
import '../../search_flight_utils/widgets/pia_flight_card.dart';
import '../../pia/pia_flight_model.dart';
import '../../pia/pia_flight_controller.dart';
import '../../pia/pia_return_flight_page.dart';

class PIAPackageSelectionDialog extends StatelessWidget {
  final PIAFlight flight;
  final bool isReturnFlight;
  final RxBool isLoading = false.obs;

  PIAPackageSelectionDialog({
    super.key,
    required this.flight,
    required this.isReturnFlight,
  });

  final PageController _pageController = PageController(viewportFraction: 0.9);
  final piaController = Get.find<PIAFlightController>();

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFlightInfo(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildPackagesList(),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightInfo() {
    return PIAFlightCard(flight: flight);
  }

  Widget _buildPackagesList() {
    final List<PIAFareOption> fareOptions = piaController
        .getFareOptionsForFlight(flight);

    print("abc:");
    print(fareOptions);


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
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'Available Packages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            itemCount: fareOptions.length,
            itemBuilder: (context, index) {
              final package = fareOptions[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(
                    scale: Curves.easeOutQuint.transform(value),
                    child: _buildPackageCard(package, index),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(
          height: 50,
          child: Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  fareOptions.length,
                      (index) => AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: value.abs() < 0.5 ? 24 : 8,
                        decoration: BoxDecoration(
                          color: value.abs() < 0.5
                              ? TColors.primary
                              : TColors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(PIAFareOption package, int index) {
    final headerColor = TColors.primary;
    final isSoldOut = false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with package name and price
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [headerColor, headerColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    package.fareName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColors.background,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      package.price.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TColors.background,
                      ),
                    ),
                    Text(
                      package.currency,
                      style: TextStyle(
                        fontSize: 14,
                        color: TColors.background.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Package details
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPackageDetail(
                      Icons.luggage,
                      'Hand Baggage',
                      '10 KG', // Standard for PIA
                    ),
                    const SizedBox(height: 12),
                    _buildPackageDetail(
                      Icons.luggage,
                      'Checked Baggage',
                      package.baggageAllowance.weight > 0
                          ? '${package.baggageAllowance.weight} ${package.baggageAllowance.unit}'
                          : '${package.baggageAllowance.pieces} piece(s)',
                    ),
                    const SizedBox(height: 12),
                    _buildPackageDetail(
                      Icons.restaurant,
                      'Meal',
                      getMealInfo(
                        package.rawData['flightSegment']?['flightNotes']?['note'] ?? 'N',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPackageDetail(
                      Icons.airline_seat_recline_normal,
                      'Cabin Class',
                      package.cabinClass,
                    ),
                    const SizedBox(height: 12),
                    _buildPackageDetail(
                      Icons.change_circle,
                      'Change Fee',
                      package.changeFee,
                    ),
                    const SizedBox(height: 12),
                    _buildPackageDetail(
                      Icons.currency_exchange,
                      'Refund Fee',
                      package.refundFee,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Price and button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
                  () => ElevatedButton(
                onPressed: isSoldOut || isLoading.value
                    ? null
                    : () => onSelectPackage(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSoldOut ? Colors.grey : TColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 2,
                ),
                child: isLoading.value
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      TColors.background,
                    ),
                  ),
                )
                    : Text(
                  isReturnFlight
                      ? 'Select Return Package'
                      : 'Select Package',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSoldOut
                        ? Colors.white70
                        : TColors.background,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDetail(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: TColors.primary, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: TColors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getMealInfo(String mealCode) {
    switch (mealCode.toUpperCase()) {
      case 'P':
        return 'Alcoholic beverages for purchase';
      case 'C':
        return 'Complimentary alcoholic beverages';
      case 'B':
        return 'Breakfast';
      case 'K':
        return 'Continental breakfast';
      case 'D':
        return 'Dinner';
      case 'F':
        return 'Food for purchase';
      case 'G':
        return 'Food/Beverages for purchase';
      case 'M':
        return 'Meal';
      case 'N':
        return 'No meal service';
      case 'R':
        return 'Complimentary refreshments';
      case 'V':
        return 'Refreshments for purchase';
      case 'S':
        return 'Snack';
      default:
        return 'No Meal';
    }
  }
  // In pia_flight_package.dart
  void onSelectPackage(int selectedPackageIndex) async {
    try {
      isLoading.value = true;

      final List<PIAFareOption> fareOptions = piaController
          .getFareOptionsForFlight(flight);
      final selectedFareOption = fareOptions[selectedPackageIndex];

      print("abcd");
      print(selectedFareOption.rawData);
      // Create a copy of the flight with the selected fare option
      final updatedFlight = flight.copyWith(
        selectedFareOption: selectedFareOption,
      );

       if (piaController.isRoundTrip.value) {
        if (!isReturnFlight) {
          piaController.selectedOutboundFlight = updatedFlight;
          piaController.selectedOutboundFareOption =selectedFareOption;
          Get.back();
          piaController.showReturnFlights.value = true;
          Get.to(
                () => PIAReturnFlightsPage(
              returnFlights: piaController.inboundFlights,
            ),
          );
        } else {
          piaController.selectedReturnFlight = updatedFlight;
          piaController.selectedReturnFareOption =selectedFareOption;
          Get.back();
          Get.to(() => PIAReviewTripPage(
            flight: updatedFlight,
            isReturn: true,
          ));
        }
      } else {
        piaController.selectedOutboundFlight = updatedFlight;
        piaController.selectedOutboundFareOption =selectedFareOption;
        Get.back();
        Get.to(() => PIAReviewTripPage(
          flight: updatedFlight,
          isReturn: false,
        ));
      }
    } finally {
      isLoading.value = false;
    }
  }
  //
  // void onSelectPackage(int selectedPackageIndex) async {
  //   try {
  //     isLoading.value = true;
  //
  //     final List<PIAFareOption> fareOptions = piaController
  //         .getFareOptionsForFlight(flight);
  //     final selectedFareOption = fareOptions[selectedPackageIndex];
  //
  //     // Create a copy of the flight with the selected fare option
  //     final updatedFlight = flight.copyWith(
  //       selectedFareOption: selectedFareOption,
  //     );
  //
  //     if (piaController.isRoundTrip.value) {
  //       if (!isReturnFlight) {
  //         // Store outbound selection and show return flights
  //         piaController.selectedOutboundFlight = updatedFlight;
  //         piaController.selectedOutboundFareOption = selectedFareOption;
  //         Get.back(); // Close package dialog
  //         piaController.showReturnFlights.value = true;
  //         Get.to(
  //               () => PIAReturnFlightsPage(
  //             returnFlights: piaController.inboundFlights,
  //           ),
  //         );
  //       } else {
  //         // Store return selection and proceed to booking
  //         piaController.selectedReturnFlight = updatedFlight;
  //         piaController.selectedReturnFareOption = selectedFareOption;
  //         Get.back(); // Close package dialog
  //         Get.to(() => PIAReviewTripPage(
  //           flight: updatedFlight,
  //           isReturn: true,
  //         ));
  //       }
  //     } else {
  //       // For one-way or multi-city
  //       piaController.selectedOutboundFlight = flight;
  //       piaController.selectedOutboundFareOption = selectedFareOption;
  //       Get.back(); // Close package dialog
  //       Get.to(() => PIAReviewTripPage(
  //         flight: updatedFlight,
  //         isReturn: false,
  //       ));
  //     }
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Failed to select package. Please try again.',
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //       icon: const Icon(Icons.error_outline, color: Colors.white),
  //       duration: const Duration(seconds: 3),
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
}