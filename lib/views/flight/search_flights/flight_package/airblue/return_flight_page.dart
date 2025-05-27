// Create a new file: return_flights_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../search_flight_utils/widgets/airblue_flight_card.dart';
import 'airblue_flight_model.dart';
import 'airblue_flight_controller.dart';

class ReturnFlightsPage extends StatelessWidget {
  final List<AirBlueFlight> returnFlights;
  final AirBlueFlightController airBlueController = Get.find<AirBlueFlightController>();

  ReturnFlightsPage({super.key, required this.returnFlights});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Return Flight'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: _buildFlightList(),
    );
  }

  Widget _buildFlightList() {
    return ListView.builder(
      // padding: const EdgeInsets.all(16),
      itemCount: returnFlights.length,
      itemBuilder: (context, index) {
        final flight = returnFlights[index];
        return GestureDetector(
          onTap: () => airBlueController.handleReturnFlightSelection(flight),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AirBlueFlightCard(flight: flight, showReturnFlight: false),
          ),
        );
      },
    );
  }
}