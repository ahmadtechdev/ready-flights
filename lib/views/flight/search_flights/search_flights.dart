import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utility/colors.dart';
import 'airarabia/airarabia_flight_controller.dart';
import 'airblue/airblue_flight_controller.dart';
import 'pia/pia_flight_controller.dart';
import 'sabre/sabre_flight_controller.dart';
import 'search_flight_utils/filter_flight_model.dart';
import 'search_flight_utils/widgets/airarabia_flight_card.dart';
import 'search_flight_utils/widgets/airblue_flight_card.dart';
import 'search_flight_utils/widgets/currency_dialog.dart';
import 'search_flight_utils/widgets/flight_bottom_sheet.dart';
import 'search_flight_utils/widgets/pia_flight_card.dart';
import 'search_flight_utils/widgets/sabre_flight_card.dart';

enum FlightScenario { oneWay, returnFlight, multiCity }



class FlightBookingPage extends StatelessWidget {
  final FlightScenario scenario;
  final FlightController controller = Get.put(FlightController());
  final AirBlueFlightController airBlueController = Get.find<AirBlueFlightController>();
  final PIAFlightController piaController = Get.put(PIAFlightController());
  final AirArabiaFlightController airArabiaController = Get.put(AirArabiaFlightController());

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
        leading: const BackButton(),
        title: Obx(() {
          // Get total flight count
          final totalFlights = controller.filteredFlights.length + airBlueController.flights.length + piaController.filteredFlights.length;
          final isLoading = controller.isLoading.value || airBlueController.isLoading.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isLoading)
                    const Text(
                      'Searching flights...',
                      style: TextStyle(
                        fontSize: 16,
                        color: TColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      '$totalFlights Flights Found',
                      style: const TextStyle(
                        fontSize: 16,
                        color: TColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Show loading indicator in the title
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ],
          );
        }),
        actions: [
          GetX<FlightController>(
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
          _buildFilterSection(),
          _buildFlightList(),
        ],
      ),
    );
  }


  Widget _buildFilterSection() {
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
                'Suggested', controller.sortType.value == 'Suggested')),
            Obx(() => _filterButton(
                'Cheapest', controller.sortType.value == 'Cheapest')),
            Obx(() =>
                _filterButton('Fastest', controller.sortType.value == 'Fastest')),
            OutlinedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: Get.context!,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => FilterBottomSheet(
                    controller: controller,
                    airBlueController: airBlueController,
                    piaController: piaController,
                  ),
                );
              },
              child: const Row(
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

  Widget _buildFlightList() {
    final airBlueController = Get.find<AirBlueFlightController>();
    final piaController = Get.put(PIAFlightController());
    final flightController = Get.find<FlightController>();

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Sabre flights section
            Obx(() {
              if (flightController.isLoading.value && flightController.filteredFlights.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: flightController.filteredFlights.length,
                itemBuilder: (context, index) {
                  final flight = flightController.filteredFlights[index];
                  return GestureDetector(
                    onTap: () => flightController.handleFlightSelection(flight),
                    child: FlightCard(flight: flight),
                  );
                },
              );
            }),
        
            // AirBlue flights section (only if not multi-city)
            Obx(() {
              // if (tripType.value == TripType.multiCity) return const SizedBox();
              if (airBlueController.isLoading.value && airBlueController.flights.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: airBlueController.flights.length,
                itemBuilder: (context, index) {
                  final flight = airBlueController.flights[index];
                  return GestureDetector(
                    onTap: () => airBlueController.handleAirBlueFlightSelection(flight),
                    child: AirBlueFlightCard(flight: flight),
                  );
                },
              );
            }),
        
            // PIA flights section
            Obx(() {
              if (piaController.isLoading.value && piaController.filteredFlights.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: piaController.filteredFlights.length,
                itemBuilder: (context, index) {
                  final flight = piaController.filteredFlights[index];
                  return GestureDetector(
                    onTap: () => piaController.handlePIAFlightSelection(flight),
                    child: PIAFlightCard(flight: flight),
                  );
                },
              );
            }),


            // Air Arabia flights section
            Obx(() {
              if (airArabiaController.isLoading.value && airArabiaController.flights.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: airArabiaController.flights.length,
                itemBuilder: (context, index) {
                  final flight = airArabiaController.flights[index];
                  return GestureDetector(
                    onTap: () {
                      // Handle Air Arabia flight selection
                    },
                    child: AirArabiaFlightCard(flight: flight),
                  );
                },
              );
            }),


          ],
        ),
      ),
    );
  }
  Widget _filterButton(String text, bool isSelected) {
    return TextButton(
      onPressed: () {
        // Update sort type in all controllers
        controller.updateSortType(text);
        airBlueController.applyFilters(FlightFilter(sortType: text));
        airArabiaController.applyFilters(FlightFilter(sortType: text));
        piaController.applyFilters(FlightFilter(sortType: text));
      },
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? TColors.primary : TColors.grey,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

