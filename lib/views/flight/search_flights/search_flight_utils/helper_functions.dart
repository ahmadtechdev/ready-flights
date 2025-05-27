// 1. First, let's update the Flight model to match the API response

import '../../../../widgets/colors.dart';
import '../../../../widgets/snackbar.dart';

import '../flight_package/sabre/sabre_flight_models.dart';



String getFareType(Map<String, dynamic> fareInfo) {
  try {
    final cabinCode = fareInfo['passengerInfoList']?[0]?['passengerInfo']
            ?['fareComponents']?[0]?['segments']?[0]?['segment']?['cabinCode']
        as String?;
    switch (cabinCode) {
      case 'C':
        return 'Business';
      case 'F':
        return 'First';
      default:
        return 'Economy';
    }
  } catch (e) {
    return 'Economy'; // Default to Economy if there's any error
  }
}

List<TaxDesc> parseTaxes(List<dynamic> taxes) {
  try {
    return taxes
        .map((tax) => TaxDesc(
              code: tax['code']?.toString() ?? 'Unknown',
              amount: (tax['amount'] is int)
                  ? tax['amount'].toDouble()
                  : (tax['amount'] as double? ?? 0.0),
              currency: tax['currency']?.toString() ?? 'PKR',
              description: tax['description']?.toString() ?? 'No description',
            ))
        .toList();
  } catch (e) {
    print('Error parsing taxes: $e');
    return [];
  }
}

BaggageAllowance parseBaggageAllowance(List<dynamic> baggageInfo) {
  try {
    if (baggageInfo.isEmpty) {
      return BaggageAllowance(
          pieces: 0, weight: 0, unit: '', type: 'Check airline policy');
    }

    // Check if we have weight-based allowance
    if (baggageInfo[0]?['allowance']?['weight'] != null) {
      return BaggageAllowance(
          pieces: 0,
          weight: (baggageInfo[0]['allowance']['weight'] as num).toDouble(),
          unit: baggageInfo[0]['allowance']['unit'] ?? 'KG',
          type:
              '${baggageInfo[0]['allowance']['weight']} ${baggageInfo[0]['allowance']['unit'] ?? 'KG'}');
    }

    // Check if we have piece-based allowance
    if (baggageInfo[0]?['allowance']?['pieceCount'] != null) {
      return BaggageAllowance(
          pieces: baggageInfo[0]['allowance']['pieceCount'] as int,
          weight: 0,
          unit: 'PC',
          type: '${baggageInfo[0]['allowance']['pieceCount']} PC');
    }

    // Default case
    return BaggageAllowance(
        pieces: 0, weight: 0, unit: '', type: 'Check airline policy');
  } catch (e) {
    print('Error parsing baggage allowance: $e');
    return BaggageAllowance(
        pieces: 0, weight: 0, unit: '', type: 'Check airline policy');
  }
}

AirlineInfo getAirlineInfo(String code, Map<String, AirlineInfo>? apiAirlineMap) {
  // First try to get from API data
  if (apiAirlineMap != null && apiAirlineMap.containsKey(code)) {
    return apiAirlineMap[code]!;
  }

  CustomSnackBar(message: 'Airlines name and logo could not be loaded from API', backgroundColor: TColors.third);

  return AirlineInfo(
      'Unknown Airline',
      'https://cdn-icons-png.flaticon.com/128/15700/15700374.png');
}





