// ignore_for_file: body_might_complete_normally_catch_error

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ready_flights/services/api_service_emirates.dart';
import 'package:ready_flights/views/flight/search_flights/emirates_ndc/emirates_flight_controller.dart';
import '../../../services/api_service_airarabia.dart';
import '../../../services/api_service_flydubai.dart';
import '../../../services/api_service_sabre.dart';
import '../../../services/api_service_pia.dart';
import '../../../widgets/city_selection_bottom_sheet.dart';
import '../../../widgets/class_selection_bottom_sheet.dart';
import '../../../widgets/travelers_selection_bottom_sheet.dart';
import '../search_flights/airarabia/airarabia_flight_controller.dart';
import '../search_flights/airblue/airblue_flight_controller.dart';
import '../search_flights/flydubai/flydubai_controller.dart';
import '../search_flights/pia/pia_flight_controller.dart';
import '../search_flights/sabre/sabre_flight_controller.dart';
import '../search_flights/search_flights.dart';

enum TripType { oneWay, roundTrip, multiCity }
class CityPair {
  final RxString fromCity;
  final RxString fromCityName;
  final RxString toCity;
  final RxString toCityName;
  final RxString departureDate;
  final Rx<DateTime> departureDateTime; // Add DateTime property

  CityPair({
    String? fromCity,
    String? fromCityName,
    String? toCity,
    String? toCityName,
    String? departureDate,
    DateTime? departureDateTime,
  }) : fromCity = (fromCity ?? 'DEL').obs,
        fromCityName = (fromCityName ?? 'NEW DELHI').obs,
        toCity = (toCity ?? 'BOM').obs,
        toCityName = (toCityName ?? 'MUMBAI').obs,
        departureDate = (departureDate ?? '03/11/2025').obs,
        departureDateTime = (departureDateTime ?? DateTime.now()).obs;

  void swap() {
    final tempCity = fromCity.value;
    final tempCityName = fromCityName.value;

    fromCity.value = toCity.value;
    fromCityName.value = toCityName.value;

    toCity.value = tempCity;
    toCityName.value = tempCityName;
  }

  // Method to update both string and DateTime when date changes
  void updateDepartureDate(DateTime newDate) {
    departureDateTime.value = newDate;
    departureDate.value = DateFormat('dd/MM/yyyy').format(newDate);
  }
}

class FlightBookingController extends GetxController {
  // Trip type
  final Rx<TripType> tripType = TripType.oneWay.obs;
  var isSearching = false.obs;

  // City pairs for multicity
  final RxList<CityPair> cityPairs = <CityPair>[].obs;

  // City selection for one-way and round trip
  final RxString fromCity = 'LHE'.obs;
  final RxString fromCityName = 'Lahore'.obs;
  final RxString toCity = 'DXB'.obs;
  final RxString toCityName = 'Dubai'.obs;

  // Observable variables for origin, destination
  var origins = RxList<String>([]);
  var destinations = RxList<String>([]);

  // Date selection - Add DateTime properties
  final RxString departureDate =
      DateFormat('dd/MM/yyyy').format(DateTime.now()).obs;
  final RxString returnDate =
      DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.now().add(const Duration(days: 1))).obs;

  // Add DateTime observables for the CustomDateRangeSelector
  final Rx<DateTime> departureDateTimeValue = DateTime.now().obs;
  final Rx<DateTime> returnDateTimeValue =
      DateTime.now().add(const Duration(days: 1)).obs;

  // Traveller and class selection
  final RxInt travellersCount = 1.obs;
  final RxString travelClass = 'Economy'.obs;

  // Individual traveler counts
  final RxInt adultCount = 1.obs;
  final RxInt childrenCount = 0.obs;
  final RxInt infantCount = 0.obs;

  // API Service and Flight Controller
  final ApiServiceSabre apiServiceFlight = Get.put(ApiServiceSabre());
  final SabreFlightController flightController = Get.put(SabreFlightController());
  final AirArabiaFlightController airArabiaController = Get.put(
    AirArabiaFlightController(),
  );
  final PIAFlightApiService piaFlightApiService = Get.put(
    PIAFlightApiService(),
  );
  final ApiServiceAirArabia apiServiceAirArabia = Get.put(
    ApiServiceAirArabia(),
  );
  final FlydubaiFlightController flydubaiController = Get.put(FlydubaiFlightController());
  final ApiServiceEmirates apiServiceEmirates = Get.put(ApiServiceEmirates());
final EmiratesFlightController emiratesController = Get.put(EmiratesFlightController());



  // Getter for formatted origins string
  String get formattedOrigins =>
      origins.isNotEmpty ? ',${origins.join(',')}' : '';

  // Getter for formatted destinations string
  String get formattedDestinations =>
      destinations.isNotEmpty ? ',${destinations.join(',')}' : '';

  @override
  void onInit() {
    super.onInit();
    initializeTripType();
    initializeCityPairs();
    _syncDateValues(); // Sync initial date values
  }

  void _syncDateValues() {
    departureDateTimeValue.value = DateFormat(
      'dd/MM/yyyy',
    ).parse(departureDate.value);
    returnDateTimeValue.value = DateFormat(
      'dd/MM/yyyy',
    ).parse(returnDate.value);
  }

  void initializeTripType() {
    setTripType(TripType.roundTrip);
  }

  void initializeCityPairs() {
    // Clear existing pairs
    cityPairs.clear();

    // Add initial two pairs with proper date sequencing
    DateTime baseDate = DateTime.now();

    cityPairs.addAll([
      CityPair(
        fromCity: 'LHE',
        fromCityName: 'LAHORE',
        toCity: 'DXB',
        toCityName: 'DUBAI',
        departureDate: _formatDateForUI(baseDate),
        departureDateTime: baseDate,
      ),
      CityPair(
        fromCity: 'AUH',
        fromCityName: 'Abu Dhabi',
        toCity: 'LHE',
        toCityName: 'Lahore',
        departureDate: _formatDateForUI(baseDate.add(const Duration(days: 1))),
        departureDateTime: baseDate.add(const Duration(days: 1)),
      ),
    ]);
  }

  void setTripType(TripType type) {
    tripType.value = type;

    if (type == TripType.multiCity) {
      // If there are no city pairs, initialize them
      if (cityPairs.isEmpty) {
        initializeCityPairs();
      }
      // If there's only one pair, add another with connected cities and sequential dates
      else if (cityPairs.length < 2) {
        DateTime nextDay = DateFormat('dd/MM/yyyy')
            .parse(cityPairs.last.departureDate.value)
            .add(const Duration(days: 1));

        cityPairs.add(
          CityPair(
            fromCity: cityPairs.last.toCity.value,
            fromCityName: cityPairs.last.toCityName.value,
            toCity: 'LHE',
            toCityName: 'LAHORE',
            departureDate: _formatDateForUI(nextDay),
            departureDateTime: nextDay,
          ),
        );
      }
    }
  }

  // NEW METHODS FOR CustomDateRangeSelector COMPATIBILITY

  // Method for updating departure date (used by CustomDateRangeSelector)
  void updateDepartureDate(DateTime newDate) {
    departureDateTimeValue.value = newDate;
    departureDate.value = _formatDateForUI(newDate);

    // If return date is before the new departure date, update return date
    if (returnDateTimeValue.value.isBefore(
      newDate.add(const Duration(days: 1)),
    )) {
      updateReturnDate(newDate.add(const Duration(days: 1)));
    }
  }

  // Method for updating return date (used by CustomDateRangeSelector)
  void updateReturnDate(DateTime newDate) {
    // Ensure return date is not before departure date
    if (newDate.isBefore(
      departureDateTimeValue.value.add(const Duration(days: 1)),
    )) {
      returnDateTimeValue.value = departureDateTimeValue.value.add(
        const Duration(days: 1),
      );
      returnDate.value = _formatDateForUI(returnDateTimeValue.value);
    } else {
      returnDateTimeValue.value = newDate;
      returnDate.value = _formatDateForUI(newDate);
    }
  }

  // Method for updating multi-city flight date (used by CustomDateRangeSelector)
  void updateMultiCityFlightDate(int index, DateTime newDate) {
    if (index < cityPairs.length) {
      cityPairs[index].updateDepartureDate(newDate);

      // Update subsequent flights to maintain chronological order
      if (index < cityPairs.length - 1) {
        DateTime nextDay = newDate.add(const Duration(days: 1));
        cityPairs[index + 1].updateDepartureDate(nextDay);
      }
    }
  }

  // EXISTING METHODS (Updated to maintain compatibility)

  void swapCities() {
    if (tripType.value != TripType.multiCity) {
      final tempCity = fromCity.value;
      final tempCityName = fromCityName.value;

      fromCity.value = toCity.value;
      fromCityName.value = toCityName.value;

      toCity.value = tempCity;
      toCityName.value = tempCityName;
    }
  }

  void swapCitiesForPair(int index) {
    if (index < cityPairs.length) {
      cityPairs[index].swap();

      // Update the next flight's origin to match this flight's destination
      if (index < cityPairs.length - 1) {
        cityPairs[index + 1].fromCity.value = cityPairs[index].toCity.value;
        cityPairs[index + 1].fromCityName.value =
            cityPairs[index].toCityName.value;
      }
    }
  }

  void addCityPair() {
    if (cityPairs.length < 5) {
      final lastPair = cityPairs.last;

      // Use DateTime from last pair and add one day
      DateTime nextDepartureDate = lastPair.departureDateTime.value.add(
        const Duration(days: 1),
      );

      cityPairs.add(
        CityPair(
          fromCity: lastPair.toCity.value,
          fromCityName: lastPair.toCityName.value,
          toCity: 'DXB',
          toCityName: 'Dubai',
          departureDate: _formatDateForUI(nextDepartureDate),
          departureDateTime: nextDepartureDate,
        ),
      );
    }
  }

  void removeCityPair() {
    if (cityPairs.length > 2) {
      cityPairs.removeLast();
    }
  }

  void setDepartureDate(String date) {
    departureDate.value = date;
    departureDateTimeValue.value = DateFormat('dd/MM/yyyy').parse(date);

    // If return date is before the new departure date, update return date
    final DateTime departure = DateFormat(
      'dd/MM/yyyy',
    ).parse(departureDate.value);
    final DateTime returnDt = DateFormat('dd/MM/yyyy').parse(returnDate.value);

    if (returnDt.isBefore(departure)) {
      setReturnDate(date);
    }
  }

  void setReturnDate(String date) {
    returnDate.value = date;
    returnDateTimeValue.value = DateFormat('dd/MM/yyyy').parse(date);

    // If departure date is after the new return date, update departure date
    final DateTime departure = DateFormat(
      'dd/MM/yyyy',
    ).parse(departureDate.value);
    final DateTime returnDt = DateFormat('dd/MM/yyyy').parse(returnDate.value);

    if (departure.isAfter(returnDt)) {
      setDepartureDate(date);
    }
  }

  void setDepartureDateForPair(int index, String date) {
    if (index < cityPairs.length) {
      DateTime selectedDate = DateFormat('dd/MM/yyyy').parse(date);
      cityPairs[index].updateDepartureDate(selectedDate);

      // If this is not the last pair, update the next pair's departure date to be one day after
      if (index < cityPairs.length - 1) {
        DateTime nextDay = selectedDate.add(const Duration(days: 1));
        cityPairs[index + 1].updateDepartureDate(nextDay);
      }
    }
  }

  // Add to FlightBookingController class
  final AirBlueFlightController airBlueFlightController =
  Get.find<AirBlueFlightController>();
  final PIAFlightController piaFlightController = Get.put(
    PIAFlightController(),
  );

  // Update the searchFlights method to include proper PIA API calls
  Future<void> searchFlights() async {
    try {
      isSearching.value = true;

      // Clear previous results
      flightController.clearFlights();
      airBlueFlightController.clearFlights();
      airArabiaController.clearFlights();
      piaFlightController.clearFlights();
      flydubaiController.clearFlights();



      // Prepare parameters
      String origin = '';
      String destination = '';
      String formattedDates = '';

      if (tripType.value == TripType.multiCity) {
        origins.clear();
        destinations.clear();

        for (var pair in cityPairs) {
          origins.add(pair.fromCity.value);
          destinations.add(pair.toCity.value);
        }

        formattedDates = ',';
        for (int i = 0; i < cityPairs.length; i++) {
          if (i > 0) formattedDates += ',';
          formattedDates += _formatDateForAPI(
            cityPairs[i].departureDateTime.value,
          );
        }

        origin = formattedOrigins;
        destination = formattedDestinations;
      } else {
        origin = ',${fromCity.value}';
        destination = ',${toCity.value}';
        formattedDates = ',${_formatDateForAPI(departureDateTimeValue.value)}';
        if (tripType.value == TripType.roundTrip) {
          formattedDates += ',${_formatDateForAPI(returnDateTimeValue.value)}';
        }
      }

      // Call APIs in parallel
      final futures = [
          _callEmiratesApi(
        type: tripType.value == TripType.multiCity ? 2 : (tripType.value == TripType.roundTrip ? 1 : 0),
        origin: origin,
        destination: destination,
        depDate: formattedDates,
        adult: adultCount.value,
        child: childrenCount.value,
        infant: infantCount.value,
        cabin: travelClass.value,
      ),
        _callSabreApi(
          type: tripType.value == TripType.multiCity ? 2 : (tripType.value == TripType.roundTrip ? 1 : 0),
          origin: origin,
          destination: destination,
          depDate: formattedDates,
          adult: adultCount.value,
          child: childrenCount.value,
          infant: infantCount.value,
          cabin: travelClass.value.toUpperCase(),
        ),

        // // Call AirBlue API for all trip types including multi-city
        // _callAirBlueApi(
        //   type: tripType.value == TripType.multiCity ? 2 : (tripType.value == TripType.roundTrip ? 1 : 0),
        //   origin: origin,
        //   destination: destination,
        //   depDate: formattedDates,


        //   adult: adultCount.value,
        //   child: childrenCount.value,
        //   infant: infantCount.value,
        //   cabin: travelClass.value,
        // ),



        // Call Air Arabia API for all trip types except multi-city
          // _callAirArabiaApi(
          //   type: tripType.value == TripType.multiCity ? 2 : (tripType.value == TripType.roundTrip ? 1 : 0),
          //   origin: origin,
          //   destination: destination,
          //   depDate: formattedDates,
          //   adult: adultCount.value,
          //   child: childrenCount.value,
          //   infant: infantCount.value,
            
          //   cabin: travelClass.value,
          // ),
      ];

      // 2. FlyDubai API (via FlyDubai controller) - SINGLE CALL, NO DUPLICATES
      // futures.add(_callFlyDubaiApi(
      //   type: tripType.value == TripType.multiCity ? 2 : (tripType.value == TripType.roundTrip ? 1 : 0),
      //   origin: origin,
      //   destination: destination,
      //   depDate: formattedDates,
      //   adult: adultCount.value,
      //   child: childrenCount.value,
      //   infant: infantCount.value,
      //   cabin: travelClass.value,
      // ));

      // Add PIA API call based on trip type
      if (tripType.value == TripType.multiCity && cityPairs.isNotEmpty) {
        // Prepare multi-city segments
        final segments = cityPairs
            .map(
              (pair) => {
            'from': pair.fromCity.value,
            'to': pair.toCity.value,
            'date': _formatDateForAPI(pair.departureDateTime.value),
          },
        )
            .toList();
      
        futures.add(
          _callPiaApi(
            fromCity: cityPairs.first.fromCity.value,
            toCity: cityPairs.first.toCity.value,
            departureDate: _formatDateForAPI(
              cityPairs.first.departureDateTime.value,
            ),
            adultCount: adultCount.value,
            childCount: childrenCount.value,
            infantCount: infantCount.value,
            tripType: 'MULTI_DIRECTIONAL',
            multiCitySegments: segments,
          ),
        );
      } else {
        futures.add(
          _callPiaApi(
            fromCity: fromCity.value,
            toCity: toCity.value,
            departureDate: _formatDateForAPI(departureDateTimeValue.value),
            adultCount: adultCount.value,
            childCount: childrenCount.value,
            infantCount: infantCount.value,
            tripType: tripType.value == TripType.roundTrip ? 'ROUND_TRIP' : 'ONE_WAY',
            returnDate: tripType.value == TripType.roundTrip
                ? _formatDateForAPI(returnDateTimeValue.value)
                : null,
          ),
        );
      }

      // Don't wait for all APIs to complete - they'll update UI as they finish
      Future.wait(futures).catchError((e) {
        debugPrint('Error in flight model_controllers: $e');
      });

      // Navigate immediately to results page
      Get.to(
            () => FlightBookingPage(
          scenario: tripType.value == TripType.roundTrip
              ? FlightScenario.returnFlight
              : (tripType.value == TripType.multiCity
              ? FlightScenario.multiCity
              : FlightScenario.oneWay),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error in searchFlights: $e');
      debugPrint('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Error searching flights: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSearching.value = false;
    }
  }
  // Update the _callAirArabiaApi method in flight_booking_controller.dart
  Future<void> _callAirArabiaApi({
    required int type,
    required String origin,
    required String destination,
    required String depDate,
    required int adult,
    required int child,
    required int infant,
    required String cabin,
  }) async {
    try {
      final result = await apiServiceAirArabia.searchFlights(
        type: type,
        origin: origin,
        destination: destination,
        depDate: depDate,
        adult: adult,
        child: child,
        infant: infant,
        cabin: cabin,
      );

      // Make sure the result is a Map
      airArabiaController.loadFlights(result);
        } catch (e) {
      debugPrint('Air Arabia API error: $e');
      airArabiaController.setErrorMessage('Failed to load Air Arabia flights');
    }
  }

  Future<void> _callPiaApi({
    required String fromCity,
    required String toCity,
    required String departureDate,
    required int adultCount,
    required int childCount,
    required int infantCount,
    required String tripType,
    String? returnDate,
    List<Map<String, String>>? multiCitySegments,
  }) async {
    try {
      final result = await piaFlightApiService.piaFlightAvailability(
        fromCity: fromCity,
        toCity: toCity,
        departureDate: departureDate,
        adultCount: adultCount,
        childCount: childCount,
        infantCount: infantCount,
        tripType: tripType,
        returnDate: returnDate,
        multiCitySegments: multiCitySegments,
      );

      if (result.containsKey('error')) {
        piaFlightController.setErrorMessage(result['error']);
      } else {
        piaFlightController.loadFlights(result);
      }
    } catch (e) {
      debugPrint('PIA API error: $e');
      piaFlightController.setErrorMessage('PIA API error: ${e.toString()}');
    }
  }


  Future<void> _callFlyDubaiApi({
    required int type,
    required String origin,
    required String destination,
    required String depDate,
    required int adult,
    required int child,
    required int infant,
    required String cabin,
  }) async {
    try {
      debugPrint('=== CALLING FLYDUBAI VIA API SERVICE ===');

      // Clean parameters
      String actualOrigin = origin.replaceAll(',', '').trim().toUpperCase();
      String actualDestination = destination.replaceAll(',', '').trim().toUpperCase();
      String cleanDepDate = depDate.replaceAll(',', '').trim();

      debugPrint('Cleaned Parameters:');
      debugPrint('Origin: $actualOrigin');
      debugPrint('Destination: $actualDestination');
      debugPrint('Date: $cleanDepDate');
      debugPrint('Type: $type (${type == 0 ? "One-way" : type == 1 ? "Round-trip" : "Multi-city"})');

      // Format dates properly based on trip type
      String formattedDates = '';
      List<Map<String, String>>? multiCitySegments;

      if (type == 2) {
        // Multi-city: prepare segments
        multiCitySegments = cityPairs.map((pair) => {
          'from': pair.fromCity.value,
          'to': pair.toCity.value,
          'date': _formatDateForAPI(pair.departureDateTime.value),
        }).toList();

        // Create comma-separated dates for multi-city
        formattedDates = cityPairs.map((pair) =>
            _formatDateForAPI(pair.departureDateTime.value)
        ).join(',');

      } else if (type == 1) {
        // Round-trip: format both departure and return dates
        formattedDates = '${_formatDateForAPI(departureDateTimeValue.value)},${_formatDateForAPI(returnDateTimeValue.value)}';
      } else {
        // One-way: just departure date
        formattedDates = _formatDateForAPI(departureDateTimeValue.value);
      }

      debugPrint('Formatted dates: $formattedDates');

      // Create API service instance
      final apiService = ApiServiceFlyDubai();

      // Call the API service
      final result = await apiService.searchFlights(
        type: type,
        origin: actualOrigin,
        destination: actualDestination,
        depDate: formattedDates,
        adult: adult,
        child: child,
        infant: infant,
        cabin: cabin,
        multiCitySegments: multiCitySegments,
      );

      debugPrint('FlyDubai API result keys: ${result.keys}');

      // Process result
      if (result['success'] == true && result.containsKey('flights')) {
        flydubaiController.loadFlights(result, fromCity.value, toCity.value, tripType.value == TripType.roundTrip ? 1 : 0);
        debugPrint('FlyDubai flights loaded successfully');
      } else {
        final error = result['error'] ?? 'Unknown FlyDubai API error';
        flydubaiController.setErrorMessage(error);
        debugPrint('FlyDubai API Error: $error');
      }

    } catch (e, stackTrace) {
      debugPrint('FlyDubai API call error: $e');
      debugPrint('Stack trace: $stackTrace');
      flydubaiController.setErrorMessage('FlyDubai API error: ${e.toString()}');
    }
  }
  Future<void> _callEmiratesApi({
  required int type,
  required String origin,
  required String destination,
  required String depDate,
  required int adult,
  required int child,
  required int infant,
  required String cabin,
}) async {
  try {
    debugPrint('=== CALLING EMIRATES API ===');
    debugPrint('Type: $type');
    debugPrint('Origin: $origin');
    debugPrint('Destination: $destination');
    debugPrint('Departure Date: $depDate');
    debugPrint('Adult: $adult, Child: $child, Infant: $infant');
    debugPrint('Cabin: $cabin');

    final result = await apiServiceEmirates.searchFlights(
      type: type,
      origin: origin,
      destination: destination,
      depDate: depDate,
      adult: adult,
      child: child,
      infant: infant,
      cabin: cabin,
    );

    debugPrint('Emirates API result keys: ${result.keys}');

    // Load flights into controller (you'll implement this based on response structure)
    emiratesController.loadFlights(result);
    
    debugPrint('Emirates flights loaded successfully');
  } catch (e, stackTrace) {
    debugPrint('Emirates API error: $e');
    debugPrint('Stack trace: $stackTrace');
    emiratesController.setErrorMessage('Emirates API error: ${e.toString()}');
  }
}
  Future<void> _callSabreApi({
    required int type,
    required String origin,
    required String destination,
    required String depDate,
    required int adult,
    required int child,
    required int infant,
    required String cabin,
  }) async { 
    print("check run saber ");


    try {
    print("check run saber 1");

      final result = await apiServiceFlight.searchFlights(
        type: type,
        origin: origin,
        destination: destination,
        depDate: depDate,
        adult: adult,
        child: child,
        infant: infant,
        stop: 2,
        cabin: cabin,
        flight: 0,
      );
      flightController.loadFlights(result);
    } catch (e) {
      // Optionally show error in UI
    }
  }

  Future<void> _callAirBlueApi({
    required int type,
    required String origin,
    required String destination,
    required String depDate,
    required int adult,
    required int child,
    required int infant,
    required String cabin,
  }) async {
    try {
      final result = await apiServiceFlight.searchFlights(
        type: type,
        origin: origin,
        destination: destination,
        depDate: depDate,
        adult: adult,
        child: child,
        infant: infant,
        stop: 2,
        cabin: cabin,
        flight: 1,
      );
      airBlueFlightController.loadFlights(result);
    } catch (e) {
      airBlueFlightController.setErrorMessage('Failed to load AirBlue flights');
    }
  }

  String _formatDateForUI(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatDateForAPI(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void openDepartureDatePicker(BuildContext context) {
    _showDatePicker(context, (date) {
      updateDepartureDate(date); // Use new method
    });
  }

  void openReturnDatePicker(BuildContext context) {
    if (tripType.value != TripType.oneWay) {
      _showDatePicker(context, (date) {
        updateReturnDate(date); // Use new method
      });
    }
  }

  void openDatePickerForPair(BuildContext context, int index) {
    _showDatePicker(context, (date) {
      updateMultiCityFlightDate(index, date); // Use new method
    });
  }

  void _showDatePicker(
      BuildContext context,
      Function(DateTime) onDateSelected,
      ) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        onDateSelected(date);
      }
    });
  }

  void showCitySelectionBottomSheet(
      BuildContext context,
      FieldType fieldType, {
        int? multiCityIndex,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CitySelectionBottomSheet(
        fieldType: fieldType,
        onCitySelected: (AirportData airport) {
          if (tripType.value == TripType.multiCity &&
              multiCityIndex != null) {
            if (fieldType == FieldType.departure) {
              cityPairs[multiCityIndex].fromCity.value = airport.code;
              cityPairs[multiCityIndex].fromCityName.value =
                  airport.cityName;
            } else {
              cityPairs[multiCityIndex].toCity.value = airport.code;
              cityPairs[multiCityIndex].toCityName.value = airport.cityName;

              // If this is not the last pair, update the next pair's departure city
              if (multiCityIndex < cityPairs.length - 1) {
                cityPairs[multiCityIndex + 1].fromCity.value = airport.code;
                cityPairs[multiCityIndex + 1].fromCityName.value =
                    airport.cityName;
              }
            }
          } else {
            if (fieldType == FieldType.departure) {
              fromCity.value = airport.code;
              fromCityName.value = airport.cityName;
            } else {
              toCity.value = airport.code;
              toCityName.value = airport.cityName;
            }
          }
        },
      ),
    );
  }

  void showTravelersSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TravelersSelectionBottomSheet(
        initialClass: travelClass.value, // Pass current class
        onTravelersSelected: (adults, children, infants, selectedClass) {
          // Update all values including travel class
          adultCount.value = adults;
          childrenCount.value = children;
          infantCount.value = infants;
          travelClass.value = selectedClass;

          // Update travelers count for display
          travellersCount.value = adults + children + infants;
        },
      ),
    );
  }

  void showClassSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ClassSelectionBottomSheet(
        initialClass: travelClass.value,
        onClassSelected: (selectedClass) {
          travelClass.value = selectedClass;
        },
      ),
    );
  }

  void updateTravellerCounts(int adults, int children, int infants) {
    adultCount.value = adults;
    childrenCount.value = children;
    infantCount.value = infants;
    travellersCount.value = adults + children + infants;
  }

  // Add this to your FlightBookingController class

// Helper method to check if a city/country is in Pakistan
  bool _isPakistan(String cityCode, String cityName, String countryName) {
    // Check if country is Pakistan (case insensitive)
    final isCountryPakistan = countryName.toLowerCase().contains('pakistan');

    // // Additional check for city codes (optional, for extra certainty)
    // final pakistanCityCodes = ['LHE', 'KHI', 'ISB', 'PEW', 'MUX', 'LYP', 'SKT'];
    // final isCityCodePakistani = pakistanCityCodes.contains(cityCode.toUpperCase());

    return isCountryPakistan;
  }

// Computed property to check if current selection is domestic
  bool get isDomesticFlight {
    if (tripType.value == TripType.multiCity) {
      // For multi-city, check if all segments are within Pakistan
      return cityPairs.every((pair) {
        // We need to get the full airport data to check country
        // This assumes you have access to the airport data in the controller
        // You might need to modify this based on how you store airport data
        final departureAirport = _getAirportByCode(pair.fromCity.value);
        final arrivalAirport = _getAirportByCode(pair.toCity.value);

        return departureAirport != null &&
            arrivalAirport != null &&
            _isPakistan(departureAirport.code, departureAirport.cityName, departureAirport.countryName) &&
            _isPakistan(arrivalAirport.code, arrivalAirport.cityName, arrivalAirport.countryName);
      });
    } else {
      // For one-way/round-trip, check departure and arrival
      final departureAirport = _getAirportByCode(fromCity.value);
      final arrivalAirport = _getAirportByCode(toCity.value);

      return departureAirport != null &&
          arrivalAirport != null &&
          _isPakistan(departureAirport.code, departureAirport.cityName, departureAirport.countryName) &&
          _isPakistan(arrivalAirport.code, arrivalAirport.cityName, arrivalAirport.countryName);
    }
  }

// Helper method to get airport data by code (you'll need to implement this)
  AirportData? _getAirportByCode(String code) {
    // You'll need access to the list of airports here
    // If you're using the AirportController, you might do:
    final airportController = Get.find<AirportController>();
    return airportController.airports.firstWhereOrNull((airport) => airport.code == code);
  }

}