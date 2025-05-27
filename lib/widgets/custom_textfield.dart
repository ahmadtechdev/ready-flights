import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import 'colors.dart'; // Ensure you have this file with color definitions

class AirportData {
  final String code;
  final String name;
  final String cityName;
  final String countryName;
  final String cityCode;

  AirportData({
    required this.code,
    required this.name,
    required this.cityName,
    required this.countryName,
    required this.cityCode,
  });

  factory AirportData.fromJson(Map<String, dynamic> json) {
    return AirportData(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      cityName: json['city_name'] ?? '',
      countryName: json['country_name'] ?? '',
      cityCode: json['city_code'] ?? '',
    );
  }
}

enum FieldType { departure, destination }

class AirportController extends GetxController {
  var airports = <AirportData>[].obs;
  var defaultDepartureAirports = <AirportData>[].obs;
  var defaultDestinationAirports = <AirportData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var filteredAirports = <AirportData>[].obs;
  var isAirportsLoaded = false.obs;

  // Controllers for the displayed values
  final departureCodeController = TextEditingController().obs;
  final departureCityController = TextEditingController().obs;
  final destinationCodeController = TextEditingController().obs;
  final destinationCityController = TextEditingController().obs;

  final List<String> departureAirportCodes = [
    "KHI",
    "LHE",
    "ISB",
    "LYP",
    "PEW",
    "MUX",
    "SKT",
  ];

  final List<String> destinationAirportCodes = [
    "DXB",
    "JED",
    "MED",
    "LON",
    "CDG",
    "IST",
    "KUL",
    "GYD",
    "BKK",
  ];

  Future<void> fetchAirports() async {
    try {
      // Reset previous states
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http
          .get(
            Uri.parse('https://agent1.pk/api.php?type=airports'),
            headers: {'Connection': 'keep-alive'},
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Connection timeout');
            },
          );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success' && jsonData['data'] is List) {
          final List<dynamic> airportsData = jsonData['data'];

          // Check if data is actually received
          if (airportsData.isEmpty) {
            errorMessage.value = 'No airports found';
            return;
          }

          airports.value =
              airportsData.map((item) => AirportData.fromJson(item)).toList();

          _filterDefaultAirports();

          isAirportsLoaded.value = true;
        } else {
          errorMessage.value = jsonData['message'] ?? 'Invalid data format';
        }
      } else {
        errorMessage.value =
            'Failed to load airports. Status: ${response.statusCode}';
      }
    } on SocketException {
      errorMessage.value = 'No internet connection';
    } on TimeoutException {
      errorMessage.value = 'Connection timeout. Please try again';
    } catch (e) {
      errorMessage.value = 'Unexpected error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void _filterDefaultAirports() {
    if (airports.isEmpty) return;

    defaultDepartureAirports.value =
        airports
            .where((airport) => departureAirportCodes.contains(airport.code))
            .toList()
          ..sort((a, b) {
            final indexA = departureAirportCodes.indexOf(a.code);
            final indexB = departureAirportCodes.indexOf(b.code);
            return indexA.compareTo(indexB);
          });

    defaultDestinationAirports.value =
        airports
            .where((airport) => destinationAirportCodes.contains(airport.code))
            .toList()
          ..sort((a, b) {
            final indexA = destinationAirportCodes.indexOf(a.code);
            final indexB = destinationAirportCodes.indexOf(b.code);
            return indexA.compareTo(indexB);
          });
  }

  void searchAirports(String query, FieldType fieldType) {
    if (query.isEmpty) {
      filteredAirports.value =
          fieldType == FieldType.departure
              ? defaultDepartureAirports
              : defaultDestinationAirports;
    } else {
      final searchQuery = query.toLowerCase();
      filteredAirports.value =
          airports
              .where(
                (airport) =>
                    airport.cityName.toLowerCase().contains(searchQuery) ||
                    airport.name.toLowerCase().contains(searchQuery) ||
                    airport.code.toLowerCase().contains(searchQuery) ||
                    airport.countryName.toLowerCase().contains(searchQuery),
              )
              .toList();
    }
  }

  void swapAirports() {
    // Swap the text values
    final tempCodeText = departureCodeController.value.text;
    final tempCityText = departureCityController.value.text;

    departureCodeController.value.text = destinationCodeController.value.text;
    departureCityController.value.text = destinationCityController.value.text;

    destinationCodeController.value.text = tempCodeText;
    destinationCityController.value.text = tempCityText;
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final String? initialValue;
  final Function(String name, String code)? onCitySelected;
  final TextEditingController controller;
  final FieldType fieldType;

  final AirportController airportController = Get.put(AirportController());

  CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.initialValue,
    this.onCitySelected,
    TextEditingController? controller,
    this.fieldType = FieldType.departure,
  }) : controller = controller ?? TextEditingController(text: initialValue);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAirportSuggestions(context),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: TColors.primary),
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: TColors.primary, width: 1),
            ),
          ),
        ),
      ),
    );
  }

  void _showAirportSuggestions(BuildContext context) {
    // Reset any previous error
    airportController.errorMessage.value = '';

    // Trigger fetch if not loaded
    if (!airportController.isAirportsLoaded.value) {
      airportController.fetchAirports();
    }

    // Initialize with default airports
    airportController.filteredAirports.value =
        fieldType == FieldType.departure
            ? airportController.defaultDepartureAirports
            : airportController.defaultDestinationAirports;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fieldType == FieldType.departure
                          ? 'Select Departure Airport'
                          : 'Select Destination Airport',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search by city or airport name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged:
                      (value) =>
                          airportController.searchAirports(value, fieldType),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  // Prioritize error message
                  if (airportController.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            airportController.errorMessage.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => airportController.fetchAirports(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Loading state
                  if (airportController.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: TColors.primary),
                    );
                  }

                  // Search results header
                  final searchActive =
                      airportController.filteredAirports !=
                      (fieldType == FieldType.departure
                          ? airportController.defaultDepartureAirports
                          : airportController.defaultDestinationAirports);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        searchActive ? 'Search Results' : 'Suggested Airports',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (searchActive)
                        Text(
                          '${airportController.filteredAirports.length} results',
                          style: const TextStyle(color: TColors.grey),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 8),
                Expanded(
                  child: Obx(() {
                    // No airports found scenario
                    if (airportController.filteredAirports.isEmpty &&
                        !airportController.isLoading.value &&
                        airportController.errorMessage.value.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.airport_shuttle,
                              color: Colors.grey,
                              size: 50,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No airports found',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Airports list
                    return ListView.builder(
                      itemCount: airportController.filteredAirports.length,
                      itemBuilder: (context, index) {
                        final airport =
                            airportController.filteredAirports[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: TColors.primary,
                          ),
                          title: Text(
                            '${airport.cityName} (${airport.code})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${airport.name}, ${airport.countryName}',
                          ),
                          onTap: () {
                            controller.text =
                                '${airport.cityName} (${airport.code})';
                            if (onCitySelected != null) {
                              onCitySelected!(
                                airport.cityName,
                                airport.cityCode,
                              );
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
          ),
        );
      },
    );
  }
}

class AirportSelectionScreen extends StatelessWidget {
  AirportSelectionScreen({super.key});

  final TextEditingController departureController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Ensure AirportController is registered
    if (!Get.isRegistered<AirportController>()) {
      Get.put(AirportController());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Airport Selection')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              hintText: 'Select Departure',
              icon: Icons.flight_takeoff,
              controller: departureController,
              fieldType: FieldType.departure,
              onCitySelected: (cityName, cityCode) {
                print('Selected departure: $cityName ($cityCode)');
                // Handle departure selection
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Select Destination',
              icon: Icons.flight_land,
              controller: destinationController,
              fieldType: FieldType.destination,
              onCitySelected: (cityName, cityCode) {
                print('Selected destination: $cityName ($cityCode)');
                // Handle destination selection
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AirportSelectionPanel extends StatelessWidget {
  final Function(String cityName, String cityCode, FieldType type)?
  onCitySelected;
  final AirportController controller = Get.find<AirportController>();

  AirportSelectionPanel({super.key, this.onCitySelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // FROM - TO Header
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    "FROM",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    "TO",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Airport Selection Row
          IntrinsicHeight(
            child: Row(
              children: [
                // Departure Field
                Expanded(
                  child: GestureDetector(
                    onTap:
                        () => _showAirportSuggestions(
                          context,
                          FieldType.departure,
                        ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              controller
                                      .departureCodeController
                                      .value
                                      .text
                                      .isNotEmpty
                                  ? controller
                                      .departureCodeController
                                      .value
                                      .text
                                  : "DEL",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Obx(
                            () => Text(
                              controller
                                      .departureCityController
                                      .value
                                      .text
                                      .isNotEmpty
                                  ? controller
                                      .departureCityController
                                      .value
                                      .text
                                  : "NEW DELHI",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Swap Button
                Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.swap_horiz,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        controller.swapAirports();
                        // Notify parent about the swap
                        if (onCitySelected != null) {
                          // Notify about departure change
                          onCitySelected!(
                            controller.departureCityController.value.text,
                            controller.departureCodeController.value.text,
                            FieldType.departure,
                          );
                          // Notify about destination change
                          onCitySelected!(
                            controller.destinationCityController.value.text,
                            controller.destinationCodeController.value.text,
                            FieldType.destination,
                          );
                        }
                      },
                    ),
                  ),
                ),

                // Destination Field
                Expanded(
                  child: GestureDetector(
                    onTap:
                        () => _showAirportSuggestions(
                          context,
                          FieldType.destination,
                        ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              controller
                                      .destinationCodeController
                                      .value
                                      .text
                                      .isNotEmpty
                                  ? controller
                                      .destinationCodeController
                                      .value
                                      .text
                                  : "BOM",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Obx(
                            () => Text(
                              controller
                                      .destinationCityController
                                      .value
                                      .text
                                      .isNotEmpty
                                  ? controller
                                      .destinationCityController
                                      .value
                                      .text
                                  : "MUMBAI",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAirportSuggestions(BuildContext context, FieldType fieldType) {
    // Reset any previous error
    controller.errorMessage.value = '';

    // Trigger fetch if not loaded
    if (!controller.isAirportsLoaded.value) {
      controller.fetchAirports();
    }

    // Initialize with default airports
    controller.filteredAirports.value =
        fieldType == FieldType.departure
            ? controller.defaultDepartureAirports
            : controller.defaultDestinationAirports;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fieldType == FieldType.departure
                          ? 'Select Departure Airport'
                          : 'Select Destination Airport',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search by city or airport name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged:
                      (value) => controller.searchAirports(value, fieldType),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  // Prioritize error message
                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            controller.errorMessage.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => controller.fetchAirports(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Loading state
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: TColors.primary),
                    );
                  }

                  // Search results header
                  final searchActive =
                      controller.filteredAirports !=
                      (fieldType == FieldType.departure
                          ? controller.defaultDepartureAirports
                          : controller.defaultDestinationAirports);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        searchActive ? 'Search Results' : 'Suggested Airports',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (searchActive)
                        Text(
                          '${controller.filteredAirports.length} results',
                          style: const TextStyle(color: TColors.grey),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 8),
                Expanded(
                  child: Obx(() {
                    // No airports found scenario
                    if (controller.filteredAirports.isEmpty &&
                        !controller.isLoading.value &&
                        controller.errorMessage.value.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.airport_shuttle,
                              color: Colors.grey,
                              size: 50,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No airports found',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Airports list
                    return ListView.builder(
                      itemCount: controller.filteredAirports.length,
                      itemBuilder: (context, index) {
                        final airport = controller.filteredAirports[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: TColors.primary,
                          ),
                          title: Row(
                            children: [
                              Text(
                                airport.code,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  airport.cityName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${airport.name}, ${airport.countryName}',
                          ),
                          onTap: () {
                            // Update the appropriate controller based on field type
                            if (fieldType == FieldType.departure) {
                              controller.departureCodeController.value.text =
                                  airport.code;
                              controller.departureCityController.value.text =
                                  airport.cityName.toUpperCase();
                            } else {
                              controller.destinationCodeController.value.text =
                                  airport.code;
                              controller.destinationCityController.value.text =
                                  airport.cityName.toUpperCase();
                            }

                            if (onCitySelected != null) {
                              onCitySelected!(
                                airport.cityName,
                                airport.cityCode,
                                fieldType,
                              );
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
          ),
        );
      },
    );
  }
}
