// ignore_for_file: empty_catches

import 'package:get/get.dart';

import '../../../../services/api_service_sabre.dart';

import '../filters/filter_flight_model.dart';
import '../search_flight_utils/filter_flight_model.dart';
import '../flight_package/airblue/airblue_flight_package.dart';
import 'airblue_flight_model.dart';

class AirBlueFlightController extends GetxController {
  final ApiServiceSabre apiService = Get.find<ApiServiceSabre>();

  // Original list of AirBlue flights (never modified after parsing)
  final RxList<AirBlueFlight> _originalFlights = <AirBlueFlight>[].obs;

  // Filtered list of AirBlue flights (shown in UI)
  final RxList<AirBlueFlight> filteredFlights = <AirBlueFlight>[].obs;

  // Keep the flights getter for backward compatibility
  RxList<AirBlueFlight> get flights => filteredFlights;

  // Map to store all fare options for each RPH
  final RxMap<String, List<AirBlueFareOption>> fareOptionsByRPH = <String, List<AirBlueFareOption>>{}.obs;

  // Selected flights for round trip
  AirBlueFlight? selectedOutboundFlight;
  AirBlueFareOption? selectedOutboundFareOption;
  AirBlueFlight? selectedReturnFlight;
  AirBlueFareOption? selectedReturnFareOption;

  // Loading state
  final RxBool isLoading = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  final RxString sortType = 'Suggested'.obs;

  void clearFlights() {
    _originalFlights.clear();
    filteredFlights.clear();
    fareOptionsByRPH.clear();
    errorMessage.value = '';

    // Clear selected flights too
    selectedOutboundFlight = null;
    selectedOutboundFareOption = null;
    selectedReturnFlight = null;
    selectedReturnFareOption = null;
  }

  void setErrorMessage(String message) {
    errorMessage.value = message;
  }

  // Search AirBlue flights
  Future<void> parseApiResponse(Map<String, dynamic>? response) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Clear previous flights and options
      _originalFlights.clear();
      filteredFlights.clear();
      fareOptionsByRPH.clear();

      // Parse the response
      if (response == null ||
          response['soap\$Envelope'] == null ||
          response['soap\$Envelope']['soap\$Body'] == null) {
        isLoading.value = false;
        return;
      }

      final pricedItineraries =
      response['soap\$Envelope']['soap\$Body']['AirLowFareSearchResponse']?['AirLowFareSearchResult']?['PricedItineraries']?['PricedItinerary'];

      if (pricedItineraries == null) {
        isLoading.value = false;
        return;
      }

      // Temporary maps to store flights by RPH and ref number
      Map<String, List<Map<String, dynamic>>> outboundFlightsByRPH = {};
      Map<String, List<Map<String, dynamic>>> returnFlightsByRPH = {};

      // First, group all flights by RPH and ref number
      if (pricedItineraries is List) {
        for (var itinerary in pricedItineraries) {
          try {
            // Get the RPH value and ref number
            final originDestOption = itinerary['AirItinerary']?['OriginDestinationOptions']?['OriginDestinationOption'];
            final rph = originDestOption?['RPH']?.toString() ?? '';
            final refNumber = itinerary['OriginDestinationRefNumber']?.toString() ?? '1';

            // Add to appropriate map based on ref number
            if (refNumber == '1') {
              // Outbound flight
              if (!outboundFlightsByRPH.containsKey(rph)) {
                outboundFlightsByRPH[rph] = [];
              }
              outboundFlightsByRPH[rph]!.add(itinerary);
            } else {
              // Return flight
              if (!returnFlightsByRPH.containsKey(rph)) {
                returnFlightsByRPH[rph] = [];
              }
              returnFlightsByRPH[rph]!.add(itinerary);
            }
          } catch (e) {
          }
        }
      } else if (pricedItineraries is Map) {
        try {
          // Get the RPH value and ref number
          final originDestOption = pricedItineraries['AirItinerary']?['OriginDestinationOptions']?['OriginDestinationOption'];
          final rph = originDestOption?['RPH']?.toString() ?? '';
          final refNumber = pricedItineraries['OriginDestinationRefNumber']?.toString() ?? '1';

          // Add to appropriate map based on ref number
          if (refNumber == '1') {
            outboundFlightsByRPH[rph] = [Map<String, dynamic>.from(pricedItineraries)];
          } else {
            returnFlightsByRPH[rph] = [Map<String, dynamic>.from(pricedItineraries)];
          }
        } catch (e) {
        }
      }

      // Process outbound flights (refNumber = 1)
      outboundFlightsByRPH.forEach((rph, itineraries) {
        try {
          List<AirBlueFareOption> fareOptions = [];

          for (var itinerary in itineraries) {
            try {
              final flight = AirBlueFlight.fromJson(
                itinerary,
                apiService.airlineMap.value,
              );
              fareOptions.add(AirBlueFareOption.fromFlight(flight, itinerary));
            } catch (e) {
            }
          }

          if (fareOptions.isNotEmpty) {
            fareOptions.sort((a, b) => a.price.compareTo(b.price));
            fareOptionsByRPH[rph] = fareOptions;

            final lowestPriceOption = fareOptions.first;
            final representativeFlight = AirBlueFlight.fromJson(
              lowestPriceOption.rawData,
              apiService.airlineMap.value,
            ).copyWithFareOptions(fareOptions);

            _originalFlights.add(representativeFlight);
          }
        } catch (e) {
        }
      });

      // Store return flights (refNumber = 2) separately for later use
      returnFlightsByRPH.forEach((rph, itineraries) {
        try {
          List<AirBlueFareOption> fareOptions = [];

          for (var itinerary in itineraries) {
            try {
              final flight = AirBlueFlight.fromJson(
                itinerary,
                apiService.airlineMap.value,
              );
              fareOptions.add(AirBlueFareOption.fromFlight(flight, itinerary));
            } catch (e) {
            }
          }

          if (fareOptions.isNotEmpty) {
            fareOptions.sort((a, b) => a.price.compareTo(b.price));
            // Store with a prefix to distinguish return flights
            fareOptionsByRPH['return_$rph'] = fareOptions;
          }
        } catch (e) {
        }
      });

      // Sort original flights by price
      _originalFlights.sort((a, b) => a.price.compareTo(b.price));

      // Initialize filtered flights with all flights
      filteredFlights.assignAll(_originalFlights);
    } catch (e) {
      errorMessage.value = 'Failed to load AirBlue flights: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Add this method to get return flights when needed
  List<AirBlueFlight> getReturnFlights() {
    final returnFlights = <AirBlueFlight>[];

    fareOptionsByRPH.forEach((rph, options) {
      if (rph.startsWith('return_')) {
        if (options.isNotEmpty) {
          final representativeFlight = AirBlueFlight.fromJson(
            options.first.rawData,
            apiService.airlineMap.value,
          ).copyWithFareOptions(options);
          returnFlights.add(representativeFlight);
        }
      }
    });

    // Sort return flights by price
    returnFlights.sort((a, b) => a.price.compareTo(b.price));

    return returnFlights;
  }

  void loadFlights(Map<String, dynamic> apiResponse) {
    parseApiResponse(apiResponse);
  }

  // Current selected flight for package selection
  final Rx<AirBlueFlight?> selectedFlight = Rx<AirBlueFlight?>(null);

  void handleAirBlueFlightSelection(AirBlueFlight flight, {bool isReturnFlight = false}) {
    selectedFlight.value = flight;

    // Open the AirBlue package selection dialog
    Get.dialog(
      AirBluePackageSelectionDialog(
        flight: flight,
        isReturnFlight: isReturnFlight,
      ),
      barrierDismissible: false,
    );
  }

  // Get fare options for a selected flight
  List<AirBlueFareOption> getFareOptionsForFlight(AirBlueFlight flight) {
    String rphKey = flight.rph;

    // Check if we're dealing with a return flight
    if (selectedOutboundFlight != null && flight != selectedOutboundFlight) {
      // This might be a return flight, check both with and without 'return_' prefix
      if (fareOptionsByRPH.containsKey('return_${flight.rph}')) {
        rphKey = 'return_${flight.rph}';
      }
    }

    return fareOptionsByRPH[rphKey] ?? [];
  }

  // Add to airblue_flight_controller.dart
  void handleReturnFlightSelection(AirBlueFlight flight) {
    selectedReturnFlight = flight;

    // Open package selection for return flight
    Get.dialog(
      AirBluePackageSelectionDialog(
        flight: flight,
        isReturnFlight: true,
      ),
      barrierDismissible: false,
    );
  }

  // Updated apply filters method - now works on original flights and updates filtered flights
  void applyFilters({
    List<String>? airlines,
    List<String>? stops,
    String? sortType,
  }) {
    if (sortType != null) {
      this.sortType.value = sortType;
    }
    _applySortingAndFiltering(airlines: airlines, stops: stops);
  }

  // Method to apply sorting and filtering - works on _originalFlights, updates filteredFlights
  void _applySortingAndFiltering({
    List<String>? airlines,
    List<String>? stops,
  }) {
    // Start with original flights (never modified)
    List<AirBlueFlight> filtered = List.from(_originalFlights);

    // Apply airline filter
    if (airlines != null && !airlines.contains('all')) {
      filtered = filtered.where((flight) {
        // For AirBlue, check if PA is in the selected airlines
        // Since all AirBlue flights have airlineCode 'PA'
        return airlines.any((airlineCode) =>
        flight.airlineCode.toUpperCase() == airlineCode.toUpperCase());
      }).toList();
    }

    // Apply stops filter
    if (stops != null && !stops.contains('all')) {
      filtered = filtered.where((flight) {
        // Calculate stops based on segmentInfo
        int stopCount = flight.segmentInfo.length - 1;

        if (stops.contains('nonstop')) {
          return stopCount == 0;
        }
        if (stops.contains('1stop')) {
          return stopCount == 1;
        }
        if (stops.contains('2stop')) {
          return stopCount == 2;
        }
        if (stops.contains('3stop')) {
          return stopCount == 3;
        }
        return false;
      }).toList();
    }

    // Apply sorting
    switch (sortType.value) {
      case 'Cheapest':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Fastest':
        filtered.sort((a, b) {
          // Calculate total duration from legSchedules
          final aDuration = a.legSchedules.fold(0, (sum, leg) => sum + (leg['elapsedTime'] as int));
          final bDuration = b.legSchedules.fold(0, (sum, leg) => sum + (leg['elapsedTime'] as int));
          return aDuration.compareTo(bDuration);
        });
        break;
      case 'Suggested':
      default:
      // Keep original order (already sorted by price during parsing)
        break;
    }

    // Update the filtered flights list (this is what the UI shows)
    filteredFlights.assignAll(filtered);
  }

  // Method to get filtered flights by airline
  List<AirBlueFlight> getFlightsByAirline(String airlineCode) {
    return filteredFlights.where((flight) {
      return flight.airlineCode.toUpperCase() == airlineCode.toUpperCase();
    }).toList();
  }

  // Method to get flight count by airline
  int getFlightCountByAirline(String airlineCode) {
    return getFlightsByAirline(airlineCode).length;
  }

  // Method to get available airlines (for AirBlue, it's always just PA)
  List<FilterAirline> getAvailableAirlines() {
    if (_originalFlights.isEmpty) return [];

    return [
      FilterAirline(
        code: 'PA',
        name: 'Air Blue',
        logoPath: 'https://images.kiwi.com/airlines/64/PA.png',
      )
    ];
  }
}