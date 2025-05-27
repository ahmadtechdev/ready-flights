import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

import '../../../../../services/api_service_pia.dart';
import 'pia_flight_model.dart';

class PIAFlightController extends GetxController {
  final RxList<PIAFlight> flights = <PIAFlight>[].obs;
  final RxList<PIAFlight> filteredFlights = <PIAFlight>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedCurrency = 'PKR'.obs;

  final PIAFlightApiService _apiService = Get.put(PIAFlightApiService());

  void updateCurrency(String currency) {
    selectedCurrency.value = currency;
  }

  void clearFlights() {
    flights.clear();
    filteredFlights.clear(); // Also clear filtered flights
    errorMessage.value = '';
  }

  void setErrorMessage(String message) {
    errorMessage.value = message;
  }

  Future<void> loadFlights(Map<String, dynamic> apiResponse) async {

    try {
      isLoading.value = true;
      clearFlights();

      if (apiResponse.isEmpty) {
        throw Exception('Empty API response');
      }

      if (apiResponse['error'] != null) {
        throw Exception(apiResponse['error']);
      }

      // For Badgerfish conversion, namespaces become attributes with '@'
      final envelope = apiResponse['S:Envelope'] ??
          apiResponse['soapenv:Envelope'] ??
          apiResponse['Envelope'] ??
          apiResponse['@S:Envelope'] ??
          apiResponse['@soapenv:Envelope'];

      if (envelope == null) {
        // Try direct access if conversion flattened the structure
        if (apiResponse['Availability'] != null) {
          _processAvailability(apiResponse);
          return;
        }
        throw Exception('Invalid API response format - missing envelope');
      }

      // Handle Badgerfish format where body might be under '$' or '@'
      final body = envelope['S:Body'] ??
          envelope['soapenv:Body'] ??
          envelope['Body'] ??
          envelope['@S:Body'] ??
          envelope['@soapenv:Body'] ??
          envelope['\$']?['S:Body'] ??
          envelope['\$']?['soapenv:Body'];

      if (body == null) {
        throw Exception('Invalid API response format - missing body');
      }

      final response = body['ns2:GetAvailabilityResponse'] ??
          body['impl:GetAvailabilityResponse'] ??
          body['GetAvailabilityResponse'] ??
          body['@ns2:GetAvailabilityResponse'] ??
          body['@impl:GetAvailabilityResponse'] ??
          body['\$']?['ns2:GetAvailabilityResponse'] ??
          body['\$']?['impl:GetAvailabilityResponse'];

      if (response == null) {
        throw Exception('Invalid API response format - missing availability response');
      }

      final availability = response['Availability'] ??
          response['\$']?['Availability'] ??
          response['@Availability'];

      if (availability == null) {
        throw Exception('No availability data in response');
      }

      _processAvailability(availability);
    } catch (e, stackTrace) {
      debugPrint('Error loading PIA flights: $e');
      debugPrint('Stack trace: $stackTrace');
      setErrorMessage('Failed to load PIA flights: ${e.toString()}');
      flights.value = [];
      filteredFlights.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void _processAvailability(Map<String, dynamic> availability) {
    try {
      debugPrint('Processing availability data: ${availability.keys}');

      // Handle different response structures
      final routeList = availability['availabilityRouteList'] ??
          availability['availabilityResultList']?['availabilityRouteList'] ??
          availability['\$']?['availabilityRouteList'];

      if (routeList == null) {
        throw Exception('No route list found in availability data');
      }

      // Handle both single route and list of routes
      final routes = routeList is List ? routeList : [routeList];
      debugPrint('Found ${routes.length} routes');

      for (final route in routes) {
        final byDateList = route['availabilityByDateList'] ?? route['\$']?['availabilityByDateList'];
        if (byDateList == null) continue;

        // Handle both single date and list of dates
        final dateLists = byDateList is List ? byDateList : [byDateList];
        debugPrint('Found ${dateLists.length} date lists');

        for (final dateData in dateLists) {
          final options = dateData['originDestinationOptionList'] ?? dateData['\$']?['originDestinationOptionList'];
          if (options == null) continue;

          // Handle both single option and list of options
          final optionList = options is List ? options : [options];
          debugPrint('Found ${optionList.length} options');

          for (final option in optionList) {
            final fareGroups = option['fareComponentGroupList'] ?? option['\$']?['fareComponentGroupList'];
            if (fareGroups == null) continue;

            // Handle both single fare group and list
            final fareGroupList = fareGroups is List ? fareGroups : [fareGroups];
            for (final fareGroup in fareGroupList) {
              _processFareGroup(fareGroup, option);
            }
          }
        }
      }

      debugPrint('Finished processing. Found ${flights.length} flights.');
      filteredFlights.assignAll(flights);
    } catch (e, stackTrace) {
      debugPrint('Error processing availability: $e');
      debugPrint('Stack trace: $stackTrace');
      setErrorMessage('Failed to process flight data');
    }
  }

  void _processFareGroup(Map<String, dynamic> fareGroup, Map<String, dynamic> option) {
    try {
      final boundList = fareGroup['boundList'] ?? option['boundList'];
      if (boundList == null) return;

      // Handle both single bound and list of bounds
      final bounds = boundList is List ? boundList : [boundList];

      for (final bound in bounds) {
        final segments = bound['availFlightSegmentList'];
        if (segments == null) continue;

        // Handle both single segment and list of segments
        final segmentList = segments is List ? segments : [segments];

        // Get the main flight segment (first segment)
        if (segmentList.isEmpty) continue;
        final mainSegment = segmentList[0];

        // Process fare components
        final fareComponents = fareGroup['fareComponentList'];
        if (fareComponents == null) continue;

        // Handle both single fare component and list of fare components
        final componentList = fareComponents is List ? fareComponents : [fareComponents];

        for (final component in componentList) {
          final flight = _createFlightFromComponents(mainSegment, component);
          if (flight != null) {
            debugPrint('Adding flight: ${flight.flightNumber}');
            flights.add(flight);
            filteredFlights.add(flight);
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing fare group: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  PIAFlight? _createFlightFromComponents(
      Map<String, dynamic> segment, Map<String, dynamic> fareComponent) {
    try {
      debugPrint('Creating flight from segment: ${segment['flightNumber']}');

      // Handle different segment structures
      final flightSegment = segment['flightSegment'] ?? segment;

      // Validate required fields are present
      if (flightSegment['departureAirport'] == null || flightSegment['arrivalAirport'] == null) {
        debugPrint('Missing airport information in segment: ${flightSegment.keys}');
        return null;
      }

      // Get passenger fare info (first passenger type)
      final passengerFareInfoList = fareComponent['passengerFareInfoList'] ??
          fareComponent['\$']?['passengerFareInfoList'];

      if (passengerFareInfoList == null) {
        debugPrint('No passenger fare info list');
        return null;
      }

      // Handle both single info and list
      final fareInfoList = passengerFareInfoList is List
          ? (passengerFareInfoList.isNotEmpty ? passengerFareInfoList[0] : null)
          : passengerFareInfoList;

      if (fareInfoList == null) {
        debugPrint('No fare info list');
        return null;
      }

      final fareInfo = fareInfoList['fareInfoList'] ?? fareInfoList['\$']?['fareInfoList'];
      if (fareInfo == null) {
        debugPrint('No fare info found');
        return null;
      }

      // Handle both single fare info and list
      final firstFareInfo = fareInfo is List ? (fareInfo.isNotEmpty ? fareInfo[0] : null) : fareInfo;

      if (firstFareInfo == null) {
        debugPrint('No first fare info found');
        return null;
      }

      final pricingInfo = fareInfoList['pricingInfo'] ?? fareInfoList['\$']?['pricingInfo'];
      if (pricingInfo == null) {
        debugPrint('No pricing info found');
        return null;
      }

      // Create flight data structure for the model
      final flightData = {
        'flightSegment': flightSegment,
        'fareInfoList': [{'fareInfoList': [firstFareInfo]}],
        'pricingInfo': pricingInfo,
      };

      return PIAFlight.fromApiResponse(flightData);
    } catch (e, stackTrace) {
      debugPrint('Error creating flight from components: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  void handlePIAFlightSelection(PIAFlight flight) {
    Get.snackbar("PIA Flight Selected", "Yes it is !!!!");
    // Handle flight selection logic
    // Get.to(() => PackageSelectionDialog(
    //   flight: flight,
    //   isAnyFlightRemaining: false,
    // ));
  }

// Add filter and sorting methods similar to Sabre controller as needed
}