import 'package:intl/intl.dart';

class GroupFlightModel {
  final int id;
  final String airline;
  final String sector;
  final String shortName;
  final int groupPriceDetailId;
  final DateTime departure;
  final String departureTime;
  final String arrivalTime;
  final String origin;
  final String destination;
  final String flightNumber;
  final int price;
  final int seats;
  final bool hasLayover;
  final String baggage;
  final String logoUrl;

  GroupFlightModel({
    required dynamic id,
    required this.airline,
    required this.sector,
    required this.shortName,
    required dynamic groupPriceDetailId,
    required this.departure,
    required this.departureTime,
    required this.arrivalTime,
    required this.origin,
    required this.destination,
    required this.flightNumber,
    required dynamic price,
    required dynamic seats,
    required this.hasLayover,
    required this.baggage,
    required this.logoUrl,
  }) : // Safely convert dynamic types to the required int types with error handling
       id = _parseIntSafely(id, 0),
       groupPriceDetailId = _parseIntSafely(groupPriceDetailId, 0),
       price = _parseIntSafely(price, 0),
       seats = _parseIntSafely(seats, 0);

  // Helper method to get formatted date
  String get formattedDate {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(departure);
  }

  // Static helper method to safely parse integers
  static int _parseIntSafely(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;

    if (value is int) return value;

    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        // If parsing fails, return the default value
        print('Error parsing value "$value" to int: $e');
        return defaultValue;
      }
    }

    // For any other type, try to convert to string first and then parse
    try {
      return int.parse(value.toString());
    } catch (e) {
      print('Error converting value "$value" to int: $e');
      return defaultValue;
    }
  }

  // Factory constructor to create a GroupFlightModel from JSON
  factory GroupFlightModel.fromJson(Map<String, dynamic> json) {
    // Extract flight details from the first item in details array if it exists
    final details =
        json['details'] != null && (json['details'] as List).isNotEmpty
            ? json['details'][0]
            : {};

    // Extract airline info
    final airline = json['airline'] ?? {};

    // Parse departure date safely
    DateTime departureDate;
    try {
      departureDate =
          json['dept_date'] != null
              ? DateTime.parse(json['dept_date'].toString())
              : DateTime.now();
    } catch (e) {
      print('Error parsing date: ${json['dept_date']}');
      departureDate = DateTime.now();
    }

    // Parse departure and arrival times safely
    String deptTime = '00:00';
    if (details['dept_time'] != null) {
      String timeStr = details['dept_time'].toString();
      deptTime = timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
    }

    String arvTime = '00:00';
    if (details['arv_time'] != null) {
      String timeStr = details['arv_time'].toString();
      arvTime = timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
    }

    return GroupFlightModel(
      id: json['id'] ?? 0,
      airline: airline['airline_name']?.toString() ?? '',
      sector: json['sector']?.toString() ?? '',
      shortName: airline['short_name']?.toString() ?? '',
      groupPriceDetailId: json['group_price_detail_id'] ?? 0,
      departure: departureDate,
      departureTime: deptTime,
      arrivalTime: arvTime,
      origin: details['origin']?.toString() ?? '',
      destination: details['destination']?.toString() ?? '',
      flightNumber: details['flight_no']?.toString() ?? '',
      price: json['price'] ?? 0,
      seats: json['available_no_of_pax'] ?? 0,
      hasLayover: false, // Default value
      baggage: (details['baggage'] ?? json['baggage'] ?? 'N/A').toString(),
      logoUrl:
          airline['logo_url']?.toString() ??
          'assets/images/default_airline.png',
    );
  }
}
