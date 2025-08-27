// controllers/flydubai_flight_controller.dart

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ready_flights/views/flight/search_flights/flydubai/flydubai_model.dart';
import 'dart:developer' as developer;

import '../../../../services/api_service_flydubai.dart';
import '../filters/filter_flight_model.dart';
import '../flight_package/flydubai/flydubai_package.dart';
import '../sabre/sabre_flight_models.dart';

class FlydubaiFlightController extends GetxController {
  // Use the separate API service
  final ApiServiceFlyDubai apiService = Get.put(ApiServiceFlyDubai());

  // Original list of Flydubai flights (never modified after parsing)
  final RxList<FlydubaiFlight> _originalFlights = <FlydubaiFlight>[].obs;

  // Filtered list of Flydubai flights (shown in UI)
  final RxList<FlydubaiFlight> filteredFlights = <FlydubaiFlight>[].obs;

  // Keep the flights getter for backward compatibility
  RxList<FlydubaiFlight> get flights => filteredFlights;

  // Map to store all fare options for each LFID
  final RxMap<String, List<FlydubaiFlightFare>> fareOptionsByLFID = <String, List<FlydubaiFlightFare>>{}.obs;

  // Selected flights for round trip
  FlydubaiFlight? selectedOutboundFlight;
  FlydubaiFlightFare? selectedOutboundFareOption;
  FlydubaiFlight? selectedReturnFlight;
  FlydubaiFlightFare? selectedReturnFareOption;

  // Observable selected flight for UI updates
  final Rx<FlydubaiFlight?> selectedFlight = Rx<FlydubaiFlight?>(null);

  // Loading state
  final RxBool isLoading = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  // Sort type
  final RxString sortType = 'Suggested'.obs;

  void clearFlights() {
    _originalFlights.clear();
    filteredFlights.clear();
    fareOptionsByLFID.clear();
    errorMessage.value = '';

    // Clear selected flights too
    selectedOutboundFlight = null;
    selectedOutboundFareOption = null;
    selectedReturnFlight = null;
    selectedReturnFareOption = null;
  }

  void loadFlights(Map<String, dynamic> result) {
    try {
      debugPrint('=== LOADING FLYDUBAI FLIGHTS ===');

      if (result.containsKey('flights')) {
        parseApiResponse(result['flights']);
        debugPrint('FlyDubai flights loaded from API result');
      } else {
        setErrorMessage('No flights data in result');
        debugPrint('No flights key found in result: ${result.keys}');
      }
    } catch (e) {
      debugPrint('Error loading FlyDubai flights: $e');
      setErrorMessage('Failed to load flights: $e');
    }
  }

  void setErrorMessage(String message) {
    errorMessage.value = message;
    developer.log('FlyDubai Controller Error: $message');
  }

  // Main method to search flights - uses the API service
  Future<void> searchFlights({
    required int type, // 0 = one-way, 1 = round-trip, 2 = multi-city
    required String origin,
    required String destination,
    required String depDate,
    required int adult,
    required int child,
    required int infant,
    required String cabin,
    List<Map<String, String>>? multiCitySegments,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      clearFlights();

      developer.log('=== FlyDubai Controller: Starting flight search ===');
      developer.log('Search Parameters:');
      developer.log('Type: $type');
      developer.log('Origin: $origin');
      developer.log('Destination: $destination');
      developer.log('Departure Date: $depDate');
      developer.log('Passengers: Adult=$adult, Child=$child, Infant=$infant');
      developer.log('Cabin: $cabin');

      // Clean the origin and destination parameters
      String cleanOrigin = origin.replaceAll(',', '').trim();
      String cleanDestination = destination.replaceAll(',', '').trim();
      String cleanDepDate = depDate.replaceAll(',', '').trim();

      developer.log('Cleaned Parameters:');
      developer.log('Clean Origin: $cleanOrigin');
      developer.log('Clean Destination: $cleanDestination');
      developer.log('Clean DepDate: $cleanDepDate');

      // Call the API service with cleaned parameters
      final result = await apiService.searchFlights(
        type: type,
        origin: ',$cleanOrigin', // Add comma back for API format
        destination: ',$cleanDestination', // Add comma back for API format
        depDate: ',$cleanDepDate', // Add comma back for API format
        adult: adult,
        child: child,
        infant: infant,
        cabin: cabin,
        multiCitySegments: multiCitySegments,
      );

      developer.log('FlyDubai API Result Keys: ${result.keys}');

      // Process the result
      if (result.containsKey('error')) {
        setErrorMessage(result['error']);
        developer.log('FlyDubai API Error: ${result['error']}');
      } else if (result.containsKey('flights') && result['success'] == true) {
        // Parse the response with search parameters for validation
        await parseApiResponse(result['flights'],
            expectedOrigin: cleanOrigin,
            expectedDestination: cleanDestination);
        developer.log('FlyDubai flights loaded: ${filteredFlights.length}');
      } else {
        setErrorMessage('Invalid FlyDubai API response format');
        developer.log('Invalid FlyDubai API response structure: ${result.keys}');
      }

    } catch (e) {
      developer.log('FlyDubai Controller search error: $e');
      setErrorMessage('Failed to search flights: $e');
    } finally {
      isLoading.value = false;
    }
  }

// Updated parseApiResponse method with validation
// Updated parseApiResponse method in FlydubaiFlightController

  Future<void> parseApiResponse(Map<String, dynamic>? response, {
    String? expectedOrigin,
    String? expectedDestination,
  }) async {
    try {
      // Clear previous flights and options
      _originalFlights.clear();
      filteredFlights.clear();
      fareOptionsByLFID.clear();

      if (response == null) {
        setErrorMessage('No response data received');
        return;
      }

      developer.log('=== PARSING FLYDUBAI API RESPONSE ===');
      developer.log('Raw response keys: ${response.keys}');

      final flydubaiResponse = FlydubaiResponse.fromJson(response);

      if (!flydubaiResponse.success) {
        setErrorMessage(flydubaiResponse.errorMessage ?? 'Failed to parse response');
        return;
      }

      developer.log('Found ${flydubaiResponse.flightSegments.length} flight segments');

      // Create airline map for FlyDubai
      final airlineMap = {
        'FZ': AirlineInfo('FlyDubai', 'https://images.kiwi.com/airlines/64/FZ.png')
      };

      // Process all segments
      for (var segment in flydubaiResponse.flightSegments) {
        try {
          developer.log('Processing segment LFID: ${segment.lfid}');
          developer.log('Segment route: ${segment.origin} -> ${segment.destination}');

          // Check if segment has valid fare data
          if (segment.fareTypes.isEmpty) {
            developer.log('Skipping segment ${segment.lfid} - no fare data');
            continue;
          }

          // Validate route if expected values provided
          if (expectedOrigin != null && expectedDestination != null) {
            if (segment.origin != expectedOrigin || segment.destination != expectedDestination) {
              developer.log('Skipping segment - route mismatch: ${segment.origin}-${segment.destination} vs $expectedOrigin-$expectedDestination');
              continue;
            }
          }

          // Create flight with actual segment data
          final flight = FlydubaiFlight.fromFlightSegment(
            segment,
            airlineMap,
            response,
            expectedOrigin: segment.origin,
            expectedDestination: segment.destination,
          );

          // Store fare options by LFID
          fareOptionsByLFID[segment.lfid.toString()] = segment.fareTypes;

          _originalFlights.add(flight);
          developer.log('✅ Added flight: ${flight.airlineCode} ${flight.flightSegment.flightNumber} - ${flight.flightSegment.origin} to ${flight.flightSegment.destination} - PKR ${flight.price}');

        } catch (e) {
          developer.log('❌ Error processing segment ${segment.lfid}: $e');
          // Continue processing other segments
          continue;
        }
      }

      // Sort original flights by price
      _originalFlights.sort((a, b) => a.price.compareTo(b.price));

      // Initialize filtered flights with all flights
      filteredFlights.assignAll(_originalFlights);

      developer.log('=== PARSING COMPLETE ===');
      developer.log('Successfully parsed ${_originalFlights.length} FlyDubai flights');

      if (_originalFlights.isEmpty) {
        setErrorMessage('No FlyDubai flights found for the selected route and dates');
      }

    } catch (e, stackTrace) {
      developer.log('❌ Parse API response error: $e');
      developer.log('Stack trace: $stackTrace');
      setErrorMessage('Failed to parse FlyDubai response: $e');
    }
  }// Enhanced city code normalization for ALL routes

  void handleFlydubaiFlightSelection(FlydubaiFlight flight, {bool isReturnFlight = false}) {
    if (isReturnFlight) {
      selectedReturnFlight = flight;
      developer.log('Selected FlyDubai return flight: ${flight.airlineCode} ${flight.flightSegment.flightNumber}');
    } else {
      selectedOutboundFlight = flight;
      selectedFlight.value = flight;
      developer.log('Selected FlyDubai outbound flight: ${flight.airlineCode} ${flight.flightSegment.flightNumber}');
    }

    // Show package selection dialog
    Get.dialog(
      FlyDubaiPackageSelectionDialog(
        flight: flight,
        isReturnFlight: isReturnFlight,
      ),
      barrierDismissible: false,
    );
  }

// Add this method to get return flights (similar to AirBlue)
  List<FlydubaiFlight> getReturnFlights() {
    // This would contain your logic to get return flights
    // For now, returning empty list - implement based on your requirements
    return [];
  }


  // Get fare options for a selected flight
  List<FlydubaiFlightFare> getFareOptionsForFlight(FlydubaiFlight flight) {
    return fareOptionsByLFID[flight.rph] ?? [];
  }

  // Apply filters method - works on original flights and updates filtered flights
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

  // Method to apply sorting and filtering
  void _applySortingAndFiltering({
    List<String>? airlines,
    List<String>? stops,
  }) {
    // Start with original flights (never modified)
    List<FlydubaiFlight> filtered = List.from(_originalFlights);

    // Apply airline filter (for FlyDubai, only FZ is available)
    if (airlines != null && !airlines.contains('all') && !airlines.contains('FZ')) {
      filtered.clear(); // No flights if FlyDubai is not selected
    }

    // Apply stops filter
    if (stops != null && !stops.contains('all')) {
      filtered = filtered.where((flight) {
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
    developer.log('Applied filters: ${filtered.length} FlyDubai flights after filtering');
  }

  // Method to get available airlines (for Flydubai, it's always just FZ)
  List<FilterAirline> getAvailableAirlines() {
    if (_originalFlights.isEmpty) return [];

    return [
      FilterAirline(
        code: 'FZ',
        name: 'FlyDubai',
        logoPath: 'https://images.kiwi.com/airlines/64/FZ.png',
      )
    ];
  }

  // Test method for API diagnostics
  Future<void> testFlydubaiAPI() async {
    try {
      developer.log('=== TESTING FLYDUBAI API VIA CONTROLLER ===');

      final testResult = await apiService.testConnection();

      if (testResult['success']) {
        developer.log('✅ FlyDubai API test successful via controller');
      } else {
        developer.log('❌ FlyDubai API test failed: ${testResult['error']}');
        setErrorMessage('API test failed: ${testResult['error']}');
      }

    } catch (e) {
      developer.log('❌ FlyDubai API controller test error: $e');
      setErrorMessage('Controller test failed: $e');
    }
  }

}
// AirlineInfo is now imported from sabre_flight_models.dart AirlineInfo(this.name, this.logoPath);