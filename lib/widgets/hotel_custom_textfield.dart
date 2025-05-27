import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/api_service_hotel.dart';

class CityData {
  final String value;
  final String countryCode;
  final String zone;
  final String label;

  CityData({
    required this.value,
    required this.countryCode,
    required this.zone,
    required this.label,
  });

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      value: json['value']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      zone: json['zone']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }

  String get displayName {
    return label;
  }

  // You may need these getters for backward compatibility with existing code
  String get cityStateCode => value;
  String get cityStateName => zone;
  String get countryName => label.split(', ').last;
  String get zoneName => zone;
  String get zoneCode => value.split('-').first;
}

class CityController extends GetxController {
  final ApiServiceHotel _apiService = Get.put(ApiServiceHotel());

  var cities = <CityData>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  Worker? _debounceWorker;

  @override
  void onInit() {
    super.onInit();
    _debounceWorker = debounce(
      searchQuery,
      (value) => _searchCities(value),
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    _debounceWorker?.dispose();
    super.onClose();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> _searchCities(String query) async {
    if (query.isEmpty) {
      cities.clear();
      return;
    }

    isLoading.value = true;
    cities.clear();

    try {
      final response = await _apiService.fetchCities(query);
      print("API Response: $response"); // Debug print

      if (response != null && response.isNotEmpty) {
        try {
          final cityList =
              response.map<CityData>((cityJson) {
                print("Processing city item: $cityJson");
                if (cityJson is Map<String, dynamic>) {
                  return CityData.fromJson(cityJson);
                } else {
                  print("Invalid city item format: $cityJson");
                  throw FormatException("Invalid city data format");
                }
              }).toList();

          cities.value = cityList;
        } catch (parseError) {
          print("Error parsing city data: $parseError");
          cities.clear();
          Get.snackbar(
            'Error',
            'Error processing city data. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        cities.clear();
        Get.snackbar(
          'Info',
          'No cities found for your search',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Error in city search: $e");
      cities.clear();
      Get.snackbar(
        'Error',
        'Failed to fetch cities. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final String? label;
  final Function(CityData)? onCitySelected;

  CustomTextField({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.label,
    this.onCitySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cityController = Get.put(CityController());

    return GestureDetector(
      onTap: () => _showCitySuggestions(context, cityController),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: hintText,
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  void _showCitySuggestions(
    BuildContext context,
    CityController cityController,
  ) {
    cityController.cities.clear();
    cityController.searchQuery.value = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select City',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search for a city',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) => cityController.updateSearchQuery(value),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (cityController.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return const SizedBox.shrink();
              }),
              Expanded(
                child: Obx(() {
                  if (cityController.cities.isEmpty) {
                    if (cityController.searchQuery.value.length >= 2 &&
                        !cityController.isLoading.value) {
                      return const Center(
                        child: Text(
                          'No cities found. Try a different search term.',
                        ),
                      );
                    }
                    return const Center(
                      child: Text('Start typing to search for cities'),
                    );
                  }

                  return ListView.builder(
                    itemCount: cityController.cities.length,
                    itemBuilder: (context, index) {
                      final city = cityController.cities[index];
                      return ListTile(
                        title: Text(city.zone),
                        subtitle: Text(city.label),
                        onTap: () {
                          controller.text = city.displayName;
                          if (onCitySelected != null) {
                            onCitySelected!(city);
                          }
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
