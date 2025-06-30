// ignore_for_file: empty_catches

import 'package:get/get.dart';

import '../../../../services/api_service_sabre.dart';

import '../search_flight_utils/filter_flight_model.dart';
import '../flight_package/airblue/airblue_flight_package.dart';
import 'airblue_flight_model.dart';

class AirBlueFlightController extends GetxController {
  final ApiServiceSabre apiService = Get.find<ApiServiceSabre>();

  // List of AirBlue flights (now with unique RPH)
  final RxList<AirBlueFlight> flights = <AirBlueFlight>[].obs;



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

  void clearFlights() {

    flights.clear();
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
      flights.clear();
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

            flights.add(representativeFlight);
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

      // Sort flights by price
      flights.sort((a, b) => a.price.compareTo(b.price));
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
}

// In airblue_flight_controller.dart
extension AirBlueFlightFiltering on AirBlueFlightController {
  void applyFilters(FlightFilter filter) {
    // Filter by airlines (AirBlue only)
    List<AirBlueFlight> airlineFiltered = flights.where((flight) {
      if (filter.selectedAirlines.isEmpty) return true;
      return filter.selectedAirlines.contains('PA'); // AirBlue's code
    }).toList();

    // Filter by stops (AirBlue flights are usually non-stop)
    List<AirBlueFlight> stopsFiltered = airlineFiltered.where((flight) {
      if (filter.maxStops == null) return true;
      return flight.stopSchedules.length <= filter.maxStops! + 1;
    }).toList();

    // Sort
    List<AirBlueFlight> sorted = [...stopsFiltered];
    switch (filter.sortType) {
      case 'Cheapest':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Fastest':
        sorted.sort((a, b) {
          int aDuration = _calculateTotalDuration(a.legSchedules);
          int bDuration = _calculateTotalDuration(b.legSchedules);
          return aDuration.compareTo(bDuration);
        });
        break;
      default:
      // Suggested sorting
        break;
    }

    flights.value = sorted;
  }

  int _calculateTotalDuration(List<Map<String, dynamic>> legSchedules) {
    return legSchedules.fold(0, (sum, leg) {
      return sum + (leg['elapsedTime'] as int? ?? 0);
    });
  }
}