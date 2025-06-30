// ignore_for_file: unused_element, depend_on_referenced_packages, deprecated_member_use

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml2json/xml2json.dart';

import '../views/flight/search_flights/booking_flight/booking_flight_controller.dart';
import '../views/flight/search_flights/pia/pia_flight_controller.dart';
import '../views/flight/search_flights/pia/pia_flight_model.dart';

class PIAFlightApiService {
  final Dio _dio = Dio();
  final PIAFlightController piaController = Get.put(PIAFlightController());

  Future<Map<String, dynamic>> piaFlightAvailability({
    required String fromCity,
    required String toCity,
    required String departureDate,
    required int adultCount,
    required int childCount,
    required int infantCount,
    String tripType = 'ONE_WAY',
    String preferredCurrency = 'PKR',
    String preferredLanguage = 'PK',
    String? returnDate, // For round trips
    List<Map<String, String>>? multiCitySegments, // For multi-city trips
  }) async {
    try {
      // Build originDestinationInformationList based on trip type
      String originDestinationInfo = '';

      if (tripType == 'ONE_WAY') {
        originDestinationInfo = '''
        <originDestinationInformationList>
          <dateOffset>0</dateOffset>
          <departureDateTime>$departureDate</departureDateTime>
          <destinationLocation>
            <locationCode>$toCity</locationCode>
          </destinationLocation>
          <flexibleFaresOnly>false</flexibleFaresOnly>
          <includeInterlineFlights>false</includeInterlineFlights>
          <openFlight>false</openFlight>
          <originLocation>
            <locationCode>$fromCity</locationCode>
          </originLocation>
        </originDestinationInformationList>
        ''';
      }
      else if (tripType == 'ROUND_TRIP') {
        originDestinationInfo = '''
        <originDestinationInformationList>
          <dateOffset>0</dateOffset>
          <departureDateTime>$departureDate</departureDateTime>
          <destinationLocation>
            <locationCode>$toCity</locationCode>
          </destinationLocation>
          <flexibleFaresOnly>false</flexibleFaresOnly>
          <includeInterlineFlights>false</includeInterlineFlights>
          <openFlight>false</openFlight>
          <originLocation>
            <locationCode>$fromCity</locationCode>
          </originLocation>
        </originDestinationInformationList>
        <originDestinationInformationList>
          <dateOffset>0</dateOffset>
          <departureDateTime>${returnDate ?? departureDate}</departureDateTime>
          <destinationLocation>
            <locationCode>$fromCity</locationCode>
          </destinationLocation>
          <flexibleFaresOnly>false</flexibleFaresOnly>
          <includeInterlineFlights>false</includeInterlineFlights>
          <openFlight>false</openFlight>
          <originLocation>
            <locationCode>$toCity</locationCode>
          </originLocation>
        </originDestinationInformationList>
        ''';
      }
      else if (tripType == 'MULTI_DIRECTIONAL') {
        if (multiCitySegments != null && multiCitySegments.isNotEmpty) {
          for (var segment in multiCitySegments) {
            originDestinationInfo += '''
            <originDestinationInformationList>
              <dateOffset>0</dateOffset>
              <departureDateTime>${segment['date'] ?? departureDate}</departureDateTime>
              <destinationLocation>
                <locationCode>${segment['to'] ?? toCity}</locationCode>
              </destinationLocation>
              <flexibleFaresOnly>false</flexibleFaresOnly>
              <includeInterlineFlights>false</includeInterlineFlights>
              <openFlight>false</openFlight>
              <originLocation>
                <locationCode>${segment['from'] ?? fromCity}</locationCode>
              </originLocation>
            </originDestinationInformationList>
            ''';
          }
        } else {
          // Default multi-city if no segments provided
          originDestinationInfo = '''
          <originDestinationInformationList>
            <dateOffset>0</dateOffset>
            <departureDateTime>$departureDate</departureDateTime>
            <destinationLocation>
              <locationCode>$toCity</locationCode>
            </destinationLocation>
            <flexibleFaresOnly>false</flexibleFaresOnly>
            <includeInterlineFlights>false</includeInterlineFlights>
            <openFlight>false</openFlight>
            <originLocation>
              <locationCode>$fromCity</locationCode>
            </originLocation>
          </originDestinationInformationList>
          <originDestinationInformationList>
            <dateOffset>0</dateOffset>
            <departureDateTime>${DateTime.parse(departureDate).add(const Duration(days: 3)).toString().substring(0, 10)}</departureDateTime>
            <destinationLocation>
              <locationCode>LHE</locationCode>
            </destinationLocation>
            <flexibleFaresOnly>false</flexibleFaresOnly>
            <includeInterlineFlights>false</includeInterlineFlights>
            <openFlight>false</openFlight>
            <originLocation>
              <locationCode>$toCity</locationCode>
            </originLocation>
          </originDestinationInformationList>
          ''';
        }
      }

      // Build the XML request with dynamic parameters
      final request = '''
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:impl="http://impl.soap.ws.crane.hititcs.com/">
  <soapenv:Header/>
  <soapenv:Body>
    <impl:GetAvailability>
      <AirAvailabilityRequest>
        <clientInformation>
          <clientIP>127.0.0.1</clientIP>
          <member>false</member>
          <password>NewOneRoof@121</password>
          <preferredCurrency>$preferredCurrency</preferredCurrency>
          <preferredLanguage>$preferredLanguage</preferredLanguage>
          <userName>PSA2746487</userName>
        </clientInformation>
        $originDestinationInfo
        <travelerInformation>
          <passengerTypeQuantityList>
            <hasStrecher/>
            <passengerType>
              <code>ADLT</code>
            </passengerType>
            <quantity>$adultCount</quantity>
          </passengerTypeQuantityList>
          <passengerTypeQuantityList>
            <hasStrecher/>
            <passengerType>
              <code>CHLD</code>
            </passengerType>
            <quantity>$childCount</quantity>
          </passengerTypeQuantityList>
          <passengerTypeQuantityList>
            <hasStrecher/>
            <passengerType>
              <code>INFT</code>
            </passengerType>
            <quantity>$infantCount</quantity>
          </passengerTypeQuantityList>
        </travelerInformation>
        <tripType>$tripType</tripType>
      </AirAvailabilityRequest>
    </impl:GetAvailability>
  </soapenv:Body>
</soapenv:Envelope>
''';

      // Print the request in pretty format
      // debugPrint('=== PIA FLIGHT AVAILABILITY REQUEST ===');
      // _printXmlPretty(request);

      // Make the API call
      final response = await _dio.post(
        'https://app-stage.crane.aero/craneota/CraneOTAService',
        data: request,
        options: Options(
          contentType: 'text/xml; charset=utf-8',
          headers: {
            'SOAPAction': 'http://impl.soap.ws.crane.hititcs.com/GetAvailability',
            'Content-Type': 'text/xml; charset=utf-8',
          },
          responseType: ResponseType.plain,
        ),
      );
      //
      // // Print the response in pretty format
      // debugPrint('=== PIA FLIGHT AVAILABILITY RESPONSE ===');
      // _printXmlPretty(response.data.toString());

      // Convert XML to Map if needed
      return _convertXmlToJson(response.data.toString());
    } catch (e) {
      debugPrint('Error checking PIA flight availability: $e');
      rethrow;
    }
  }

  // ************* PIA Flight Booking**********************************************

  Future<Map<String, dynamic>> savePIABooking({
    required BookingFlightController bookingController,
    required PIAFlight flight,
    required PIAFlight? returnFlight,
    required String token,
  }) async {
    try {
      // Prepare booking info
      final bookingInfo = {
        "bfname": bookingController.firstNameController.text,
        "blname": bookingController.lastNameController.text,
        "bemail": bookingController.emailController.text,
        "bphno": bookingController.phoneController.text,
        "badd": bookingController.addressController.text,
        "bcity": bookingController.cityController.text,
        "final_price": flight.price.toString(),
        "client_email": bookingController.emailController.text,
        "client_phone": bookingController.phoneController.text,
      };

      // Prepare passengers data
      final adults = bookingController.adults.map((adult) {
        return {
          "title": adult.titleController.text,
          "first_name": adult.firstNameController.text,
          "last_name": adult.lastNameController.text,
          "dob": adult.dateOfBirthController.text,
          "nationality": adult.nationalityController.text,
          "passport": adult.passportController.text,
          "passport_expiry": adult.passportExpiryController.text,
          "cnic": "3310285868703", // CNIC is not collected in current form, leaving empty
        };
      }).toList();

      final children = bookingController.children.map((child) {
        return {
          "title": child.titleController.text,
          "first_name": child.firstNameController.text,
          "last_name": child.lastNameController.text,
          "dob": child.dateOfBirthController.text,
          "nationality": child.nationalityController.text,
          "passport": child.passportController.text,
          "passport_expiry": child.passportExpiryController.text,
          "cnic": "3310285868703",
        };
      }).toList();

      final infants = bookingController.infants.map((infant) {
        return {
          "title": infant.titleController.text,
          "first_name": infant.firstNameController.text,
          "last_name": infant.lastNameController.text,
          "dob": infant.dateOfBirthController.text,
          "nationality": infant.nationalityController.text,
          "passport": infant.passportController.text,
          "passport_expiry": infant.passportExpiryController.text,
          "cnic": "3310285868703",
        };
      }).toList();

      // Prepare flights data - will contain all segments for all legs
      final flights = <Map<String, dynamic>>[];

      // Process outbound flight (could be OneWay or part of RoundTrip/MultiCity)
      _processFlightLegs(flight, flights, isReturn: false);

      // Process return flight if exists
      if (returnFlight != null) {
        _processFlightLegs(returnFlight, flights, isReturn: true);
      }

      // Prepare final request body
      final requestBody = {
        "booking_info": bookingInfo,
        "adults": adults,
        "children": children,
        "infants": infants,
        "flights": flights,
      };

      // Print the request in pretty format
      debugPrint('=== PIA FLIGHT DB SAVE REQUEST ===');
      if (kDebugMode) {
        print(requestBody);
      }
      debugPrint('=== PIA FLIGHT DB SAVE REQUEST END ===');
      // Configure Dio
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://onerooftravel.net/api/',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          responseType: ResponseType.json,
        ),
      );

      // Make the API call
      final response = await dio.post('flight-booking', data: requestBody);

      debugPrint('=== PIA FLIGHT DB SAVE Response ===');
      if (kDebugMode) {
        print(response.data);
      }
      debugPrint('=== PIA FLIGHT DB SAVE Response END ===');

      // Handle response
      if (response.statusCode == 200 || response.data['status']== 200) {

        if (response.data is Map<String, dynamic>) {

          return response.data;
        } else if (response.data is String) {

          return jsonDecode(response.data) as Map<String, dynamic>;
        }

        return {'status': 'success'};
      } else {
        // Handle error responses
        dynamic errorData;
        try {
          errorData = response.data is String
              ? jsonDecode(response.data)
              : response.data;
        } catch (e) {
          errorData = {'message': response.data?.toString() ?? 'Unknown error'};
        }

        // Format error message from API response
        String errorMessage = 'Failed to create booking';
        if (errorData is Map) {
          if (errorData['errors'] is Map) {
            final errors = (errorData['errors'] as Map).entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n');
            errorMessage = errors;
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        }

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          errors: errorData['errors'] ?? {},
        );
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      String errorMessage = 'Network error occurred';
      if (e.response != null) {
        try {
          final errorData = e.response!.data is String
              ? jsonDecode(e.response!.data)
              : e.response!.data;

          if (errorData is Map && errorData['errors'] != null) {
            errorMessage = (errorData['errors'] as Map).entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n');
          } else if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {
          errorMessage = e.response?.data?.toString() ?? 'Unknown error';
        }
      }
      throw ApiException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
        errors: {},
      );
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: null, errors: {});
    }
  }

  void _processFlightLegs(PIAFlight flight, List<Map<String, dynamic>> flights, {required bool isReturn}) {
    // Get all legs for this flight (could be multiple for multi-city)
    final legs = flight.legWithStops;

    for (var leg in legs) {
      final segment = _getFirstSegmentInfo(leg);
      final flightSegment = leg['flightSegment'] ?? {};

      // Parse departure and arrival times
      final departureDateTime = DateTime.parse(_extractStringValue(flightSegment['departureDateTime']));
      final arrivalDateTime = DateTime.parse(_extractStringValue(flightSegment['arrivalDateTime']));
      final duration = arrivalDateTime.difference(departureDateTime);

      // Get airports
      final departureAirport = _extractNestedValue(flightSegment, ['departureAirport', 'locationCode']) ?? '';
      final arrivalAirport = _extractNestedValue(flightSegment, ['arrivalAirport', 'locationCode']) ?? '';

      // Get terminals
      final departureTerminal = _extractNestedValue(flightSegment, ['departureAirport', 'terminal']) ?? 'Main';
      final arrivalTerminal = _extractNestedValue(flightSegment, ['arrivalAirport', 'terminal']) ?? 'Main';

      // Get flight number
      final flightNumber = _extractStringValue(flightSegment['flightNumber']);

      // Add flight data
      flights.add({
        "departure": {
          "airport": departureAirport,
          "date": departureDateTime.toIso8601String().split('T')[0],
          "time": "${departureDateTime.hour.toString().padLeft(2, '0')}:${departureDateTime.minute.toString().padLeft(2, '0')}",
          "terminal": departureTerminal,
        },
        "arrival": {
          "airport": arrivalAirport,
          "date": arrivalDateTime.toIso8601String().split('T')[0],
          "time": "${arrivalDateTime.hour.toString().padLeft(2, '0')}:${arrivalDateTime.minute.toString().padLeft(2, '0')}",
          "terminal": arrivalTerminal,
        },
        "flight_number": flightNumber,
        "airline_code": "PK", // PIA's IATA code
        "operating_flight_number": flightNumber,
        "operating_airline_code": "PK",
        "cabin_class": _getCabinClassName(segment.cabinCode),
        "sub_class": segment.cabinCode,
        "hand_baggage": "7kg", // Default value as per web
        "check_baggage": flight.baggageAllowance.weight > 0
            ? "${flight.baggageAllowance.weight} ${flight.baggageAllowance.unit}"
            : "${flight.baggageAllowance.pieces} piece(s)",
        "meal": segment.mealCode == 'M' ? 'Meal' : 'None',
        "layover": _getLayoverInfo(leg, legs),
        "duration": "${duration.inHours}h ${duration.inMinutes.remainder(60)}m",
        "type": piaController.isMultiCity.value ? "MultiCity" :  isReturn ? "Round" : "OneWay" ,
      });
    }
  }

  PIAFlightSegmentInfo _getFirstSegmentInfo(Map<String, dynamic> leg) {
    try {
      final flightSegment = leg['flightSegment'] ?? {};
      final bookingClass = flightSegment['bookingClassList'];

      if (bookingClass == null) {
        return PIAFlightSegmentInfo(
          bookingCode: '',
          cabinCode: 'Y',
          mealCode: 'N',
          seatsAvailable: '0',
          fareBasisCode: '',
        );
      }

      return PIAFlightSegmentInfo(
        bookingCode: _extractNestedValue(bookingClass, ['resBookDesigCode']) ?? '',
        cabinCode: _extractNestedValue(bookingClass, ['cabin']) ?? 'Y',
        mealCode: _extractNestedValue(flightSegment, ['flightNotes', 'note']) ?? 'N',
        seatsAvailable: _extractNestedValue(bookingClass, ['resBookDesigQuantity']) ?? '0',
        fareBasisCode: _extractNestedValue(bookingClass, ['resBookDesigCode']) ?? '',
      );
    } catch (e) {
      return PIAFlightSegmentInfo(
        bookingCode: '',
        cabinCode: 'Y',
        mealCode: 'N',
        seatsAvailable: '0',
        fareBasisCode: '',
      );
    }
  }

  String _getLayoverInfo(Map<String, dynamic> currentLeg, List<dynamic> allLegs) {
    try {
      // For multi-city, show connecting airports if any
      if (allLegs.length > 1) {
        final currentIndex = allLegs.indexOf(currentLeg);
        if (currentIndex < allLegs.length - 1) {
          final nextLeg = allLegs[currentIndex + 1];
          final nextDeparture = nextLeg['flightSegment']?['departureAirport']?['locationCode'];
          if (nextDeparture != null) {
            return "Connecting at $nextDeparture";
          }
        }
      }
      return "None";
    } catch (e) {
      return "None";
    }
  }

  String _getCabinClassName(String cabinCode) {
    switch (cabinCode.toUpperCase()) {
      case 'F':
        return 'First Class';
      case 'C':
        return 'Business Class';
      case 'J':
        return 'Premium Business';
      case 'W':
        return 'Premium Economy';
      case 'S':
        return 'Premium Economy';
      case 'Y':
        return 'Economy';
      default:
        return 'Economy';
    }
  }

  String _extractStringValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is Map<String, dynamic>) {
      if (value.containsKey('\$')) {
        return _extractStringValue(value['\$']);
      }
      return value['text']?.toString().trim() ?? '';
    }
    return value.toString().trim();
  }

  String? _extractNestedValue(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return null;

    dynamic current = data;
    for (final key in keys) {
      if (current is! Map<String, dynamic>) return null;

      if (current.containsKey('\$') && current['\$'] is Map) {
        current = current['\$'];
      }

      if (!current.containsKey(key)) {
        final nsKey = current.keys.firstWhere(
              (k) => k.endsWith(':$key') || k.endsWith('@$key'),
          orElse: () => key,
        );
        if (!current.containsKey(nsKey)) return null;
        current = current[nsKey];
      } else {
        current = current[key];
      }

      if (current is Map && current.containsKey('text')) {
        current = current['text'];
      }
    }

    return _extractStringValue(current);
  }

  // ************* PIA Flight Booking**********************************************


  // ************* PIA PNR Creation **********************************************

  Future<Map<String, dynamic>> createPIAPNR({
    required BookingFlightController bookingController,
    required PIAFlight flight,
    required PIAFlight? returnFlight,
  }) async {
    try {
      // Prepare booking segments
      final bookingSegments = <Map<String, dynamic>>[];

      // Process outbound flight
      _processFlightForPNR(flight, bookingSegments);

      // Process return flight if exists
      if (returnFlight != null) {
        _processFlightForPNR(returnFlight, bookingSegments);
      }

      // Prepare passengers data
      final adults = bookingController.adults.map((adult) {
        return {
          "title": adult.titleController.text,
          "first_name": adult.firstNameController.text,
          "last_name": adult.lastNameController.text,
          "dob": adult.dateOfBirthController.text,
          "gender": adult.genderController.text == "Male" ? "M" : "F",
          "passport": adult.passportController.text,
          "email": adult.emailController.text,
          "phone": adult.phoneController.text,
          "passport_expiry": adult.passportExpiryController.text,
          "nationality": adult.nationalityController.text,
          "type": "ADLT",
        };
      }).toList();

      final children = bookingController.children.map((child) {
        return {
          "title": child.titleController.text,
          "first_name": child.firstNameController.text,
          "last_name": child.lastNameController.text,
          "dob": child.dateOfBirthController.text,
          "gender": child.genderController.text == "Male" ? "M" : "F",
          "passport": child.passportController.text,
          "passport_expiry": child.passportExpiryController.text,
          "nationality": child.nationalityController.text,
          "type": "CHLD",
        };
      }).toList();

      final infants = bookingController.infants.map((infant) {
        return {
          "title": infant.titleController.text,
          "first_name": infant.firstNameController.text,
          "last_name": infant.lastNameController.text,
          "dob": infant.dateOfBirthController.text,
          "gender": infant.genderController.text == "Male" ? "M" : "F",
          "passport": infant.passportController.text,
          "passport_expiry": infant.passportExpiryController.text,
          "nationality": infant.nationalityController.text,
          "type": "INFT",
        };
      }).toList();

      // Prepare the XML request
      final request = '''
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:impl="http://impl.soap.ws.crane.hititcs.com/">
  <soapenv:Header/>
  <soapenv:Body>
    <impl:CreateBooking>
      <AirBookingRequest>
        <clientInformation>
          <clientIP>129.0.0.1</clientIP>
          <member>false</member>
          <password>NewOneRoof@121</password>
          <preferredCurrency>PKR</preferredCurrency>
          <preferredLanguage>PK</preferredLanguage>
          <userName>PSA2746487</userName>
        </clientInformation>
        <airItinerary>
          <adviceCodeSegmentExist>false</adviceCodeSegmentExist>
          <bookOriginDestinationOptions>
            ${_buildBookingSegments(bookingSegments)}
          </bookOriginDestinationOptions>
        </airItinerary>
        ${_buildPassengersXML(adults, children, infants)}
        ${_buildContactXML(bookingController)}
        <availabilityReferenceID>${flight.selectedFareOption?.rawData["internalID"]}</availabilityReferenceID>
        <infantWithSeatCount>${infants.length}</infantWithSeatCount>
        <requestPurpose>MODIFY_PERMANENTLY_AND_CALC</requestPurpose>
        <specialRequestDetails>
          ${_buildChildSSR(children, adults.length)}
          ${_buildInfantSSR(infants)}
        </specialRequestDetails>
      </AirBookingRequest>
    </impl:CreateBooking>
  </soapenv:Body>
</soapenv:Envelope>
''';

      // Print the request for debugging
      debugPrint('=== PIA PNR REQUEST ===');
      _printXmlPretty(request);

      // Make the API call
      final response = await _dio.post(
        'https://app-stage.crane.aero/craneota/CraneOTAService',
        data: request,
        options: Options(
          contentType: 'text/xml; charset=utf-8',
          headers: {
            'SOAPAction': 'http://impl.soap.ws.crane.hititcs.com/CreateBooking',
            'Content-Type': 'text/XML',
          },
          responseType: ResponseType.plain,
        ),
      );

      debugPrint('=== PIA PNR RESPONSE ===');
      _printXmlPretty(response.data.toString());

      // Convert XML to Map if needed
      return _convertXmlToJson(response.data.toString());
    } catch (e) {
      debugPrint('Error creating PIA PNR: $e');
      rethrow;
    }
  }

  void _processFlightForPNR(PIAFlight flight, List<Map<String, dynamic>> bookingSegments) {
    final segments = flight.legWithStops;
    for (var segment in segments) {
      final flightSegment = segment['flightSegment'] ?? segment;
      final bookingClass = segment['bookingClassList'];

      // Use the selected fare option from the flight
      final fareInfo = flight.selectedFareOption?.rawData ?? {};

      print("check 123:");
      print(bookingClass);


      bookingSegments.add({
        "flightSegment": flightSegment,
        "bookingClass": bookingClass,
        "fareInfo": fareInfo,
        "internalID": fareInfo['internalID'] ?? "N/A",
      });
    }
  }

  Map<String, dynamic> _getFareInfoForSegment(Map<String, dynamic> segment, PIAFlight flight) {
    try {
      // Try to find matching fare info from flight's pricing info
      final flightSegment = segment['flightSegment'] ?? segment;
      _extractStringValue(flightSegment['flightSegmentSequence']);

      for (var pricingInfo in flight.pricingInforArray) {
        final fareComponentList = pricingInfo['fareComponentList'] ?? [];
        if (fareComponentList is! List) continue;

        for (var fareComponent in fareComponentList) {
          final fareInfoList = fareComponent['fareInfoList'] ?? [];
          if (fareInfoList is! List) continue;

          for (var fareInfo in fareInfoList) {

            return fareInfo;
            // final infoSequence = _extractStringValue(fareInfo['flightSegmentSequence']);
            // if (infoSequence == segmentSequence) {
            //   return fareInfo;
            // }
          }
        }
      }

      // Fallback to first available fare info
      if (flight.pricingInforArray.isNotEmpty) {
        final firstPricing = flight.pricingInforArray.first;
        final fareComponentList = firstPricing['fareComponentList'] ?? [];
        if (fareComponentList is List && fareComponentList.isNotEmpty) {
          final firstComponent = fareComponentList.first;
          final fareInfoList = firstComponent['fareInfoList'] ?? [];
          if (fareInfoList is List && fareInfoList.isNotEmpty) {
            return fareInfoList.first;
          }
        }
      }

      return {};
    } catch (e) {
      debugPrint('Error getting fare info for segment: $e');
      return {};
    }
  }

  String _buildBookingSegments(List<Map<String, dynamic>> segments) {
    final buffer = StringBuffer();

    buffer.write('<bookOriginDestinationOptionList>');

    for (var segment in segments) {
      final flightSegment = segment['flightSegment'];
      final fareInfo = segment['fareInfo'];
      final bookingClassList = segment['bookingClass'];

      // Find the matching booking class from the selected fare option
      String? resBookDesigQuantity;
      if (bookingClassList is List) {
        print("AHmad A:");
        for (var bookingClass in bookingClassList) {
          print("AHmad B:");
          print(fareInfo['passengerFareInfoList']['fareInfoList']['resBookDesigCode'] );
          if (
              bookingClass['resBookDesigCode'] == fareInfo['passengerFareInfoList']['fareInfoList']['resBookDesigCode']) {
            print("AHmad C:");
            resBookDesigQuantity = _extractStringValue(bookingClass['resBookDesigQuantity']);
           print("Ahmad D:");
           print(resBookDesigQuantity);
            break;
          }
        }
      }

      buffer.write('''
<bookFlightSegmentList>
  <actionCode>NN</actionCode>
  <addOnSegment>false</addOnSegment>
<bookingClass>
    <cabin>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['cabin'])}</cabin>
    <resBookDesigCode>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['resBookDesigCode'])}</resBookDesigCode>
    <resBookDesigQuantity>${resBookDesigQuantity ?? ''}</resBookDesigQuantity>
</bookingClass>
<fareInfo>
    <cabin>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['cabin'])}</cabin>
    <cabinClassCode>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['cabinClassCode'])}</cabinClassCode>
    <fareBaggageAllowance>
        <allowanceType>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['fareBaggageAllowance']?['allowanceType'])}</allowanceType>
        <maxAllowedPieces>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['fareBaggageAllowance']?['maxAllowedPieces'])}</maxAllowedPieces>
        <maxAllowedWeight>
            <unitOfMeasureCode>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['fareBaggageAllowance']?['maxAllowedWeight']?['unitOfMeasureCode'])}</unitOfMeasureCode>
            <weight>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['fareBaggageAllowance']?['maxAllowedWeight']?['weight'])}</weight>
        </maxAllowedWeight>
    </fareBaggageAllowance>
    <fareGroupName>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['fareGroupName'])}</fareGroupName>
    <fareReferenceCode>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['fareReferenceCode'])}</fareReferenceCode>
    <fareReferenceID>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['fareReferenceID'])}</fareReferenceID>
    <fareReferenceName>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['fareReferenceName'])}</fareReferenceName>
    <flightSegmentSequence>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['flightSegmentSequence'])}</flightSegmentSequence>
    <notValidAfter>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['notValidAfter'])}</notValidAfter>
    <notValidBefore>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['notValidBefore'])}</notValidBefore>
    <resBookDesigCode>${_extractStringValue(fareInfo['passengerFareInfoList']['fareInfoList']?['resBookDesigCode'])}</resBookDesigCode>
</fareInfo>
  <flightSegment>
    <airline>
      <code>${_extractStringValue(flightSegment['airline']?['code'])}</code>
      <companyFullName>${_extractStringValue(flightSegment['airline']?['companyFullName'])}</companyFullName>
      <companyShortName>${_extractStringValue(flightSegment['airline']?['companyShortName'])}</companyShortName>
    </airline>
    <arrivalAirport>
      <cityInfo>
        <city>
          <locationCode>${_extractStringValue(flightSegment['arrivalAirport']?['cityInfo']?['city']?['locationCode'])}</locationCode>
          <locationName>${_extractStringValue(flightSegment['arrivalAirport']?['cityInfo']?['city']?['locationName'])}</locationName>
          <locationNameLanguage>${_extractStringValue(flightSegment['arrivalAirport']?['cityInfo']?['city']?['locationNameLanguage'])}</locationNameLanguage>
        </city>
        <country>
          <locationCode>${_extractStringValue(flightSegment['arrivalAirport']?['cityInfo']?['country']?['locationCode'])}</locationCode>
          <locationName>${_extractStringValue(flightSegment['arrivalAirport']?['cityInfo']?['country']?['locationName'])}</locationName>
          <locationNameLanguage>${_extractStringValue(flightSegment['arrivalAirport']?['cityInfo']?['country']?['locationNameLanguage'])}</locationNameLanguage>
          <currency>
            <code>${_extractStringValue(flightSegment['arrivalAirport']?['cityInfo']?['country']?['currency']?['code'])}</code>
          </currency>
        </country>
      </cityInfo>
      <codeContext>${_extractStringValue(flightSegment['arrivalAirport']?['codeContext'])}</codeContext>
      <language>${_extractStringValue(flightSegment['arrivalAirport']?['language'])}</language>
      <locationCode>${_extractStringValue(flightSegment['arrivalAirport']?['locationCode'])}</locationCode>
      <locationName>${_extractStringValue(flightSegment['arrivalAirport']?['locationName'])}</locationName>
    </arrivalAirport>
    <arrivalDateTime>${_extractStringValue(flightSegment['arrivalDateTime'])}</arrivalDateTime>
    <arrivalDateTimeUTC>${_extractStringValue(flightSegment['arrivalDateTimeUTC'])}</arrivalDateTimeUTC>
    <departureAirport>
      <cityInfo>
        <city>
          <locationCode>${_extractStringValue(flightSegment['departureAirport']?['cityInfo']?['city']?['locationCode'])}</locationCode>
          <locationName>${_extractStringValue(flightSegment['departureAirport']?['cityInfo']?['city']?['locationName'])}</locationName>
          <locationNameLanguage>${_extractStringValue(flightSegment['departureAirport']?['cityInfo']?['city']?['locationNameLanguage'])}</locationNameLanguage>
        </city>
        <country>
          <locationCode>${_extractStringValue(flightSegment['departureAirport']?['cityInfo']?['country']?['locationCode'])}</locationCode>
          <locationName>${_extractStringValue(flightSegment['departureAirport']?['cityInfo']?['country']?['locationName'])}</locationName>
          <locationNameLanguage>${_extractStringValue(flightSegment['departureAirport']?['cityInfo']?['country']?['locationNameLanguage'])}</locationNameLanguage>
          <currency>
            <code>${_extractStringValue(flightSegment['departureAirport']?['cityInfo']?['country']?['currency']?['code'])}</code>
          </currency>
        </country>
      </cityInfo>
      <codeContext>${_extractStringValue(flightSegment['departureAirport']?['codeContext'])}</codeContext>
      <language>${_extractStringValue(flightSegment['departureAirport']?['language'])}</language>
      <locationCode>${_extractStringValue(flightSegment['departureAirport']?['locationCode'])}</locationCode>
      <locationName>${_extractStringValue(flightSegment['departureAirport']?['locationName'])}</locationName>
    </departureAirport>
    <departureDateTime>${_extractStringValue(flightSegment['departureDateTime'])}</departureDateTime>
    <departureDateTimeUTC>${_extractStringValue(flightSegment['departureDateTimeUTC'])}</departureDateTimeUTC>
    <flightNumber>${_extractStringValue(flightSegment['flightNumber'])}</flightNumber>
    <ondControlled>${_extractStringValue(flightSegment['ondControlled'])}</ondControlled>
    <sector>${_extractStringValue(flightSegment['sector'])}</sector>
    <codeshare>${_extractStringValue(flightSegment['codeshare'])}</codeshare>
    <distance>${_extractStringValue(flightSegment['distance'] ?? '0')}</distance>
    <equipment>
      <airEquipType>${_extractStringValue(flightSegment['equipment']?['airEquipType'])}</airEquipType>
      <airEquipTypeModel>${_extractStringValue(flightSegment['equipment']?['airEquipTypeModel'])}</airEquipTypeModel>
      <changeofGauge>${_extractStringValue(flightSegment['equipment']?['changeofGauge'])}</changeofGauge>
    </equipment>
    <flownMileageQty>${_extractStringValue(flightSegment['flownMileageQty'])}</flownMileageQty>
    <iatciFlight>${_extractStringValue(flightSegment['iatciFlight'])}</iatciFlight>
    <journeyDuration>${_extractStringValue(flightSegment['journeyDuration'])}</journeyDuration>
    <onTimeRate>${_extractStringValue(flightSegment['onTimeRate'] ?? '0')}</onTimeRate>
    <secureFlightDataRequired>${_extractStringValue(flightSegment['secureFlightDataRequired'])}</secureFlightDataRequired>
    <stopQuantity>${_extractStringValue(flightSegment['stopQuantity'] ?? '0')}</stopQuantity>
  </flightSegment>
  <involuntaryPermissionGiven>false</involuntaryPermissionGiven>
  <sequenceNumber>0</sequenceNumber>
</bookFlightSegmentList>
''');
    }

    buffer.write('</bookOriginDestinationOptionList>');
    return buffer.toString();
  }
  String _buildPassengersXML(List<Map<String, dynamic>> adults, List<Map<String, dynamic>> children, List<Map<String, dynamic>> infants) {
    final buffer = StringBuffer();
    // ignore: unused_local_variable
    int sequence = 0;

    // Process adults
    for (var adult in adults) {
      sequence++;
      buffer.write('''
<airTravelerList>
  <accompaniedByInfant>false</accompaniedByInfant>
  <birthDate>${adult['dob']}T00:00:00</birthDate>
  <contactPerson>
    <email>
      <email>${adult['email'] ?? ''}</email>
      <markedForSendingRezInfo>false</markedForSendingRezInfo>
      <preferred>false</preferred>
      <shareMarketInd>false</shareMarketInd>
    </email>
    <personName>
      <givenName>${adult['first_name']}</givenName>
      <shareMarketInd>false</shareMarketInd>
      <surname>${adult['last_name']}</surname>
    </personName>
    <phoneNumber>
      <markedForSendingRezInfo>true</markedForSendingRezInfo>
      <preferred>false</preferred>
      <shareMarketInd>false</shareMarketInd>
      <subscriberNumber>${adult['phone'] ?? ''}</subscriberNumber>
    </phoneNumber>
    <shareContactInfo>false</shareContactInfo>
    <shareMarketInd>false</shareMarketInd>
    <useForInvoicing>false</useForInvoicing>
  </contactPerson>
  <gender>${adult['gender']}</gender>
  <hasStrecher>false</hasStrecher>
  <parentSequence>0</parentSequence>
  <passengerTypeCode>${adult['type']}</passengerTypeCode>
  <personName>
    <givenName>${adult['first_name']}</givenName>
    <nameTitle>${adult['title']}</nameTitle>
    <shareMarketInd>false</shareMarketInd>
    <surname>${adult['last_name']}</surname>
  </personName>
  <requestedSeatCount>1</requestedSeatCount>
  <shareMarketInd>false</shareMarketInd>
  <unaccompaniedMinor>false</unaccompaniedMinor>
  <documentInfoList>
    <birthDate>${adult['dob']}</birthDate>
    <docExpireDate>${adult['passport_expiry']}</docExpireDate>
    <docHolderFormattedName>
      <givenName>${adult['first_name']}</givenName>
      <shareMarketInd>false</shareMarketInd>
      <surname>${adult['last_name']}</surname>
    </docHolderFormattedName>
    <docHolderNationality>${adult['nationality']}</docHolderNationality>
    <docID>${adult['passport']}</docID>
    <docType>PASSPORT</docType>
    <gender>${adult['gender']}</gender>
  </documentInfoList>
</airTravelerList>
''');
    }

    // Process children
    for (var child in children) {
      sequence++;
      buffer.write('''
<airTravelerList>
  <accompaniedByInfant>false</accompaniedByInfant>
  <birthDate>${child['dob']}T00:00:00</birthDate>
  <contactPerson>
    <email>
      <email>${child['email'] ?? ''}</email>
      <markedForSendingRezInfo>false</markedForSendingRezInfo>
      <preferred>false</preferred>
      <shareMarketInd>false</shareMarketInd>
    </email>
    <personName>
      <givenName>${child['first_name']}</givenName>
      <shareMarketInd>false</shareMarketInd>
      <surname>${child['last_name']}</surname>
    </personName>
    <phoneNumber>
      <markedForSendingRezInfo>true</markedForSendingRezInfo>
      <preferred>false</preferred>
      <shareMarketInd>false</shareMarketInd>
      <subscriberNumber>${child['phone'] ?? ''}</subscriberNumber>
    </phoneNumber>
    <shareContactInfo>false</shareContactInfo>
    <shareMarketInd>false</shareMarketInd>
    <useForInvoicing>false</useForInvoicing>
  </contactPerson>
  <gender>${child['gender']}</gender>
  <hasStrecher>false</hasStrecher>
  <parentSequence>0</parentSequence>
  <passengerTypeCode>${child['type']}</passengerTypeCode>
  <personName>
    <givenName>${child['first_name']}</givenName>
    <nameTitle>${child['title']}</nameTitle>
    <shareMarketInd>false</shareMarketInd>
    <surname>${child['last_name']}</surname>
  </personName>
  <requestedSeatCount>1</requestedSeatCount>
  <shareMarketInd>false</shareMarketInd>
  <unaccompaniedMinor>false</unaccompaniedMinor>
  <documentInfoList>
    <birthDate>${child['dob']}</birthDate>
    <docExpireDate>${child['passport_expiry']}</docExpireDate>
    <docHolderFormattedName>
      <givenName>${child['first_name']}</givenName>
      <shareMarketInd>false</shareMarketInd>
      <surname>${child['last_name']}</surname>
    </docHolderFormattedName>
    <docHolderNationality>${child['nationality']}</docHolderNationality>
    <docID>${child['passport']}</docID>
    <docType>PASSPORT</docType>
    <gender>${child['gender']}</gender>
  </documentInfoList>
</airTravelerList>
''');
    }

    // Process infants
    for (var infant in infants) {
      sequence++;
      buffer.write('''
<airTravelerList>
  <accompaniedByInfant>false</accompaniedByInfant>
  <birthDate>${infant['dob']}T00:00:00</birthDate>
  <contactPerson>
    <email>
      <email>${infant['email'] ?? ''}</email>
      <markedForSendingRezInfo>false</markedForSendingRezInfo>
      <preferred>false</preferred>
      <shareMarketInd>false</shareMarketInd>
    </email>
    <personName>
      <givenName>${infant['first_name']}</givenName>
      <shareMarketInd>false</shareMarketInd>
      <surname>${infant['last_name']}</surname>
    </personName>
    <phoneNumber>
      <markedForSendingRezInfo>true</markedForSendingRezInfo>
      <preferred>false</preferred>
      <shareMarketInd>false</shareMarketInd>
      <subscriberNumber>${infant['phone'] ?? ''}</subscriberNumber>
    </phoneNumber>
    <shareContactInfo>false</shareContactInfo>
    <shareMarketInd>false</shareMarketInd>
    <useForInvoicing>false</useForInvoicing>
  </contactPerson>
  <gender>${infant['gender']}</gender>
  <hasStrecher>false</hasStrecher>
  <parentSequence>0</parentSequence>
  <passengerTypeCode>${infant['type']}</passengerTypeCode>
  <personName>
    <givenName>${infant['first_name']}</givenName>
    <nameTitle>${infant['title']}</nameTitle>
    <shareMarketInd>false</shareMarketInd>
    <surname>${infant['last_name']}</surname>
  </personName>
  <requestedSeatCount>1</requestedSeatCount>
  <shareMarketInd>false</shareMarketInd>
  <unaccompaniedMinor>false</unaccompaniedMinor>
  <documentInfoList>
    <birthDate>${infant['dob']}</birthDate>
    <docExpireDate>${infant['passport_expiry']}</docExpireDate>
    <docHolderFormattedName>
      <givenName>${infant['first_name']}</givenName>
      <shareMarketInd>false</shareMarketInd>
      <surname>${infant['last_name']}</surname>
    </docHolderFormattedName>
    <docHolderNationality>${infant['nationality']}</docHolderNationality>
    <docID>${infant['passport']}</docID>
    <docType>PASSPORT</docType>
    <gender>${infant['gender']}</gender>
  </documentInfoList>
</airTravelerList>
''');
    }

    return buffer.toString();
  }

  String _buildContactXML(BookingFlightController bookingController) {
    return '''
<contactInfoList>
  <email>
    <email>${bookingController.emailController.text}</email>
    <markedForSendingRezInfo>false</markedForSendingRezInfo>
    <preferred>false</preferred>
    <shareMarketInd>false</shareMarketInd>
  </email>
  <personName>
    <givenName>${bookingController.firstNameController.text}</givenName>
    <shareMarketInd>false</shareMarketInd>
    <surname>${bookingController.lastNameController.text}</surname>
  </personName>
  <phoneNumber>
    <markedForSendingRezInfo>true</markedForSendingRezInfo>
    <preferred>false</preferred>
    <shareMarketInd>false</shareMarketInd>
    <subscriberNumber>${bookingController.phoneController.text}</subscriberNumber>
  </phoneNumber>
  <shareContactInfo>false</shareContactInfo>
  <shareMarketInd>false</shareMarketInd>
  <useForInvoicing>false</useForInvoicing>
</contactInfoList>
''';
  }

  String _buildChildSSR(List<Map<String, dynamic>> children, int adultLenght) {
    if (children.isEmpty) return '';

    final buffer = StringBuffer();
    int sequence = adultLenght; // Start after adults

    for (var child in children) {
      sequence++;
      final dob = DateFormat('dMMMy').format(DateTime.parse(child['dob']));
      buffer.write('''
<specialServiceRequestList>
  <airTravelerSequence>$sequence</airTravelerSequence>
  <flightSegmentSequence>1</flightSegmentSequence>
  <SSR>
    <allowedQuantityPerPassenger/>
    <bundleRelatedSsr/>
    <code>CHLD</code>
    <exchangeable/>
    <explanation>$dob</explanation>
    <extraBaggage/>
    <free/>
    <iciAllowed/>
    <refundable/>
    <showOnItinerary/>
    <unitOfMeasureExist/>
  </SSR>
  <serviceQuantity>1</serviceQuantity>
  <status>NN</status>
  <ticketed/>
</specialServiceRequestList>
''');
    }

    return buffer.toString();
  }

  String _buildInfantSSR(List<Map<String, dynamic>> infants) {
    if (infants.isEmpty) return '';

    final buffer = StringBuffer();
    int sequence = 0; // Infants are associated with adults

    for (var infant in infants) {
      sequence++;
      final dob = DateFormat('dMMMy').format(DateTime.parse(infant['dob']));
      buffer.write('''
<specialServiceRequestList>
  <airTravelerSequence>$sequence</airTravelerSequence>
  <flightSegmentSequence>1</flightSegmentSequence>
  <SSR>
    <allowedQuantityPerPassenger/>
    <bundleRelatedSsr/>
    <code>INFT</code>
    <exchangeable/>
    <explanation>${infant['last_name']}/${infant['first_name']} $dob</explanation>
    <extraBaggage/>
    <free/>
    <iciAllowed/>
    <refundable/>
    <showOnItinerary/>
    <unitOfMeasureExist/>
  </SSR>
  <serviceQuantity>1</serviceQuantity>
  <status>NN</status>
  <ticketed/>
  <documentInfoList>
    <birthDate>${infant['dob']}</birthDate>
    <docExpireDate>${infant['passport_expiry']}</docExpireDate>
    <docHolderFormattedName>
      <givenName>${infant['first_name']}</givenName>
      <shareMarketInd>false</shareMarketInd>
      <surname>${infant['last_name']}</surname>
    </docHolderFormattedName>
    <docHolderNationality>${infant['nationality']}</docHolderNationality>
    <docID>${infant['passport']}</docID>
    <docType>PASSPORT</docType>
    <gender>${infant['gender']}</gender>
  </documentInfoList>
</specialServiceRequestList>
''');
    }

    return buffer.toString();
  }

  String _getInternalIds(List<Map<String, dynamic>> segments) {
    final ids = segments.map((s) => s['internalID']).toSet().toList();

    print("ahmad");
    print(ids);
    return ids.join(',');
  }

  // ************* PIA PNR Creation **********************************************

  Map<String, dynamic> _convertXmlToJson(String xmlString) {
    try {
      final cleanedXml = xmlString.trim();

      // For debugging - print the parsed XML structure
      // debugPrint('Parsed XML structure: ${document.toXmlString(pretty: true)}');

      final transformer = Xml2Json();
      transformer.parse(cleanedXml);

      // Use Parker conversion which might be simpler for this structure
      final jsonString = transformer.toParker();
      final jsonResult = jsonDecode(jsonString) as Map<String, dynamic>;

      // // Debug print the converted JSON
      // debugPrint('Converted JSON: $jsonResult');

      return jsonResult;
    } catch (e, stackTrace) {
      debugPrint('Error converting XML to JSON: $e');
      debugPrint('Stack trace: $stackTrace');
      return {'error': 'Failed to parse XML response'};
    }
  }

  void _parseXmlElement(xml.XmlElement element, Map<String, dynamic> jsonMap) {
    for (final child in element.children) {
      if (child is xml.XmlElement) {
        if (child.children.length == 1 && child.children.first is xml.XmlText) {
          jsonMap[child.name.local] = child.text;
        } else {
          final childMap = <String, dynamic>{};
          _parseXmlElement(child, childMap);
          jsonMap[child.name.local] = childMap;
        }
      }
    }
  }
  void printJsonPretty(dynamic jsonData) {
    const int chunkSize = 1000;
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    for (int i = 0; i < jsonString.length; i += chunkSize) {
    }
  }
  void _printXmlPretty(String xmlString) {
    try {
      final document = xml.XmlDocument.parse(xmlString);
      final prettyXml = document.toXmlString(pretty: true, indent: '  ');
      const chunkSize = 800;
      for (var i = 0; i < prettyXml.length; i += chunkSize) {
        debugPrint(prettyXml.substring(
          i,
          i + chunkSize < prettyXml.length ? i + chunkSize : prettyXml.length,
        ));
      }
    } catch (e) {
      debugPrint('Could not pretty print XML: $e');
      debugPrint(xmlString);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic> errors;

  ApiException({required this.message, this.statusCode, required this.errors});

  @override
  String toString() => message;
}