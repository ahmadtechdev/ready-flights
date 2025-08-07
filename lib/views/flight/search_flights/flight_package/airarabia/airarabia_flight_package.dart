import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utility/colors.dart';
import '../../airarabia/airarabia_flight_model.dart';
import '../../airarabia/airarabia_flight_controller.dart';
import '../../search_flight_utils/widgets/airarabia_flight_card.dart';

class AirArabiaPackageSelectionDialog extends StatelessWidget {
  final AirArabiaFlight flight;
  final bool isReturnFlight;
  final RxBool isLoading = false.obs;

  AirArabiaPackageSelectionDialog({
    super.key,
    required this.flight,
    required this.isReturnFlight,
  });

  final airArabiaController = Get.find<AirArabiaFlightController>();

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
          'Select Flight Package',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // _buildFlightInfo(),
            AirArabiaFlightCard(flight: flight),
            _buildPackageCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${flight.flightSegments.first['departure']?['airport']} → ${flight.flightSegments.last['arrival']?['airport']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.flight, size: 16, color: TColors.primary),
              const SizedBox(width: 8),
              Text(
                '${flight.airlineName} (${flight.airlineCode})',
                style: const TextStyle(fontSize: 14),
              ),
              const Spacer(),
              Text(
                'PKR ${flight.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                colors: [TColors.primary, TColors.primary.withOpacity(0.8)],
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
                const Text(
                  'Standard Package',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'PKR ${flight.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Package details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPackageDetail(
                  Icons.luggage,
                  'Hand Baggage',
                  '10 KG included',
                ),
                const SizedBox(height: 12),
                _buildPackageDetail(
                  Icons.luggage,
                  'Checked Baggage',
                  '20 KG included',
                ),
                const SizedBox(height: 12),
                _buildPackageDetail(
                  Icons.restaurant,
                  'Meal',
                  'No meal service',
                ),
                const SizedBox(height: 12),
                _buildPackageDetail(
                  Icons.airline_seat_recline_normal,
                  'Cabin Class',
                  getCabinClassName(flight.cabinClass),
                ),
                const SizedBox(height: 12),
                _buildPackageDetail(
                  Icons.change_circle,
                  'Change Fee',
                  'PKR 5,000',
                ),
                const SizedBox(height: 12),
                _buildPackageDetail(
                  Icons.currency_exchange,
                  'Refund Fee',
                  'Non-refundable',
                ),
              ],
            ),
          ),

          // Select button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
                  () => ElevatedButton(
                onPressed: isLoading.value ? null : () => onSelectPackage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 2,
                ),
                child: isLoading.value
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  'Select Package',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
    return Row(
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
    );
  }

  String getCabinClassName(String cabinCode) {
    switch (cabinCode) {
      case 'F':
        return 'First Class';
      case 'C':
        return 'Business Class';
      case 'Y':
        return 'Economy Class';
      case 'W':
        return 'Premium Economy';
      default:
        return 'Economy Class';
    }
  }

  void onSelectPackage() async {

  }
}