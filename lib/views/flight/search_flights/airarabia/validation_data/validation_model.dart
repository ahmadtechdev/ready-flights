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
      pricing: PricingInfo.fromJson(json['pricing']),
      extras: ExtrasInfo.fromJson(json['extras']),
      meta: MetaInfo.fromJson(json['meta']),
    );
  }
}

class PricingInfo {
  final PTCFareBreakdown ptcFareBreakdown;
  final double totalPrice;
  final String totalPriceAed;
  final String currency;
  final double aedRoe;

  PricingInfo({
    required this.ptcFareBreakdown,
    required this.totalPrice,
    required this.totalPriceAed,
    required this.currency,
    required this.aedRoe,
  });

  factory PricingInfo.fromJson(Map<String, dynamic> json) {
    return PricingInfo(
      ptcFareBreakdown: PTCFareBreakdown.fromJson(json['PTC_FareBreakdown']),
      totalPrice: (json['total_price'] as num).toDouble(),
      totalPriceAed: json['total_price_aed'] ?? '',
      currency: json['currency'] ?? 'PKR',
      aedRoe: (json['aed_roe'] as num).toDouble(),
    );
  }
}

class PTCFareBreakdown {
  final Map<String, dynamic> attributes;
  final PassengerTypeQuantity passengerTypeQuantity;
  final FareBasisCodes fareBasisCodes;
  final PassengerFare passengerFare;
  final TravelerRefNumber travelerRefNumber;

  PTCFareBreakdown({
    required this.attributes,
    required this.passengerTypeQuantity,
    required this.fareBasisCodes,
    required this.passengerFare,
    required this.travelerRefNumber,
  });

  factory PTCFareBreakdown.fromJson(Map<String, dynamic> json) {
    return PTCFareBreakdown(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
      passengerTypeQuantity: PassengerTypeQuantity.fromJson(json['PassengerTypeQuantity']),
      fareBasisCodes: FareBasisCodes.fromJson(json['FareBasisCodes']),
      passengerFare: PassengerFare.fromJson(json['PassengerFare']),
      travelerRefNumber: TravelerRefNumber.fromJson(json['TravelerRefNumber']),
    );
  }
}

// Additional model classes for PassengerTypeQuantity, FareBasisCodes, PassengerFare, TravelerRefNumber
// would be defined here following the same pattern

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
      baggage: BaggageInfo.fromJson(json['baggage']),
      meal: MealInfo.fromJson(json['meal']),
      seat: SeatInfo.fromJson(json['seat']),
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
      jsession: json['jsession'] ?? '',
      body: BaggageBody.fromJson(json['body']),
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
      aaBaggageDetailsRS: AABaggageDetailsRS.fromJson(json['AA_OTA_AirBaggageDetailsRS']),
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
      success: List<dynamic>.from(json['Success'] ?? []),
      warnings: List<dynamic>.from(json['Warnings'] ?? []),
      onDBaggagesEnabled: json['OnDBaggagesEnabled'] ?? false,
      baggageDetailsResponses: BaggageDetailsResponses.fromJson(json['BaggageDetailsResponses']),
      errors: List<dynamic>.from(json['Errors'] ?? []),
    );
  }
}

class BaggageDetailsResponses {
  final OnDBaggageDetailsResponse onDBaggageDetailsResponse;

  BaggageDetailsResponses({
    required this.onDBaggageDetailsResponse,
  });

  factory BaggageDetailsResponses.fromJson(Map<String, dynamic> json) {
    return BaggageDetailsResponses(
      onDBaggageDetailsResponse: OnDBaggageDetailsResponse.fromJson(json['OnDBaggageDetailsResponse']),
    );
  }
}

class OnDBaggageDetailsResponse {
  final List<FlightSegmentInfo> flightSegmentInfo;
  final List<BaggageOption> baggage;

  OnDBaggageDetailsResponse({
    required this.flightSegmentInfo,
    required this.baggage,
  });

  factory OnDBaggageDetailsResponse.fromJson(Map<String, dynamic> json) {
    return OnDBaggageDetailsResponse(
      flightSegmentInfo: List<FlightSegmentInfo>.from(
        (json['OnDFlightSegmentInfo'] as List).map((x) => FlightSegmentInfo.fromJson(x))
      ),
      baggage: List<BaggageOption>.from(
        (json['Baggage'] as List).map((x) => BaggageOption.fromJson(x))
      ),
    );
  }
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

// airarabia_revalidation_model.dart (continued)

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
      baggageCode: json['baggageCode'] ?? '',
      baggageDescription: json['baggageDescription'] ?? '',
      baggageCharge: json['baggageCharge'] ?? '0.00',
      currencyCode: json['currencyCode'] ?? 'PKR',
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
      jsession: json['jsession'] ?? '',
      body: MealBody.fromJson(json['body']),
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
      aaMealDetailsRS: AAMealDetailsRS.fromJson(json['AA_OTA_AirMealDetailsRS']),
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
      success: List<dynamic>.from(json['Success'] ?? []),
      warnings: List<dynamic>.from(json['Warnings'] ?? []),
      mealDetailsResponses: MealDetailsResponses.fromJson(json['MealDetailsResponses']),
      errors: List<dynamic>.from(json['Errors'] ?? []),
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
      mealDetailsResponse: List<MealDetailsResponse>.from(
        (json['MealDetailsResponse'] as List).map((x) => MealDetailsResponse.fromJson(x))
      ),
      multipleMealSelectionEnabled: json['multipleMealSelectionEnabled'] ?? false,
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
      flightSegmentInfo: FlightSegmentInfo.fromJson(json['FlightSegmentInfo']),
      meals: List<MealOption>.from(
        (json['Meal'] as List).map((x) => MealOption.fromJson(x))
      ),
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
      mealCode: json['mealCode'] ?? '',
      mealDescription: json['mealDescription'] ?? '',
      mealCharge: json['mealCharge'] ?? '0.00',
      mealName: json['mealName'] ?? '',
      defaultMeal: json['defaultMeal'] ?? 'N',
      availableMeals: json['availableMeals'] ?? '0',
      soldMeals: json['soldMeals'] ?? '0',
      allocatedMeals: json['allocatedMeals'] ?? '0',
      mealImageLink: json['mealImageLink'] ?? '',
      mealCategoryCode: json['mealCategoryCode'] ?? '',
      currencyCode: json['currencyCode'] ?? 'PKR',
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
      jsession: json['jsession'] ?? '',
      body: SeatBody.fromJson(json['body']),
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
      otaAirSeatMapRS: OTAAirSeatMapRS.fromJson(json['OTA_AirSeatMapRS']),
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
      success: List<dynamic>.from(json['Success'] ?? []),
      warnings: List<dynamic>.from(json['Warnings'] ?? []),
      seatMapResponses: SeatMapResponses.fromJson(json['SeatMapResponses']),
      errors: List<dynamic>.from(json['Errors'] ?? []),
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
      seatMapResponse: List<SeatMapResponse>.from(
        (json['SeatMapResponse'] as List).map((x) => SeatMapResponse.fromJson(x))
      ),
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
      flightSegmentInfo: FlightSegmentInfo.fromJson(json['FlightSegmentInfo']),
      seatMapDetails: SeatMapDetails.fromJson(json['SeatMapDetails']),
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
      cabinClass: CabinClass.fromJson(json['CabinClass']),
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
      airRows: AirRows.fromJson(json['AirRows']),
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
      airRow: List<AirRow>.from(
        (json['AirRow'] as List).map((x) => AirRow.fromJson(x))
      ),
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
      airSeats: AirSeats.fromJson(json['AirSeats']),
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
      airSeat: List<AirSeat>.from(
        (json['AirSeat'] as List).map((x) => AirSeat.fromJson(x))
      ),
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
      jsession: json['jsession'] ?? '',
      echoToken: json['echoToken'] ?? '',
      transactionId: json['transactionId'] ?? '',
      finalKey: json['final_key'] ?? '',
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
  final String fareBasisCode;

  FareBasisCodes({
    required this.fareBasisCode,
  });

  factory FareBasisCodes.fromJson(Map<String, dynamic> json) {
    return FareBasisCodes(
      fareBasisCode: json['FareBasisCode'] ?? '',
    );
  }
}

class PassengerFare {
  final Map<String, dynamic> attributes;
  final BaseFare baseFare;
  final EquiBaseFare equiBaseFare;
  final Taxes taxes;
  final List<dynamic> fees;
  final TotalFare totalFare;

  PassengerFare({
    required this.attributes,
    required this.baseFare,
    required this.equiBaseFare,
    required this.taxes,
    required this.fees,
    required this.totalFare,
  });

  factory PassengerFare.fromJson(Map<String, dynamic> json) {
    return PassengerFare(
      attributes: Map<String, dynamic>.from(json['@attributes'] ?? {}),
      baseFare: BaseFare.fromJson(json['BaseFare']),
      equiBaseFare: EquiBaseFare.fromJson(json['EquiBaseFare']),
      taxes: Taxes.fromJson(json['Taxes']),
      fees: List<dynamic>.from(json['Fees'] ?? []),
      totalFare: TotalFare.fromJson(json['TotalFare']),
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
      taxes: List<TaxItem>.from(
        (json['Tax'] as List).map((x) => TaxItem.fromJson(x))
      ),
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