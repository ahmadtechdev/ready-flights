// views/flight/search_flights/flydubai/flydubai_return_flights_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utility/colors.dart';
import '../search_flight_utils/widgets/flydubai_flight_card.dart';
import 'flydubai_controller.dart';
import 'flydubai_model.dart';

class FlyDubaiReturnFlightsPage extends StatefulWidget {
  final List<FlydubaiFlight> returnFlights;

  const FlyDubaiReturnFlightsPage({
    super.key,
    required this.returnFlights,
  });

  @override
  State<FlyDubaiReturnFlightsPage> createState() => _FlyDubaiReturnFlightsPageState();
}

class _FlyDubaiReturnFlightsPageState extends State<FlyDubaiReturnFlightsPage> {
  final FlydubaiFlightController flydubaiController = Get.find<FlydubaiFlightController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize filtered return flights
    flydubaiController.filteredReturnFlights.assignAll(widget.returnFlights);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSelectedOutboundFlightHeader(),

          Expanded(
            child: _buildReturnFlightsList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: TColors.background,
      surfaceTintColor: TColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: TColors.text),
        onPressed: () => Get.back(),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Return Flights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
          Text(
            'FlyDubai',
            style: TextStyle(
              fontSize: 12,
              color: TColors.grey,
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }

  Widget _buildSelectedOutboundFlightHeader() {
    final outboundFlight = flydubaiController.selectedOutboundFlight;
    final outboundFare = flydubaiController.selectedOutboundFareOption;

    if (outboundFlight == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColors.primary.withOpacity(0.1),
            TColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flight_takeoff_rounded,
                color: TColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Selected Outbound Flight',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Flight info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${outboundFlight.airlineCode} ${outboundFlight.flightSegment.flightNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${outboundFlight.flightSegment.origin} → ${outboundFlight.flightSegment.destination}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: TColors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(outboundFlight.flightSegment.departureDateTime),
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Price and package info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${outboundFare?.currency ?? 'PKR'} ${outboundFlight.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    outboundFare?.fareTypeName ?? 'Selected',
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }




// In flydubai_return_flight.dart, update the flight card tap handler
  Widget _buildReturnFlightsList() {
    return Obx(() {
      if (flydubaiController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
          ),
        );
      }

      if (flydubaiController.filteredReturnFlights.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: _refreshFlights,
        color: TColors.primary,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: flydubaiController.filteredReturnFlights.length,
          itemBuilder: (context, index) {
            final flight = flydubaiController.filteredReturnFlights[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  // Handle return flight selection
                  flydubaiController.handleFlydubaiFlightSelection(
                      flight,
                      isReturnFlight: true
                  );
                },
                child: FlyDubaiFlightCard(
                  flight: flight,
                  showReturnFlight: true,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_land_rounded,
            size: 64,
            color: TColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Return Flights Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No return flights available for your selected criteria.',
            style: TextStyle(
              fontSize: 14,
              color: TColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to Outbound'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: TColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _refreshFlights() async {
    // Refresh return flights - in a real app, you might want to call the API again
    await Future.delayed(const Duration(seconds: 1));
    flydubaiController.filteredReturnFlights.assignAll(widget.returnFlights);
  }


  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];

    return '${weekdays[dateTime.weekday - 1]}, ${dateTime.day} ${months[dateTime.month - 1]}';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}