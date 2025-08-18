// FIXED: airblue_multicity_flight_selection.dart - Better handling of null/empty flights

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/views/flight/search_flights/airblue/airblue_flight_controller.dart';
import '../../../../../utility/colors.dart';

import '../../form/flight_booking_controller.dart';
import '../search_flight_utils/widgets/airblue_flight_card.dart';
import 'airblue_flight_model.dart';

class AirBlueMultiCityFlightPage extends StatefulWidget {
  final int currentSegment;
  final List<AirBlueFlight>? availableFlights; // Made nullable

  const AirBlueMultiCityFlightPage({
    super.key,
    required this.currentSegment,
    this.availableFlights, // Now nullable
  });

  @override
  State<AirBlueMultiCityFlightPage> createState() => _AirBlueMultiCityFlightPageState();
}

class _AirBlueMultiCityFlightPageState extends State<AirBlueMultiCityFlightPage> {
  @override
  void initState() {
    super.initState();

    // Debug the current state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final airBlueController = Get.find<AirBlueFlightController>();
      airBlueController.debugMultiCityState();
      print('DEBUG: Multi-city flight page opened for segment ${widget.currentSegment}');
      print('DEBUG: Available flights: ${_getSafeFlights().length}');
    });
  }

  // Helper method to get safe flight list
  List<AirBlueFlight> _getSafeFlights() {
    return widget.availableFlights ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.find<FlightBookingController>();
    final airBlueController = Get.find<AirBlueFlightController>();

    // Ensure we have a valid city pair for this segment
    if (widget.currentSegment >= bookingController.cityPairs.length) {
      return _buildErrorScaffold('Invalid segment');
    }

    final cityPair = bookingController.cityPairs[widget.currentSegment];

    return WillPopScope(
      onWillPop: () async {
        // Clear any selections for this segment if going back
        if (widget.currentSegment < airBlueController.selectedMultiCityFlights.length) {
          airBlueController.selectedMultiCityFlights[widget.currentSegment] = null;
        }
        if (widget.currentSegment < airBlueController.selectedMultiCityFareOptions.length) {
          airBlueController.selectedMultiCityFareOptions[widget.currentSegment] = null;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: TColors.background,
        appBar: AppBar(
          backgroundColor: TColors.background,
          surfaceTintColor: TColors.background,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Flight: ${cityPair.fromCity.value} → ${cityPair.toCity.value}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Segment ${widget.currentSegment + 1} of ${bookingController.cityPairs.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: TColors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              print('DEBUG: Manual back navigation from segment ${widget.currentSegment}');
              Get.back();
            },
          ),

        ),
        body: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(bookingController, airBlueController),

            // Segment info card
            _buildSegmentInfoCard(cityPair, widget.currentSegment),

            // Flight list
            Expanded(
              child: _buildFlightList(airBlueController, cityPair),
            ),
          ],
        ),
      ),
    );
  }

  Scaffold _buildErrorScaffold(String errorMessage) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.background,
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: TColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TColors.text,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
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
      ),
    );
  }

  Widget _buildProgressIndicator(FlightBookingController bookingController, AirBlueFlightController airBlueController) {
    return Obx(() => Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.flight_takeoff,
            color: TColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multi-City Trip Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    bookingController.cityPairs.length,
                        (index) {
                      // Check if this segment is completed
                      bool isCompleted = index < airBlueController.selectedMultiCityFlights.length &&
                          airBlueController.selectedMultiCityFlights[index] != null &&
                          index < airBlueController.selectedMultiCityFareOptions.length &&
                          airBlueController.selectedMultiCityFareOptions[index] != null;

                      bool isCurrent = index == widget.currentSegment;

                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        height: 6,
                        width: 20,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green
                              : isCurrent
                              ? TColors.primary
                              : TColors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${widget.currentSegment + 1}/${bookingController.cityPairs.length}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TColors.primary,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSegmentInfoCard(dynamic cityPair, int segmentIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TColors.primary, TColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // From city
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From',
                  style: TextStyle(
                    fontSize: 12,
                    color: TColors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  cityPair.fromCity.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.white,
                  ),
                ),
                Text(
                  cityPair.fromCityName.value,
                  style: TextStyle(
                    fontSize: 10,
                    color: TColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Arrow
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: TColors.white,
              size: 20,
            ),
          ),

          // To city
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'To',
                  style: TextStyle(
                    fontSize: 12,
                    color: TColors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  cityPair.toCity.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.white,
                  ),
                ),
                Text(
                  cityPair.toCityName.value,
                  style: TextStyle(
                    fontSize: 10,
                    color: TColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightList(AirBlueFlightController airBlueController, dynamic cityPair) {
    final safeFlights = _getSafeFlights();

    if (safeFlights.isEmpty) {
      return _buildNoFlightsFound(airBlueController, cityPair);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: safeFlights.length,
      itemBuilder: (context, index) {
        final flight = safeFlights[index];
        return GestureDetector(
          // MAIN FIX: Use widget.currentSegment directly instead of trying to access it from controller
          onTap: () {
            print('DEBUG: Flight tapped for segment ${widget.currentSegment}');
            print('DEBUG: Flight route: ${flight.legSchedules.first['departure']['airport']} -> ${flight.legSchedules.last['arrival']['airport']}');
            print('DEBUG: Flight RPH: ${flight.rph}');
            print('DEBUG: Using segment index from widget: ${widget.currentSegment}');

            // CRITICAL FIX: Force set the current segment in controller before calling handler
            airBlueController.currentMultiCitySegment.value = widget.currentSegment;

            // Debug: verify the controller has the right segment
            print('DEBUG: Controller current segment set to: ${airBlueController.currentMultiCitySegment.value}');

            // Call the flight selection handler with the correct segment index from widget
            airBlueController.handleMultiCityFlightSelection(flight, widget.currentSegment);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TColors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: AirBlueFlightCard(
              flight: flight,
              showReturnFlight: false,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoFlightsFound(AirBlueFlightController airBlueController, dynamic cityPair) {
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
            'No Flights Found for This Segment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: TColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No flights available from ${cityPair.fromCity.value} to ${cityPair.toCity.value}.\nPlease check your search criteria or try different dates.',
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
                  print('DEBUG: Skip segment button pressed for segment ${widget.currentSegment}');
                  Get.back();

                  // Try to proceed to next segment
                  Future.delayed(const Duration(milliseconds: 500), () {
                    airBlueController.proceedToNextMultiCitySegment();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Skip This Segment',
                  style: TextStyle(
                    color: TColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  print('DEBUG: Modify search button pressed for segment ${widget.currentSegment}');
                  Get.back();

                  // Show a snackbar suggesting to modify search
                  Get.snackbar(
                    'No Flights Available',
                    'Try different dates or modify your search criteria for this route.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: TColors.primary,
                    colorText: TColors.white,
                  );
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
            ],
          ),
        ],
      ),
    );
  }
}