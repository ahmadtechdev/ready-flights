


import 'sabre_package_modal.dart';

class SabreFlight {
  final String imgPath;
  final String airline;
  final String flightNumber;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final double price;
  final String from;
  final String to;
  final String type;
  final bool isRefundable;
  final bool isNonStop;
  final String departureTerminal;
  final String arrivalTerminal;
  final String departureCity;
  final String arrivalCity;
  final String aircraftType;
  final List<TaxDesc> taxes;
  final BaggageAllowance baggageAllowance;
  final List<FlightPackageInfo> packages;
  final List<String> stops; // New field
  final List<Map<String, dynamic>> stopSchedules;
  final int? legElapsedTime; // Total elapsed time from the leg
  final String cabinClass;
  final String mealCode;
  final SabreFlight? returnFlight; // For storing return flight information
  final bool isReturn; // To identify if this is a return flight
  final String? groupId; // To group related flights together
  // New Fields for Round-Trip Support
  final String? returnDepartureTime;
  final String? returnArrivalTime;
  final String? returnFrom;
  final String? returnTo;
  final bool isRoundTrip;
  final List<SabreFlight>?
  connectedFlights; // For storing related flights in multi-city
  final int? tripSequence; // To track order in multi-city trips
  final String? tripType; // "oneWay", "return", "multiCity"
  final List<Map<String, dynamic>> legSchedules;
  final List<FlightSegmentInfo> segmentInfo;
  final List<Map<String, dynamic>> pricingInforArray;
  // Add this new property

  SabreFlight({
    required this.imgPath,
    required this.airline,
    required this.flightNumber,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.from,
    required this.to,
    required this.type,
    required this.isRefundable,
    required this.isNonStop,
    required this.departureTerminal,
    required this.arrivalTerminal,
    required this.departureCity,
    required this.arrivalCity,
    required this.aircraftType,
    required this.taxes,
    required this.baggageAllowance,
    required this.packages,
    required this.legSchedules,
    required this.segmentInfo,
    required this.stopSchedules,
    this.stops = const [],
    this.legElapsedTime = 0,
    required this.cabinClass,
    required this.mealCode,
    this.returnFlight,
    this.isReturn = false,
    this.groupId,
    // Initialize new fields
    this.returnDepartureTime,
    this.returnArrivalTime,
    this.returnFrom,
    this.returnTo,
    this.isRoundTrip = false,
    this.connectedFlights,
    this.tripSequence,
    this.tripType,
    required this.pricingInforArray
  });
}

class PriceInfo {
  final double totalPrice;
  final double totalTaxAmount;
  final String currency;
  final double baseFareAmount;
  final String baseFareCurrency;
  final double constructionAmount;
  final String constructionCurrency;
  final double equivalentAmount;
  final String equivalentCurrency;

  PriceInfo({
    required this.totalPrice,
    required this.totalTaxAmount,
    required this.currency,
    required this.baseFareAmount,
    required this.baseFareCurrency,
    required this.constructionAmount,
    required this.constructionCurrency,
    required this.equivalentAmount,
    required this.equivalentCurrency,
  });

  factory PriceInfo.fromApiResponse(Map<String, dynamic> fareInfo) {
    final totalFare = fareInfo['totalFare'] as Map<String, dynamic>;
    return PriceInfo(
      totalPrice: (totalFare['totalPrice'] is int)
          ? totalFare['totalPrice'].toDouble()
          : totalFare['totalPrice'] as double,
      totalTaxAmount: (totalFare['totalTaxAmount'] is int)
          ? totalFare['totalTaxAmount'].toDouble()
          : totalFare['totalTaxAmount'] as double,
      currency: totalFare['currency'] as String,
      baseFareAmount: (totalFare['baseFareAmount'] is int)
          ? totalFare['baseFareAmount'].toDouble()
          : totalFare['baseFareAmount'] as double,
      baseFareCurrency: totalFare['baseFareCurrency'] as String,
      constructionAmount: (totalFare['constructionAmount'] is int)
          ? totalFare['constructionAmount'].toDouble()
          : totalFare['constructionAmount'] as double,
      constructionCurrency: totalFare['constructionCurrency'] as String,
      equivalentAmount: (totalFare['equivalentAmount'] is int)
          ? totalFare['equivalentAmount'].toDouble()
          : totalFare['equivalentAmount'] as double,
      equivalentCurrency: totalFare['equivalentCurrency'] as String,
    );
  }

  double getPriceInCurrency(String targetCurrency) {
    switch (targetCurrency) {
      case 'PKR':
        return equivalentCurrency == 'PKR' ? equivalentAmount : totalPrice;
      case 'USD':
        return baseFareCurrency == 'USD' ? baseFareAmount : totalPrice;
      default:
        return totalPrice;
    }
  }
}

// Helper functions
class AirlineInfo {
  final String name;
  final String logoPath;

  AirlineInfo(this.name, this.logoPath);
}

// Supporting classes
class TaxDesc {
  final String code;
  final double amount;
  final String currency;
  final String description;

  TaxDesc({
    required this.code,
    required this.amount,
    required this.currency,
    required this.description,
  });
}

class BaggageAllowance {
  final int pieces;
  final double weight;
  final String unit;
  final String type;

  BaggageAllowance({
    required this.pieces,
    required this.weight,
    required this.unit,
    required this.type,
  });
}

class FlightSegmentInfo {
  final String bookingCode;
  final String cabinCode;
  final String mealCode;
  final String seatsAvailable;
  final String fareBasisCode; // Added fareBasisCode

  FlightSegmentInfo({
    required this.bookingCode,
    required this.cabinCode,
    required this.mealCode,
    required this.seatsAvailable,
    this.fareBasisCode = '', // Default empty string
  });
}

