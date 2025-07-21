// airarabia_flight_model.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../widgets/custom_textfield.dart';

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

        print("Error: $e");
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