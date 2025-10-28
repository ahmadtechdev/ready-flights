import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/views/flight/search_flights/emirates_ndc/emirates_flight_controller.dart';
import 'package:ready_flights/views/flight/search_flights/flydubai/flydubai_controller.dart';
import 'package:ready_flights/views/flight/search_flights/search_flight_utils/widgets/emirates_ndc_card.dart';
import 'package:ready_flights/views/flight/search_flights/search_flight_utils/widgets/flydubai_flight_card.dart';
import 'package:ready_flights/views/home/home_screen.dart';
import '../../../utility/colors.dart';
import 'airarabia/airarabia_flight_controller.dart';
import 'airblue/airblue_flight_controller.dart';
import 'filters/flight_filter_service.dart';
import 'pia/pia_flight_controller.dart';
import 'sabre/sabre_flight_controller.dart';
import 'search_flight_utils/widgets/airarabia_flight_card.dart';
import 'search_flight_utils/widgets/airblue_flight_card.dart';
import 'search_flight_utils/widgets/currency_dialog.dart';
import 'filters/flight_bottom_sheet.dart';
import 'search_flight_utils/widgets/pia_flight_card.dart';
import 'search_flight_utils/widgets/sabre_flight_card.dart';
import '../form/flight_booking_controller.dart';

enum FlightScenario { oneWay, returnFlight, multiCity }

class FlightBookingPage extends StatelessWidget {
  final FlightScenario scenario;
  final SabreFlightController controller = Get.put(SabreFlightController());
  final AirBlueFlightController airBlueController = Get.find<AirBlueFlightController>();
  final PIAFlightController piaController = Get.put(PIAFlightController());
  final AirArabiaFlightController airArabiaController = Get.put(AirArabiaFlightController());
  final FlydubaiFlightController flyDubaiController = Get.put(FlydubaiFlightController());
  final FilterController filterController = Get.put(FilterController());
   final EmiratesFlightController emiratesController = Get.put(EmiratesFlightController()); 

  FlightBookingPage({super.key, required this.scenario}) {
    controller.setScenario(scenario);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        surfaceTintColor: TColors.background,
        backgroundColor: TColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAll(() => HomeScreen()); // Replace with the page you want
          },
        ),
        title: Obx(() {
          final flightBookingController = Get.find<FlightBookingController>();
          
          // Get flight search details
          String origin = '';
          String destination = '';
          String date = '';
          String travelClass = flightBookingController.travelClass.value;
          int travelers = flightBookingController.travellersCount.value;
          
          if (flightBookingController.tripType.value == TripType.multiCity) {
            if (flightBookingController.cityPairs.isNotEmpty) {
              origin = flightBookingController.cityPairs.first.fromCityName.value;
              destination = flightBookingController.cityPairs.last.toCityName.value;
              date = flightBookingController.cityPairs.first.departureDate.value;
            }
          } else {
            origin = flightBookingController.fromCityName.value;
            destination = flightBookingController.toCityName.value;
            date = flightBookingController.departureDate.value;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    origin,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.swap_horiz,
                    size: 12,
                    color: TColors.text,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    destination,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: TColors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    travelClass,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '|',
                    style: TextStyle(
                      fontSize: 12,
                      color: TColors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$travelers ${travelers == 1 ? 'Traveller' : 'Travellers'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
        actions: [
          GetX<SabreFlightController>(
            builder: (controller) => TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CurrencyDialog(controller: controller),
                );
              },
              child: Text(
                controller.selectedCurrency.value,
                style: const TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(context),
          _buildFlightList(),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.secondary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Obx(() => _filterButton(
                'Suggested',
                filterController.sortType.value == 'Suggested',
                    () => filterController.setSuggested()
            )),
            Obx(() => _filterButton(
                'Cheapest',
                filterController.sortType.value == 'Cheapest',
                    () => filterController.setCheapest()
            )),
            Obx(() => _filterButton(
                'Fastest',
                filterController.sortType.value == 'Fastest',
                    () => filterController.setFastest()
            )),
            OutlinedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const FlightFilterBottomSheet(),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: TColors.grey,
                side: BorderSide(color: TColors.grey.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Filters',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Update the _buildFlightList method to include Emirates

Widget _buildFlightList() {
  final airBlueController = Get.find<AirBlueFlightController>();
  final piaController = Get.put(PIAFlightController());
  final flightController = Get.find<SabreFlightController>();
  final emiratesController = Get.find<EmiratesFlightController>(); // Add this

  return Expanded(
    child: Obx(() {
      // Check if any controller is loading
      final isAnyLoading = airBlueController.isLoading.value ||
          flyDubaiController.isLoading.value ||
          flightController.isLoading.value ||
          piaController.isLoading.value ||
          airArabiaController.isLoading.value ||
          emiratesController.isLoading.value; // Add this

      // Check if all controllers have finished loading and have no flights
      final hasNoFlights = !isAnyLoading &&
          airBlueController.filteredFlights.isEmpty &&
          flyDubaiController.filteredOutboundFlights.isEmpty &&
          flightController.filteredFlights.isEmpty &&
          piaController.filteredFlights.isEmpty &&
          airArabiaController.filteredFlights.isEmpty &&
          emiratesController.filteredFlights.isEmpty; // Add this

      // Show main loading indicator when all controllers are loading and no flights are available
      if (isAnyLoading && hasNoFlights) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Searching for flights...',
                style: TextStyle(
                  color: TColors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            // Total flights count
            _buildTotalFlightsCount(),

            const SizedBox(height: 6),


            // AirBlue flights section
            _buildAirBlueSection(),

            // FlyDubai flights section
            _buildFlyDubaiSection(),

            // Sabre flights section
            _buildSabreSection(),

            // PIA flights section
            _buildPIASection(),

            // Air Arabia flights section
            _buildAirArabiaSection(),

            // Emirates flights section
            _buildEmiratesSection(), // Add this


            const SizedBox(height: 36),
          ],
        ),
      );
    }),
  );
}
// Add this to the FlightBookingPage class

Widget _buildTotalFlightsCount() {
  return Obx(() {
    // Get total flight count including all airlines
    final totalFlights = controller.filteredFlights.length +
        airBlueController.flights.length +
        piaController.filteredFlights.length +
        airArabiaController.flights.length +
        flyDubaiController.filteredOutboundFlights.length +
        emiratesController.filteredFlights.length;

    final isLoading = controller.isLoading.value ||
        airBlueController.isLoading.value ||
        piaController.isLoading.value ||
        airArabiaController.isLoading.value ||
        flyDubaiController.isLoading.value ||
        emiratesController.isLoading.value;

    if (isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'We found $totalFlights ${totalFlights == 1 ? 'flight' : 'flights'} for you',
        style: const TextStyle(
          fontSize: 12,
          color: TColors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  });
}

Widget _buildEmiratesSection() {
  return Obx(() {
    if (emiratesController.isLoading.value) {
      return _buildSectionLoader('Emirates');
    }

    if (emiratesController.filteredFlights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: emiratesController.filteredFlights.map((flight) {
        return EmiratesFlightCard(flight: flight);
      }).toList(),
    );
  });
}
  Widget _buildAirBlueSection() {
    return Obx(() {
      if (airBlueController.isLoading.value) {
        return _buildSectionLoader('AirBlue');
      }

      if (airBlueController.filteredFlights.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: airBlueController.filteredFlights.map((flight) {
          return AirBlueFlightCard(flight: flight);
        }).toList(),
      );
    });
  }

  Widget _buildFlyDubaiSection() {
    return Obx(() {
      if (flyDubaiController.isLoading.value) {
        return _buildSectionLoader('FlyDubai');
      }

      if (flyDubaiController.filteredOutboundFlights.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: flyDubaiController.filteredOutboundFlights.map((flight) {
          return FlyDubaiFlightCard(flight: flight, showReturnFlight: false);
        }).toList(),
      );
    });
  }

  Widget _buildSabreSection() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildSectionLoader('Sabre');
      }

      if (controller.filteredFlights.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: controller.filteredFlights.map((flight) {
          return FlightCard(flight: flight);
        }).toList(),
      );
    });
  }

  Widget _buildPIASection() {
    return Obx(() {
      if (piaController.isLoading.value) {
        return _buildSectionLoader('PIA');
      }

      if (piaController.filteredFlights.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: piaController.filteredFlights.map((flight) {
          return GestureDetector(
            onTap: () => piaController.handlePIAFlightSelection(flight),
            child: PIAFlightCard(flight: flight),
          );
        }).toList(),
      );
    });
  }

  Widget _buildAirArabiaSection() {
    return Obx(() {
      if (airArabiaController.isLoading.value) {
        return _buildSectionLoader('Air Arabia');
      }

      if (airArabiaController.filteredFlights.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: airArabiaController.filteredFlights.map((flight) {
          return GestureDetector(
            onTap: () => airArabiaController.handleAirArabiaFlightSelection(flight),
            child: AirArabiaFlightCard(flight: flight),
          );
        }).toList(),
      );
    });
  }

  Widget _buildSectionLoader(String airlineName) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 16),
          Text(
            'Searching flights...',
            style: const TextStyle(
              color: TColors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String text, bool isSelected, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? TColors.primary : TColors.grey,
        backgroundColor: isSelected ? TColors.primary.withOpacity(0.1) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}