import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utility/colors.dart';
import '../flydubai/flydubai_model.dart';
import '../flydubai/flydubai_controller.dart';
import '../search_flight_utils/widgets/flydubai_flight_card.dart';

class FlyDubaiReviewTripPage extends StatelessWidget {
  final FlydubaiFlight flight;
  final bool isReturn;

  const FlyDubaiReviewTripPage({
    super.key,
    required this.flight,
    required this.isReturn,
  });

  @override
  Widget build(BuildContext context) {
    final flyDubaiController = Get.find<FlydubaiFlightController>();

    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.background,
        surfaceTintColor: TColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Review Your Trip',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flight details
                  const Text(
                    'Flight Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: TColors.text,
                    ),
                  ),
                  const SizedBox(height: 16),

                  FlyDubaiFlightCard(flight: flight, showReturnFlight: false, isShowBookButton: false,),

                  const SizedBox(height: 24),

                  // // Selected package info
                  // _buildSelectedPackageInfo(flyDubaiController),
                  //
                  // const SizedBox(height: 24),
                  //
                  // // Price breakdown
                  _buildPriceBreakdown(flyDubaiController),
                ],
              ),
            ),
          ),

          // Continue button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to passenger details or booking confirmation
                Get.snackbar(
                  'Next Step',
                  'Proceeding to passenger details...',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: TColors.primary,
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Continue to Passenger Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TColors.background,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPackageInfo(FlydubaiFlightController controller) {
    final selectedFare = isReturn
        ? controller.selectedReturnFareOption
        : controller.selectedOutboundFareOption;

    if (selectedFare == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Package: ${selectedFare.fareTypeName}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
          const SizedBox(height: 16),

          _buildPackageFeature(Icons.luggage, 'Checked Baggage', _getBaggageInfo(selectedFare.fareTypeName)),
          _buildPackageFeature(Icons.restaurant, 'Meal', _getMealInfo(selectedFare.fareTypeName)),
          _buildPackageFeature(Icons.airline_seat_recline_normal, 'Cabin', selectedFare.cabin),
          _buildPackageFeature(Icons.event_seat, 'Seats Available', '${selectedFare.seatsAvailable}'),
        ],
      ),
    );
  }

  Widget _buildPackageFeature(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: TColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 14,
              color: TColors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(FlydubaiFlightController controller) {
    final selectedFare = isReturn
        ? controller.selectedReturnFareOption
        : controller.selectedOutboundFareOption;

    if (selectedFare == null) {
      return const SizedBox.shrink();
    }

    final basePrice = selectedFare.baseFareAmountIncludingTax * 0.75; // Approximate base
    final taxesAndFees = selectedFare.baseFareAmountIncludingTax * 0.25; // Approximate taxes

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
          const SizedBox(height: 16),

          _buildPriceRow('Base Fare', basePrice, selectedFare.currency),
          _buildPriceRow('Taxes & Fees', taxesAndFees, selectedFare.currency),

          const Divider(height: 24),

          _buildPriceRow('Total Amount', selectedFare.displayFareAmount, selectedFare.currency, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, String currency, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? TColors.text : TColors.grey,
            ),
          ),
          Text(
            '$currency ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? TColors.primary : TColors.text,
            ),
          ),
        ],
      ),
    );
  }

  String _getBaggageInfo(String fareTypeName) {
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

  String _getMealInfo(String fareTypeName) {
    switch (fareTypeName.toUpperCase()) {
      case 'LITE':
        return 'Purchase onboard';
      case 'VALUE':
        return 'Complimentary meal';
      case 'FLEX':
        return 'Premium meal';
      case 'BUSINESS':
        return 'Gourmet dining';
      default:
        return 'Meal included';
    }
  }
}