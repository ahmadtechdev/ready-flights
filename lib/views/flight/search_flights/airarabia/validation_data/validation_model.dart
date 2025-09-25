// airarabia_revalidation_model.dart
class AirArabiaRevalidationResponse {
  final int status;
  final String message;
  final AirArabiaRevalidationData? data;

  AirArabiaRevalidationResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AirArabiaRevalidationResponse.fromJson(Map<String, dynamic> json) {
    return AirArabiaRevalidationResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? AirArabiaRevalidationData.fromJson(json['data']) : null,
    );
  }
}

class AirArabiaRevalidationData {
  final PricingInfo pricing;
  final ExtrasInfo extras;
  final MetaInfo meta;

  AirArabiaRevalidationData({
    required this.pricing,
    required this.extras,
    required this.meta,
  });

  factory AirArabiaRevalidationData.fromJson(Map<String, dynamic> json) {
    return AirArabiaRevalidationData(
      pricing: PricingInfo.fromJson(json['pricing'] ?? {}),
      extras: ExtrasInfo.fromJson(json['extras'] ?? {}),
      meta: MetaInfo.fromJson(json['meta'] ?? {}),
    );
  }
}


class PricingInfo {
  final List<PTCFareBreakdown> ptcFareBreakdowns; // Changed to List
  final double totalPrice;
  final String totalPriceAed;
  final String currency;
  final double aedRoe;

  PricingInfo({
    required this.ptcFareBreakdowns,
    required this.totalPrice,
    required this.totalPriceAed,
    required this.currency,
    required this.aedRoe,
  });

  factory PricingInfo.fromJson(Map<String, dynamic> json) {
    return PricingInfo(
      ptcFareBreakdowns: _parsePTCFareBreakdownList(json['PTC_FareBreakdown']), // Fixed
      totalPrice: _parseDouble(json['total_price']),
      totalPriceAed: json['total_price_aed']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'PKR',
      aedRoe: _parseDouble(json['aed_roe']),
    );
  }
}
List<PTCFareBreakdown> _parsePTCFareBreakdownList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((x) => PTCFareBreakdown.fromJson(x as Map<String, dynamic>)).toList();
  }
  if (value is Map<String, dynamic>) {
    return [PTCFareBreakdown.fromJson(value)];
  }
  return [];
}


class PTCFareBreakdown {
  final Map<String, dynamic> attributes;
  final PassengerTypeQuantity? passengerTypeQuantity;
  final FareBasisCodes? fareBasisCodes;
  final PassengerFare? passengerFare;
  final List<TravelerRefNumber> travelerRefNumber;

  PTCFareBreakdown({
    required this.attributes,
    this.passengerTypeQuantity,
    this.fareBasisCodes,
    this.passengerFare,
    required this.travelerRefNumber,
  });

  factory PTCFareBreakdown.fromJson(Map<String, dynamic> json) {
    return PTCFareBreakdown(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
      passengerTypeQuantity: json['PassengerTypeQuantity'] != null
          ? PassengerTypeQuantity.fromJson(json['PassengerTypeQuantity'])
          : null,
      fareBasisCodes: json['FareBasisCodes'] != null
          ? FareBasisCodes.fromJson(json['FareBasisCodes'])
          : null,
      passengerFare: json['PassengerFare'] != null
          ? PassengerFare.fromJson(json['PassengerFare'])
          : null,
      travelerRefNumber: _parseTravelerRefNumberList(json['TravelerRefNumber']),
    );
  }
}

class ExtrasInfo {
  final BaggageInfo baggage;
  final MealInfo meal;
  final SeatInfo seat;

  ExtrasInfo({
    required this.baggage,
    required this.meal,
    required this.seat,
  });

  factory ExtrasInfo.fromJson(Map<String, dynamic> json) {
    return ExtrasInfo(
      baggage: BaggageInfo.fromJson(json['baggage'] ?? {}),
      meal: MealInfo.fromJson(json['meal'] ?? {}),
      seat: SeatInfo.fromJson(json['seat'] ?? {}),
    );
  }
}

class BaggageInfo {
  final String jsession;
  final BaggageBody body;

  BaggageInfo({
    required this.jsession,
    required this.body,
  });

  factory BaggageInfo.fromJson(Map<String, dynamic> json) {
    return BaggageInfo(
      jsession: json['jsession']?.toString() ?? '',
      body: BaggageBody.fromJson(json['body'] ?? {}),
    );
  }
}

class BaggageBody {
  final AABaggageDetailsRS aaBaggageDetailsRS;

  BaggageBody({
    required this.aaBaggageDetailsRS,
  });

  factory BaggageBody.fromJson(Map<String, dynamic> json) {
    return BaggageBody(
      aaBaggageDetailsRS: AABaggageDetailsRS.fromJson(json['AA_OTA_AirBaggageDetailsRS'] ?? {}),
    );
  }
}

class AABaggageDetailsRS {
  final Map<String, dynamic> attributes;
  final List<dynamic> success;
  final List<dynamic> warnings;
  final bool onDBaggagesEnabled;
  final BaggageDetailsResponses baggageDetailsResponses;
  final List<dynamic> errors;

  AABaggageDetailsRS({
    required this.attributes,
    required this.success,
    required this.warnings,
    required this.onDBaggagesEnabled,
    required this.baggageDetailsResponses,
    required this.errors,
  });

  factory AABaggageDetailsRS.fromJson(Map<String, dynamic> json) {
    return AABaggageDetailsRS(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
      success: _parseList(json['Success']),
      warnings: _parseList(json['Warnings']),
      onDBaggagesEnabled: _parseBool(json['OnDBaggagesEnabled']),
      baggageDetailsResponses: BaggageDetailsResponses.fromJson(json['BaggageDetailsResponses'] ?? {}),
      errors: _parseList(json['Errors']),
    );
  }
}
// Key sections that need to be updated in your validation_model.dart

class BaggageDetailsResponses {
  final List<OnDBaggageDetailsResponse> onDBaggageDetailsResponse;

  BaggageDetailsResponses({
    required this.onDBaggageDetailsResponse,
  });

  factory BaggageDetailsResponses.fromJson(Map<String, dynamic> json) {
    return BaggageDetailsResponses(
      onDBaggageDetailsResponse: _parseOnDBaggageDetailsResponseList(
          json['OnDBaggageDetailsResponse']),
    );
  }
}

class OnDBaggageDetailsResponse {
  final dynamic flightSegmentInfo; // Keep as dynamic
  final List<BaggageOption> baggage;

  OnDBaggageDetailsResponse({
    required this.flightSegmentInfo,
    required this.baggage,
  });

  factory OnDBaggageDetailsResponse.fromJson(Map<String, dynamic> json) {
    return OnDBaggageDetailsResponse(
      flightSegmentInfo: json['OnDFlightSegmentInfo'], // Keep raw
      baggage: _parseBaggageList(json['Baggage']),
    );
  }

  // Helper method to get segments as a list
  List<FlightSegmentInfo> getSegments() {
    if (flightSegmentInfo == null) return [];
    if (flightSegmentInfo is List) {
      return (flightSegmentInfo as List)
          .map((x) => FlightSegmentInfo.fromJson(x as Map<String, dynamic>))
          .toList();
    }
    if (flightSegmentInfo is Map<String, dynamic>) {
      return [FlightSegmentInfo.fromJson(flightSegmentInfo as Map<String, dynamic>)];
    }
    return [];
  }
}

// Add this helper function at the bottom of the file
List<OnDBaggageDetailsResponse> _parseOnDBaggageDetailsResponseList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((x) => OnDBaggageDetailsResponse.fromJson(x as Map<String, dynamic>)).toList();
  }
  if (value is Map<String, dynamic>) {
    return [OnDBaggageDetailsResponse.fromJson(value)];
  }
  return [];
}

class FlightSegmentInfo {
  final Map<String, dynamic> attributes;
  final Map<String, dynamic> departureAirport;
  final Map<String, dynamic> arrivalAirport;

  FlightSegmentInfo({
    required this.attributes,
    required this.departureAirport,
    required this.arrivalAirport,
  });

  factory FlightSegmentInfo.fromJson(Map<String, dynamic> json) {
    return FlightSegmentInfo(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
      departureAirport: Map<String, dynamic>.from(json['DepartureAirport'] ?? {}),
      arrivalAirport: Map<String, dynamic>.from(json['ArrivalAirport'] ?? {}),
    );
  }
}

class BaggageOption {
  final String baggageCode;
  final String baggageDescription;
  final String baggageCharge;
  final String currencyCode;

  BaggageOption({
    required this.baggageCode,
    required this.baggageDescription,
    required this.baggageCharge,
    required this.currencyCode,
  });

  factory BaggageOption.fromJson(Map<String, dynamic> json) {
    return BaggageOption(
      baggageCode: json['baggageCode']?.toString() ?? '',
      baggageDescription: json['baggageDescription']?.toString() ?? '',
      baggageCharge: json['baggageCharge']?.toString() ?? '0.00',
      currencyCode: json['currencyCode']?.toString() ?? 'PKR',
    );
  }
}

class MealInfo {
  final String jsession;
  final MealBody body;

  MealInfo({
    required this.jsession,
    required this.body,
  });

  factory MealInfo.fromJson(Map<String, dynamic> json) {
    return MealInfo(
      jsession: json['jsession']?.toString() ?? '',
      body: MealBody.fromJson(json['body'] ?? {}),
    );
  }
}

class MealBody {
  final AAMealDetailsRS aaMealDetailsRS;

  MealBody({
    required this.aaMealDetailsRS,
  });

  factory MealBody.fromJson(Map<String, dynamic> json) {
    return MealBody(
      aaMealDetailsRS: AAMealDetailsRS.fromJson(json['AA_OTA_AirMealDetailsRS'] ?? {}),
    );
  }
}

class AAMealDetailsRS {
  final Map<String, dynamic> attributes;
  final List<dynamic> success;
  final List<dynamic> warnings;
  final MealDetailsResponses mealDetailsResponses;
  final List<dynamic> errors;

  AAMealDetailsRS({
    required this.attributes,
    required this.success,
    required this.warnings,
    required this.mealDetailsResponses,
    required this.errors,
  });

  factory AAMealDetailsRS.fromJson(Map<String, dynamic> json) {
    return AAMealDetailsRS(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
      success: _parseList(json['Success']),
      warnings: _parseList(json['Warnings']),
      mealDetailsResponses: MealDetailsResponses.fromJson(json['MealDetailsResponses'] ?? {}),
      errors: _parseList(json['Errors']),
    );
  }
}

class MealDetailsResponses {
  final List<MealDetailsResponse> mealDetailsResponse;
  final bool multipleMealSelectionEnabled;

  MealDetailsResponses({
    required this.mealDetailsResponse,
    required this.multipleMealSelectionEnabled,
  });

  factory MealDetailsResponses.fromJson(Map<String, dynamic> json) {
    return MealDetailsResponses(
      mealDetailsResponse: _parseMealDetailsResponseList(json['MealDetailsResponse']),
      multipleMealSelectionEnabled: _parseBool(json['multipleMealSelectionEnabled']),
    );
  }
}

class MealDetailsResponse {
  final FlightSegmentInfo flightSegmentInfo;
  final List<MealOption> meals;

  MealDetailsResponse({
    required this.flightSegmentInfo,
    required this.meals,
  });

  factory MealDetailsResponse.fromJson(Map<String, dynamic> json) {
    return MealDetailsResponse(
      flightSegmentInfo: FlightSegmentInfo.fromJson(json['FlightSegmentInfo'] ?? {}),
      meals: _parseMealOptionList(json['Meal']),
    );
  }
}

class MealOption {
  final String mealCode;
  final String mealDescription;
  final String mealCharge;
  final String mealName;
  final String defaultMeal;
  final String availableMeals;
  final String soldMeals;
  final String allocatedMeals;
  final String mealImageLink;
  final String mealCategoryCode;
  final String currencyCode;

  MealOption({
    required this.mealCode,
    required this.mealDescription,
    required this.mealCharge,
    required this.mealName,
    required this.defaultMeal,
    required this.availableMeals,
    required this.soldMeals,
    required this.allocatedMeals,
    required this.mealImageLink,
    required this.mealCategoryCode,
    required this.currencyCode,

  });

  factory MealOption.fromJson(Map<String, dynamic> json) {
    return MealOption(
      mealCode: json['mealCode']?.toString() ?? '',
      mealDescription: json['mealDescription']?.toString() ?? '',
      mealCharge: json['mealCharge']?.toString() ?? '0.00',
      mealName: json['mealName']?.toString() ?? '',
      defaultMeal: json['defaultMeal']?.toString() ?? 'N',
      availableMeals: json['availableMeals']?.toString() ?? '0',
      soldMeals: json['soldMeals']?.toString() ?? '0',
      allocatedMeals: json['allocatedMeals']?.toString() ?? '0',
      mealImageLink: json['mealImageLink']?.toString() ?? '',
      mealCategoryCode: json['mealCategoryCode']?.toString() ?? '',
      currencyCode: json['currencyCode']?.toString() ?? 'PKR',
    );
  }
}

class SeatInfo {
  final String jsession;
  final SeatBody body;

  SeatInfo({
    required this.jsession,
    required this.body,
  });

  factory SeatInfo.fromJson(Map<String, dynamic> json) {
    return SeatInfo(
      jsession: json['jsession']?.toString() ?? '',
      body: SeatBody.fromJson(json['body'] ?? {}),
    );
  }
}

class SeatBody {
  final OTAAirSeatMapRS otaAirSeatMapRS;

  SeatBody({
    required this.otaAirSeatMapRS,
  });

  factory SeatBody.fromJson(Map<String, dynamic> json) {
    return SeatBody(
      otaAirSeatMapRS: OTAAirSeatMapRS.fromJson(json['OTA_AirSeatMapRS'] ?? {}),
    );
  }
}

class OTAAirSeatMapRS {
  final Map<String, dynamic> attributes;
  final List<dynamic> success;
  final List<dynamic> warnings;
  final SeatMapResponses seatMapResponses;
  final List<dynamic> errors;

  OTAAirSeatMapRS({
    required this.attributes,
    required this.success,
    required this.warnings,
    required this.seatMapResponses,
    required this.errors,
  });

  factory OTAAirSeatMapRS.fromJson(Map<String, dynamic> json) {
    return OTAAirSeatMapRS(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
      success: _parseList(json['Success']),
      warnings: _parseList(json['Warnings']),
      seatMapResponses: SeatMapResponses.fromJson(json['SeatMapResponses'] ?? {}),
      errors: _parseList(json['Errors']),
    );
  }
}

class SeatMapResponses {
  final List<SeatMapResponse> seatMapResponse;

  SeatMapResponses({
    required this.seatMapResponse,
  });

  factory SeatMapResponses.fromJson(Map<String, dynamic> json) {
    return SeatMapResponses(
      seatMapResponse: _parseSeatMapResponseList(json['SeatMapResponse']),
    );
  }
}

class SeatMapResponse {
  final Map<String, dynamic> attributes;
  final FlightSegmentInfo flightSegmentInfo;
  final SeatMapDetails seatMapDetails;

  SeatMapResponse({
    required this.attributes,
    required this.flightSegmentInfo,
    required this.seatMapDetails,
  });

  factory SeatMapResponse.fromJson(Map<String, dynamic> json) {
    return SeatMapResponse(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
      flightSegmentInfo: FlightSegmentInfo.fromJson(json['FlightSegmentInfo'] ?? {}),
      seatMapDetails: SeatMapDetails.fromJson(json['SeatMapDetails'] ?? {}),
    );
  }
}

class SeatMapDetails {
  final CabinClass cabinClass;

  SeatMapDetails({
    required this.cabinClass,
  });

  factory SeatMapDetails.fromJson(Map<String, dynamic> json) {
    return SeatMapDetails(
      cabinClass: CabinClass.fromJson(json['CabinClass'] ?? {}),
    );
  }
}

class CabinClass {
  final Map<String, dynamic> attributes;
  final AirRows airRows;

  CabinClass({
    required this.attributes,
    required this.airRows,
  });

  factory CabinClass.fromJson(Map<String, dynamic> json) {
    return CabinClass(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
      airRows: AirRows.fromJson(json['AirRows'] ?? {}),
    );
  }
}

class AirRows {
  final List<AirRow> airRow;

  AirRows({
    required this.airRow,
  });

  factory AirRows.fromJson(Map<String, dynamic> json) {
    return AirRows(
      airRow: _parseAirRowList(json['AirRow']),
    );
  }
}

class AirRow {
  final Map<String, dynamic> attributes;
  final AirSeats airSeats;

  AirRow({
    required this.attributes,
    required this.airSeats,
  });

  factory AirRow.fromJson(Map<String, dynamic> json) {
    return AirRow(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
      airSeats: AirSeats.fromJson(json['AirSeats'] ?? {}),
    );
  }
}

class AirSeats {
  final List<AirSeat> airSeat;

  AirSeats({
    required this.airSeat,
  });

  factory AirSeats.fromJson(Map<String, dynamic> json) {
    return AirSeats(
      airSeat: _parseAirSeatList(json['AirSeat']),
    );
  }
}

class AirSeat {
  final Map<String, dynamic> attributes;

  AirSeat({
    required this.attributes,
  });

  factory AirSeat.fromJson(Map<String, dynamic> json) {
    return AirSeat(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
    );
  }
}

class SeatOption {
  final String seatNumber;
  final double seatCharge;
  final String currencyCode;
  final String seatAvailability;

  SeatOption({
    required this.seatNumber,
    required this.seatCharge,
    required this.currencyCode,
    required this.seatAvailability,
  });
}

class MetaInfo {
  final String jsession;
  final String echoToken;
  final String transactionId;
  final String finalKey;

  MetaInfo({
    required this.jsession,
    required this.echoToken,
    required this.transactionId,
    required this.finalKey,
  });

  factory MetaInfo.fromJson(Map<String, dynamic> json) {
    return MetaInfo(
      jsession: json['jsession']?.toString() ?? '',
      echoToken: json['echoToken']?.toString() ?? '',
      transactionId: json['transactionId']?.toString() ?? '',
      finalKey: json['final_key']?.toString() ?? '',
    );
  }
}

// Additional classes for pricing information
class PassengerTypeQuantity {
  final Map<String, dynamic> attributes;

  PassengerTypeQuantity({
    required this.attributes,
  });

  factory PassengerTypeQuantity.fromJson(Map<String, dynamic> json) {
    return PassengerTypeQuantity(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
    );
  }
}

class FareBasisCodes {
  final List<String> fareBasisCodes; // Changed to List

  FareBasisCodes({
    required this.fareBasisCodes,
  });

  factory FareBasisCodes.fromJson(Map<String, dynamic> json) {
    return FareBasisCodes(
      fareBasisCodes: _parseFareBasisCodes(json['FareBasisCode']), // Fixed
    );
  }
}



class PassengerFare {
  final Map<String, dynamic> attributes;
  final BaseFare? baseFare;
  final EquiBaseFare? equiBaseFare;
  final Taxes? taxes;
  final List<dynamic> fees;
  final TotalFare? totalFare;

  PassengerFare({
    required this.attributes,
    this.baseFare,
    this.equiBaseFare,
    this.taxes,
    required this.fees,
    this.totalFare,
  });

  factory PassengerFare.fromJson(Map<String, dynamic> json) {
    return PassengerFare(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
      baseFare: json['BaseFare'] != null ? BaseFare.fromJson(json['BaseFare']) : null,
      equiBaseFare: json['EquiBaseFare'] != null ? EquiBaseFare.fromJson(json['EquiBaseFare']) : null,
      taxes: json['Taxes'] != null ? Taxes.fromJson(json['Taxes']) : null, // Fixed
      fees: _parseList(json['Fees']),
      totalFare: json['TotalFare'] != null ? TotalFare.fromJson(json['TotalFare']) : null,
    );
  }
}


class BaseFare {
  final Map<String, dynamic> attributes;

  BaseFare({
    required this.attributes,
  });

  factory BaseFare.fromJson(Map<String, dynamic> json) {
    return BaseFare(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
    );
  }
}

class EquiBaseFare {
  final Map<String, dynamic> attributes;

  EquiBaseFare({
    required this.attributes,
  });

  factory EquiBaseFare.fromJson(Map<String, dynamic> json) {
    return EquiBaseFare(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
    );
  }
}

class Taxes {
  final List<TaxItem> taxes;

  Taxes({
    required this.taxes,
  });

  factory Taxes.fromJson(Map<String, dynamic> json) {
    return Taxes(
      taxes: _parseTaxItemList(json['Tax']), // Fixed
    );
  }
}

class TaxItem {
  final Map<String, dynamic> attributes;

  TaxItem({
    required this.attributes,
  });

  factory TaxItem.fromJson(Map<String, dynamic> json) {
    return TaxItem(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
    );
  }
}

class TotalFare {
  final Map<String, dynamic> attributes;

  TotalFare({
    required this.attributes,
  });

  factory TotalFare.fromJson(Map<String, dynamic> json) {
    return TotalFare(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
    );
  }
}

class TravelerRefNumber {
  final Map<String, dynamic> attributes;

  TravelerRefNumber({
    required this.attributes,
  });

  factory TravelerRefNumber.fromJson(Map<String, dynamic> json) {
    return TravelerRefNumber(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
    );
  }
}

// Helper functions for safe parsing
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

List<dynamic> _parseList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value;
  return [value]; // Single item wrapped in list
}

List<FlightSegmentInfo> _parseFlightSegmentInfoList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((x) => FlightSegmentInfo.fromJson(x as Map<String, dynamic>)).toList();
  }
  if (value is Map<String, dynamic>) {
    return [FlightSegmentInfo.fromJson(value)];
  }
  return [];
}

List<BaggageOption> _parseBaggageList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((x) => BaggageOption.fromJson(x as Map<String, dynamic>)).toList();
  }
  if (value is Map<String, dynamic>) {
    return [BaggageOption.fromJson(value)];
  }
  return [];
}

List<MealDetailsResponse> _parseMealDetailsResponseList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((x) => MealDetailsResponse.fromJson(x as Map<String, dynamic>)).toList();
  }
  if (value is Map<String, dynamic>) {
    return [MealDetailsResponse.fromJson(value)];
  }
  return [];
}

List<MealOption> _parseMealOptionList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((x) => MealOption.fromJson(x as Map<String, dynamic>)).toList();
  }
  if (value is Map<String, dynamic>) {
    return [MealOption.fromJson(value)];
  }
  return [];
}

List<SeatMapResponse> _parseSeatMapResponseList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((x) => SeatMapResponse.fromJson(x as Map<String, dynamic>)).toList();
  }
  if (value is Map<String, dynamic>) {
    return [SeatMapResponse.fromJson(value)];
  }
  return [];
}

List<AirRow> _parseAirRowList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((x) => AirRow.fromJson(x as Map<String, dynamic>)).toList();
  }
  if (value is Map<String, dynamic>) {
    return [AirRow.fromJson(value)];
  }
  return [];
}

List<AirSeat> _parseAirSeatList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((x) => AirSeat.fromJson(x as Map<String, dynamic>)).toList();
  }
  if (value is Map<String, dynamic>) {
    return [AirSeat.fromJson(value)];
  }
  return [];
}
List<TravelerRefNumber> _parseTravelerRefNumberList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((x) => TravelerRefNumber.fromJson(x as Map<String, dynamic>)).toList();
  }
  if (value is Map<String, dynamic>) {
    return [TravelerRefNumber.fromJson(value)];
  }
  return [];
}

List<String> _parseFareBasisCodes(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((x) => x.toString()).toList();
  }
  if (value is String) {
    return [value];
  }
  return [value.toString()];
}

List<TaxItem> _parseTaxItemList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((x) => TaxItem.fromJson(x as Map<String, dynamic>)).toList();
  }
  if (value is Map<String, dynamic>) {
    return [TaxItem.fromJson(value)];
  }
  return [];
}
  
