// models/emirates_flight_model.dart
import 'package:flutter/foundation.dart';

class EmiratesFlight {
  final String id;
  final double price; // Real price without margin
  final double basePrice;
  final double taxAmount;
  final String currency;
  final bool isRefundable;
  final BaggageAllowance baggageAllowance;
  final List<Map<String, dynamic>> legSchedules;
  final List<Map<String, dynamic>> stopSchedules;
  final String airlineCode;
  final String airlineName;
  final String airlineImg;
  final String offerId;
  final Map<String, dynamic> rawData;
  final String fareBasisCode;
  final String cabinClass;
  final String cabinName;
  final String priceClassName;
  final List<String> amenities;
  final String flightNumber;
  final String departureDate;
  final String departureTime;
    final String responseId;

  EmiratesFlight({
    required this.id,
    required this.price,
    required this.basePrice,
    required this.taxAmount,
    required this.currency,
    required this.isRefundable,
    required this.baggageAllowance,
    required this.legSchedules,
    required this.stopSchedules,
    required this.airlineCode,
    required this.airlineName,
    required this.airlineImg,
    required this.offerId,
    required this.rawData,
    required this.fareBasisCode,
    required this.cabinClass,
    required this.cabinName,
    required this.priceClassName,
    required this.amenities,
    required this.flightNumber,
    required this.departureDate,
    required this.departureTime,
     required this.responseId,
  });

  factory EmiratesFlight.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('\n🔵 Creating EmiratesFlight from JSON');
      debugPrint('Offer ID: ${json['OfferID']}');
       // ✅ Extract ResponseID from rawData
      String responseId = '';
      if (json['ResponseID'] != null) {
        responseId = json['ResponseID'].toString();
      } else if (json['ShoppingResponseID'] != null) {
        responseId = json['ShoppingResponseID']['ResponseID']?.toString() ?? '';
      }
      debugPrint('ResponseID: $responseId');

      // Extract DataLists for reference data
      final dataLists = json['DataLists'] ?? {};
      
      // Extract flight segment information
      final flightSegmentData = _extractFlightSegmentData(json, dataLists);
      debugPrint('Flight segment data extracted: ${flightSegmentData['departure']['airport']} -> ${flightSegmentData['arrival']['airport']}');

      // Extract price information (real price without margin)
      final priceInfo = _extractPriceInfo(json);
      debugPrint('Base Price: ${priceInfo['base']} ${priceInfo['currency']}');
      debugPrint('Tax: ${priceInfo['tax']} ${priceInfo['currency']}');
      debugPrint('Total: ${priceInfo['total']} ${priceInfo['currency']}');

      // Extract fare details FROM OFFERITEM
      final offerItem = json['OfferItem'];
      final fareDetail = offerItem != null ? offerItem['FareDetail'] : null;
      
      // Extract price class directly from OfferItem's PriceClassRef
      final priceClassInfo = _extractPriceClassFromOfferItem(json, dataLists, fareDetail);
      debugPrint('🏷️ Price Class: "${priceClassInfo['name']}" (${priceClassInfo['code']})');
      debugPrint('   Cabin: ${priceClassInfo['cabinName']}');

      // Create leg schedules with proper airport codes
      final legSchedules = _createLegSchedules(flightSegmentData);
      final stopSchedules = _createStopSchedules(flightSegmentData);

      debugPrint('✅ EmiratesFlight created successfully\n');

      return EmiratesFlight(
        id: json['OfferID']?.toString() ?? 'UNKNOWN',
        price: priceInfo['total'], // Store real price without margin
        basePrice: priceInfo['base'],
        taxAmount: priceInfo['tax'],
        currency: priceInfo['currency'],
        isRefundable: _determineRefundable(fareDetail),
        baggageAllowance: _getBaggageAllowance(json, dataLists),
        legSchedules: legSchedules,
        stopSchedules: stopSchedules,
        airlineCode: 'EK',
        airlineName: 'Emirates',
        airlineImg: 'https://images.kiwi.com/airlines/64/EK.png',
        offerId: json['OfferID']?.toString() ?? '',
        rawData: json,
        fareBasisCode: _extractFareBasisCode(fareDetail),
        cabinClass: priceClassInfo['cabinCode'],
        cabinName: priceClassInfo['cabinName'],
        priceClassName: priceClassInfo['name'],
        amenities: priceClassInfo['amenities'],
        flightNumber: flightSegmentData['flightNumber'],
        departureDate: flightSegmentData['departure']['date'],
        departureTime: flightSegmentData['departure']['time'],
        responseId: responseId, 
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating EmiratesFlight: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('JSON keys: ${json.keys}');
      rethrow;
    }
  }

  static Map<String, dynamic> _extractPriceClassFromOfferItem(
    Map<String, dynamic> offer,
    Map<String, dynamic> dataLists,
    Map<String, dynamic>? fareDetail,
  ) {
    try {
      debugPrint('🔍 Extracting price class from OfferItem...');
      
      // Step 1: Get PriceClassRef from OfferItem's FareDetail > FareComponent
      String? priceClassRef;
      if (fareDetail != null) {
        final fareComponent = fareDetail['FareComponent'];
        if (fareComponent != null) {
          priceClassRef = _extractValue(fareComponent['PriceClassRef']);
          debugPrint('  PriceClassRef from OfferItem: $priceClassRef');
        }
      }

      // Step 2: Look up the price class in DataLists using the reference
      if (priceClassRef != null && priceClassRef.isNotEmpty) {
        final priceClassList = dataLists['PriceClassList'];
        if (priceClassList != null) {
          final priceClasses = priceClassList['PriceClass'];
          if (priceClasses is Map) {
            final priceClass = priceClasses[priceClassRef];
            if (priceClass != null) {
              final name = _extractValue(priceClass['Name']) ?? 'Standard';
              final code = _extractValue(priceClass['Code']) ?? 'Y';
              
              debugPrint('  ✅ Price Class Found in DataLists: $name (Code: $code)');
              
              return {
                'name': name,
                'code': code,
                'cabinCode': _extractCabinCodeFromPriceClass(priceClass, fareDetail),
                'cabinName': _extractCabinNameFromPriceClass(priceClass, fareDetail),
                'amenities': _extractAmenities(priceClass),
              };
            }
          }
        }
      }

      debugPrint('  ⚠️ Using fallback cabin extraction from FareDetail');
      final cabinCode = _extractCabinClass(fareDetail);
      return {
        'name': _getCabinBasedPriceName(cabinCode),
        'code': cabinCode,
        'cabinCode': cabinCode,
        'cabinName': _extractCabinName(fareDetail),
        'amenities': <String>[],
      };
      
    } catch (e) {
      debugPrint('  ❌ Error extracting price class: $e');
      return {
        'name': 'Standard',
        'code': 'Y',
        'cabinCode': 'Y',
        'cabinName': 'Economy Class',
        'amenities': <String>[],
      };
    }
  }

  static String _extractCabinCodeFromPriceClass(
    Map<String, dynamic> priceClass,
    Map<String, dynamic>? fareDetail,
  ) {
    // First try to get from FareDetail
    if (fareDetail != null) {
      final cabinFromFare = _extractCabinClass(fareDetail);
      if (cabinFromFare.isNotEmpty && cabinFromFare != 'Y') {
        return cabinFromFare;
      }
    }
    
    // Fallback: infer from price class name
    final name = _extractValue(priceClass['Name'])?.toLowerCase() ?? '';
    if (name.contains('business')) return 'C';
    if (name.contains('first')) return 'F';
    if (name.contains('premium')) return 'W';
    return 'Y';
  }

  static String _extractCabinNameFromPriceClass(
    Map<String, dynamic> priceClass,
    Map<String, dynamic>? fareDetail,
  ) {
    final cabinCode = _extractCabinCodeFromPriceClass(priceClass, fareDetail);
    switch (cabinCode) {
      case 'F':
        return 'First Class';
      case 'C':
      case 'J':
        return 'Business Class';
      case 'W':
        return 'Premium Economy';
      case 'Y':
      default:
        return 'Economy Class';
    }
  }

  static String _getCabinBasedPriceName(String cabinCode) {
    switch (cabinCode) {
      case 'F':
        return 'First Class';
      case 'C':
      case 'J':
        return 'Business Class';
      case 'W':
        return 'Premium Economy';
      case 'Y':
      default:
        return 'Economy Standard';
    }
  }

  static Map<String, dynamic> _extractFlightSegmentData(
    Map<String, dynamic> offer,
    Map<String, dynamic> dataLists,
  ) {
    try {
      final offerItem = offer['OfferItem'];
      if (offerItem == null) return _getDefaultSegmentData();

      final fareDetail = offerItem['FareDetail'];
      if (fareDetail == null) return _getDefaultSegmentData();

      final fareComponent = fareDetail['FareComponent'];
      if (fareComponent == null) return _getDefaultSegmentData();

      final segmentRefs = fareComponent['SegmentRefs'];
      if (segmentRefs == null) return _getDefaultSegmentData();

      final onPoint = segmentRefs['ON_Point']?.toString() ?? '';
      final offPoint = segmentRefs['OFF_Point']?.toString() ?? '';
      final segmentKey = segmentRefs['\$t']?.toString() ?? segmentRefs.toString();

      final flightSegmentList = dataLists['FlightSegmentList'];
      if (flightSegmentList == null) return _getDefaultSegmentData();

      final flightSegments = flightSegmentList['FlightSegment'];
      if (flightSegments == null) return _getDefaultSegmentData();

      Map<String, dynamic>? segmentData;
      if (flightSegments is Map) {
        if (flightSegments.containsKey(segmentKey)) {
          segmentData = flightSegments[segmentKey];
        } else {
          for (var entry in flightSegments.entries) {
            final segment = entry.value;
            final departure = segment['Departure'];
            final arrival = segment['Arrival'];
            
            if (departure != null && arrival != null) {
              final depAirport = _extractValue(departure['AirportCode']);
              final arrAirport = _extractValue(arrival['AirportCode']);
              
              if (depAirport == onPoint && arrAirport == offPoint) {
                segmentData = segment;
                break;
              }
            }
          }
        }
      } else if (flightSegments is List && flightSegments.isNotEmpty) {
        segmentData = flightSegments.first;
      }

      if (segmentData == null) return _getDefaultSegmentData();

      final departure = segmentData['Departure'] ?? {};
      final arrival = segmentData['Arrival'] ?? {};
      final marketingCarrier = segmentData['MarketingCarrier'] ?? {};
      final flightDetail = segmentData['FlightDetail'] ?? {};

      final departureAirport = _extractValue(departure['AirportCode']) ?? onPoint;
      final arrivalAirport = _extractValue(arrival['AirportCode']) ?? offPoint;
      final departureDate = _extractValue(departure['Date']) ?? '';
      final departureTime = _extractValue(departure['Time']) ?? '00:00';
      final arrivalDate = _extractValue(arrival['Date']) ?? '';
      final arrivalTime = _extractValue(arrival['Time']) ?? '00:00';

      return {
        'departure': {
          'airport': departureAirport,
          'city': _getCityName(departureAirport),
          'terminal': _extractValue(departure['Terminal']?['Name']) ?? 'Main',
          'time': departureTime,
          'date': departureDate,
          'dateTime': '${departureDate}T$departureTime',
        },
        'arrival': {
          'airport': arrivalAirport,
          'city': _getCityName(arrivalAirport),
          'terminal': _extractValue(arrival['Terminal']?['Name']) ?? 'Main',
          'time': arrivalTime,
          'date': arrivalDate,
          'dateTime': '${arrivalDate}T$arrivalTime',
        },
        'carrier': {
          'marketing': _extractValue(marketingCarrier['AirlineID']) ?? 'EK',
          'marketingFlightNumber': _extractValue(marketingCarrier['FlightNumber']) ?? '623',
          'operating': _extractValue(marketingCarrier['AirlineID']) ?? 'EK',
        },
        'equipment': _extractValue(segmentData['Equipment']?['AircraftCode']) ?? '777',
        'flightNumber': _extractValue(marketingCarrier['FlightNumber']) ?? '623',
        'duration': _calculateFlightDuration(flightDetail),
      };
    } catch (e) {
      debugPrint('❌ Error extracting flight segment: $e');
      return _getDefaultSegmentData();
    }
  }

  static String _extractValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      return value['\$t']?.toString() ?? value['value']?.toString() ?? '';
    }
    return value.toString();
  }

  static Map<String, dynamic> _getDefaultSegmentData() {
    return {
      'departure': {
        'airport': 'LHE',
        'city': 'Lahore',
        'terminal': 'Main',
        'time': '09:00',
        'date': '',
        'dateTime': 'T09:00',
      },
      'arrival': {
        'airport': 'DXB',
        'city': 'Dubai',
        'terminal': '3',
        'time': '11:15',
        'date': '',
        'dateTime': 'T11:15',
      },
      'carrier': {
        'marketing': 'EK',
        'marketingFlightNumber': '625',
        'operating': 'EK',
      },
      'equipment': '777',
      'flightNumber': '625',
      'duration': 195,
    };
  }

  static Map<String, dynamic> _extractPriceInfo(Map<String, dynamic> json) {
    try {
      final totalPrice = json['TotalPrice']?['DetailCurrencyPrice']?['Total'] ?? {};
      final offerItem = json['OfferItem'];
      
      double total = 0;
      double base = 0;
      double tax = 0;
      String currency = 'PKR';

      if (totalPrice is Map) {
        total = double.tryParse(totalPrice['\$t']?.toString() ?? totalPrice['value']?.toString() ?? totalPrice.toString()) ?? 0;
        currency = totalPrice['Code']?.toString() ?? 'PKR';
      } else {
        total = double.tryParse(totalPrice.toString()) ?? 0;
      }

      if (offerItem != null) {
        final fareDetail = offerItem['FareDetail'];
        if (fareDetail != null) {
          final price = fareDetail['Price'];
          if (price != null) {
            final baseAmount = price['BaseAmount'];
            if (baseAmount != null) {
              base = double.tryParse(_extractValue(baseAmount)) ?? 0;
            }

            final taxes = price['Taxes'];
            if (taxes != null) {
              final taxTotal = taxes['Total'];
              if (taxTotal != null) {
                tax = double.tryParse(_extractValue(taxTotal)) ?? 0;
              }
            }
          }
        }
      }

      return {
        'total': total,
        'base': base,
        'tax': tax,
        'currency': currency,
      };
    } catch (e) {
      return {
        'total': 0.0,
        'base': 0.0,
        'tax': 0.0,
        'currency': 'PKR',
      };
    }
  }

  static List<Map<String, dynamic>> _createLegSchedules(Map<String, dynamic> segmentData) {
    return [
      {
        'airlineCode': 'EK',
        'airlineName': 'Emirates',
        'airlineImg': 'https://images.kiwi.com/airlines/64/EK.png',
        'departure': segmentData['departure'],
        'arrival': segmentData['arrival'],
        'elapsedTime': segmentData['duration'],
        'stops': 0,
        'schedules': [
          {
            'carrier': segmentData['carrier'],
            'departure': segmentData['departure'],
            'arrival': segmentData['arrival'],
            'equipment': segmentData['equipment'],
          }
        ],
      }
    ];
  }

  static List<Map<String, dynamic>> _createStopSchedules(Map<String, dynamic> segmentData) {
    return [
      {
        'carrier': segmentData['carrier'],
        'departure': segmentData['departure'],
        'arrival': segmentData['arrival'],
        'equipment': segmentData['equipment'],
      }
    ];
  }

  static int _calculateFlightDuration(Map<String, dynamic> flightDetail) {
    try {
      final duration = flightDetail['FlightDuration']?['Value']?.toString() ?? '';
      if (duration.startsWith('PT')) {
        final hoursMatch = RegExp(r'(\d+)H').firstMatch(duration);
        final minutesMatch = RegExp(r'(\d+)M').firstMatch(duration);
        final hours = hoursMatch != null ? int.parse(hoursMatch.group(1)!) : 0;
        final minutes = minutesMatch != null ? int.parse(minutesMatch.group(1)!) : 0;
        return hours * 60 + minutes;
      }
      return 195;
    } catch (e) {
      return 195;
    }
  }

  static BaggageAllowance _getBaggageAllowance(
    Map<String, dynamic> offer,
    Map<String, dynamic> dataLists,
  ) {
    try {
      final baggageAllowances = offer['BaggageAllowance'];
      if (baggageAllowances != null) {
        final baggageList = baggageAllowances is List ? baggageAllowances : [baggageAllowances];
        
        for (var baggage in baggageList) {
          final baggageRef = baggage['BaggageAllowanceRef'];
          final baggageAllowanceList = dataLists['BaggageAllowanceList'];
          
          if (baggageAllowanceList != null) {
            final baggageDetails = baggageAllowanceList['BaggageAllowance'];
            
            if (baggageDetails is Map) {
              final detail = baggageDetails[baggageRef];
              if (detail != null) {
                final category = detail['BaggageCategory']?.toString() ?? 'Checked';
                
                if (category == 'Checked') {
                  final weightAllowance = detail['WeightAllowance'];
                  if (weightAllowance != null) {
                    final maxWeight = weightAllowance['MaximumWeight'];
                    return BaggageAllowance(
                      type: 'Checked',
                      pieces: 0,
                      weight: double.tryParse(_extractValue(maxWeight['Value'])) ?? 25,
                      unit: maxWeight['UOM']?.toString() ?? 'KG',
                    );
                  }
                }
              }
            }
          }
        }
      }

      return BaggageAllowance(type: 'Checked', pieces: 0, weight: 25, unit: 'KG');
    } catch (e) {
      return BaggageAllowance(type: 'Checked', pieces: 0, weight: 25, unit: 'KG');
    }
  }

  static bool _determineRefundable(Map<String, dynamic>? fareDetail) {
    try {
      if (fareDetail != null) {
        final fareComponent = fareDetail['FareComponent'];
        if (fareComponent != null) {
          final fareRules = fareComponent['FareRules'];
          if (fareRules != null) {
            final penalty = fareRules['Penalty'];
            if (penalty != null) {
              final refundable = penalty['RefundableInd'];
              return refundable == 'true' || refundable == true;
            }
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static String _extractFareBasisCode(Map<String, dynamic>? fareDetail) {
    try {
      if (fareDetail != null) {
        final fareComponent = fareDetail['FareComponent'];
        if (fareComponent != null) {
          final fareBasis = fareComponent['FareBasis'];
          if (fareBasis != null) {
            final fareBasisCode = fareBasis['FareBasisCode'];
            if (fareBasisCode != null) {
              return _extractValue(fareBasisCode['Code']);
            }
          }
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static String _extractCabinClass(Map<String, dynamic>? fareDetail) {
    try {
      if (fareDetail != null) {
        final fareComponent = fareDetail['FareComponent'];
        if (fareComponent != null) {
          final fareBasis = fareComponent['FareBasis'];
          if (fareBasis != null) {
            final cabinType = fareBasis['CabinType'];
            if (cabinType != null) {
              return cabinType['CabinTypeCode']?.toString() ?? 'Y';
            }
          }
        }
      }
      return 'Y';
    } catch (e) {
      return 'Y';
    }
  }

  static String _extractCabinName(Map<String, dynamic>? fareDetail) {
    final cabinCode = _extractCabinClass(fareDetail);
    switch (cabinCode) {
      case 'F':
        return 'First Class';
      case 'C':
      case 'J':
        return 'Business Class';
      case 'W':
        return 'Premium Economy';
      case 'Y':
      default:
        return 'Economy Class';
    }
  }

  static List<String> _extractAmenities(Map<String, dynamic> priceClass) {
    final amenities = <String>[];
    try {
      final descriptions = priceClass['Descriptions'];
      if (descriptions != null) {
        final descriptionList = descriptions['Description'];
        if (descriptionList != null) {
          final descList = descriptionList is List ? descriptionList : [descriptionList];
          for (var desc in descList) {
            final text = desc['Text']?.toString() ?? '';
            if (text.isNotEmpty && 
                !text.contains('OriginDestinationReference') && 
                !text.contains('Icons') &&
                !text.contains('Cabin') &&
                text.startsWith('•')) {
              amenities.add(text.substring(1).trim());
            }
          }
        }
      }
    } catch (e) {
      // Ignore
    }
    
    if (amenities.isEmpty) {
      amenities.addAll([
        'ICE entertainment',
        'Hot and cold refreshments',
        'Complimentary Wi-Fi for Skywards members'
      ]);
    }
    
    return amenities;
  }

  static String _getCityName(String airportCode) {
    const cityMap = {
      'LHE': 'Lahore',
      'DXB': 'Dubai',
      'AUH': 'Abu Dhabi',
      'KHI': 'Karachi',
      'ISB': 'Islamabad',
      'JED': 'Jeddah',
      'RUH': 'Riyadh',
    };
    return cityMap[airportCode] ?? airportCode;
  }
}

class BaggageAllowance {
  final String type;
  final int pieces;
  final double weight;
  final String unit;

  BaggageAllowance({
    required this.type,
    required this.pieces,
    required this.weight,
    required this.unit,
  });
}