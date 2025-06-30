// models/airblue_flight_model.dart

// ignore_for_file: empty_catches

import 'package:flutter/foundation.dart';
import '../sabre/sabre_flight_models.dart';
import 'airblue_pnr_pricing.dart';

class AirBlueFlight {
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
  final String rph; // Added RPH field
  final List<AirBlueFareOption>? fareOptions;
  final Map<String, dynamic> rawData;// Added for storing different fare options
  final List<AirBluePNRPricing>? pnrPricing;

  AirBlueFlight({
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
    required this.rph, // Required RPH parameter
    this.fareOptions,
    required this.rawData,
    this.pnrPricing,
  });

  factory AirBlueFlight.fromJson(Map<String, dynamic> json, Map<String, AirlineInfo> airlineMap) {
    try {
      // Extract flight segment data
      final flightSegment = json['AirItinerary']['OriginDestinationOptions']['OriginDestinationOption']['FlightSegment'] ?? {};

      // Extract RPH value from the OriginDestinationOption
      final originDestOption = json['AirItinerary']['OriginDestinationOptions']['OriginDestinationOption'] ?? {};
      final rph = originDestOption['RPH']?.toString() ?? '0-0'; // Default value if RPH is not found

      // Extract airline info
      final marketingAirline = flightSegment['MarketingAirline'] ?? {};
      final airlineCode = marketingAirline['Code'] ?? 'PA';

      // Get airline info from the map
      final airlineInfo = airlineMap[airlineCode] ??
          AirlineInfo('Air Blue', 'https://images.kiwi.com/airlines/64/PA.png');

      // Extract pricing info
      final pricingInfo = json['AirItineraryPricingInfo'];
      final totalFare = pricingInfo['ItinTotalFare']['TotalFare'];
      final basePrice = pricingInfo['ItinTotalFare']['BaseFare'];
      final taxAmount = pricingInfo['ItinTotalFare']['Taxes'];
      final feeAmount = pricingInfo['ItinTotalFare']['Fees'];

      // Generate a unique ID
      final flightId = '${flightSegment['FlightNumber'] ?? 'UNKNOWN'}-${DateTime.now().millisecondsSinceEpoch}';

      // Get baggage allowance
      final baggageInfo = _getBaggageAllowance(pricingInfo);

      // Create flight segments
      final segmentInfo = _createSegmentInfo(json);

      return AirBlueFlight(
        id: flightId,
        price: double.tryParse(totalFare['Amount']?.toString() ?? '0') ?? 0,
        basePrice: double.tryParse(basePrice['Amount']?.toString() ?? '0') ?? 0,
        taxAmount: double.tryParse(taxAmount['Amount']?.toString() ?? '0') ?? 0,
        feeAmount: double.tryParse(feeAmount['Amount']?.toString() ?? '0') ?? 0,
        currency: totalFare['CurrencyCode'] ?? 'PKR',
        isRefundable: _determineRefundable(json),
        baggageAllowance: baggageInfo,
        legSchedules: _createLegSchedules(json, airlineInfo),
        stopSchedules: _createStopSchedules(json),
        segmentInfo: segmentInfo,
        airlineCode: airlineCode,
        airlineName: airlineInfo.name,
        airlineImg: airlineInfo.logoPath,
        rph: rph,
        rawData: json,// Set the RPH value

      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error creating AirBlueFlight: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  AirBlueFlight copyWithFareOptions(List<AirBlueFareOption> options) {
    return AirBlueFlight(
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
      fareOptions: options,
      rawData: rawData,
      pnrPricing: pnrPricing, // Keep existing pnrPricing if any
    );
  }


  // Separate method for PNR pricing
  AirBlueFlight copyWithPNRPricing(List<AirBluePNRPricing> pricing) {
    return AirBlueFlight(
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
      fareOptions: fareOptions,
      rawData: rawData,
      pnrPricing: pricing,
    );
  }
  static BaggageAllowance _getBaggageAllowance(Map<String, dynamic> pricingInfo) {
    try {
      final fareBreakdown = pricingInfo['PTC_FareBreakdowns']['PTC_FareBreakdown'];

      // Check if FareInfo is a list and get the baggage information
      if (fareBreakdown['FareInfo'] is List) {
        // Find the entry with baggage information
        for (var fareInfo in fareBreakdown['FareInfo']) {
          if (fareInfo['PassengerFare']?['FareBaggageAllowance'] != null) {
            final baggage = fareInfo['PassengerFare']['FareBaggageAllowance'];
            final weight = baggage['UnitOfMeasureQuantity']?.toString() ?? '20';
            final unit = baggage['UnitOfMeasure']?.toString() ?? 'KGS';

            return BaggageAllowance(
              type: 'Checked',
              pieces: 0, // AirBlue typically specifies by weight, not pieces
              weight: double.tryParse(weight) ?? 20,
              unit: unit,
            );
          }
        }
      } else if (fareBreakdown['FareInfo']?['PassengerFare']?['FareBaggageAllowance'] != null) {
        // Direct access if not a list
        final baggage = fareBreakdown['FareInfo']['PassengerFare']['FareBaggageAllowance'];
        final weight = baggage['UnitOfMeasureQuantity']?.toString() ?? '20';
        final unit = baggage['UnitOfMeasure']?.toString() ?? 'KGS';

        return BaggageAllowance(
          type: 'Checked',
          pieces: 0,
          weight: double.tryParse(weight) ?? 20,
          unit: unit,
        );
      }

      // Default baggage allowance if not found
      return BaggageAllowance(
        type: 'Checked',
        pieces: 0,
        weight: 20,
        unit: 'KGS',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting baggage allowance: $e');
      }
      return BaggageAllowance(
        type: 'Checked',
        pieces: 0,
        weight: 20,
        unit: 'KGS',
      );
    }
  }

  static bool _determineRefundable(Map<String, dynamic> json) {
    try {
      final pricingInfo = json['AirItineraryPricingInfo'] ?? {};
      final fareBreakdown = pricingInfo['PTC_FareBreakdowns']?['PTC_FareBreakdown'];

      if (fareBreakdown == null) return false;

      // Check if FareInfo is a list
      if (fareBreakdown['FareInfo'] is List) {
        for (var fareInfo in fareBreakdown['FareInfo']) {
          final fareType = fareInfo['FareInfo']?['FareType']?.toString() ?? '';
          if (fareType.contains('NONREF')) {
            return false;
          }
        }
      } else {
        final fareType = fareBreakdown['FareInfo']?['FareInfo']?['FareType']?.toString() ?? '';
        if (fareType.contains('NONREF')) {
          return false;
        }
      }

      // If no non-refundable indication found, return true
      // This is based on the fare basis code containing 'EF' or 'EV' from the sample data
      // You might need to adjust this logic based on your actual business requirements
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error determining refundable status: $e');
      }
      return false;
    }
  }

  static List<Map<String, dynamic>> _createLegSchedules(
      Map<String, dynamic> json,
      AirlineInfo airlineInfo
      ) {
    try {
      final airItinerary = json['AirItinerary'] ?? {};
      final originDestOption = airItinerary['OriginDestinationOptions']['OriginDestinationOption'] ?? {};
      final flightSegment = originDestOption['FlightSegment'] ?? {};

      final departure = flightSegment['DepartureAirport'] ?? {};
      final arrival = flightSegment['ArrivalAirport'] ?? {};
      final departureDateTime = flightSegment['DepartureDateTime']?.toString() ?? '';
      final arrivalDateTime = flightSegment['ArrivalDateTime']?.toString() ?? '';

      return [
        {
          'airlineCode': flightSegment['MarketingAirline']?['Code'] ?? 'PA',
          'airlineName': airlineInfo.name,
          'airlineImg': airlineInfo.logoPath,
          'departure': {
            'airport': departure['LocationCode'] ?? '',
            'city': _getCityName(departure['LocationCode']?.toString() ?? ''),
            'terminal': 'Main', // Default terminal
            'time': departureDateTime,
            'dateTime': departureDateTime,
          },
          'arrival': {
            'airport': arrival['LocationCode'] ?? '',
            'city': _getCityName(arrival['LocationCode']?.toString() ?? ''),
            'terminal': 'Main', // Default terminal
            'time': arrivalDateTime,
            'dateTime': arrivalDateTime,
          },
          'elapsedTime': _calculateFlightDuration(departureDateTime, arrivalDateTime),
          'stops': 0, // AirBlue flights in the sample are non-stop
          'schedules': [
            {
              'carrier': {
                'marketing': flightSegment['MarketingAirline']['Code'] ?? 'PA',
                'marketingFlightNumber': flightSegment['FlightNumber'] ?? '',
                'operating': flightSegment['OperatingAirline']?['Code'] ?? flightSegment['MarketingAirline']['Code'] ?? 'PA',
              },
              'departure': {
                'airport': departure['LocationCode'] ?? '',
                'terminal': 'Main',
                'time': departureDateTime,
                'dateTime': departureDateTime,
              },
              'arrival': {
                'airport': arrival['LocationCode'] ?? '',
                'terminal': 'Main',
                'time': arrivalDateTime,
                'dateTime': arrivalDateTime,
              },
              'equipment': flightSegment['Equipment']?['AirEquipType'] ?? 'A320',
            }
          ],
        }
      ];
    } catch (e) {
      if (kDebugMode) {
        print('Error creating leg schedules: $e');
      }
      return [];
    }
  }

  static List<Map<String, dynamic>> _createStopSchedules(Map<String, dynamic> json) {
    try {
      final airItinerary = json['AirItinerary'] ?? {};
      final originDestOption = airItinerary['OriginDestinationOptions']['OriginDestinationOption'] ?? {};
      final flightSegment = originDestOption['FlightSegment'] ?? {};

      final departure = flightSegment['DepartureAirport'] ?? {};
      final arrival = flightSegment['ArrivalAirport'] ?? {};

      return [
        {
          'carrier': {
            'marketing': flightSegment['MarketingAirline']['Code'] ?? 'PA',
            'marketingFlightNumber': flightSegment['FlightNumber'] ?? '',
            'operating': flightSegment['OperatingAirline']?['Code'] ?? flightSegment['MarketingAirline']['Code'] ?? 'PA',
          },
          'departure': {
            'airport': departure['LocationCode'] ?? '',
            'terminal': 'Main',
            'time': flightSegment['DepartureDateTime'] ?? '',
            'dateTime': flightSegment['DepartureDateTime'] ?? '',
          },
          'arrival': {
            'airport': arrival['LocationCode'] ?? '',
            'terminal': 'Main',
            'time': flightSegment['ArrivalDateTime'] ?? '',
            'dateTime': flightSegment['ArrivalDateTime'] ?? '',
          },
          'equipment': flightSegment['Equipment']?['AirEquipType'] ?? 'A320',
        }
      ];
    } catch (e) {
      if (kDebugMode) {
        print('Error creating stop schedules: $e');
      }
      return [];
    }
  }

  static List<FlightSegmentInfo> _createSegmentInfo(Map<String, dynamic> json) {
    try {
      final pricingInfo = json['AirItineraryPricingInfo'] ?? {};
      final fareBreakdown = pricingInfo['PTC_FareBreakdowns']?['PTC_FareBreakdown'];

      if (fareBreakdown == null) {
        return [FlightSegmentInfo(bookingCode: 'L', cabinCode: 'Y', mealCode: 'M', seatsAvailable: '')];
      }

      // Check if FareInfo is a list
      if (fareBreakdown['FareInfo'] is List) {
        final fareInfo = fareBreakdown['FareInfo'][0];
        final bookingCode = fareInfo['FareInfo']?['FareBasisCode']?.toString() ?? 'L';
        final fareType = fareInfo['FareInfo']?['FareType']?.toString() ?? '';

        return [
          FlightSegmentInfo(
            bookingCode: bookingCode,
            cabinCode: _determineCabinClass(fareType),
            mealCode: 'M', // Default meal code
            seatsAvailable: '',
          )
        ];
      } else {
        final fareInfo = fareBreakdown['FareInfo'];
        final bookingCode = fareInfo['FareInfo']?['FareBasisCode']?.toString() ?? 'L';
        final fareType = fareInfo['FareInfo']?['FareType']?.toString() ?? '';

        return [
          FlightSegmentInfo(
            bookingCode: bookingCode,
            cabinCode: _determineCabinClass(fareType),
            mealCode: 'M',
            seatsAvailable: '',
          )
        ];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating segment info: $e');
      }
      return [FlightSegmentInfo(bookingCode: 'L', cabinCode: 'Y', mealCode: 'M', seatsAvailable: '')];
    }
  }

  static String _determineCabinClass(String fareType) {
    if (fareType.contains('F')) return 'F'; // First
    if (fareType.contains('C')) return 'C'; // Business
    if (fareType.contains('W')) return 'W'; // Premium Economy
    return 'Y'; // Default to Economy
  }

  static int _calculateFlightDuration(String departure, String arrival) {
    try {
      final depTime = DateTime.parse(departure);
      final arrTime = DateTime.parse(arrival);
      return arrTime.difference(depTime).inMinutes;
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating flight duration: $e');
      }
      return 0;
    }
  }

   static String _getCityName(String airportCode) {
    // Add more airport codes as needed
    const cityMap = {
      'LHE': 'Lahore',
      'KHI': 'Karachi',
      'ISB': 'Islamabad',
      'PEW': 'Peshawar',
      'JED': 'Jeddah',
      'DXB': 'Dubai',
    };
    return cityMap[airportCode] ?? airportCode;
  }
}


// New class to represent different fare options for the same flight
// In airblue_flight_model.dart
class AirBlueFareOption {
  final String cabinCode;
  final String cabinName;
  final String brandName;
  final double price;
  final double basePrice;
  final double taxAmount;
  final double feeAmount;
  final String currency;
  final bool isRefundable;
  final String mealCode;
  final String baggageAllowance;
  final Map<String, dynamic> rawData;
  final Map<String, dynamic> pricingInfo;
  final String fareName; // Added to store fare name (Flexi, Extra, Value)
  final String changeFee; // Added for change fee info
  final String refundFee; // Added for refund fee info

  AirBlueFareOption({
    required this.cabinCode,
    required this.cabinName,
    required this.brandName,
    required this.price,
    required this.basePrice,
    required this.taxAmount,
    required this.feeAmount,
    required this.currency,
    required this.isRefundable,
    required this.mealCode,
    required this.baggageAllowance,
    required this.rawData,
    required this.pricingInfo,
    required this.fareName,
    required this.changeFee,
    required this.refundFee,
  });

  factory AirBlueFareOption.fromFlight(AirBlueFlight flight, Map<String, dynamic> rawData) {
    // Extract fare basis code to determine fare name and refundable status
    final String fareBasisCode = _extractFareBasisCode(rawData).toUpperCase();
    final String fareName = _getFareNameFromCode(fareBasisCode);
    final bool isRefundable = !fareBasisCode.contains('NR');

    // Extract cabin information
    final String cabinCode = _extractCabinCode(rawData);
    final String cabinName = _getCabinName(cabinCode);

    // Extract baggage allowance
    final String baggageAllowance = _extractBaggageAllowance(rawData);

    // Extract change and refund fees
    final Map<String, String> fees = _extractFees(rawData);
    final Map<String, dynamic> pricingInfo = _getPricingInfo(rawData);

    return AirBlueFareOption(
      cabinCode: cabinCode,
      cabinName: cabinName,
      brandName: fareName, // Using fareName as brandName
      price: flight.price,
      basePrice: flight.basePrice,
      taxAmount: flight.taxAmount,
      feeAmount: flight.feeAmount,
      currency: flight.currency,
      isRefundable: isRefundable,
      mealCode: 'M', // Default to meal available
      baggageAllowance: baggageAllowance,
      rawData: rawData,
      pricingInfo: pricingInfo,
      fareName: fareName,
      changeFee: fees['changeFee'] ?? 'Restricted',
      refundFee: fees['refundFee'] ?? 'Restricted',
    );
  }

  // Helper method to get fare name from code
  static String _getFareNameFromCode(String fareCode) {
    if (fareCode.contains('EV')) return 'Value';
    if (fareCode.contains('EF')) return 'Flexi';
    if (fareCode.contains('EX')) return 'Extra';
    return 'Standard';
  }
  static Map<String, dynamic> _getPricingInfo(Map<String, dynamic> data) {
  final pricingInfo = data['AirItineraryPricingInfo'];

  return pricingInfo;
  }

  // Updated helper method to extract fees
  static Map<String, String> _extractFees(Map<String, dynamic> data) {
    final Map<String, String> fees = {
      'changeFee': 'Restricted',
      'refundFee': 'Restricted',
    };

    try {
      final pricingInfo = data['AirItineraryPricingInfo'];
      if (pricingInfo == null) return fees;

      final ptcFareBreakdown = pricingInfo['PTC_FareBreakdowns']?['PTC_FareBreakdown'];
      if (ptcFareBreakdown == null) return fees;

      // Check if it's a list or single item
      if (ptcFareBreakdown is List && ptcFareBreakdown.isNotEmpty) {
        final fareInfo = ptcFareBreakdown[0]['FareInfo'];
        if (fareInfo is List && fareInfo.length > 1) {
          final ruleInfo = fareInfo[1]['RuleInfo'];
          if (ruleInfo != null) {
            final chargesRules = ruleInfo['ChargesRules'];
            if (chargesRules != null) {
              // Change fees
              final changePenalties = chargesRules['VoluntaryChanges']?['Penalty'];
              if (changePenalties is List) {
                fees['changeFee'] = 'Restricted'; // As per web UI
              }

              // Refund fees
              final refundPenalties = chargesRules['VoluntaryRefunds']?['Penalty'];
              if (refundPenalties is List) {
                fees['refundFee'] = 'Restricted'; // As per web UI
              }
            }
          }
        }
      }
    } catch (e) {
    }

    return fees;
  }

  // Update the _extractBaggageAllowance method to match web format
  static String _extractBaggageAllowance(Map<String, dynamic> data) {
    try {
      final pricingInfo = data['AirItineraryPricingInfo'];
      if (pricingInfo == null) return '20 KGS'; // Default as per web

      final ptcFareBreakdown = pricingInfo['PTC_FareBreakdowns']?['PTC_FareBreakdown'];
      if (ptcFareBreakdown == null) return '20 KGS';

      // Check if it's a list or single item
      if (ptcFareBreakdown is List && ptcFareBreakdown.isNotEmpty) {
        final fareInfo = ptcFareBreakdown[0]['FareInfo'];
        if (fareInfo is List && fareInfo.length > 1) {
          final baggage = fareInfo[1]['PassengerFare']?['FareBaggageAllowance'];
          if (baggage != null) {
            final weight = baggage['UnitOfMeasureQuantity']?.toString() ?? '20';
            final unit = baggage['UnitOfMeasure']?.toString() ?? 'KGS';
            return '$weight $unit';
          }
        }
      } else if (ptcFareBreakdown is Map) {
        final fareInfo = ptcFareBreakdown['FareInfo'];
        if (fareInfo is List && fareInfo.length > 1) {
          final baggage = fareInfo[1]['PassengerFare']?['FareBaggageAllowance'];
          if (baggage != null) {
            final weight = baggage['UnitOfMeasureQuantity']?.toString() ?? '20';
            final unit = baggage['UnitOfMeasure']?.toString() ?? 'KGS';
            return '$weight $unit';
          }
        }
      }
    } catch (e) {
    }

    return '20 KGS'; // Default as per web
  }

  // Helper methods (_extractFareBasisCode, _extractCabinCode, etc.) go here
  // Copy all the static helper methods from airblue_package_modal.dart
  // Helper method to extract fare basis code
  static String _extractFareBasisCode(Map<String, dynamic> data) {
    try {
      final airItinPricingInfo = data['AirItineraryPricingInfo'];

      if (airItinPricingInfo == null) return '';

      final ptcFareBreakdowns = airItinPricingInfo['PTC_FareBreakdowns']?['PTC_FareBreakdown'];

      if (ptcFareBreakdowns == null) return '';

      // Check if it's a list or a single item

        final fareInfos = ptcFareBreakdowns['FareInfo']?[0]['FareInfo'];

        if (fareInfos is List && fareInfos.isNotEmpty) {
          return fareInfos[0]['FareBasisCode'] ?? '';
        } else if (fareInfos != null) {
          return fareInfos['FareBasisCode'] ?? '';
        }

      return '';
    } catch (e) {
      return '';
    }
  }

  // Helper method to extract cabin code
  static String _extractCabinCode(Map<String, dynamic> data) {
    try {
      final originDestOption = data['AirItinerary']?['OriginDestinationOptions']?['OriginDestinationOption'];
      if (originDestOption == null) return 'Y';

      final flightSegment = originDestOption['FlightSegment'];
        return flightSegment['ResBookDesigCode'] ?? '';

    } catch (e) {
      return '';
    }
  }

  // Helper method to get proper cabin name based on cabin code
  static String _getCabinName(String cabinCode) {

    //  THiss shoudl update according to web
    switch (cabinCode.toUpperCase()) {
      case 'F': return 'First Class';
      case 'C': return 'Business Class';
      case 'J': return 'Premium Business';
      case 'W': return 'Premium Economy';
      case 'S': return 'Premium Economy';
      case 'Y': return 'Economy';
      default: return 'Economy';
    }
  }


}