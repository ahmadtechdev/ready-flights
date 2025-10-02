// airarabia_flight_controller.dart
import 'package:get/get.dart';

import '../../../../services/api_service_airarabia.dart';
import '../filters/filter_flight_model.dart';
import '../flight_package/airarabia/airarabia_flight_package.dart';
import 'airarabia_flight_model.dart';

class AirArabiaFlightController extends GetxController {
  
  final ApiServiceAirArabia apiService = Get.find<ApiServiceAirArabia>();
   int selectedPackageIndex = 0;


  final RxList<AirArabiaFlight> flights = <AirArabiaFlight>[].obs;
  final RxList<AirArabiaFlight> filteredFlights = <AirArabiaFlight>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString sortType = 'Suggested'.obs;

  // Selected flight and package for booking
  AirArabiaFlight? selectedFlight;
  AirArabiaPackage? selectedPackage;

  void clearFlights() {
    flights.clear();
    filteredFlights.clear();
    errorMessage.value = '';
  }

  void setErrorMessage(String message) {
    errorMessage.value = message;
  }

  Future<void> loadFlights(Map<String, dynamic> apiResponse) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      flights.clear();

      if (apiResponse['status'] != 200) {
        throw Exception(apiResponse['message'] ?? 'Failed to load flights');
      }

      final data = apiResponse['data'];
      final ondWiseFlights = data['ondWiseFlightCombinations'];

      // Check if this is a round trip (has both outbound and inbound flights)
      final isRoundTrip = ondWiseFlights.keys.length > 1;

      if (isRoundTrip) {
        // Handle round trip flights
        _processRoundTripFlights(ondWiseFlights);
      } else {
        // Handle one-way flights (original logic)
        _processOneWayFlights(ondWiseFlights);
      }

      // // Sort flights by price initially
      // flights.sort((a, b) => a.price.compareTo(b.price));

      // Initialize filtered flights with all flights
      filteredFlights.value = List.from(flights);

      // Apply any existing filters immediately
      _applySortingAndFiltering();

    } catch (e) {
      errorMessage.value = 'Failed to load Air Arabia flights: $e';
    } finally {
      isLoading.value = false;
    }
  }
  void _processOneWayFlights(Map<String, dynamic> ondWiseFlights) {
    ondWiseFlights.forEach((route, dateWiseFlights) {
      final dateFlights = dateWiseFlights['dateWiseFlightCombinations'];
      dateFlights.forEach((date, flightData) {
        final flightOptions = flightData['flightOptions'];
        for (var option in flightOptions) {
          if (option['availabilityStatus'] == 'AVAILABLE') {
            try {
              final flight = AirArabiaFlight.fromJson(option);
              flights.add(flight);
            } catch (e) {
              // Skip invalid flight options
            }
          }
        }
      });
    });
  }

  void _processRoundTripFlights(Map<String, dynamic> ondWiseFlights) {
    // Get all flight routes
    final routes = ondWiseFlights.keys.toList();

    // We need to identify which route is outbound and which is inbound
    // The first route in the response is typically outbound, second is inbound
    final outboundRoute = routes[1];
    // ignore: unused_local_variable
    final inboundRoute = routes[0];

    // Get all outbound and inbound flight options
    final outboundFlights = <Map<String, dynamic>>[];
    final inboundFlights = <Map<String, dynamic>>[];

    ondWiseFlights.forEach((route, dateWiseFlights) {
      final dateFlights = dateWiseFlights['dateWiseFlightCombinations'];

      dateFlights.forEach((date, flightData) {
        final flightOptions = flightData['flightOptions'];
        for (var option in flightOptions) {
          if (option['availabilityStatus'] == 'AVAILABLE') {
            // Determine if this is outbound or inbound based on route
            final isOutbound = route == outboundRoute;

            if (isOutbound) {
              outboundFlights.add(option);
            } else {
              inboundFlights.add(option);
            }
            
          }
        }
      });
    });

    // Verify we have both directions
    if (outboundFlights.isEmpty || inboundFlights.isEmpty) {
      errorMessage.value = 'Incomplete round trip options available';
      return;
    }

    // When creating round trip packages, mark flights with direction
    for (var outbound in outboundFlights) {
      outbound['isOutbound'] = true;
      for (var inbound in inboundFlights) {
        inbound['isOutbound'] = false;
        try {
          final combinedFlight = _createRoundTripPackage(outbound, inbound);
          flights.add(combinedFlight);
        } catch (e) {
          // Skip invalid combinations
        }
      }
    }
  }

  AirArabiaFlight _createRoundTripPackage(
      Map<String, dynamic> outbound,
      Map<String, dynamic> inbound
      ) {
    // Combine flight segments (outbound first, then inbound)
    final combinedSegments = [
      ...outbound['flightSegments'],
      ...inbound['flightSegments']
    ];

    // Sum the prices
    final outboundPrice = outbound['cabinPrices'][0]['price'] as num;
    final inboundPrice = inbound['cabinPrices'][0]['price'] as num;
    final totalPrice = outboundPrice + inboundPrice;

    // Create a new flight option with combined data
    final combinedOption = {
      ...outbound,
      'flightSegments': combinedSegments,
      'cabinPrices': [
        {
          ...outbound['cabinPrices'][0],
          'price': totalPrice,
        }
      ],
      'isRoundTrip': true,
      'outboundFlight': outbound,
      'inboundFlight': inbound,
    };

    return AirArabiaFlight.fromJson(combinedOption);
  }

  void handleAirArabiaFlightSelection(AirArabiaFlight flight) {
    Get.to(
          () => AirArabiaPackageSelectionDialog(
        flight: flight,
        isReturnFlight: false,
      ),
    );
  }

  // Updated apply filters method with better airline filtering
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

  // Updated sorting and filtering with airline code support
  void _applySortingAndFiltering({
    List<String>? airlines,
    List<String>? stops,
  }) {
    List<AirArabiaFlight> filtered = List.from(flights);

    // Apply airline filter
    if (airlines != null && !airlines.contains('all')) {
      filtered = filtered.where((flight) {
        // For Air Arabia, check if G9 is in the selected airlines
        // Since all Air Arabia flights have airlineCode 'G9'
        return airlines.any((airlineCode) =>
        flight.airlineCode.toUpperCase() == airlineCode.toUpperCase()
        );
      }).toList();

    }
    // Apply stops filter
    if (stops != null && !stops.contains('all')) {
      filtered = filtered.where((flight) {
        // Calculate stops based on flight segments
        int stopCount = flight.flightSegments.length - 1;

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
        return false; // If no matching stop filter, exclude the flight
      }).toList();
    }

    // Apply sorting
    switch (sortType.value) {
      case 'Cheapest':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Fastest':
        filtered.sort((a, b) => a.totalDuration.compareTo(b.totalDuration));
        break;
      case 'Suggested':
      default:
      // Keep original order or apply suggested logic
      // You can implement custom suggested logic here
        break;
    }

    filteredFlights.value = filtered;
  }

  // Method to get filtered flights by airline
  List<AirArabiaFlight> getFlightsByAirline(String airlineCode) {
    return flights.where((flight) {
      return flight.airlineCode.toUpperCase() == airlineCode.toUpperCase();
    }).toList();
  }

  // Method to get flight count by airline
  int getFlightCountByAirline(String airlineCode) {
    return getFlightsByAirline(airlineCode).length;
  }

  // Method to get available airlines (for Air Arabia, it's always just G9)
  List<FilterAirline> getAvailableAirlines() {
    if (flights.isEmpty) return [];

    return [
      FilterAirline(
        code: 'G9',
        name: 'Air Arabia',
        logoPath: 'https://images.kiwi.com/airlines/64/G9.png',
      )
    ];
  }



}

