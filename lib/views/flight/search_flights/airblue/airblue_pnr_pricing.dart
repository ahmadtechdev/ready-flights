class AirBluePNRPricing {
  final String passengerType; // ADT, CHD, INF
  final int quantity;
  final double baseFare;
  final double totalTax;
  final double totalFees;
  final double totalFare;
  final String currency;
  final List<Map<String, dynamic>> taxes;
  final List<Map<String, dynamic>> fees;

  AirBluePNRPricing({
    required this.passengerType,
    required this.quantity,
    required this.baseFare,
    required this.totalTax,
    required this.totalFees,
    required this.totalFare,
    required this.currency,
    required this.taxes,
    required this.fees,
  });

  factory AirBluePNRPricing.fromJson(Map<dynamic, dynamic> json) {
    // Safely parse passenger type and quantity
    final passengerType = json['PassengerTypeQuantity']?['Code']?.toString() ?? '';
    final quantity = int.tryParse(json['PassengerTypeQuantity']?['Quantity']?.toString() ?? '1') ?? 1;

    // Safely parse base fare
    final baseFare = double.tryParse(
      json['PassengerFare']?['BaseFare']?['Amount']?.toString() ?? '0',
    ) ?? 0.0;

    // Safely parse taxes
    double totalTax = 0.0;
    List<Map<String, dynamic>> taxList = [];
    if (json['PassengerFare']?['Taxes'] != null) {
      final taxes = json['PassengerFare']['Taxes'];
      totalTax = double.tryParse(taxes['Amount']?.toString() ?? '0') ?? 0.0;

      if (taxes['Tax'] is List) {
        taxList = List<Map<String, dynamic>>.from(taxes['Tax']);
      } else if (taxes['Tax'] is Map) {
        taxList = [Map<String, dynamic>.from(taxes['Tax'])];
      }
    }

    // Safely parse fees
    double totalFees = 0.0;
    List<Map<String, dynamic>> feeList = [];
    if (json['PassengerFare']?['Fees'] != null) {
      final fees = json['PassengerFare']['Fees'];
      totalFees = double.tryParse(fees['Amount']?.toString() ?? '0') ?? 0.0;

      if (fees['Fee'] is List) {
        feeList = List<Map<String, dynamic>>.from(fees['Fee']);
      } else if (fees['Fee'] is Map) {
        feeList = [Map<String, dynamic>.from(fees['Fee'])];
      }
    }

    // Safely parse total fare
    final totalFare = double.tryParse(
      json['PassengerFare']?['TotalFare']?['Amount']?.toString() ?? '0',
    ) ?? 0.0;

    final currency = json['PassengerFare']?['TotalFare']?['CurrencyCode']?.toString() ?? 'PKR';

    return AirBluePNRPricing(
      passengerType: passengerType,
      quantity: quantity,
      baseFare: baseFare,
      totalTax: totalTax,
      totalFees: totalFees,
      totalFare: totalFare,
      currency: currency,
      taxes: taxList,
      fees: feeList,
    );
  }

  // Add to airblue_pnr_pricing.dart
  Map<String, dynamic> toJson() {
    return {
      'passengerType': passengerType,
      'quantity': quantity,
      'baseFare': baseFare,
      'totalTax': totalTax,
      'totalFees': totalFees,
      'totalFare': totalFare,
      'currency': currency,
      'taxes': taxes,
      'fees': fees,
    };
  }
}