import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utility/colors.dart';
import '../sabre/sabre_flight_controller.dart';
import '../airblue/airblue_flight_controller.dart';
import '../pia/pia_flight_controller.dart';
import '../airarabia/airarabia_flight_controller.dart';
import 'filter_flight_model.dart';
import 'flight_filter_service.dart';

class FlightFilterBottomSheet extends StatefulWidget {
  const FlightFilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<FlightFilterBottomSheet> createState() => _FlightFilterBottomSheetState();
}

class _FlightFilterBottomSheetState extends State<FlightFilterBottomSheet> {
  final FilterController filterController = Get.put(FilterController());
  final FlightController sabreController = Get.find<FlightController>();
  final AirArabiaFlightController airArabiaController = Get.find<AirArabiaFlightController>();
  final AirBlueFlightController airBlueController = Get.find<AirBlueFlightController>();
  final PIAFlightController piaController = Get.find<PIAFlightController>();

  @override
  void initState() {
    super.initState();
    // Refresh available airlines when bottom sheet opens
    filterController.loadAvailableAirlines();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: TColors.grey, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.text,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    filterController.resetFilters();
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: TColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Airlines section
                  _buildSectionTitle('Airlines'),
                  const SizedBox(height: 12),

                  // All Airlines checkbox
                  Obx(() => _buildCheckboxTile(
                    'All Airlines',
                    filterController.allAirlines.value,
                        (value) => filterController.toggleAllAirlines(value!),
                  )),

                  // Individual airline options
                  Obx(() {
                    if (filterController.availableAirlines.isEmpty) {
                      return const SizedBox();
                    }
                    return Column(
                      children: [
                        const SizedBox(height: 8),
                        ...filterController.availableAirlines.map((airline) =>
                            _buildAirlineTile(airline)
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  // Sort section
                  _buildSectionTitle('Sort'),
                  const SizedBox(height: 12),

                  Obx(() => _buildCheckboxTile(
                    'Cheapest',
                    filterController.sortType.value == 'Cheapest',
                        (value) {
                      if (value!) {
                        filterController.setCheapest();
                      } else {
                        filterController.setSuggested();
                      }
                    },
                  )),

                  Obx(() => _buildCheckboxTile(
                    'Fastest',
                    filterController.sortType.value == 'Fastest',
                        (value) {
                      if (value!) {
                        filterController.setFastest();
                      } else {
                        filterController.setSuggested();
                      }
                    },
                  )),

                  const SizedBox(height: 24),

                  // Stops section
                  _buildSectionTitle('Stops'),
                  const SizedBox(height: 12),

                  Obx(() => _buildCheckboxTile(
                    'All',
                    filterController.allStops.value,
                        (value) => filterController.toggleAllStops(value!),
                  )),

                  Obx(() => _buildCheckboxTile(
                    'Non-Stops',
                    filterController.nonStops.value,
                        (value) => filterController.toggleNonStops(value!),
                  )),

                  Obx(() => _buildCheckboxTile(
                    '1-Stop',
                    filterController.oneStop.value,
                        (value) => filterController.toggleOneStop(value!),
                  )),

                  Obx(() => _buildCheckboxTile(
                    '2-Stop',
                    filterController.twoStop.value,
                        (value) => filterController.toggleTwoStop(value!),
                  )),

                  Obx(() => _buildCheckboxTile(
                    '3-Stop',
                    filterController.threeStop.value,
                        (value) => filterController.toggleThreeStop(value!),
                  )),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: TColors.grey, width: 0.5),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  filterController.applyFilters();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: TColors.text,
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: TColors.primary,
            checkColor: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: TColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirlineTile(FilterAirline airline) {
    // Get flight count for this airline
    int flightCount;
    if(airline.code == "G9"){
      flightCount = airArabiaController.getFlightCountByAirline(airline.code);
    }else if (airline.code == "PA"){
      flightCount = airBlueController.getFlightCountByAirline(airline.code);

    }else if (airline.code =="PK"){
      flightCount = piaController.getFlightCountByAirline(airline.code);

    }else{
      flightCount = sabreController.getFlightCountByAirline(airline.code);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Obx(() => Checkbox(
            value: filterController.airlineFilters[airline.code] ?? false,
            onChanged: (value) {
              filterController.toggleAirlineFilter(airline.code, value!);
            },
            activeColor: TColors.primary,
            checkColor: Colors.white,
          )),
          const SizedBox(width: 8),
          // Airline logo
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: TColors.grey.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                airline.logoPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: TColors.grey.withOpacity(0.2),
                    child: const Icon(
                      Icons.flight,
                      size: 16,
                      color: TColors.grey,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: TColors.grey.withOpacity(0.1),
                    child: const Center(
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  airline.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: TColors.text,
                  ),
                ),
                Text(
                  '($flightCount)',
                  style: TextStyle(
                    fontSize: 12,
                    color: TColors.grey.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}