// airarabia_flight_model.dart
import 'package:flutter/foundation.dart';


class AirArabiaFlight {
  final String id;
  final double price;
  final String currency;
  final List<Map<String, dynamic>> flightSegments;
  final String airlineCode;
  final String airlineName;
  final String airlineImg;
  final String cabinClass;
  final bool isRefundable;
  final String availabilityStatus;
  final bool isRoundTrip;
  final Map<String, dynamic>? outboundFlight;
  final Map<String, dynamic>? inboundFlight;

  AirArabiaFlight({
    required this.id,
    required this.price,
    this.currency = 'PKR',
    required this.flightSegments,
    this.airlineCode = 'G9',
    this.airlineName = 'Air Arabia',
    this.airlineImg = 'https://images.kiwi.com/airlines/64/G9.png',
    required this.cabinClass,
    this.isRefundable = false,
    required this.availabilityStatus,
    this.isRoundTrip = false,
    this.outboundFlight,
    this.inboundFlight,
  });

  factory AirArabiaFlight.fromJson(Map<String, dynamic> json) {
    try {
      final flightSegments = (json['flightSegments'] as List).map((segment) {
        // Cast segment to Map<String, dynamic>
        final segmentMap = Map<String, dynamic>.from(segment as Map);
        final originMap = Map<String, dynamic>.from(segmentMap['origin'] as Map);
        final destinationMap = Map<String, dynamic>.from(segmentMap['destination'] as Map);

        return {
          'flightNumber': segmentMap['flightNumber'],
          'departure': {
            'airport': originMap['airportCode'],
            'city': originMap['airportCode'],
            'terminal': originMap['terminal'] ?? 'Main',
            'dateTime': segmentMap['departureDateTimeLocal'],
          },
          'arrival': {
            'airport': destinationMap['airportCode'],
            'city': destinationMap['airportCode'],
            'terminal': destinationMap['terminal'] ?? 'Main',
            'dateTime': segmentMap['arrivalDateTimeLocal'],
          },
          'aircraftModel': segmentMap['aircraftModel'] ?? 'A320',
          'elapsedTime': _calculateFlightDuration(
            segmentMap['departureDateTimeLocal'],
            segmentMap['arrivalDateTimeLocal'],
          ),
        };
      }).toList();

      // Safely get cabin price with proper type casting
      Map<String, dynamic> cabinPrice;
      try {
        // Check if cabinPrices exists and is not null
        if (json['cabinPrices'] != null) {
          final cabinPricesRaw = json['cabinPrices'] as List;

          // Convert each cabin price to proper Map<String, dynamic>
          final cabinPrices = cabinPricesRaw.map((price) =>
          Map<String, dynamic>.from(price as Map)
          ).toList();

          // First try to find available cabin price
          final availablePrices = cabinPrices
              .where((price) => price['availabilityStatus'] == 'AVAILABLE')
              .toList();


          if (availablePrices.isNotEmpty) {

            cabinPrice = availablePrices.first;

          } else {
            // Fallback to first cabin price if none are available
            cabinPrice = cabinPrices.first;

          }
        } else {
          // If cabinPrices is null, create a default cabin price
          throw Exception('cabinPrices is null');
        }
      } catch (e) {
        // If all else fails, create a default cabin price
        cabinPrice = {
          'cabinClass': 'Y',
          'price': 0.0,
          'availabilityStatus': 'UNAVAILABLE'
        };

        if (kDebugMode) {
          print("Error: $e");
        }
      }
      // Get flight segments for outbound/inbound logic
      final flightSegmentsRaw = json['flightSegments'] as List;
      final flightSegmentsList = flightSegmentsRaw.map((seg) =>
      Map<String, dynamic>.from(seg as Map)
      ).toList();

      return AirArabiaFlight(
        id: '${flightSegmentsList.first['flightNumber']}-${DateTime.now().millisecondsSinceEpoch}',
        price: (cabinPrice['price'] as num).toDouble(),
        flightSegments: flightSegments,
        cabinClass: cabinPrice['cabinClass'] ?? 'Y',
        availabilityStatus: json['availabilityStatus'] ?? 'UNAVAILABLE',
        isRoundTrip: json['isRoundTrip'] ?? false,
        outboundFlight: json['outboundFlight'] != null
            ? Map<String, dynamic>.from(json['outboundFlight'] as Map)
            : _findOutboundFlight(flightSegmentsList),
        inboundFlight: json['inboundFlight'] != null
            ? Map<String, dynamic>.from(json['inboundFlight'] as Map)
            : _findInboundFlight(flightSegmentsList),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error creating AirArabiaFlight: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  // Helper method to find outbound flight
  static Map<String, dynamic>? _findOutboundFlight(List<Map<String, dynamic>> segments) {
    try {
      return segments.firstWhere(
            (seg) => seg['isOutbound'] == true,
      );
    } catch (e) {
      return null;
    }
  }

  // Helper method to find inbound flight
  static Map<String, dynamic>? _findInboundFlight(List<Map<String, dynamic>> segments) {
    try {
      return segments.firstWhere(
            (seg) => seg['isOutbound'] == false,
      );
    } catch (e) {
      return null;
    }
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

  int get totalDuration {
    return flightSegments.fold(0, (sum, segment) {
      return sum + (segment['elapsedTime'] as int);
    });
  }

  bool get isDirectFlight => flightSegments.length == 1;
}

// AirArabia Package Models
class AirArabiaPackage {
  final String packageName;
  final String packageType; // Basic, Value, Ultimate
  final double basePrice;
  final double totalPrice;
  final String currency;
  final String cabinClass;
  final String baggageAllowance;
  final String mealInfo;
  final String seatInfo;
  final String modificationPolicy;
  final String cancellationPolicy;
  final bool isRefundable;
  final Map<String, dynamic> rawData;

  AirArabiaPackage({
    required this.packageName,
    required this.packageType,
    required this.basePrice,
    required this.totalPrice,
    required this.currency,
    required this.cabinClass,
    required this.baggageAllowance,
    required this.mealInfo,
    required this.seatInfo,
    required this.modificationPolicy,
    required this.cancellationPolicy,
    required this.isRefundable,
    required this.rawData,
  });

  factory AirArabiaPackage.fromJson(Map<String, dynamic> json) {
    try {
      final packageName = json['bundledServiceName'] ?? 'Basic';
      final packageType = _getPackageType(packageName);
      final basePrice = double.tryParse(json['perPaxBundledFee']?.toString() ?? '')
          ?? (json['perPaxBundledFee'] as num?)?.toDouble()
          ?? 0.0;
      final totalPrice = basePrice; // Will be calculated with margin later
      final currency = 'PKR';
      final cabinClass = 'Y'; // Default to Economy

      // Parse description for package details
      final description = json['description'] ?? '';
      final descriptionLines = description.split('\n');

      final baggageAllowance = _getBaggageAllowance(packageType);
      final mealInfo = descriptionLines.length > 2 ? descriptionLines[2] : 'Charges Apply';
      final seatInfo = descriptionLines.length > 3 ? descriptionLines[3] : 'Charges Apply';
      final modificationPolicy = descriptionLines.length > 4 ? descriptionLines[4] : 'Charges Apply';
      final cancellationPolicy = descriptionLines.length > 5 ? descriptionLines[5] : 'Charges Apply';

      final isRefundable = !packageType.toLowerCase().contains('basic');

      return AirArabiaPackage(
        packageName: packageName,
        packageType: packageType,
        basePrice: basePrice,
        totalPrice: totalPrice,
        currency: currency,
        cabinClass: cabinClass,
        baggageAllowance: baggageAllowance,
        mealInfo: mealInfo,
        seatInfo: seatInfo,
        modificationPolicy: modificationPolicy,
        cancellationPolicy: cancellationPolicy,
        isRefundable: isRefundable,
        rawData: json,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating AirArabiaPackage: $e');
      }
      rethrow;
    }
  }

  static String _getPackageType(String packageName) {
    switch (packageName.toLowerCase()) {
      case 'value':
        return 'Value';
      case 'ultimate':
        return 'Ultimate';
      default:
        return 'Basic';
    }
  }

  static String _getBaggageAllowance(String packageType) {
    switch (packageType.toLowerCase()) {
      case 'value':
        return '30 KG';
      case 'ultimate':
        return '40 KG';
      default:
        return 'Charges Apply';
    }
  }
}

class AirArabiaPackageResponse {
  final List<AirArabiaPackage> packages;
  final double basePrice;
  final String currency;
  final String route; // e.g., "KHI/SHJ/DAC"
  final Map<String, dynamic> rawData;

  AirArabiaPackageResponse({
    required this.packages,
    required this.basePrice,
    required this.currency,
    required this.route,
    required this.rawData,
  });

  factory AirArabiaPackageResponse.fromJson(Map<String, dynamic> json) {
    try {
      final List<AirArabiaPackage> packages = [];
      double basePrice = 0.0;
      final String currency = 'PKR';
      String route = '';

      // Parse the response structure based on the PHP example
      final Map<String, dynamic>? dataWrapper = json['data'] as Map<String, dynamic>?;
      final dynamic bodyNode = (dataWrapper != null) ? dataWrapper['body'] : json['body'];
      if (bodyNode != null) {
        final body = bodyNode;
        final otaAirPriceRS = body['OTA_AirPriceRS'];

        if (otaAirPriceRS != null) {
          final pricedItineraries = otaAirPriceRS['PricedItineraries'];

          if (pricedItineraries != null) {
            final pricedItinerary = pricedItineraries['PricedItinerary'];

            if (pricedItinerary != null) {
              final airItinerary = pricedItinerary['AirItinerary'];
              final airItineraryPricingInfo = pricedItinerary['AirItineraryPricingInfo'];

              // Extract route information
              if (airItinerary != null) {
                final originDestinationOptions = airItinerary['OriginDestinationOptions'];
                if (originDestinationOptions != null) {
                  final aaBundledServiceExt = originDestinationOptions['AABundledServiceExt'];

                  if (aaBundledServiceExt != null) {
                    // Handle both single item and list
                    final List<dynamic> bundledServices = aaBundledServiceExt is List
                        ? aaBundledServiceExt
                        : [aaBundledServiceExt];

                    for (var service in bundledServices) {
                      if (service['@attributes'] != null) {
                        route = service['@attributes']['applicableOnd'] ?? '';
                      }

                      // Extract packages from bundledService
                      if (service['bundledService'] != null) {
                        final bundledService = service['bundledService'];
                        final List<dynamic> serviceList = bundledService is List
                            ? bundledService
                            : [bundledService];

                        for (var packageData in serviceList) {
                          packages.add(AirArabiaPackage.fromJson(packageData));
                        }
                      }
                    }
                  }
                }
              }

              // Extract base price
              if (airItineraryPricingInfo != null) {
                final itinTotalFare = airItineraryPricingInfo['ItinTotalFare'];
                if (itinTotalFare != null) {
                  final totalFare = itinTotalFare['TotalFare'];
                  final attrs = (totalFare is Map) ? totalFare['@attributes'] : null;
                  final amountStr = (attrs is Map) ? attrs['Amount']?.toString() : null;
                  if (amountStr != null) {
                    basePrice = double.tryParse(amountStr) ?? 0.0;
                  }
                }
              }
            }
          }
        }
      }
      return AirArabiaPackageResponse(
        packages: packages,
        basePrice: basePrice,
        currency: currency,
        route: route,
        rawData: json,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating AirArabiaPackageResponse: $e');
      }
      rethrow;
    }
  }
}