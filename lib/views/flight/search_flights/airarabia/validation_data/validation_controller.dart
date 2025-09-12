// air_arabia_revalidation_controller.dart
import 'package:get/get.dart';
import 'package:ready_flights/services/api_service_airarabia.dart';
import 'package:ready_flights/views/flight/search_flights/airarabia/validation_data/validation_model.dart';

class AirArabiaRevalidationController extends GetxController {
  final ApiServiceAirArabia _apiService = Get.find<ApiServiceAirArabia>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<AirArabiaRevalidationResponse?> revalidationResponse = 
      Rx<AirArabiaRevalidationResponse?>(null);

  // Extras data
  final RxList<BaggageOption> availableBaggage = <BaggageOption>[].obs;
  final RxList<MealOption> availableMeals = <MealOption>[].obs;
  final RxMap<String, List<MealOption>> mealsBySegment = <String, List<MealOption>>{}.obs;
  final RxList<SeatOption> availableSeats = <SeatOption>[].obs;
  final RxMap<String, List<SeatOption>> seatsBySegment = <String, List<SeatOption>>{}.obs;

  // Selected extras
  final RxMap<String, BaggageOption> selectedBaggage = <String, BaggageOption>{}.obs;
  final RxMap<String, List<MealOption>> selectedMeals = <String, List<MealOption>>{}.obs;
  final RxMap<String, SeatOption> selectedSeats = <String, SeatOption>{}.obs;
  
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
    await revalidatePackage(
      type: args['type'] ?? 0,
      adult: args['adult'] ?? 1,
      child: args['child'] ?? 0,
      infant: args['infant'] ?? 0,
      sector: args['sector'] ?? [],
      fare: args['fare'] ?? {},
      csId: args['csId'] ?? 15,
    );
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
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _processResponseData() {
    final data = revalidationResponse.value?.data;
    if (data == null) return;

    // Set base price and currency
    basePrice.value = data.pricing.totalPrice;
    currency.value = data.pricing.currency;

    // Process baggage options
    _processBaggageOptions(data.extras.baggage);
    
    // Process meal options
    _processMealOptions(data.extras.meal);
    
    // Process seat options
    _processSeatOptions(data.extras.seat);
  }

  void _processBaggageOptions(BaggageInfo baggageInfo) {
    try {
      // Safe navigation with null checks
      final baggageDetails = baggageInfo.body.aaBaggageDetailsRS;
      final baggageResponses = baggageDetails.baggageDetailsResponses;
      final onDBaggageResponse = baggageResponses.onDBaggageDetailsResponse;
      
      // Check if baggage list exists and is not null
      final baggageOptions = onDBaggageResponse.baggage ?? [];
      
      availableBaggage.value = baggageOptions;

      if (baggageOptions.isNotEmpty) {
        // Set default "No Bag" option or first available option
        final noBagOption = baggageOptions.firstWhere(
          (bag) => bag.baggageCode.toLowerCase().contains('no bag'),
          orElse: () => baggageOptions.first,
        );
        
        selectedBaggage['default'] = noBagOption;
      }
    } catch (e) {
      print('Error processing baggage options: $e');
      availableBaggage.value = []; // Ensure empty list on error
    }
  }

  void _processMealOptions(MealInfo mealInfo) {
    try {
      final mealResponses = mealInfo.body.aaMealDetailsRS
          .mealDetailsResponses.mealDetailsResponse ?? [];

      availableMeals.clear();
      mealsBySegment.clear();

      for (final response in mealResponses) {
        final segmentCode = response.flightSegmentInfo.attributes['SegmentCode'] ?? 
                           response.flightSegmentInfo.attributes['RPH'] ?? 
                           'segment_${mealResponses.indexOf(response)}';
        
        final meals = response.meals ?? [];
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
      final seatResponses = seatInfo.body.otaAirSeatMapRS.seatMapResponses.seatMapResponse ?? [];

      availableSeats.clear();
      seatsBySegment.clear();

      for (final response in seatResponses) {
        final segmentCode = response.flightSegmentInfo.attributes['SegmentCode'] ?? 
                           response.flightSegmentInfo.attributes['RPH'] ?? 
                           'segment_${seatResponses.indexOf(response)}';
        
        // Extract seats from the response
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
      final airRows = response.seatMapDetails.cabinClass.airRows.airRow ?? [];
      
      for (final row in airRows) {
        final airSeats = row.airSeats.airSeat ?? [];
        for (final airSeat in airSeats) {
          if (airSeat.attributes['SeatAvailability'] == 'VAC') {
            seats.add(SeatOption(
              seatNumber: airSeat.attributes['SeatNumber'] ?? '',
              seatCharge: double.tryParse(airSeat.attributes['SeatCharacteristics'] ?? '0') ?? 0.0,
              currencyCode: airSeat.attributes['CurrencyCode'] ?? 'PKR',
              seatAvailability: airSeat.attributes['SeatAvailability'] ?? '',
            ));
          }
        }
      }
    } catch (e) {
      print('Error extracting seats: $e');
    }
    
    return seats;
  }

   void selectBaggage(String passengerId, BaggageOption baggage) {
    selectedBaggage[passengerId] = baggage;
    _updateExtrasPrice();
  }

  void toggleMeal(String segmentCode, MealOption meal) {
    if (!selectedMeals.containsKey(segmentCode)) {
      selectedMeals[segmentCode] = [];
    }
    
    final currentMeals = selectedMeals[segmentCode]!;
    final existingIndex = currentMeals.indexWhere((m) => m.mealCode == meal.mealCode);
    
    if (existingIndex >= 0) {
      currentMeals.removeAt(existingIndex);
    } else {
      currentMeals.add(meal);
    }
    
    selectedMeals.refresh();
    _updateExtrasPrice();
  }

  void selectSeat(String segmentCode, SeatOption seat) {
    selectedSeats[segmentCode] = seat;
    _updateExtrasPrice();
  }

  void _updateExtrasPrice() {
    double extrasTotal = 0.0;

    // Add baggage charges
    for (final baggage in selectedBaggage.values) {
      extrasTotal += double.tryParse(baggage.baggageCharge) ?? 0.0;
    }

    // Add meal charges
    for (final mealList in selectedMeals.values) {
      for (final meal in mealList) {
        extrasTotal += double.tryParse(meal.mealCharge) ?? 0.0;
      }
    }

    // Add seat charges
    for (final seat in selectedSeats.values) {
      extrasTotal += seat.seatCharge;
    }

    totalExtrasPrice.value = extrasTotal;
  }

  double get totalPrice {
    return basePrice.value + totalExtrasPrice.value;
  }

bool isMealSelected(String segmentCode, MealOption meal) {
  return selectedMeals[segmentCode]?.any((m) => m.mealCode == meal.mealCode) ?? false;
}

  SeatOption? getSelectedSeat(String segmentCode) {
    return selectedSeats[segmentCode];
  }

  List<FlightSegmentInfo> getFlightSegments() {
    try {
      return revalidationResponse.value?.data?.extras.baggage.body.aaBaggageDetailsRS
          .baggageDetailsResponses.onDBaggageDetailsResponse.flightSegmentInfo ?? [];
    } catch (e) {
      print('Error getting flight segments: $e');
      return [];
    }
  }

  // Added missing methods
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
      'baggage': selectedBaggage.map((key, value) => MapEntry(key, {
        'description': value.baggageDescription,
        'charge': value.baggageCharge,
      })),
      'meals': selectedMeals.map((key, value) => MapEntry(key, 
        value.map((meal) => {
          'name': meal.mealName,
          'charge': meal.mealCharge,
        }).toList()
      )),
      'seats': selectedSeats.map((key, value) => MapEntry(key, {
        'number': value.seatNumber,
        'charge': value.seatCharge,
      })),
    };
  }
}