import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/views/flight/search_flights/flydubai/flydubai_controller.dart';
import 'package:ready_flights/views/flight/search_flights/search_flight_utils/widgets/flydubai_flight_card.dart';
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

enum FlightScenario { oneWay, returnFlight, multiCity }

class FlightBookingPage extends StatelessWidget {
  final FlightScenario scenario;
  final SabreFlightController controller = Get.put(SabreFlightController());
  final AirBlueFlightController airBlueController = Get.find<AirBlueFlightController>();
  final PIAFlightController piaController = Get.put(PIAFlightController());
  final AirArabiaFlightController airArabiaController = Get.put(AirArabiaFlightController());
  final FlydubaiFlightController flyDubaiController = Get.put(FlydubaiFlightController()); // Add this controller
  final FilterController filterController = Get.put(FilterController());

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
          // Get total flight count including FlyDubai
          final totalFlights = controller.filteredFlights.length +
              airBlueController.flights.length +
              piaController.filteredFlights.length +
              airArabiaController.flights.length +
              flyDubaiController.filteredFlights.length; // Add FlyDubai count

          final isLoading = controller.isLoading.value ||
              airBlueController.isLoading.value ||
              piaController.isLoading.value ||
              airArabiaController.isLoading.value ||
              flyDubaiController.isLoading.value; // Add FlyDubai loading state

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

  Widget _buildFlightList() {
    final airBlueController = Get.find<AirBlueFlightController>();
    final piaController = Get.put(PIAFlightController());
    final flightController = Get.find<SabreFlightController>();

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

            // AirBlue flights section
            Obx(() {
              if (airBlueController.isLoading.value && airBlueController.filteredFlights.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: airBlueController.filteredFlights.length,
                itemBuilder: (context, index) {
                  final flight = airBlueController.filteredFlights[index];
                  return GestureDetector(
                    onTap: () => airBlueController.handleAirBlueFlightSelection(flight),
                    child: AirBlueFlightCard(flight: flight),
                  );
                },
              );
            }),



// FlyDubai flights section
            Obx(() {
              if (flyDubaiController.isLoading.value && flyDubaiController.filteredFlights.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: flyDubaiController.filteredFlights.length,
                itemBuilder: (context, index) {
                  final flight = flyDubaiController.filteredFlights[index];
                  return GestureDetector(
                    onTap: () => flyDubaiController.handleFlydubaiFlightSelection(flight),
                    child: FlyDubaiFlightCard(flight: flight),
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
              if (airArabiaController.isLoading.value && airArabiaController.filteredFlights.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: airArabiaController.filteredFlights.length,
                itemBuilder: (context, index) {
                  final flight = airArabiaController.filteredFlights[index];
                  return GestureDetector(
                    onTap: () => airArabiaController.handleAirArabiaFlightSelection(flight),
                    child: AirArabiaFlightCard(flight: flight),
                  );
                },
              );
            }),

            const SizedBox(height: 36),
          ],
        ),
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
  }}