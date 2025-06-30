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
  });

  factory AirArabiaFlight.fromJson(Map<String, dynamic> json) {
    try {
      final flightSegments = (json['flightSegments'] as List).map((segment) {
        return {
          'flightNumber': segment['flightNumber'],
          'departure': {
            'airport': segment['origin']['airportCode'],
            'city': _getCityName(segment['origin']['airportCode']),
            'terminal': segment['origin']['terminal'] ?? 'Main',
            'dateTime': segment['departureDateTimeLocal'],
          },
          'arrival': {
            'airport': segment['destination']['airportCode'],
            'city': _getCityName(segment['destination']['airportCode']),
            'terminal': segment['destination']['terminal'] ?? 'Main',
            'dateTime': segment['arrivalDateTimeLocal'],
          },
          'aircraftModel': segment['aircraftModel'] ?? 'A320',
          'elapsedTime': _calculateFlightDuration(
            segment['departureDateTimeLocal'],
            segment['arrivalDateTimeLocal'],
          ),
        };
      }).toList();

      // Get the first available cabin price
      final cabinPrice = json['cabinPrices'].firstWhere(
            (price) => price['availabilityStatus'] == 'AVAILABLE',
        orElse: () => json['cabinPrices'].first,
      );

      return AirArabiaFlight(
        id: '${json['flightSegments'].first['flightNumber']}-${DateTime.now().millisecondsSinceEpoch}',
        price: (cabinPrice['price'] as num).toDouble(),
        flightSegments: flightSegments,
        cabinClass: cabinPrice['cabinClass'],
        availabilityStatus: json['availabilityStatus'],
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error creating AirArabiaFlight: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
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

  static String _getCityName(String airportCode) {
    const cityMap = {
      'SKT': 'Sialkot',
      'DAC': 'Dhaka',
      'SHJ': 'Sharjah',
      // Add more airport codes as needed
    };
    return cityMap[airportCode] ?? airportCode;
  }

  int get totalDuration {
    return flightSegments.fold(0, (sum, segment) {
      return sum + (segment['elapsedTime'] as int);
    });
  }

  bool get isDirectFlight => flightSegments.length == 1;
}

// airarabia_roundtrip_model.dart
class AirArabiaRoundTrip {
  final AirArabiaFlight outbound;
  final AirArabiaFlight inbound;
  final double totalPrice;

  AirArabiaRoundTrip({
    required this.outbound,
    required this.inbound,
    required this.totalPrice,
  });

  int get totalDuration => outbound.totalDuration + inbound.totalDuration;
}