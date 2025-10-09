// flydubai_extras_controller.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/services/api_service_flydubai.dart';
import 'package:ready_flights/views/flight/search_flights/flydubai/flydubai_model.dart';
import 'package:ready_flights/views/flight/search_flights/flydubai/flydubai_controller.dart';

class FlydubaiExtrasController extends GetxController {
  final ApiServiceFlyDubai _apiService = Get.find<ApiServiceFlyDubai>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Extras data
  final RxList<dynamic> availableBaggage = <dynamic>[].obs;
  final RxList<dynamic> availableMeals = <dynamic>[].obs;
  final RxList<dynamic> availableSeats = <dynamic>[].obs;

  // Selected extras
  // Keys strategy:
  // - For baggage: "seg{segmentCode}|p{passengerId}"
  // - For meals:   "seg{segmentCode}|p{passengerId}"
  // - For seats:   "seg{segmentCode}|p{passengerId}"
  final RxMap<String, dynamic> selectedBaggage = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> selectedMeals = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> selectedSeats = <String, dynamic>{}.obs;

  // Flight information
  final Rx<FlydubaiFlight?> selectedFlight = Rx<FlydubaiFlight?>(null);
  final Rx<FlydubaiFlightFare?> selectedFare = Rx<FlydubaiFlightFare?>(null);
  final RxList<String> bookingIds = <String>[].obs;

  // Passengers (exclude infants for extras)
  final RxInt adultPassengers = 1.obs;
  final RxInt childPassengers = 0.obs;
  final RxInt infantPassengers = 0.obs;
  final RxList<String> passengerIds = <String>[].obs; // p0, p1, ... for adults+children only

  // Pricing
  final RxDouble basePrice = 0.0.obs;
  final RxDouble totalExtrasPrice = 0.0.obs;
  final RxString currency = 'PKR'.obs;

  @override
  void onInit() {
    super.onInit();
    reset();

    // Check if screen was called with arguments for extras
    final arguments = Get.arguments;
    if (arguments != null) {
      _loadExtras(arguments);
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Ensure passengers are initialized even if not passed in arguments
    if (passengerIds.isEmpty) {
      _initializePassengerIds();
    }
  }

  Future<void> _loadExtras(Map<String, dynamic> args) async {
    final flight = args['flight'] as FlydubaiFlight?;
    final fare = args['fare'] as FlydubaiFlightFare?;
    final isReturn = args['isReturn'] as bool? ?? false;

    // Passenger counts (with defaults)
    adultPassengers.value = (args['adult'] as int?) ?? 1;
    childPassengers.value = (args['child'] as int?) ?? 0;
    infantPassengers.value = (args['infant'] as int?) ?? 0;

    // Initialize passenger IDs immediately
    _initializePassengerIds();

    debugPrint('Passengers initialized: Adults=${adultPassengers.value}, Children=${childPassengers.value}, Total IDs=${passengerIds.length}');

    if (flight != null && fare != null) {
      await loadFlightExtras(flight, fare, isReturn);
    }
  }
  Future<bool> loadFlightExtras(FlydubaiFlight flight, FlydubaiFlightFare fare, bool isReturnFlight) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Store flight and fare info
      selectedFlight.value = flight;
      selectedFare.value = fare;

      // Generate booking IDs. For round-trip, include both outbound and return.
      final List<String> ids = [];

      // If this is return-leg extras, try to add outbound bookingId first
      if (isReturnFlight) {
        try {
          final flyController = Get.find<FlydubaiFlightController>();
          final outboundFlight = flyController.selectedOutboundFlight;
          final outboundFare = flyController.selectedOutboundFareOption;
          if (outboundFlight != null && outboundFare != null) {
            final outboundFareIndex = _getFareIndex(outboundFlight, outboundFare);
            ids.add('${outboundFlight.flightSegment.lfid}_$outboundFareIndex');
          }
        } catch (_) {}
      }

      // Always add current leg bookingId (outbound for one-way, return for round-trip)
      final currentFareIndex = _getFareIndex(flight, fare);
      ids.add('${flight.flightSegment.lfid}_$currentFareIndex');

      bookingIds.value = ids;

      // Set base price
      basePrice.value = flight.price;
      currency.value = flight.currency;

      // Load all extras in parallel
      final results = await Future.wait([
        _apiService.getSeatOptions(bookingIds: bookingIds, flightData: flight.rawData),
        _apiService.getBaggageOptions(bookingIds: bookingIds, flightData: flight.rawData),
        _apiService.getMealOptions(bookingIds: bookingIds, flightData: flight.rawData),
      ]);

      // Process results
      for (final result in results) {
        if (result['success'] != true) {
          errorMessage.value = result['error'] ?? 'Failed to load extras';
          return false;
        }
      }

      // Extract data from responses
      final seatData = results[0]['data'];
      final baggageData = results[1]['data'];
      final mealData = results[2]['data'];

      // Process the data (you'll need to adapt this based on the actual API response structure)
      _processSeatData(seatData);
      _processBaggageData(baggageData);
      _processMealData(mealData);

      return true;
    } catch (e) {
      errorMessage.value = 'Error loading extras: ${e.toString()}';
      print('Extras loading error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }



  void _processBaggageData(Map<String, dynamic> data) {
    try {
      final List<dynamic> baggageOptions = [];

      // Parse baggage data from API response
      if (data['ServiceOffers'] is List) {
        final serviceOffers = data['ServiceOffers'] as List;

        for (var offer in serviceOffers) {
          final offerCode = offer['offerCode']?.toString() ?? '';
          final description = offer['description']?.toString() ?? 'Baggage';
          final amount = offer['amount']?.toString() ?? '0';
          final currency = offer['currency']?.toString() ?? 'PKR';

          // Filter for baggage-related offers
          if (offerCode.contains('BAG') || offerCode.contains('BUP')) {
            baggageOptions.add({
              'id': offerCode,
              'description': description,
              'type': 'baggage',
              'charge': amount,
              'currency': currency,
              'offerID': offer['offerID']?.toString() ?? '',
            });
          }
        }
      }

      // Add default options if none found
      if (baggageOptions.isEmpty) {
        baggageOptions.addAll([
          {
            'id': 'BAG20',
            'description': '20 kg Checked Baggage',
            'type': 'baggage',
            'charge': '5000',
            'currency': 'PKR',
          },
          {
            'id': 'BAG30',
            'description': '30 kg Checked Baggage',
            'type': 'baggage',
            'charge': '8000',
            'currency': 'PKR',
          },
        ]);
      }

      availableBaggage.value = baggageOptions;
      debugPrint('✅ Processed ${baggageOptions.length} baggage options');

    } catch (e) {
      debugPrint('❌ Error processing baggage data: $e');
      availableBaggage.value = [
        {
          'id': 'default_baggage',
          'description': '20 kg Baggage',
          'type': 'baggage',
          'charge': '5000',
        }
      ];
    }
  }

  void _processMealData(Map<String, dynamic> data) {
    try {
      final List<dynamic> mealOptions = [];

      // Parse meal data from API response
      if (data['ServiceOffers'] is List) {
        final serviceOffers = data['ServiceOffers'] as List;

        for (var offer in serviceOffers) {
          final offerCode = offer['offerCode']?.toString() ?? '';
          final description = offer['description']?.toString() ?? 'Meal';
          final amount = offer['amount']?.toString() ?? '0';
          final currency = offer['currency']?.toString() ?? 'PKR';

          // Filter for meal-related offers (excluding entertainment)
          if (offerCode.contains('ML') && !offerCode.contains('IFPP')) {
            mealOptions.add({
              'id': offerCode,
              'name': description,
              'description': description,
              'type': 'meal',
              'charge': amount,
              'currency': currency,
              'offerID': offer['offerID']?.toString() ?? '',
            });
          }
        }
      }

      // Add default options if none found
      if (mealOptions.isEmpty) {
        mealOptions.addAll([
          {
            'id': 'AVML',
            'name': 'Vegetarian Meal',
            'description': 'Vegetarian Indian Meal',
            'type': 'meal',
            'charge': '1500',
            'currency': 'PKR',
          },
          {
            'id': 'CHML',
            'name': 'Child Meal',
            'description': 'Special meal for children',
            'type': 'meal',
            'charge': '1200',
            'currency': 'PKR',
          },
        ]);
      }

      availableMeals.value = mealOptions;
      debugPrint('✅ Processed ${mealOptions.length} meal options');

    } catch (e) {
      debugPrint('❌ Error processing meal data: $e');
      availableMeals.value = [
        {
          'id': 'default_meal',
          'name': 'Standard Meal',
          'description': 'Regular meal service',
          'type': 'meal',
          'charge': '1000',
        }
      ];
    }
  }
  int _getFareIndex(FlydubaiFlight flight, FlydubaiFlightFare fare) {
    final options = flight.fareOptions ?? [];
    for (int i = 0; i < options.length; i++) {
      if (options[i].fareTypeId == fare.fareTypeId) {
        return i;
      }
    }
    return 0;
  }

  void selectBaggage(String key, dynamic baggage) {
    // key should be composite: seg{code}|p{index}
    selectedBaggage[key] = baggage;
    _updateExtrasPrice();
  }

  void selectMeal(String key, dynamic meal) {
    // key should be composite: seg{code}|p{index}
    selectedMeals[key] = meal;
    _updateExtrasPrice();
  }

  // Add these methods to your FlydubaiExtrasController class

// Enhanced seat selection method
  void selectSeat(String key, dynamic seat) {
    if (seat['seatNumber']?.toString().isEmpty == true) {
      // Deselect current seat
      selectedSeats.remove(key);
    } else {
      // Select new seat
      selectedSeats[key] = seat;
    }
    _updateExtrasPrice();
  }

// Get selected seat for a key
  Map<String, dynamic>? getSelectedSeat(String key) {
    return selectedSeats[key];
  }

// Check if a specific seat is selected for a key
  bool isSeatSelected(String key, String seatNumber) {
    final selectedSeat = selectedSeats[key];
    if (selectedSeat == null) return false;

    return selectedSeat['seatNumber']?.toString() == seatNumber ||
        selectedSeat['id']?.toString().contains(seatNumber) == true;
  }

// Get seats for a specific segment (if you have multiple segments)
  List<dynamic> getSeatsForSegment(String segmentCode) {
    // For Flydubai, you might not have segments like AirArabia
    // But you can filter seats based on your data structure
    return availableSeats.where((seat) {
      // Add your filtering logic here if needed
      return true; // Return all seats for now
    }).toList();
  }

  // Helpers for passengers/segments
  void _initializePassengerIds() {
    passengerIds.clear();
    final total = adultPassengers.value + childPassengers.value;
    debugPrint('Initializing passenger IDs for $total passengers (Adults: ${adultPassengers.value}, Children: ${childPassengers.value})');

    for (int i = 0; i < total; i++) {
      passengerIds.add('p$i');
    }

    debugPrint('Passenger IDs initialized: ${passengerIds.toList()}');
  }

  String getPassengerDisplayName(int index) {
    if (index < 0 || index >= passengerIds.length) {
      return 'Passenger ${index + 1}';
    }

    final adt = adultPassengers.value;
    if (index < adt) {
      return adt == 1 ? 'Adult' : 'Adult ${index + 1}';
    }
    final chIndex = index - adt;
    final totalChildren = childPassengers.value;
    return totalChildren == 1 ? 'Child' : 'Child ${chIndex + 1}';
  }
  // Add after the existing passenger selection methods

// Get selected baggage for specific passenger
  Map<String, dynamic>? getSelectedBaggageForPassenger(String segmentCode, String passengerId) {
    final key = 'seg$segmentCode|$passengerId';
    return selectedBaggage[key];
  }

// Get selected meal for specific passenger
  Map<String, dynamic>? getSelectedMealForPassenger(String segmentCode, String passengerId) {
    final key = 'seg$segmentCode|$passengerId';
    return selectedMeals[key];
  }

// Get selected seat for specific passenger
  Map<String, dynamic>? getSelectedSeatForPassenger(String segmentCode, String passengerId) {
    final key = 'seg$segmentCode|$passengerId';
    return selectedSeats[key];
  }

// Remove selection for a passenger
  void removePassengerSelection(String segmentCode, String passengerId, String type) {
    final key = 'seg$segmentCode|$passengerId';
    switch (type) {
      case 'baggage':
        selectedBaggage.remove(key);
        break;
      case 'meal':
        selectedMeals.remove(key);
        break;
      case 'seat':
        selectedSeats.remove(key);
        break;
    }
    _updateExtrasPrice();
  }

// Get all selections for a passenger (for summary)
  Map<String, dynamic> getPassengerSelections(String segmentCode, String passengerId) {
    final key = 'seg$segmentCode|$passengerId';
    return {
      'baggage': selectedBaggage[key],
      'meal': selectedMeals[key],
      'seat': selectedSeats[key],
    };
  }

// Check if passenger has any selections
  bool hasPassengerSelections(String segmentCode, String passengerId) {
    final key = 'seg$segmentCode|$passengerId';
    return selectedBaggage.containsKey(key) ||
        selectedMeals.containsKey(key) ||
        selectedSeats.containsKey(key);
  }


  List<String> getSegmentCodes() {
    final flight = selectedFlight.value;
    if (flight == null) return ['0'];
    return [flight.flightSegment.lfid.toString()];
  }

  /// Prints JSON nicely with chunking
  void printJsonPretty(dynamic jsonData) {
    const int chunkSize = 1000;
    final jsonString = const JsonEncoder.withIndent(' ').convert(jsonData);

    for (int i = 0; i < jsonString.length; i += chunkSize) {
      final chunk = jsonString.substring(
        i,
        i + chunkSize < jsonString.length ? i + chunkSize : jsonString.length,
      );
      print(chunk);
    }
  }
// Enhanced _processSeatData method with better seat mapping
  void _processSeatData(Map<String, dynamic> data) {
    try {
      final List<dynamic> seats = [];

      printJsonPretty('🔍 Processing seat data: $data');

      // Parse seat data from API response
      if (data['seatQuotes'] != null && data['seatQuotes']['flights'] is List) {
        final flights = data['seatQuotes']['flights'] as List;

        for (var flight in flights) {
          debugPrint('✈️ Processing flight: ${flight['flightNum']}');

          // Process actual seat prices from cabins
          if (flight['cabins'] is List) {
            final cabins = flight['cabins'] as List;

            for (var cabin in cabins) {
              debugPrint('🏠 Processing cabin: ${cabin['cabin']}');

              if (cabin['seatMaps'] is List) {
                final seatMaps = cabin['seatMaps'] as List;

                for (var seatMap in seatMaps) {
                  final rowNumber = seatMap['rowNumber']?.toString() ?? '';
                  debugPrint('📍 Processing row: $rowNumber');

                  if (seatMap['seats'] is List) {
                    final seatsList = seatMap['seats'] as List;

                    for (var seat in seatsList) {
                      final seatLetter = seat['seat']?.toString() ?? '';
                      final seatNumber = '$rowNumber$seatLetter';
                      final amount = seat['amount']?.toString() ?? '0';
                      final serviceCode = seat['serviceCode']?.toString() ?? '';
                      final isAssigned = seat['assigned'] == true;
                      final isBlocked = seat['isBlocked'] == true || seat['isPreBlocked'] == true;

                      debugPrint('💺 Seat: $seatNumber, Code: $serviceCode, Amount: $amount, Assigned: $isAssigned, Blocked: $isBlocked');

                      if (seatLetter.isNotEmpty && rowNumber.isNotEmpty) {
                        seats.add({
                          'id': '${serviceCode}_$seatNumber',
                          'seatNumber': seatNumber,
                          'seatLetter': seatLetter,
                          'description': 'Seat $seatNumber',
                          'type': 'seat',
                          'charge': amount,
                          'serviceCode': serviceCode,
                          'rowNumber': rowNumber,
                          'isAvailable': !isAssigned && !isBlocked && serviceCode.isNotEmpty,
                          'isAssigned': isAssigned,
                          'isBlocked': isBlocked,
                          'isPremium': _isPremiumSeat(rowNumber),
                        });
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      // If no seats from API, generate some demo seats for testing
      if (seats.isEmpty) {
        debugPrint('⚠️ No seats found from API, generating demo seats');
        seats.addAll(_generateDemoSeats());
      }

      availableSeats.value = seats;
      debugPrint('✅ Processed ${seats.length} seat options');

    } catch (e) {
      debugPrint('❌ Error processing seat data: $e');
      // Generate demo seats as fallback
      availableSeats.value = _generateDemoSeats();
    }
  }

// Helper method to determine if a seat is premium
  bool _isPremiumSeat(String seatNumber) {
    if (seatNumber.isEmpty) return false;

    final rowMatch = RegExp(r'(\d+)').firstMatch(seatNumber);
    if (rowMatch != null) {
      final rowNumber = int.tryParse(rowMatch.group(1) ?? '0') ?? 0;
      return rowNumber <= 6; // First 6 rows are typically premium in Flydubai
    }
    return false;
  }

// Generate demo seats for testing purposes
  List<Map<String, dynamic>> _generateDemoSeats() {
    final List<Map<String, dynamic>> demoSeats = [];
    final List<int> availableRows = [3, 4, 5, 7, 8, 9, 12, 13, 14, 16, 17, 18, 20, 21, 22, 25, 26, 28];
    final List<String> columns = ['A', 'B', 'C', 'D', 'E', 'F'];

    for (final row in availableRows) {
      for (final column in columns) {
        final seatNumber = '$row$column';
        double charge = 0;

        // Premium seats (rows 1-6)
        if (row <= 6) {
          charge = [2500, 3000, 3500].elementAt((row + column.codeUnitAt(0)) % 3) as double;
        }
        // Standard seats with extra legroom
        else if ([12, 13, 14].contains(row)) {
          charge = [1500, 2000].elementAt(column.codeUnitAt(0) % 2) as double;
        }
        // Regular seats
        else {
          charge = [500, 750, 1000].elementAt((row + column.codeUnitAt(0)) % 3) as double;
        }

        demoSeats.add({
          'id': 'SEAT_$seatNumber',
          'seatNumber': seatNumber,
          'description': 'Seat $seatNumber',
          'type': 'seat',
          'charge': charge.toString(),
          'serviceCode': 'SEAT',
          'rowNumber': row.toString(),
          'isAvailable': true,
          'isPremium': row <= 6,
        });
      }
    }

    return demoSeats;
  }
  void _updateExtrasPrice() {
    double extrasTotal = 0.0;

    // Add baggage charges
    for (final baggage in selectedBaggage.values) {
      // Extract price from baggage object
      final price = double.tryParse(baggage['charge']?.toString() ?? '0') ?? 0.0;
      extrasTotal += price;
    }

    // Add meal charges
    for (final meal in selectedMeals.values) {
      // Extract price from meal object
      final price = double.tryParse(meal['charge']?.toString() ?? '0') ?? 0.0;
      extrasTotal += price;
    }

    // Add seat charges
    for (final seat in selectedSeats.values) {
      // Extract price from seat object
      final price = double.tryParse(seat['charge']?.toString() ?? '0') ?? 0.0;
      extrasTotal += price;
    }

    totalExtrasPrice.value = extrasTotal;
  }

  double get totalPrice {
    return basePrice.value + totalExtrasPrice.value;
  }

  void reset() {
    selectedFlight.value = null;
    selectedFare.value = null;
    bookingIds.clear();
    availableBaggage.clear();
    availableMeals.clear();
    availableSeats.clear();
    selectedBaggage.clear();
    selectedMeals.clear();
    selectedSeats.clear();
    basePrice.value = 0.0;
    totalExtrasPrice.value = 0.0;
    currency.value = 'PKR';
    errorMessage.value = '';
  }

  Map<String, dynamic> getBookingSummary() {
    // Group selections by passenger for better organization
    Map<String, Map<String, dynamic>> passengerSelections = {};

    for (final passengerId in passengerIds) {
      passengerSelections[passengerId] = {
        'passengerName': getPassengerDisplayName(passengerIds.indexOf(passengerId)),
        'baggage': {},
        'meals': {},
        'seats': {},
      };
    }

    // Process baggage selections
    selectedBaggage.forEach((key, value) {
      final parts = key.split('|');
      if (parts.length == 2) {
        final passengerId = parts[1];
        if (passengerSelections.containsKey(passengerId)) {
          passengerSelections[passengerId]!['baggage'] = {
            'description': value['description'] ?? '',
            'charge': value['charge'] ?? '0',
          };
        }
      }
    });

    // Process meal selections
    selectedMeals.forEach((key, value) {
      final parts = key.split('|');
      if (parts.length == 2) {
        final passengerId = parts[1];
        if (passengerSelections.containsKey(passengerId)) {












          
          passengerSelections[passengerId]!['meals'] = {
            'name': value['name'] ?? '',
            'charge': value['charge'] ?? '0',
          };
        }
      }
    });

    // Process seat selections
    selectedSeats.forEach((key, value) {
      final parts = key.split('|');
      if (parts.length == 2) {
        final passengerId = parts[1];
        if (passengerSelections.containsKey(passengerId)) {
          passengerSelections[passengerId]!['seats'] = {
            'number': value['seatNumber'] ?? '',
            'charge': value['charge'] ?? '0',
          };
        }
      }
    });

    return {
      'base_price': basePrice.value,
      'extras_price': totalExtrasPrice.value,
      'total_price': totalPrice,
      'currency': currency.value,
      'passenger_count': passengerIds.length,
      'passengers': passengerSelections,
      // Legacy format for backward compatibility
      'baggage': selectedBaggage.map((key, value) => MapEntry(key, {
        'description': value['description'] ?? '',
        'charge': value['charge'] ?? '0',
      })),
      'meals': selectedMeals.map((key, value) => MapEntry(key, {
        'name': value['name'] ?? '',
        'charge': value['charge'] ?? '0',
      })),
      'seats': selectedSeats.map((key, value) => MapEntry(key, {
        'number': value['seatNumber'] ?? '',
        'charge': value['charge'] ?? '0',
      })),
    };
  }
}