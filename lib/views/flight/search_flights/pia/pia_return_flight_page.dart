// Create a new file: pia_return_flights_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utility/colors.dart';
import '../search_flight_utils/widgets/pia_flight_card.dart';
import 'pia_flight_model.dart';
import 'pia_flight_controller.dart';

class PIAReturnFlightsPage extends StatelessWidget {
  final List<PIAFlight> returnFlights;
  final PIAFlightController piaController = Get.find<PIAFlightController>();

  PIAReturnFlightsPage({super.key, required this.returnFlights});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Return Flight'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            piaController.showReturnFlights.value = false;
            Get.back();
          },
        ),
      ),
      body: _buildFlightList(),

    );
  }

  Widget _buildFlightList() {
    return ListView.builder(
      itemCount: returnFlights.length,
      itemBuilder: (context, index) {
        final flight = returnFlights[index];
        return GestureDetector(
          onTap: () {
            piaController.selectedReturnFlight = flight;
            piaController.update();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    piaController.selectedReturnFlight?.flightNumber ==
                            flight.flightNumber
                        ? TColors.primary
                        : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: GestureDetector(
              onTap: () {
                piaController.handlePIAFlightSelection(
                  flight,
                  isReturnFlight: true,
                );
              },

              child: PIAFlightCard(flight: flight),
            ),
          ),
        );
      },
    );
  }

  // In pia_return_flight_page.dart

  // Update the _buildBottomBar method
}
