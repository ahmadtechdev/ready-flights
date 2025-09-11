// air_arabia_package_revalidation_controller.dart
import 'package:get/get.dart';
import 'package:ready_flights/services/api_service_airarabia.dart';
import 'package:ready_flights/views/flight/search_flights/airarabia/validation_model.dart';
import 'package:ready_flights/views/flight/search_flights/sabre/sabre_flight_models.dart' hide FlightSegmentInfo;

class AirArabiaPackageRevalidationController extends GetxController {
  final ApiServiceAirArabia _apiService = Get.find<ApiServiceAirArabia>();

  // Observable state variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<AirArabiaRevalidationResponse?> revalidationResponse = 
      Rx<AirArabiaRevalidationResponse?>(null);

  // Observable extras data
  final RxList<BaggageOption> availableBaggage = <BaggageOption>[].obs;
  final RxList<MealOption> availableMeals = <MealOption>[].obs;
  final RxMap<String, List<MealOption>> mealsBySegment = <String, List<MealOption>>{}.obs;

  // Selected extras
  final RxMap<String, BaggageOption> selectedBaggage = <String, BaggageOption>{}.obs;
  final RxMap<String, List<MealOption>> selectedMeals = <String, List<MealOption>>{}.obs;
  
  // Pricing information
  final RxDouble totalPrice = 0.0.obs;
  final RxString currency = 'PKR'.obs;
  final RxMap<String, double> extrasCharges = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    clearData();
  }

  /// Main method to revalidate package and get extras
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
      clearData();

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
        await _processRevalidationData();
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

  /// Process the revalidation response and extract data
  Future<void> _processRevalidationData() async {
    final data = revalidationResponse.value?.data;
    if (data == null) return;

    // Update pricing information
    totalPrice.value = data.pricing.totalPrice;
    currency.value = data.pricing.currency;

    // Process baggage options
    _processBaggageOptions(data.extras.baggage);
    
    // Process meal options
    _processMealOptions(data.extras.meal);
  }

  /// Process baggage options from the response
  void _processBaggageOptions(BaggageInfo baggageInfo) {
    try {
      final baggageOptions = baggageInfo.body.aaBaggageDetailsRS
          .baggageDetailsResponses.onDBaggageDetailsResponse.baggageOptions;
      
      availableBaggage.clear();
      availableBaggage.addAll(baggageOptions);

      // Set default "No Bag" option if available
      final noBagOption = baggageOptions
          .where((bag) => bag.baggageCode.toLowerCase().contains('no bag'))
          .firstOrNull;
      
      if (noBagOption != null) {
        selectedBaggage['default'] = noBagOption;
      }
    } catch (e) {
      print('Error processing baggage options: $e');
    }
  }

  /// Process meal options from the response
  void _processMealOptions(MealInfo mealInfo) {
    try {
      final mealResponses = mealInfo.body.aaMealDetailsRS
          .mealDetailsResponses.mealDetailsResponse;

      availableMeals.clear();
      mealsBySegment.clear();
      selectedMeals.clear();

      for (final response in mealResponses) {
        final segmentCode = response.flightSegmentInfo.attributes['SegmentCode'] ?? 
                           response.flightSegmentInfo.attributes['RPH'] ?? 
                           'segment_${mealResponses.indexOf(response)}';
        
        mealsBySegment[segmentCode] = response.meals;
        availableMeals.addAll(response.meals);
        selectedMeals[segmentCode] = [];
      }
    } catch (e) {
      print('Error processing meal options: $e');
    }
  }

  /// Select baggage for a passenger
  void selectBaggage(String passengerId, BaggageOption baggage) {
    selectedBaggage[passengerId] = baggage;
    _updateExtrasCharges();
  }

  /// Add meal for a segment
  void addMeal(String segmentCode, MealOption meal) {
    if (!selectedMeals.containsKey(segmentCode)) {
      selectedMeals[segmentCode] = <MealOption>[];
    }
    
    final currentMeals = selectedMeals[segmentCode]!;
    if (!currentMeals.any((m) => m.mealCode == meal.mealCode)) {
      currentMeals.add(meal);
      selectedMeals.refresh();
      _updateExtrasCharges();
    }
  }

  /// Remove meal from a segment
  void removeMeal(String segmentCode, MealOption meal) {
    if (selectedMeals.containsKey(segmentCode)) {
      selectedMeals[segmentCode]!.removeWhere((m) => m.mealCode == meal.mealCode);
      selectedMeals.refresh();
      _updateExtrasCharges();
    }
  }

  /// Update charges calculation for extras
  void _updateExtrasCharges() {
    extrasCharges.clear();
    double totalExtrasCharge = 0.0;

    // Calculate baggage charges
    double baggageCharge = 0.0;
    for (final baggage in selectedBaggage.values) {
      final charge = double.tryParse(baggage.baggageCharge) ?? 0.0;
      baggageCharge += charge;
    }
    extrasCharges['baggage'] = baggageCharge;
    totalExtrasCharge += baggageCharge;

    // Calculate meal charges
    double mealCharge = 0.0;
    for (final mealList in selectedMeals.values) {
      for (final meal in mealList) {
        final charge = double.tryParse(meal.mealCharge) ?? 0.0;
        mealCharge += charge;
      }
    }
    extrasCharges['meals'] = mealCharge;
    totalExtrasCharge += mealCharge;

    extrasCharges['total'] = totalExtrasCharge;
    extrasCharges.refresh();
  }

  /// Get total price including extras
  double get totalPriceWithExtras {
    return totalPrice.value + (extrasCharges['total'] ?? 0.0);
  }

  /// Get meals for a specific segment
  List<MealOption> getMealsForSegment(String segmentCode) {
    return mealsBySegment[segmentCode] ?? [];
  }

  /// Get selected meals for a specific segment
  List<MealOption> getSelectedMealsForSegment(String segmentCode) {
    return selectedMeals[segmentCode] ?? [];
  }

  /// Check if a meal is selected for a segment
  bool isMealSelected(String segmentCode, MealOption meal) {
    return selectedMeals[segmentCode]?.any((m) => m.mealCode == meal.mealCode) ?? false;
  }

  /// Get baggage options
  List<BaggageOption> getBaggageOptions() {
    return availableBaggage.toList();
  }

  /// Get selected baggage for a passenger
  BaggageOption? getSelectedBaggage(String passengerId) {
    return selectedBaggage[passengerId];
  }

  /// Get flight segment information
  List<FlightSegmentInfo> getFlightSegments() {
    return revalidationResponse.value?.data?.extras.baggage.body.aaBaggageDetailsRS
        .baggageDetailsResponses.onDBaggageDetailsResponse.flightSegmentInfos ?? [];
  }

  /// Get pricing breakdown
  PricingInfo? getPricingInfo() {
    return revalidationResponse.value?.data?.pricing;
  }

  /// Get tax breakdown
  List<TaxItem> getTaxBreakdown() {
    return revalidationResponse.value?.data?.pricing.ptcFareBreakdown
        .passengerFare.taxes.taxes ?? [];
  }

  /// Get meta information for booking
  MetaInfo? getMetaInfo() {
    return revalidationResponse.value?.data?.meta;
  }

  /// Clear all data
  void clearData() {
    revalidationResponse.value = null;
    availableBaggage.clear();
    availableMeals.clear();
    mealsBySegment.clear();
    selectedBaggage.clear();
    selectedMeals.clear();
    extrasCharges.clear();
    totalPrice.value = 0.0;
    currency.value = 'PKR';
    errorMessage.value = '';
  }

  /// Get summary of selected extras
  Map<String, dynamic> getExtrasSummary() {
    final summary = <String, dynamic>{};
    
    // Baggage summary
    final baggageList = <Map<String, dynamic>>[];
    for (final entry in selectedBaggage.entries) {
      baggageList.add({
        'passenger': entry.key,
        'baggage': entry.value.baggageDescription,
        'charge': entry.value.baggageCharge,
        'currency': entry.value.currencyCode,
      });
    }
    summary['baggage'] = baggageList;

    // Meals summary
    final mealsList = <Map<String, dynamic>>[];
    for (final entry in selectedMeals.entries) {
      for (final meal in entry.value) {
        mealsList.add({
          'segment': entry.key,
          'meal': meal.mealName,
          'charge': meal.mealCharge,
          'currency': meal.currencyCode,
        });
      }
    }
    summary['meals'] = mealsList;

    // Total charges
    summary['charges'] = extrasCharges.value;
    summary['total_price'] = totalPriceWithExtras;
    summary['currency'] = currency.value;

    return summary;
  }

  /// Validate if required extras are selected
  bool validateSelection() {
    // Add validation logic as needed
    // For example, ensure at least one baggage option is selected
    return selectedBaggage.isNotEmpty;
  }

  /// Reset selections to default
  void resetSelections() {
    selectedBaggage.clear();
    selectedMeals.clear();
    extrasCharges.clear();
    
    // Set default baggage if available
    final noBagOption = availableBaggage
        .where((bag) => bag.baggageCode.toLowerCase().contains('no bag'))
        .firstOrNull;
    
    if (noBagOption != null) {
      selectedBaggage['default'] = noBagOption;
    }
  }

  /// Prepare booking data for next step
  Map<String, dynamic> prepareBookingData() {
    final metaInfo = getMetaInfo();
    final pricingInfo = getPricingInfo();
    
    return {
      'revalidation_response': revalidationResponse.value?.toJson(),
      'selected_extras': getExtrasSummary(),
      'meta': {
        'jsession': metaInfo?.jsession,
        'transaction_id': metaInfo?.transactionId,
        'final_key': metaInfo?.finalKey,
      },
      'pricing': {
        'base_price': totalPrice.value,
        'extras_charge': extrasCharges['total'] ?? 0.0,
        'total_price': totalPriceWithExtras,
        'currency': currency.value,
      },
    };
  }
}