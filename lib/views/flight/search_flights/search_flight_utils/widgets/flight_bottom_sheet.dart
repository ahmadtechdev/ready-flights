import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utility/colors.dart';
import '../../flight_package/sabre/sabre_flight_controller.dart';

class FilterBottomSheet extends StatelessWidget {
  final FlightController controller;

  const FilterBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 32,
          ),
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStopOptionFilter(),
                    const Divider(thickness: 1),
                    _buildAirlinesFilter(),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopOptionFilter() {
    final stopOptions = [
      {'label': '0', 'value': '0 Stops'},
      {'label': '1', 'value': '1 Stop'},
      {'label': '2+', 'value': '2+ Stops'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, top: 16, bottom: 12),
          child: Text(
            'Stops',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
        ),
        Obx(() {
          final selectedStops = controller.filterState.value.selectedStops;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
            stopOptions.map((option) {
              final isSelected = selectedStops.contains(option['value']);

              return Expanded(
                child: GestureDetector(
                  onTap:
                      () => controller.toggleStopOption(
                    option['value'] as String,
                    !isSelected,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                      isSelected
                          ? TColors.primary.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                        isSelected
                            ? TColors.primary
                            : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        option['label'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color:
                          isSelected ? TColors.primary : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAirlinesFilter() {
    final airlines = controller.flights.map((f) => f.airline).toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, top: 12, bottom: 8),
          child: Text(
            'Airlines',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
        ),
        _buildAirlineOption('All Airlines', 'All Airlines'),
        ...airlines
            .map((airline) => _buildAirlineOption(airline, airline))
            .toList(),
      ],
    );
  }

  Widget _buildAirlineOption(String label, String value) {
    return Obx(() {
      final isSelected = controller.filterState.value.selectedAirlines.contains(
        value,
      );
      return InkWell(
        onTap: () => controller.toggleAirline(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected ? TColors.primary : TColors.grey,
                    width: 2,
                  ),
                  color: isSelected ? TColors.primary : TColors.background,
                ),
                child:
                isSelected
                    ? const Icon(Icons.check, size: 18, color: TColors.background)
                    : null,
              ),
              const SizedBox(width: 12),
              if (value != 'All Airlines')
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      'https://via.placeholder.com/32',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                      const Icon(Icons.flight, size: 20),
                    ),
                  ),
                ),
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => controller.resetFilters(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: TColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    color: TColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}