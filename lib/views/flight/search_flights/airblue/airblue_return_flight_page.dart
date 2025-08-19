// Fixed: airblue_return_flight_page.dart - Handle null/empty flights gracefully
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/utility/colors.dart';

import '../search_flight_utils/widgets/airblue_flight_card.dart';
import 'airblue_flight_controller.dart';
import 'airblue_flight_model.dart';

class AirblueReturnFlightsPage extends StatelessWidget {
  final List<AirBlueFlight>? returnFlights; // Made nullable
  final AirBlueFlightController airBlueController = Get.find<AirBlueFlightController>();

  AirblueReturnFlightsPage({super.key, this.returnFlights});

  @override
  Widget build(BuildContext context) {
    // Get safe flight list - handle null case
    final safeReturnFlights = returnFlights ?? [];

    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.background,
        surfaceTintColor: TColors.background,
        title: const Text('Select Return Flight'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Debug button (remove in production)
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              print('DEBUG: Return flights count: ${safeReturnFlights.length}');
              print('DEBUG: Return flights data: ${returnFlights?.map((f) => '${f.legSchedules.first['departure']['airport']} -> ${f.legSchedules.last['arrival']['airport']}').toList()}');
            },
          ),
        ],
      ),
      body: _buildFlightList(safeReturnFlights),
    );
  }

  Widget _buildFlightList(List<AirBlueFlight> flights) {
    // Handle empty flights case
    if (flights.isEmpty) {
      return _buildNoFlightsFound();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: flights.length,
      itemBuilder: (context, index) {
        final flight = flights[index];
        return GestureDetector(
          onTap: () {
            print('DEBUG: Return flight selected');
            print('DEBUG: Flight route: ${flight.legSchedules.first['departure']['airport']} -> ${flight.legSchedules.last['arrival']['airport']}');
            airBlueController.handleReturnFlightSelection(flight);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TColors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: AirBlueFlightCard(flight: flight, showReturnFlight: false),
          ),
        );
      },
    );
  }

  Widget _buildNoFlightsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff_outlined,
            size: 64,
            color: TColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Return Flights Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: TColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No return flights found for this route.\nPlease check your model_controllers criteria or try different dates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: TColors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  print('DEBUG: Search again button pressed for return flights');
                  // Go back to search or modify search criteria
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Modify Search',
                  style: TextStyle(
                    color: TColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  print('DEBUG: Continue with outbound only button pressed');
                  // Option to continue with just the outbound flight
                  Get.back();

                  // You might want to show a dialog asking if they want to continue with one-way
                  Get.snackbar(
                    'Return Flight Required',
                    'Please select return flight dates with available flights for round trip booking.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: TColors.primary,
                    colorText: TColors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    color: TColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}