import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../services/api_service_sabre.dart';
import '../../airblue/airblue_flight_controller.dart';
import '../../pia/pia_flight_controller.dart';
import '../../sabre/sabre_flight_controller.dart';
import '../filter_flight_model.dart';
import '../helper_functions.dart';

class FilterBottomSheet extends StatelessWidget {
  final FlightController controller;
  final AirBlueFlightController airBlueController;
  final PIAFlightController piaController;

  const FilterBottomSheet({
    super.key,
    required this.controller,
    required this.airBlueController,
    required this.piaController,
  });

  @override
  Widget build(BuildContext context) {
    final Rx<FlightFilter> currentFilter = FlightFilter().obs;

    // Get all available airlines from all providers
    final allAirlines = {
      ...controller.getAvailableAirlines(),
      'PA', // AirBlue
      'PK', // PIA
    }.toList()..sort();


    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Airlines Filter
          const Text('Airlines', style: TextStyle(fontWeight: FontWeight.bold)),
          Obx(() => Wrap(
            spacing: 8,
            children: allAirlines.map((code) {
              final airlineMap = Get.find<ApiServiceSabre>().getAirlineMap();
              final airlineInfo = getAirlineInfo(code, airlineMap);
              return FilterChip(
                label: Text(airlineInfo.name),
                selected: currentFilter.value.selectedAirlines.contains(code),
                onSelected: (selected) {
                  final newAirlines = Set<String>.from(currentFilter.value.selectedAirlines);
                  if (selected) {
                    newAirlines.add(code);
                  } else {
                    newAirlines.remove(code);
                  }
                  currentFilter.value = currentFilter.value.copyWith(selectedAirlines: newAirlines);
                },
              );
            }).toList(),
          )),

          const SizedBox(height: 16),

          // Stops Filter
          const Text('Stops', style: TextStyle(fontWeight: FontWeight.bold)),
          Obx(() => Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: currentFilter.value.maxStops == null,
                onSelected: (_) => currentFilter.value = currentFilter.value.copyWith(maxStops: null),
              ),
              FilterChip(
                label: const Text('Non-Stop'),
                selected: currentFilter.value.maxStops == 0,
                onSelected: (_) => currentFilter.value = currentFilter.value.copyWith(maxStops: 0),
              ),
              FilterChip(
                label: const Text('1 Stop'),
                selected: currentFilter.value.maxStops == 1,
                onSelected: (_) => currentFilter.value = currentFilter.value.copyWith(maxStops: 1),
              ),
              FilterChip(
                label: const Text('2 Stops'),
                selected: currentFilter.value.maxStops == 2,
                onSelected: (_) => currentFilter.value = currentFilter.value.copyWith(maxStops: 2),
              ),
            ],
          )),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Apply filters to all controllers
                    controller.applyFilters(currentFilter.value);
                    airBlueController.applyFilters(currentFilter.value);
                    piaController.applyFilters(currentFilter.value);
                    Get.back();
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}