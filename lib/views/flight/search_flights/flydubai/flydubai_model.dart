// models/flydubai_flight_model.dart

// ignore_for_file: empty_catches

import 'package:flutter/foundation.dart';

import '../sabre/sabre_flight_models.dart';

class FlydubaiResponse {
  final bool success;
  final List<FlydubaiFlightSegment> flightSegments;
  final String currency;
  final String searchStatus;
  final String? errorMessage;

  FlydubaiResponse({
    required this.success,
    required this.flightSegments,
    required this.currency,
    required this.searchStatus,
    this.errorMessage,
  });

  factory FlydubaiResponse.fromJson(Map<String, dynamic> json) {
    try {
      final response = json['RetrieveFareQuoteDateRangeResponse'];
      if (response == null) {
        return FlydubaiResponse(
          success: false,
          flightSegments: [],
          currency: 'PKR',
          searchStatus: 'Failed',
          errorMessage: 'Invalid response format',
        );
      }

      final result = response['RetrieveFareQuoteDateRangeResult'];
      if (result == null) {
        return FlydubaiResponse(
          success: false,
          flightSegments: [],
          currency: 'PKR',
          searchStatus: 'Failed',
          errorMessage: 'No result data found',
        );
      }

      // Check for exceptions first
      final exceptions = result['Exceptions']?['ExceptionInformation.Exception'];
      String status = 'Success';
      if (exceptions is List && exceptions.isNotEmpty) {
        final firstException = exceptions.first;
        status = firstException['ExceptionDescription']?.toString() ?? 'Success';
        if (firstException['ExceptionLevel']?.toString() != 'SUCCESS') {
          return FlydubaiResponse(
            success: false,
            flightSegments: [],
            currency: 'PKR',
            searchStatus: 'Failed',
            errorMessage: status,
          );
        }
      }

      List<FlydubaiFlightSegment> segments = [];

      // Parse from FlightSegments in the API response
      final flightSegmentsData = result['FlightSegments']?['FlightSegment'];
      if (flightSegmentsData != null) {
        if (flightSegmentsData is List) {
          for (var segmentData in flightSegmentsData) {
            try {
              final segment = FlydubaiFlightSegment.fromJson(segmentData, result);
              segments.add(segment);
            } catch (e) {
              if (kDebugMode) {
                print('Error parsing segment: $e');
              }
            }
          }
        } else if (flightSegmentsData is Map) {
          try {
            final segment = FlydubaiFlightSegment.fromJson(
                Map<String, dynamic>.from(flightSegmentsData), result);
            segments.add(segment);
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing single segment: $e');
            }
          }
        }
      }

      return FlydubaiResponse(
        success: segments.isNotEmpty,
        flightSegments: segments,
        currency: result['CurrencyOfFareQuote']?.toString() ?? 'PKR',
        searchStatus: status,
        errorMessage: segments.isEmpty ? 'No flights found' : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing Flydubai response: $e');
      }
      return FlydubaiResponse(
        success: false,
        flightSegments: [],
        currency: 'PKR',
        searchStatus: 'Failed',
        errorMessage: 'Parsing error: $e',
      );
    }
  }
}

class FlydubaiFlightSegment {
  final int lfid;
  final String origin;
  final String destination;
  final String flightNumber;
  final DateTime departureDateTime;
  final DateTime arrivalDateTime;
  final List<FlydubaiFlightFare> fareTypes;
  final String aircraft;
  final String cabinClass;
  final Map<String, dynamic> legDetails;

  FlydubaiFlightSegment({
    required this.lfid,
    required this.origin,
    required this.destination,
    required this.flightNumber,
    required this.departureDateTime,
    required this.arrivalDateTime,
    required this.fareTypes,
    required this.aircraft,
    required this.cabinClass,
    required this.legDetails,
  });

  factory FlydubaiFlightSegment.fromJson(
      Map<String, dynamic> json,
      Map<String, dynamic> fullResponse,
      ) {
    try {
      List<FlydubaiFlightFare> fares = [];

      // Parse fare types from the segment data
      final fareTypesData = json['FareTypes']?['FareType'];
      if (fareTypesData is List) {
        for (var fareType in fareTypesData) {
          final fareInfos = fareType['FareInfos']?['FareInfo'];
          if (fareInfos is List) {
            for (var fareInfo in fareInfos) {
              try {
                fares.add(FlydubaiFlightFare.fromJson(fareInfo, fareType));
              } catch (e) {
                if (kDebugMode) {
                  print('Error parsing fare: $e');
                }
              }
            }
          } else if (fareInfos is Map) {
            try {
              fares.add(FlydubaiFlightFare.fromJson(
                  Map<String, dynamic>.from(fareInfos), fareType));
            } catch (e) {
              if (kDebugMode) {
                print('Error parsing single fare: $e');
              }
            }
          }
        }
      }

      // Extract flight details from SegmentDetails instead of LegDetails
      String origin = '';
      String destination = '';
      String flightNumber = '';
      DateTime departureDateTime = DateTime.now();
      DateTime arrivalDateTime = DateTime.now().add(Duration(hours: 3));

      // Try to find matching segment in SegmentDetails
      final segmentDetails = fullResponse['SegmentDetails']?['SegmentDetail'];
      final lfid = (json['LFID'] as num?)?.toInt();

      if (segmentDetails is List) {
        for (var segment in segmentDetails) {
          if ((segment['LFID'] as num?)?.toInt() == lfid) {
            origin = segment['Origin']?.toString() ?? '';
            destination = segment['Destination']?.toString() ?? '';
            flightNumber = segment['FlightNum']?.toString() ?? '';

            // Parse dates
            if (segment['DepartureDate'] != null) {
              departureDateTime = DateTime.parse(segment['DepartureDate'].toString());
            }
            if (segment['ArrivalDate'] != null) {
              arrivalDateTime = DateTime.parse(segment['ArrivalDate'].toString());
            }
            break;
          }
        }
      }

      // Fallback to json data if segment details not found
      if (origin.isEmpty) {
        origin = json['Origin']?.toString() ?? 'N/A';
      }
      if (destination.isEmpty) {
        destination = json['Destination']?.toString() ?? 'N/A';
      }
      if (flightNumber.isEmpty) {
        flightNumber = json['FlightNum']?.toString() ?? 'N/A';
      }

      return FlydubaiFlightSegment(
        lfid: lfid ?? 0,
        origin: origin,
        destination: destination,
        flightNumber: flightNumber,
        departureDateTime: departureDateTime,
        arrivalDateTime: arrivalDateTime,
        fareTypes: fares,
        aircraft: json['AircraftType']?.toString() ?? 'B737',
        cabinClass: 'Y',
        legDetails: {}, // Keep empty as we're using SegmentDetails
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing flight segment: $e');
      }
      rethrow;
    }
  }}

class FlydubaiFlightFare {
  final String fareTypeId;
  final String fareTypeName;
  final String paxId;
  final int fareId;
  final int solnId; // Add solution ID for combinability logic
  final double displayFareAmount;
  final double baseFareAmountIncludingTax;
  final int seatsAvailable;
  final int passengerTypeId;
  final String currency;
  final String bookingCode;
  final String cabin;

  FlydubaiFlightFare({
    required this.fareTypeId,
    required this.fareTypeName,
    required this.paxId,
    required this.fareId,
    required this.solnId,
    required this.displayFareAmount,
    required this.baseFareAmountIncludingTax,
    required this.seatsAvailable,
    required this.passengerTypeId,
    required this.currency,
    required this.bookingCode,
    required this.cabin,
  });

  factory FlydubaiFlightFare.fromJson(Map<String, dynamic> fareInfo, Map<String, dynamic> fareType) {
    try {
      final paxData = fareInfo['Pax'];
      Map<String, dynamic> pax = {};

      if (paxData is List && paxData.isNotEmpty) {
        pax = paxData.first;
      } else if (paxData is Map) {
        pax = Map<String, dynamic>.from(paxData as Map);
      }

      // Get booking codes
      String bookingCode = 'Y';
      String cabin = 'ECONOMY';
      final bookingCodes = pax['BookingCodes']?['Bookingcode'];
      if (bookingCodes is List && bookingCodes.isNotEmpty) {
        final firstBooking = bookingCodes.first;
        bookingCode = firstBooking['RBD']?.toString() ?? 'Y';
        cabin = firstBooking['Cabin']?.toString() ?? 'ECONOMY';
      } else if (bookingCodes is Map) {
        bookingCode = bookingCodes['RBD']?.toString() ?? 'Y';
        cabin = bookingCodes['Cabin']?.toString() ?? 'ECONOMY';
      }

      return FlydubaiFlightFare(
        fareTypeId: fareType['FareTypeID']?.toString() ?? '',
        fareTypeName: fareType['FareTypeName']?.toString() ?? 'Economy',
        paxId: pax['ID']?.toString() ?? '',
        fareId: (pax['FareID'] as num?)?.toInt() ?? 0,
        solnId: (fareType['SolnId'] as num?)?.toInt() ?? 0, // Add solution ID
        displayFareAmount: (pax['BaseFareAmtInclTax'] as num?)?.toDouble() ??
            (pax['FareAmtInclTax'] as num?)?.toDouble() ?? 0.0,
        baseFareAmountIncludingTax: (pax['BaseFareAmtInclTax'] as num?)?.toDouble() ??
            (pax['FareAmtInclTax'] as num?)?.toDouble() ?? 0.0,
        seatsAvailable: (pax['SeatsAvailable'] as num?)?.toInt() ?? 0,
        passengerTypeId: (pax['PTCID'] as num?)?.toInt() ?? 1,
        currency: 'PKR',
        bookingCode: bookingCode,
        cabin: cabin,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing flight fare: $e');
      }
      rethrow;
    }
  }
}

class FlydubaiFlight {
  final String id;
  final double price;
  final double basePrice;
  final double taxAmount;
  final double feeAmount;
  final String currency;
  final bool isRefundable;
  final BaggageAllowance baggageAllowance;
  final List<Map<String, dynamic>> legSchedules;
  final List<Map<String, dynamic>> stopSchedules;
  final List<FlightSegmentInfo> segmentInfo;
  final String airlineCode;
  final String airlineName;
  final String airlineImg;
  final String rph;
  final List<FlydubaiFlightFare>? fareOptions;
  final Map<String, dynamic> rawData;
  final FlydubaiFlightSegment flightSegment;
  final List<Map<String, dynamic>> changeFeeDetails;
  final List<Map<String, dynamic>> refundFeeDetails;
  // Add stop information
  final int stops;
  final bool isNonStop;
  final List<String> stopCities;

  FlydubaiFlight({
    required this.id,
    required this.price,
    required this.basePrice,
    required this.taxAmount,
    required this.feeAmount,
    required this.currency,
    required this.isRefundable,
    required this.baggageAllowance,
    required this.legSchedules,
    required this.stopSchedules,
    required this.segmentInfo,
    required this.airlineCode,
    required this.airlineName,
    required this.airlineImg,
    required this.rph,
    required this.flightSegment,
    required this.changeFeeDetails,
    required this.refundFeeDetails,
    required this.stops,
    required this.isNonStop,
    required this.stopCities,
    this.fareOptions,
    required this.rawData,

  });

  factory FlydubaiFlight.fromFlightSegment(
      FlydubaiFlightSegment segment,
      Map<String, AirlineInfo> airlineMap,
      Map<String, dynamic> rawData, {
        String? expectedOrigin,
        String? expectedDestination,
      }) {
    try {
      // Get the lowest price fare
      final lowestFare = segment.fareTypes.isNotEmpty
          ? segment.fareTypes.reduce((a, b) => a.baseFareAmountIncludingTax < b.baseFareAmountIncludingTax ? a : b)
          : null;

      if (lowestFare == null) {
        throw Exception('No fare options available');
      }

      // Get airline info
      final airlineInfo =
      AirlineInfo('FlyDubai', 'https://agent1.pk/images/airline-logo/flydubai.png');

      // Generate unique ID
      final flightId = '${segment.flightNumber}-${segment.lfid}-${DateTime.now().millisecondsSinceEpoch}';

      // Force correct origin/destination if provided
      if (expectedOrigin != null && expectedDestination != null) {
        segment = FlydubaiFlightSegment(
          lfid: segment.lfid,
          origin: expectedOrigin,
          destination: expectedDestination,
          flightNumber: segment.flightNumber,
          departureDateTime: segment.departureDateTime,
          arrivalDateTime: segment.arrivalDateTime,
          fareTypes: segment.fareTypes,
          aircraft: segment.aircraft,
          cabinClass: segment.cabinClass,
          legDetails: segment.legDetails,
        );
      }

      // Create leg schedules with corrected origin/destination
      final legSchedules = _createLegSchedules(segment, airlineInfo);

      // Create stop schedules
      final stopSchedules = _createStopSchedules(segment);

      // Create segment info
      final segmentInfo = _createSegmentInfo(segment);

      // Create baggage allowance based on fare type
      final baggageAllowance = _createBaggageAllowance(lowestFare.fareTypeName);

      // Calculate pricing breakdown
      final totalPrice = lowestFare.baseFareAmountIncludingTax;
      final taxAmount = totalPrice * 0.25; // Approximate 25% for taxes and fees
      final basePrice = totalPrice - taxAmount;


      // Calculate stops from segment details
      final segmentDetails = rawData['RetrieveFareQuoteDateRangeResponse']?
      ['RetrieveFareQuoteDateRangeResult']?['SegmentDetails']?['SegmentDetail'];

      int stops = 0;
      List<String> stopCities = [];

      // Find the matching segment detail by LFID
      if (segmentDetails is List) {
        for (var segmentDetail in segmentDetails) {
          if ((segmentDetail['LFID'] as num?)?.toInt() == segment.lfid) {
            stops = (segmentDetail['Stops'] as num?)?.toInt() ?? 0;

            // Extract stop cities from the flight number (e.g., "360/807" means stop in DXB)
            if (stops > 0) {
              final flightNumbers = segmentDetail['FlightNum']?.toString().split('/') ?? [];
              if (flightNumbers.length > 1) {
                // For LHE-DXB-JED, the stop city would be DXB
                // You might need additional logic to map airport codes to city names
                stopCities = ['Dubai']; // Simplified - you'll need proper mapping
              }
            }
            break;
          }
        }
      }


      return FlydubaiFlight(
        id: flightId,
        price: totalPrice,
        basePrice: basePrice,
        taxAmount: taxAmount,
        feeAmount: 0,
        currency: lowestFare.currency,
        isRefundable: _determineRefundable(lowestFare.fareTypeName),
        baggageAllowance: baggageAllowance,
        legSchedules: legSchedules,
        stopSchedules: stopSchedules,
        segmentInfo: segmentInfo,
        airlineCode: 'FZ',
        airlineName: airlineInfo.name,
        airlineImg: airlineInfo.logoPath,
        rph: segment.lfid.toString(),
        flightSegment: segment,
        stops: stops,
        isNonStop: stops == 0,
        stopCities: stopCities,
        fareOptions: segment.fareTypes,
        rawData: rawData,
        changeFeeDetails: _getChangeFees(lowestFare.fareTypeName),
        refundFeeDetails: _getRefundFees(lowestFare.fareTypeName),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating FlydubaiFlight: $e');
      }
      rethrow;
    }
  }static List<Map<String, dynamic>> _createLegSchedules(
      FlydubaiFlightSegment segment,
      AirlineInfo airlineInfo,
      ) {
    final flightTime = segment.arrivalDateTime.difference(segment.departureDateTime).inMinutes;

    // Get origin and destination with multiple fallbacks
    String origin = segment.origin;
    String destination = segment.destination;

    // If segment origin/destination is empty or N/A, try legDetails
    if (origin.isEmpty || origin == 'N/A') {
      origin = segment.legDetails['Origin']?.toString() ?? 'DXB'; // Default fallback
    }
    if (destination.isEmpty || destination == 'N/A') {
      destination = segment.legDetails['Destination']?.toString() ?? 'LHE'; // Default fallback
    }

    return [
      {
        'airlineCode': 'FZ',
        'airlineName': airlineInfo.name,
        'airlineImg': airlineInfo.logoPath,
        'departure': {
          'airport': origin, // Use the determined origin
          'city': _getCityName(origin),
          'terminal': segment.legDetails['FromTerminal']?.toString() ?? _getTerminal(origin),
          'time': segment.departureDateTime.toIso8601String(),
          'dateTime': segment.departureDateTime.toIso8601String(),
        },
        'arrival': {
          'airport': destination, // Use the determined destination
          'city': _getCityName(destination),
          'terminal': segment.legDetails['ToTerminal']?.toString() ?? _getTerminal(destination),
          'time': segment.arrivalDateTime.toIso8601String(),
          'dateTime': segment.arrivalDateTime.toIso8601String(),
        },
        'elapsedTime': flightTime,
        'stops': 0,
        'schedules': [
          {
            'carrier': {
              'marketing': 'FZ',
              'marketingFlightNumber': segment.flightNumber,
              'operating': segment.legDetails['OperatingCarrier']?.toString() ?? 'FZ',
            },
            'departure': {
              'airport': origin,
              'terminal': segment.legDetails['FromTerminal']?.toString() ?? _getTerminal(origin),
              'time': segment.departureDateTime.toIso8601String(),
              'dateTime': segment.departureDateTime.toIso8601String(),
            },
            'arrival': {
              'airport': destination,
              'terminal': segment.legDetails['ToTerminal']?.toString() ?? _getTerminal(destination),
              'time': segment.arrivalDateTime.toIso8601String(),
              'dateTime': segment.arrivalDateTime.toIso8601String(),
            },
            'equipment': segment.aircraft,
          }
        ],
      }
    ];
  }
  static List<Map<String, dynamic>> _createStopSchedules(FlydubaiFlightSegment segment) {
    // Get origin and destination with fallbacks
    String origin = segment.origin;
    String destination = segment.destination;

    if (origin.isEmpty || origin == 'N/A') {
      origin = segment.legDetails['Origin']?.toString() ?? 'DXB';
    }
    if (destination.isEmpty || destination == 'N/A') {
      destination = segment.legDetails['Destination']?.toString() ?? 'LHE';
    }

    return [
      {
        'carrier': {
          'marketing': 'FZ',
          'marketingFlightNumber': segment.flightNumber,
          'operating': segment.legDetails['OperatingCarrier']?.toString() ?? 'FZ',
        },
        'departure': {
          'airport': origin, // Use determined origin
          'terminal': segment.legDetails['FromTerminal']?.toString() ?? _getTerminal(origin),
          'time': segment.departureDateTime.toIso8601String(),
          'dateTime': segment.departureDateTime.toIso8601String(),
        },
        'arrival': {
          'airport': destination, // Use determined destination
          'terminal': segment.legDetails['ToTerminal']?.toString() ?? _getTerminal(destination),
          'time': segment.arrivalDateTime.toIso8601String(),
          'dateTime': segment.arrivalDateTime.toIso8601String(),
        },
        'equipment': segment.aircraft,
      }
    ];
  } static List<FlightSegmentInfo> _createSegmentInfo(FlydubaiFlightSegment segment) {
    final mainFare = segment.fareTypes.isNotEmpty ? segment.fareTypes.first : null;

    return [
      FlightSegmentInfo(
        bookingCode: mainFare?.bookingCode ?? 'Y',
        cabinCode: mainFare?.bookingCode ?? 'Y',
        mealCode: 'M',
        seatsAvailable: mainFare?.seatsAvailable.toString() ?? '9',
      )
    ];
  }

  static BaggageAllowance _createBaggageAllowance(String fareTypeName) {
    // FlyDubai baggage varies by fare type
    switch (fareTypeName.toUpperCase()) {
      case 'LITE':
        return BaggageAllowance(
          type: 'Checked',
          pieces: 0,
          weight: 0,
          unit: 'KGS',
        );
      case 'VALUE':
        return BaggageAllowance(
          type: 'Checked',
          pieces: 1,
          weight: 20,
          unit: 'KGS',
        );
      case 'FLEX':
        return BaggageAllowance(
          type: 'Checked',
          pieces: 1,
          weight: 30,
          unit: 'KGS',
        );
      case 'BUSINESS':
        return BaggageAllowance(
          type: 'Checked',
          pieces: 2,
          weight: 40,
          unit: 'KGS',
        );
      default:
        return BaggageAllowance(
          type: 'Checked',
          pieces: 1,
          weight: 20,
          unit: 'KGS',
        );
    }
  }

  static bool _determineRefundable(String fareTypeName) {
    return fareTypeName.toUpperCase() == 'FLEX' || fareTypeName.toUpperCase() == 'BUSINESS';
  }

  static String _getCityName(String airportCode) {
    const cityMap = {
      'DXB': 'Dubai',
      'AUH': 'Abu Dhabi',
      'SHJ': 'Sharjah',
      'KHI': 'Karachi',
      'LHE': 'Lahore',
      'ISB': 'Islamabad',
      'PEW': 'Peshawar',
      'JED': 'Jeddah',
      'RUH': 'Riyadh',
      'DAM': 'Damascus',
      'BEY': 'Beirut',
      'CAI': 'Cairo',
      'AMM': 'Amman',
      'KWI': 'Kuwait City',
      'DOH': 'Doha',
      'BAH': 'Manama',
    };
    return cityMap[airportCode] ?? airportCode;
  }

  static String _getTerminal(String airportCode) {
    const terminalMap = {
      'DXB': 'Terminal 2',
      'AUH': 'Terminal 3',
      'SHJ': 'Terminal 1',
      'KHI': 'Terminal 1',
      'LHE': 'Terminal 1',
      'ISB': 'Terminal 1',
    };
    return terminalMap[airportCode] ?? 'Main';
  }

  static List<Map<String, dynamic>> _getChangeFees(String fareTypeName) {
    switch (fareTypeName.toUpperCase()) {
      case 'LITE':
        return [
          {
            'condition': 'Any time',
            'amount': 'Not permitted',
            'currencyCode': 'PKR',
            'penaltyAmount': '0',
          },
        ];
      case 'VALUE':
        return [
          {
            'condition': '>24h',
            'amount': 'AED 150',
            'currencyCode': 'AED',
            'penaltyAmount': '150',
          },
          {
            'condition': '<24h',
            'amount': '100%',
            'currencyCode': 'PKR',
            'penaltyAmount': '100',
          },
        ];
      case 'FLEX':
      case 'BUSINESS':
        return [
          {
            'condition': '>12h',
            'amount': 'Free',
            'currencyCode': 'PKR',
            'penaltyAmount': '0',
          },
          {
            'condition': '<12h',
            'amount': '100%',
            'currencyCode': 'PKR',
            'penaltyAmount': '100',
          },
        ];
      default:
        return [
          {
            'condition': '>24h',
            'amount': 'Fee applies',
            'currencyCode': 'PKR',
            'penaltyAmount': '5000',
          },
        ];
    }
  }

  static List<Map<String, dynamic>> _getRefundFees(String fareTypeName) {
    switch (fareTypeName.toUpperCase()) {
      case 'LITE':
        return [
          {
            'condition': 'Any time',
            'amount': 'Non-refundable',
            'currencyCode': 'PKR',
            'penaltyAmount': '0',
          },
        ];
      case 'VALUE':
        return [
          {
            'condition': '>24h',
            'amount': 'AED 200',
            'currencyCode': 'AED',
            'penaltyAmount': '200',
          },
          {
            'condition': '<24h',
            'amount': 'Non-refundable',
            'currencyCode': 'PKR',
            'penaltyAmount': '0',
          },
        ];
      case 'FLEX':
        return [
          {
            'condition': '>24h',
            'amount': 'Free',
            'currencyCode': 'PKR',
            'penaltyAmount': '0',
          },
          {
            'condition': '<24h',
            'amount': 'AED 400',
            'currencyCode': 'AED',
            'penaltyAmount': '400',
          },
        ];
      case 'BUSINESS':
        return [
          {
            'condition': '>24h',
            'amount': 'Free',
            'currencyCode': 'PKR',
            'penaltyAmount': '0',
          },
          {
            'condition': '<24h',
            'amount': 'AED 400',
            'currencyCode': 'AED',
            'penaltyAmount': '400',
          },
        ];
      default:
        return [
          {
            'condition': '>24h',
            'amount': 'Fee applies',
            'currencyCode': 'PKR',
            'penaltyAmount': '8000',
          },
        ];
    }
  }

  FlydubaiFlight copyWithFareOptions(List<FlydubaiFlightFare> options) {
    return FlydubaiFlight(
      id: id,
      price: price,
      basePrice: basePrice,
      taxAmount: taxAmount,
      feeAmount: feeAmount,
      currency: currency,
      isRefundable: isRefundable,
      baggageAllowance: baggageAllowance,
      legSchedules: legSchedules,
      stopSchedules: stopSchedules,
      segmentInfo: segmentInfo,
      airlineCode: airlineCode,
      airlineName: airlineName,
      airlineImg: airlineImg,
      rph: rph,
      flightSegment: flightSegment,
      fareOptions: options,
      rawData: rawData,
      changeFeeDetails: changeFeeDetails,
      refundFeeDetails: refundFeeDetails, stops: stops, isNonStop: isNonStop, stopCities: stopCities,
    );
  }
}