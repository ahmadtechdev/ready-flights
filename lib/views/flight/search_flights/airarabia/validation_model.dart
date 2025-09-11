// air_arabia_revalidation_model.dart
class AirArabiaRevalidationResponse {
  final int status;
  final String message;
  final RevalidationData? data;

  AirArabiaRevalidationResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AirArabiaRevalidationResponse.fromJson(Map<String, dynamic> json) {
    return AirArabiaRevalidationResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? RevalidationData.fromJson(json['data']) : null,
    );
  }

  toJson() {}
}

class RevalidationData {
  final PricingInfo pricing;
  final ExtrasInfo extras;
  final MetaInfo meta;

  RevalidationData({
    required this.pricing,
    required this.extras,
    required this.meta,
  });

  factory RevalidationData.fromJson(Map<String, dynamic> json) {
    return RevalidationData(
      pricing: PricingInfo.fromJson(json['pricing']),
      extras: ExtrasInfo.fromJson(json['extras']),
      meta: MetaInfo.fromJson(json['meta']),
    );
  }
}

class PricingInfo {
  final PtcFareBreakdown ptcFareBreakdown;
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
      ptcFareBreakdown: PtcFareBreakdown.fromJson(json['PTC_FareBreakdown']),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      totalPriceAed: json['total_price_aed'] ?? '',
      currency: json['currency'] ?? '',
      aedRoe: (json['aed_roe'] ?? 0).toDouble(),
    );
  }
}

class PtcFareBreakdown {
  final Map<String, String> attributes;
  final PassengerTypeQuantity passengerTypeQuantity;
  final FareBasisCodes fareBasisCodes;
  final PassengerFare passengerFare;
  final TravelerRefNumber travelerRefNumber;

  PtcFareBreakdown({
    required this.attributes,
    required this.passengerTypeQuantity,
    required this.fareBasisCodes,
    required this.passengerFare,
    required this.travelerRefNumber,
  });

  factory PtcFareBreakdown.fromJson(Map<String, dynamic> json) {
    return PtcFareBreakdown(
      attributes: Map<String, String>.from(json['@attributes'] ?? {}),
      passengerTypeQuantity: PassengerTypeQuantity.fromJson(json['PassengerTypeQuantity']),
      fareBasisCodes: FareBasisCodes.fromJson(json['FareBasisCodes']),
      passengerFare: PassengerFare.fromJson(json['PassengerFare']),
      travelerRefNumber: TravelerRefNumber.fromJson(json['TravelerRefNumber']),
    );
  }
}

class PassengerTypeQuantity {
  final Map<String, String> attributes;

  PassengerTypeQuantity({required this.attributes});

  factory PassengerTypeQuantity.fromJson(Map<String, dynamic> json) {
    return PassengerTypeQuantity(
      attributes: Map<String, String>.from(json['@attributes'] ?? {}),
    );
  }
}

class FareBasisCodes {
  final String fareBasisCode;

  FareBasisCodes({required this.fareBasisCode});

  factory FareBasisCodes.fromJson(Map<String, dynamic> json) {
    return FareBasisCodes(
      fareBasisCode: json['FareBasisCode'] ?? '',
    );
  }
}

class PassengerFare {
  final Map<String, String> attributes;
  final FareAmount baseFare;
  final FareAmount equiBaseFare;
  final TaxesInfo taxes;
  final List<dynamic> fees;
  final FareAmount totalFare;

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
      attributes: Map<String, String>.from(json['@attributes'] ?? {}),
      baseFare: FareAmount.fromJson(json['BaseFare']),
      equiBaseFare: FareAmount.fromJson(json['EquiBaseFare']),
      taxes: TaxesInfo.fromJson(json['Taxes']),
      fees: json['Fees'] ?? [],
      totalFare: FareAmount.fromJson(json['TotalFare']),
    );
  }
}

class FareAmount {
  final Map<String, String> attributes;
  final String amount;
  final String currencyCode;
  final String decimalPlaces;

  FareAmount({
    required this.attributes,
    required this.amount,
    required this.currencyCode,
    required this.decimalPlaces,
  });

  factory FareAmount.fromJson(Map<String, dynamic> json) {
    final attrs = Map<String, String>.from(json['@attributes'] ?? {});
    return FareAmount(
      attributes: attrs,
      amount: attrs['Amount'] ?? '',
      currencyCode: attrs['CurrencyCode'] ?? '',
      decimalPlaces: attrs['DecimalPlaces'] ?? '',
    );
  }
}

class TaxesInfo {
  final List<TaxItem> taxes;

  TaxesInfo({required this.taxes});

  factory TaxesInfo.fromJson(Map<String, dynamic> json) {
    final taxList = json['Tax'] as List<dynamic>? ?? [];
    return TaxesInfo(
      taxes: taxList.map((tax) => TaxItem.fromJson(tax)).toList(),
    );
  }
}

class TaxItem {
  final Map<String, String> attributes;
  final String amount;
  final String currencyCode;
  final String decimalPlaces;
  final String taxCode;
  final String taxName;

  TaxItem({
    required this.attributes,
    required this.amount,
    required this.currencyCode,
    required this.decimalPlaces,
    required this.taxCode,
    required this.taxName,
  });

  factory TaxItem.fromJson(Map<String, dynamic> json) {
    final attrs = Map<String, String>.from(json['@attributes'] ?? {});
    return TaxItem(
      attributes: attrs,
      amount: attrs['Amount'] ?? '',
      currencyCode: attrs['CurrencyCode'] ?? '',
      decimalPlaces: attrs['DecimalPlaces'] ?? '',
      taxCode: attrs['TaxCode'] ?? '',
      taxName: attrs['TaxName'] ?? '',
    );
  }
}

class TravelerRefNumber {
  final Map<String, String> attributes;

  TravelerRefNumber({required this.attributes});

  factory TravelerRefNumber.fromJson(Map<String, dynamic> json) {
    return TravelerRefNumber(
      attributes: Map<String, String>.from(json['@attributes'] ?? {}),
    );
  }
}

class ExtrasInfo {
  final BaggageInfo baggage;
  final MealInfo meal;
  final Map<String, dynamic> seat;

  ExtrasInfo({
    required this.baggage,
    required this.meal,
    required this.seat,
  });

  factory ExtrasInfo.fromJson(Map<String, dynamic> json) {
    return ExtrasInfo(
      baggage: BaggageInfo.fromJson(json['baggage']),
      meal: MealInfo.fromJson(json['meal']),
      seat: json['seat'] ?? {},
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
  final AaBaggageDetailsRS aaBaggageDetailsRS;

  BaggageBody({required this.aaBaggageDetailsRS});

  factory BaggageBody.fromJson(Map<String, dynamic> json) {
    return BaggageBody(
      aaBaggageDetailsRS: AaBaggageDetailsRS.fromJson(json['AA_OTA_AirBaggageDetailsRS']),
    );
  }
}

class AaBaggageDetailsRS {
  final Map<String, dynamic> attributes;
  final List<dynamic> success;
  final List<dynamic> warnings;
  final String onDBaggagesEnabled;
  final BaggageDetailsResponses baggageDetailsResponses;
  final List<dynamic> errors;

  AaBaggageDetailsRS({
    required this.attributes,
    required this.success,
    required this.warnings,
    required this.onDBaggagesEnabled,
    required this.baggageDetailsResponses,
    required this.errors,
  });

  factory AaBaggageDetailsRS.fromJson(Map<String, dynamic> json) {
    return AaBaggageDetailsRS(
      attributes: json['@attributes'] ?? {},
      success: json['Success'] ?? [],
      warnings: json['Warnings'] ?? [],
      onDBaggagesEnabled: json['OnDBaggagesEnabled'] ?? '',
      baggageDetailsResponses: BaggageDetailsResponses.fromJson(json['BaggageDetailsResponses']),
      errors: json['Errors'] ?? [],
    );
  }
}

class BaggageDetailsResponses {
  final OnDBaggageDetailsResponse onDBaggageDetailsResponse;

  BaggageDetailsResponses({required this.onDBaggageDetailsResponse});

  factory BaggageDetailsResponses.fromJson(Map<String, dynamic> json) {
    return BaggageDetailsResponses(
      onDBaggageDetailsResponse: OnDBaggageDetailsResponse.fromJson(json['OnDBaggageDetailsResponse']),
    );
  }
}

class OnDBaggageDetailsResponse {
  final List<FlightSegmentInfo> flightSegmentInfos;
  final List<BaggageOption> baggageOptions;

  OnDBaggageDetailsResponse({
    required this.flightSegmentInfos,
    required this.baggageOptions,
  });

  factory OnDBaggageDetailsResponse.fromJson(Map<String, dynamic> json) {
    final segments = json['OnDFlightSegmentInfo'] as List<dynamic>? ?? [];
    final baggage = json['Baggage'] as List<dynamic>? ?? [];
    
    return OnDBaggageDetailsResponse(
      flightSegmentInfos: segments.map((seg) => FlightSegmentInfo.fromJson(seg)).toList(),
      baggageOptions: baggage.map((bag) => BaggageOption.fromJson(bag)).toList(),
    );
  }
}

class FlightSegmentInfo {
  final Map<String, String> attributes;
  final AirportInfo departureAirport;
  final AirportInfo arrivalAirport;

  FlightSegmentInfo({
    required this.attributes,
    required this.departureAirport,
    required this.arrivalAirport,
  });

  factory FlightSegmentInfo.fromJson(Map<String, dynamic> json) {
    return FlightSegmentInfo(
      attributes: Map<String, String>.from(json['@attributes'] ?? {}),
      departureAirport: AirportInfo.fromJson(json['DepartureAirport']),
      arrivalAirport: AirportInfo.fromJson(json['ArrivalAirport']),
    );
  }
}

class AirportInfo {
  final Map<String, String> attributes;

  AirportInfo({required this.attributes});

  factory AirportInfo.fromJson(Map<String, dynamic> json) {
    return AirportInfo(
      attributes: Map<String, String>.from(json['@attributes'] ?? {}),
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
      baggageCode: json['baggageCode'] ?? '',
      baggageDescription: json['baggageDescription'] ?? '',
      baggageCharge: json['baggageCharge'] ?? '',
      currencyCode: json['currencyCode'] ?? '',
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
  final AaMealDetailsRS aaMealDetailsRS;

  MealBody({required this.aaMealDetailsRS});

  factory MealBody.fromJson(Map<String, dynamic> json) {
    return MealBody(
      aaMealDetailsRS: AaMealDetailsRS.fromJson(json['AA_OTA_AirMealDetailsRS']),
    );
  }
}

class AaMealDetailsRS {
  final Map<String, dynamic> attributes;
  final List<dynamic> success;
  final List<dynamic> warnings;
  final MealDetailsResponses mealDetailsResponses;
  final List<dynamic> errors;

  AaMealDetailsRS({
    required this.attributes,
    required this.success,
    required this.warnings,
    required this.mealDetailsResponses,
    required this.errors,
  });

  factory AaMealDetailsRS.fromJson(Map<String, dynamic> json) {
    return AaMealDetailsRS(
      attributes: json['@attributes'] ?? {},
      success: json['Success'] ?? [],
      warnings: json['Warnings'] ?? [],
      mealDetailsResponses: MealDetailsResponses.fromJson(json['MealDetailsResponses']),
      errors: json['Errors'] ?? [],
    );
  }
}

class MealDetailsResponses {
  final List<MealDetailsResponse> mealDetailsResponse;

  MealDetailsResponses({required this.mealDetailsResponse});

  factory MealDetailsResponses.fromJson(Map<String, dynamic> json) {
    final responses = json['MealDetailsResponse'] as List<dynamic>? ?? [];
    return MealDetailsResponses(
      mealDetailsResponse: responses.map((res) => MealDetailsResponse.fromJson(res)).toList(),
    );
  }
}

class MealDetailsResponse {
  final MealFlightSegmentInfo flightSegmentInfo;
  final List<MealOption> meals;

  MealDetailsResponse({
    required this.flightSegmentInfo,
    required this.meals,
  });

  factory MealDetailsResponse.fromJson(Map<String, dynamic> json) {
    final mealList = json['Meal'] as List<dynamic>? ?? [];
    return MealDetailsResponse(
      flightSegmentInfo: MealFlightSegmentInfo.fromJson(json['FlightSegmentInfo']),
      meals: mealList.map((meal) => MealOption.fromJson(meal)).toList(),
    );
  }
}

class MealFlightSegmentInfo {
  final Map<String, String> attributes;
  final AirportInfo departureAirport;
  final AirportInfo arrivalAirport;

  MealFlightSegmentInfo({
    required this.attributes,
    required this.departureAirport,
    required this.arrivalAirport,
  });

  factory MealFlightSegmentInfo.fromJson(Map<String, dynamic> json) {
    return MealFlightSegmentInfo(
      attributes: Map<String, String>.from(json['@attributes'] ?? {}),
      departureAirport: AirportInfo.fromJson(json['DepartureAirport']),
      arrivalAirport: AirportInfo.fromJson(json['ArrivalAirport']),
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
      mealCharge: json['mealCharge'] ?? '',
      mealName: json['mealName'] ?? '',
      defaultMeal: json['defaultMeal'] ?? '',
      availableMeals: json['availableMeals'] ?? '',
      soldMeals: json['soldMeals'] ?? '',
      allocatedMeals: json['allocatedMeals'] ?? '',
      mealImageLink: json['mealImageLink'] ?? '',
      mealCategoryCode: json['mealCategoryCode'] ?? '',
      currencyCode: json['currencyCode'] ?? '',
    );
  }
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