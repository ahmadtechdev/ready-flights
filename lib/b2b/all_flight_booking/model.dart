// booking_model.dart
class BookingModel {
  final String id;
  final String gds;
  final DateTime? deadlineTime;
  final DateTime creationDate;
  final String bookBy;
  final String sabrePnr;
  final String airlinePnr;
  final String bookedAirline;
  final DateTime departureDate;
  final String bookingSignature;
  final String flightStatus;
  final String bookingType;
  final int adults;
  final int children;
  final int infants;
  final String bookerId;
  final String bookerName;
  final String bookerEmail;
  final String bookerPhone;
  final String currency;
  final double totalBuy;
  final double totalSell;
  final String airlineLogo;
  final String airlineName;
  final String tripSector;
  final String passengerNames;

  // Computed fields for UI display
  String get bookingId => "BK-$id";
  String get supplier => airlineName;
  String get trip => tripSector.replaceAll("-to-", " to ");
  String get pnr =>
      airlinePnr.isEmpty
          ? sabrePnr.isEmpty
              ? "Not Created"
              : sabrePnr
          : airlinePnr;
  String get status {
    switch (flightStatus) {
      case "1":
        return "On Hold";
      case "2":
        return "Confirmed";
      case "3":
        return "Cancelled";
      case "0":
        return "Error";
      default:
        return "Issuance Request";
    }
  }

  BookingModel({
    required this.id,
    required this.gds,
    this.deadlineTime,
    required this.creationDate,
    required this.bookBy,
    required this.sabrePnr,
    required this.airlinePnr,
    required this.bookedAirline,
    required this.departureDate,
    required this.bookingSignature,
    required this.flightStatus,
    required this.bookingType,
    required this.adults,
    required this.children,
    required this.infants,
    required this.bookerId,
    required this.bookerName,
    required this.bookerEmail,
    required this.bookerPhone,
    required this.currency,
    required this.totalBuy,
    required this.totalSell,
    required this.airlineLogo,
    required this.airlineName,
    required this.tripSector,
    required this.passengerNames,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Parse dates safely
    DateTime? parseDateTime(String value) {
      if (value == "0000-00-00 00:00:00" || value.isEmpty) {
        return null;
      }
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }

    DateTime? deadlineTime = parseDateTime(json['deadline_time'] ?? '');
    DateTime creationDate =
        parseDateTime(json['pnr_creation_date'] ?? '') ?? DateTime.now();
    DateTime departureDate =
        parseDateTime(json['departure_date'] ?? '') ?? DateTime.now();

    // Parse numeric values safely
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return 0;
        }
      }
      return 0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return 0;
        }
      }
      return 0;
    }

    return BookingModel(
      id: json['m_id'] ?? '',
      gds: json['gds'] ?? '',
      deadlineTime: deadlineTime,
      creationDate: creationDate,
      bookBy: json['book_by'] ?? '',
      sabrePnr: json['sabre_pnr'] ?? '',
      airlinePnr: json['airline_pnr'] ?? '',
      bookedAirline: json['booked_airline'] ?? '',
      departureDate: departureDate,
      bookingSignature: json['booking_signature'] ?? '',
      flightStatus: json['flight_status'] ?? '0',
      bookingType: json['booking_type'] ?? '1',
      adults: parseInt(json['no_adults']),
      children: parseInt(json['no_child']),
      infants: parseInt(json['no_infant']),
      bookerId: json['booker_id'] ?? '',
      bookerName: json['booker_name'] ?? '',
      bookerEmail: json['booker_email'] ?? '',
      bookerPhone: json['booker_phone'] ?? '',
      currency: json['currency'] ?? '',
      totalBuy: parseDouble(json['total_buy']),
      totalSell: parseDouble(json['total_sell']),
      airlineLogo: json['airline_logo'] ?? '',
      airlineName: json['airline_name'] ?? '',
      tripSector: json['all_sector'] ?? '',
      passengerNames: json['all_pax'] ?? '',
    );
  }
}
