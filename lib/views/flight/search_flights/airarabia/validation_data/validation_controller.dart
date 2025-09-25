// air_arabia_revalidation_controller.dart
import 'package:get/get.dart';
import 'package:ready_flights/services/api_service_airarabia.dart';
import 'package:ready_flights/views/flight/search_flights/airarabia/validation_data/validation_model.dart';

class AirArabiaRevalidationController extends GetxController {
  final ApiServiceAirArabia _apiService = Get.find<ApiServiceAirArabia>();
  final RxInt adultPassengers = 1.obs;
  final RxInt childPassengers = 0.obs;
  final RxInt infantPassengers = 0.obs;
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<AirArabiaRevalidationResponse?> revalidationResponse = 
      Rx<AirArabiaRevalidationResponse?>(null);

  // Passenger information
  final RxInt totalPassengers = 1.obs;
  final RxList<String> passengerIds = <String>[].obs;

  // Extras data
  final RxList<BaggageOption> availableBaggage = <BaggageOption>[].obs;
  final RxList<MealOption> availableMeals = <MealOption>[].obs;
  final RxMap<String, List<MealOption>> mealsBySegment = <String, List<MealOption>>{}.obs;
  final RxList<SeatOption> availableSeats = <SeatOption>[].obs;
  final RxMap<String, List<SeatOption>> seatsBySegment = <String, List<SeatOption>>{}.obs;

  // Selected extras - now per passenger
  final RxMap<String, BaggageOption> selectedBaggage = <String, BaggageOption>{}.obs;
  final RxMap<String, RxMap<String, List<MealOption>>> selectedMeals = <String, RxMap<String, List<MealOption>>>{}.obs;
  final RxMap<String, RxMap<String, SeatOption>> selectedSeats = <String, RxMap<String, SeatOption>>{}.obs;

  // Pricing
  final RxDouble basePrice = 0.0.obs;
  final RxDouble totalExtrasPrice = 0.0.obs;
  final RxString currency = 'PKR'.obs;

  @override
  void onInit() {
    super.onInit();
    reset();

    // Check if screen was called with arguments for auto-revalidation
    final arguments = Get.arguments;
    if (arguments != null) {
      _autoRevalidate(arguments);
    }
  }

  Future<void> _autoRevalidate(Map<String, dynamic> args) async {
    // Set passenger count from arguments
    final adults = args['adult'] ?? 1;
    final children = args['child'] ?? 0;
    final infants = args['infant'] ?? 0;
    
    adultPassengers.value = adults;
    childPassengers.value = children;
    infantPassengers.value = infants;
    totalPassengers.value = adults + children + infants;
    
    // Initialize passenger IDs
    _initializePassengerIds();

    await revalidatePackage(
      type: args['type'] ?? 0,
      adult: adults,
      child: children,
      infant: infants,
      sector: args['sector'] ?? [],
      fare: args['fare'] ?? {},
      csId: args['csId'] ?? 15,
    );
  }

  void _initializePassengerIds() {
    passengerIds.clear();
    // Only create IDs for adult passengers for baggage/meal/seat selection
    for (int i = 0; i < adultPassengers.value; i++) {
      passengerIds.add('passenger_$i');
      // Initialize meal and seat maps for each adult passenger
      selectedMeals['passenger_$i'] = <String, List<MealOption>>{}.obs;
      selectedSeats['passenger_$i'] = <String, SeatOption>{}.obs;
    }
  }

  // Get passenger display name - updated to show only adults
  String getPassengerDisplayName(int index) {
    if (adultPassengers.value == 1) return 'Adult';
    return 'Adult ${index + 1}';
  }

  Future<bool> revalidatePackage({
    required int type,
    required int adult,
    required int child,
    required int infant,
    required List<Map<String, dynamic>> sector,
    required Map<String, dynamic> fare,
    required int csId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.revalidateAirArabiaPackage(
        type: type,
        adult: adult,
        child: child,
        infant: infant,
        sector: sector,
        fare: fare,
        csId: csId,
      );

      if (response['status'] == 200) {
        revalidationResponse.value = AirArabiaRevalidationResponse.fromJson(response);
        _processResponseData();
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Revalidation failed';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error during revalidation: ${e.toString()}';
      print('Revalidation error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _processResponseData() {
    try {
      final data = revalidationResponse.value?.data;
      if (data == null) {
        print('No data in revalidation response');
        return;
      }

      // Set base price and currency - handle multiple PTC fare breakdowns
      final ptcBreakdowns = data.pricing.ptcFareBreakdowns;
      double totalBasePrice = 0.0;
      
      for (final breakdown in ptcBreakdowns) {
        final passengerFare = breakdown.passengerFare;
        if (passengerFare != null && passengerFare.totalFare != null) {
          final totalFareAmount = passengerFare.totalFare!.attributes['Amount']?.toString() ?? '0';
          final quantity = int.tryParse(breakdown.passengerTypeQuantity?.attributes['Quantity'] ?? '1') ?? 1;
          totalBasePrice += (double.tryParse(totalFareAmount) ?? 0.0) * quantity;
        }
      }
      
      basePrice.value = totalBasePrice;
      currency.value = ptcBreakdowns.isNotEmpty 
          ? ptcBreakdowns.first.passengerFare?.totalFare?.attributes['CurrencyCode']?.toString() ?? 'PKR'
          : 'PKR';

      // Process baggage options
      _processBaggageOptions(data.extras.baggage);

      // Process meal options
      _processMealOptions(data.extras.meal);

      // Process seat options
      _processSeatOptions(data.extras.seat);
      
    } catch (e) {
      print('Error processing response data: $e');
      errorMessage.value = 'Error processing flight data: ${e.toString()}';
    }
  }

  // Updated to handle multiple OnDBaggageDetailsResponse objects
void _processBaggageOptions(BaggageInfo baggageInfo) {
  try {
    final baggageDetails = baggageInfo.body.aaBaggageDetailsRS;
    final baggageResponses = baggageDetails.baggageDetailsResponses;
    
    // Now it's a List<OnDBaggageDetailsResponse>
    final onDBaggageResponses = baggageResponses.onDBaggageDetailsResponse;
    
    availableBaggage.value = [];
    
    for (final response in onDBaggageResponses) {
      final baggageOptions = response.baggage;
      
      // Use the helper method to get segments
      final segments = response.getSegments();
      
      for (final segment in segments) {
        final segmentCode = segment.attributes['SegmentCode']?.toString() ?? 
                          segment.attributes['RPH']?.toString() ?? 
                          'segment_${segments.indexOf(segment)}';
        
        // Add baggage options for this segment
        availableBaggage.addAll(baggageOptions);

        if (baggageOptions.isNotEmpty) {
          final noBagOption = baggageOptions.firstWhere(
            (bag) => bag.baggageCode.toLowerCase().contains('no bag') ||
                    bag.baggageCode.toLowerCase().contains('nobag') ||
                    bag.baggageDescription.toLowerCase().contains('no bag'),
            orElse: () => baggageOptions.first,
          );

          // Set default baggage for all passengers for this segment
          for (String passengerId in passengerIds) {
            final baggageKey = '$passengerId-$segmentCode';
            selectedBaggage[baggageKey] = noBagOption;
          }
        }
      }
    }
  } catch (e) {
    print('Error processing baggage options: $e');
    availableBaggage.value = [];
  }
}

// Update the getFlightSegments method
List<FlightSegmentInfo> getFlightSegments() {
  try {
    final baggageDetails = revalidationResponse.value?.data?.extras.baggage.body.aaBaggageDetailsRS;
    final baggageResponses = baggageDetails?.baggageDetailsResponses;
    
    if (baggageResponses == null) return [];
    
    final onDBaggageResponses = baggageResponses.onDBaggageDetailsResponse;
    
    final List<FlightSegmentInfo> allSegments = [];
    
    for (final response in onDBaggageResponses) {
      // Use the helper method
      final segments = response.getSegments();
      allSegments.addAll(segments);
    }
    
    // Remove duplicates by segment code
    final uniqueSegments = <String, FlightSegmentInfo>{};
    for (final segment in allSegments) {
      final segmentCode = segment.attributes['SegmentCode']?.toString() ?? 
                         segment.attributes['RPH']?.toString() ?? 
                         'segment_${allSegments.indexOf(segment)}';
      uniqueSegments[segmentCode] = segment;
    }
    
    return uniqueSegments.values.toList();
  } catch (e) {
    print('Error getting flight segments: $e');
    return [];
  }
}
  List<OnDBaggageDetailsResponse> _parseOnDBaggageResponses(dynamic responseData) {
    if (responseData == null) return [];
    
    if (responseData is List) {
      return responseData.cast<OnDBaggageDetailsResponse>();
    } else if (responseData is OnDBaggageDetailsResponse) {
      return [responseData];
    }
    
    return [];
  }

  // Helper method to extract segment code from baggage response
  String _getSegmentCodeFromBaggageResponse(OnDBaggageDetailsResponse response) {
    try {
      if (response.flightSegmentInfo.isNotEmpty) {
        final firstSegment = response.flightSegmentInfo.first;
        return firstSegment.attributes['SegmentCode']?.toString() ?? '';
      }
    } catch (e) {
      print('Error getting segment code: $e');
    }
    return '';
  }

  void _processMealOptions(MealInfo mealInfo) {
    try {
      final mealResponses = mealInfo.body.aaMealDetailsRS.mealDetailsResponses.mealDetailsResponse;

      availableMeals.clear();
      mealsBySegment.clear();

      for (final response in mealResponses) {
        final segmentCode = response.flightSegmentInfo.attributes['SegmentCode']?.toString() ??
            response.flightSegmentInfo.attributes['RPH']?.toString() ??
            'segment_${mealResponses.indexOf(response)}';

        final meals = response.meals;
        mealsBySegment[segmentCode] = meals;
        availableMeals.addAll(meals);
      }
    } catch (e) {
      print('Error processing meal options: $e');
      availableMeals.clear();
      mealsBySegment.clear();
    }
  }

  void _processSeatOptions(SeatInfo seatInfo) {
    try {
      final seatResponses = seatInfo.body.otaAirSeatMapRS.seatMapResponses.seatMapResponse;

      availableSeats.clear();
      seatsBySegment.clear();

      for (final response in seatResponses) {
        final segmentCode = response.flightSegmentInfo.attributes['SegmentCode']?.toString() ??
            response.flightSegmentInfo.attributes['RPH']?.toString() ??
            'segment_${seatResponses.indexOf(response)}';

        final seats = _extractSeatsFromResponse(response);
        seatsBySegment[segmentCode] = seats;
        availableSeats.addAll(seats);
      }
    } catch (e) {
      print('Error processing seat options: $e');
      availableSeats.clear();
      seatsBySegment.clear();
    }
  }

  List<SeatOption> _extractSeatsFromResponse(SeatMapResponse response) {
    final List<SeatOption> seats = [];

    try {
      final airRows = response.seatMapDetails.cabinClass.airRows.airRow;

      for (final row in airRows) {
        final rowNumber = row.attributes['RowNumber']?.toString() ?? '';
        final airSeats = row.airSeats.airSeat;

        for (final airSeat in airSeats) {
          final seatAvailability = airSeat.attributes['SeatAvailability']?.toString() ?? '';
          final seatLetter = airSeat.attributes['SeatNumber']?.toString() ?? '';
          final seatNumber = '$rowNumber$seatLetter';

          if (seatAvailability == 'VAC' || seatAvailability == 'Available') {
            seats.add(SeatOption(
              seatNumber: seatNumber,
              seatCharge: double.tryParse(airSeat.attributes['SeatCharacteristics']?.toString() ?? '0') ?? 0.0,
              currencyCode: airSeat.attributes['CurrencyCode']?.toString() ?? 'PKR',
              seatAvailability: seatAvailability,
            ));
          }
        }
      }
    } catch (e) {
      print('Error extracting seats: $e');
    }

    return seats;
  }

  // Updated methods to handle per-passenger selection with segment codes

  void selectSeat(String segmentCode, String passengerId, SeatOption seat) {
    if (!selectedSeats.containsKey(passengerId)) {
      selectedSeats[passengerId] = <String, SeatOption>{}.obs;
    }
    
    if (seat.seatNumber.isEmpty) {
      selectedSeats[passengerId]!.remove(segmentCode);
    } else {
      selectedSeats[passengerId]![segmentCode] = seat;
    }
    _updateExtrasPrice();
  }

  bool isSeatSelected(String segmentCode, String passengerId, SeatOption seat) {
    final selectedSeat = selectedSeats[passengerId]?[segmentCode];
    return selectedSeat?.seatNumber == seat.seatNumber;
  }

  bool isSeatOccupiedByOtherPassenger(String segmentCode, String currentPassengerId, SeatOption seat) {
    for (String passengerId in passengerIds) {
      if (passengerId != currentPassengerId) {
        final selectedSeat = selectedSeats[passengerId]?[segmentCode];
        if (selectedSeat?.seatNumber == seat.seatNumber) {
          return true;
        }
      }
    }
    return false;
  }

  // Updated to handle segment-specific baggage
  void selectBaggage(String passengerId, BaggageOption baggage, {String segmentCode = ''}) {
    final baggageKey = segmentCode.isNotEmpty ? '$passengerId-$segmentCode' : passengerId;
    selectedBaggage[baggageKey] = baggage;
    _updateExtrasPrice();
  }

  // Helper to get baggage for a specific passenger and segment
  BaggageOption? getBaggageForPassenger(String passengerId, {String segmentCode = ''}) {
    final baggageKey = segmentCode.isNotEmpty ? '$passengerId-$segmentCode' : passengerId;
    return selectedBaggage[baggageKey];
  }

  void toggleMeal(String segmentCode, String passengerId, MealOption meal) {
    if (!selectedMeals.containsKey(passengerId)) {
      selectedMeals[passengerId] = <String, List<MealOption>>{}.obs;
    }
    if (!selectedMeals[passengerId]!.containsKey(segmentCode)) {
      selectedMeals[passengerId]![segmentCode] = [];
    }

    final currentMeals = selectedMeals[passengerId]![segmentCode]!;
    final existingIndex = currentMeals.indexWhere((m) => m.mealCode == meal.mealCode);

    if (existingIndex >= 0) {
      currentMeals.removeAt(existingIndex);
    } else {
      currentMeals.add(meal);
    }

    selectedMeals[passengerId]!.refresh();
    _updateExtrasPrice();
  }

  void _updateExtrasPrice() {
    double extrasTotal = 0.0;

    // Add baggage charges for all passengers and segments
    for (final baggageEntry in selectedBaggage.entries) {
      extrasTotal += double.tryParse(baggageEntry.value.baggageCharge) ?? 0.0;
    }

    // Add meal charges for all passengers and segments
    for (final passengerMeals in selectedMeals.values) {
      for (final mealList in passengerMeals.values) {
        for (final meal in mealList) {
          extrasTotal += double.tryParse(meal.mealCharge) ?? 0.0;
        }
      }
    }

    // Add seat charges for all passengers and segments
    for (final passengerSeats in selectedSeats.values) {
      for (final seat in passengerSeats.values) {
        extrasTotal += seat.seatCharge;
      }
    }

    totalExtrasPrice.value = extrasTotal;
  }

  double get totalPrice {
    return basePrice.value + totalExtrasPrice.value;
  }

  bool isMealSelected(String segmentCode, String passengerId, MealOption meal) {
    return selectedMeals[passengerId]?[segmentCode]?.any((m) => m.mealCode == meal.mealCode) ?? false;
  }

  SeatOption? getSelectedSeat(String segmentCode, String passengerId) {
    return selectedSeats[passengerId]?[segmentCode];
  }

  // Updated to handle multiple flight segments from baggage response
// Updated to properly handle both single segment and array of segments
 List<MealOption> getMealsForSegment(String segmentCode) {
    return mealsBySegment[segmentCode] ?? [];
  }

  List<SeatOption> getSeatsForSegment(String segmentCode) {
    return seatsBySegment[segmentCode] ?? [];
  }

  void reset() {
    revalidationResponse.value = null;
    availableBaggage.clear();
    availableMeals.clear();
    mealsBySegment.clear();
    availableSeats.clear();
    seatsBySegment.clear();
    selectedBaggage.clear();
    selectedMeals.clear();
    selectedSeats.clear();
    passengerIds.clear();
    totalPassengers.value = 1;
    basePrice.value = 0.0;
    totalExtrasPrice.value = 0.0;
    currency.value = 'PKR';
    errorMessage.value = '';
  }

  Map<String, dynamic> getBookingSummary() {
    return {
      'base_price': basePrice.value,
      'extras_price': totalExtrasPrice.value,
      'total_price': totalPrice,
      'currency': currency.value,
      'total_passengers': totalPassengers.value,
      'baggage': selectedBaggage.map((key, value) => MapEntry(key, {
        'description': value.baggageDescription,
        'charge': value.baggageCharge,
      })),
      'meals': selectedMeals.map((passengerId, passengerMeals) => MapEntry(passengerId,
          passengerMeals.map((segmentCode, mealList) => MapEntry(segmentCode,
              mealList.map((meal) => {
                'name': meal.mealName,
                'charge': meal.mealCharge,
              }).toList()
          ))
      )),
      'seats': selectedSeats.map((passengerId, passengerSeats) => MapEntry(passengerId,
          passengerSeats.map((segmentCode, seat) => MapEntry(segmentCode, {
            'number': seat.seatNumber,
            'charge': seat.seatCharge,
          }))
      )),
    };
  }
}