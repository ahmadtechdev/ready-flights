import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utility/colors.dart';
import '../../../../widgets/travelers_selection_bottom_sheet.dart';
import '../booking_flight/pia_booking_flight.dart';
import '../pia/pia_flight_model.dart';
import '../pia/pia_flight_controller.dart';
import '../search_flight_utils/widgets/pia_flight_card.dart';

class PIAReviewTripPage extends StatefulWidget {
  final PIAFlight flight;
  final bool isReturn;

  const PIAReviewTripPage({
    super.key,
    required this.flight,
    this.isReturn = false,
  });

  @override
  PIAReviewTripPageState createState() => PIAReviewTripPageState();
}

class PIAReviewTripPageState extends State<PIAReviewTripPage> {
  List<BoxShadow> _animatedShadow = [
    BoxShadow(
      color: TColors.primary.withOpacity(0.4),
      blurRadius: 5,
      spreadRadius: 8,
      offset: const Offset(0, 0),
    )
  ];
  late Timer _shadowTimer;

  final travelersController = Get.find<TravelersController>();
  final piaController = Get.find<PIAFlightController>();

  late double adultPrice;
  late double childPrice;
  late double infantPrice;
  late double totalPrice;
  late String currency;

  late double returnAdultPrice;
  late double returnChildPrice;
  late double returnInfantPrice;
  late double returnTotalPrice;
  late String returnCurrency;

  @override
  void initState() {
    super.initState();
    _startShadowAnimation();
    _calculatePrices();
  }

  void _calculatePrices() {
    // Reset all prices
    adultPrice = 0.0;
    childPrice = 0.0;
    infantPrice = 0.0;
    totalPrice = 0.0;
    currency = 'PKR';

    returnAdultPrice = 0.0;
    returnChildPrice = 0.0;
    returnInfantPrice = 0.0;
    returnTotalPrice = 0.0;
    returnCurrency = 'PKR';

    // Calculate outbound flight prices
    if (piaController.selectedOutboundFareOption != null) {
      final fareOption = piaController.selectedOutboundFareOption!;
      currency = fareOption.currency;

      // Extract prices for each passenger type from rawData
      final passengerFareInfoList = fareOption.rawData['passengerFareInfoList'];
      if (passengerFareInfoList != null) {
        final List<dynamic> fareInfos = passengerFareInfoList is List
            ? passengerFareInfoList
            : [passengerFareInfoList];

        for (var fareInfo in fareInfos) {
          final passengerType = _extractPassengerType(fareInfo);
          final pricingInfo = fareInfo['pricingInfo'] ?? {};
          final totalFare = pricingInfo['totalFare']?['amount'] ?? {};
          final priceValue = totalFare['value']?.toString() ?? '0';
          final price = double.tryParse(priceValue) ?? 0.0;

          switch (passengerType) {
            case 'ADLT':
              adultPrice = price;
              break;
            case 'CHLD':
              childPrice = price;
              break;
            case 'INFT':
              infantPrice = price;
              break;
          }
        }
      }

      // If no specific prices found, use the main price for adults
      if (adultPrice == 0.0) {
        adultPrice = fareOption.price;
      }
    }

    // Calculate return flight prices if available
    if (widget.isReturn && piaController.selectedReturnFareOption != null) {
      final returnFareOption = piaController.selectedReturnFareOption!;
      returnCurrency = returnFareOption.currency;

      // Extract prices for each passenger type from rawData
      final passengerFareInfoList = returnFareOption.rawData['passengerFareInfoList'];
      if (passengerFareInfoList != null) {
        final List<dynamic> fareInfos = passengerFareInfoList is List
            ? passengerFareInfoList
            : [passengerFareInfoList];

        for (var fareInfo in fareInfos) {
          final passengerType = _extractPassengerType(fareInfo);
          final pricingInfo = fareInfo['pricingInfo'] ?? {};
          final totalFare = pricingInfo['totalFare']?['amount'] ?? {};
          final priceValue = totalFare['value']?.toString() ?? '0';
          final price = double.tryParse(priceValue) ?? 0.0;

          switch (passengerType) {
            case 'ADLT':
              returnAdultPrice = price;
              break;
            case 'CHLD':
              returnChildPrice = price;
              break;
            case 'INF':
              returnInfantPrice = price;
              break;
          }
        }
      }

      // If no specific prices found, use the main price for adults
      if (returnAdultPrice == 0.0) {
        returnAdultPrice = returnFareOption.price;
      }
    }
  }

// Helper method to extract passenger type
  String _extractPassengerType(Map<String, dynamic> fareInfo) {
    try {
      // Try different paths to get passenger type
      if (fareInfo['passengerTypeQuantity'] != null) {
        return fareInfo['passengerTypeQuantity']?['passengerType']?['code'] ?? 'ADLT';
      }
      if (fareInfo['passengerTypeCode'] != null) {
        return fareInfo['passengerTypeCode'] ?? 'ADLT';
      }
      if (fareInfo['pricingInfo']?['passengerTypeCode'] != null) {
        return fareInfo['pricingInfo']?['passengerTypeCode'] ?? 'ADLT';
      }
    } catch (e) {
      return 'ADLT';
    }
    return 'ADLT';
  }


  void _startShadowAnimation() {
    _shadowTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      setState(() {
        _animatedShadow = _animatedShadow[0].offset.dy == 2
            ? [
          BoxShadow(
            color: TColors.primary.withOpacity(0.4),
            blurRadius: 2,
            spreadRadius: 15,
            offset: const Offset(0, 0),
          )
        ]
            : [
          BoxShadow(
            color: TColors.primary.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          )
        ];
      });
    });
  }

  @override
  void dispose() {
    _shadowTimer.cancel();
    super.dispose();
  }

  String _formatPrice(double price) {
    final parts = price.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );

    return '$formattedInteger.$decimalPart';
  }

  @override
  Widget build(BuildContext context) {
    final double combinedTotalPrice = widget.isReturn
        ? _calculateOutboundSubtotal() + _calculateInboundSubtotal()
        : _calculateOutboundSubtotal();

    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.isReturn ? 'Review Round Trip' : 'Review One Way Trip',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Outbound Flight Card
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Text(
                    'Outbound Flight',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PIAFlightCard(
                  flight: piaController.selectedOutboundFlight ?? widget.flight,
                ),
              ],
            ),

            // Return Flight Card if it's a round trip
            if (widget.isReturn && piaController.selectedReturnFlight != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 8.0),
                    child: Text(
                      'Return Flight',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  PIAFlightCard(
                    flight: piaController.selectedReturnFlight!,
                  ),
                ],
              ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Text(
                'Booking Amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            // Outbound Flight Pricing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: TColors.background,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _animatedShadow,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Outbound Flight',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (travelersController.adultCount.value > 0 && adultPrice > 0)
                      _buildPriceRow(
                        'Adult Price x ${travelersController.adultCount.value}',
                        '$currency ${_formatPrice(adultPrice * travelersController.adultCount.value)}',
                      ),
                    if (travelersController.childrenCount.value > 0 && childPrice > 0)
                      _buildPriceRow(
                        'Child Price x ${travelersController.childrenCount.value}',
                        '$currency ${_formatPrice(childPrice * travelersController.childrenCount.value)}',
                      ),
                    if (travelersController.infantCount.value > 0 && infantPrice > 0)
                      _buildPriceRow(
                        'Infant Price x ${travelersController.infantCount.value}',
                        '$currency ${_formatPrice(infantPrice * travelersController.infantCount.value)}',
                      ),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'Subtotal',
                      '$currency ${_formatPrice(_calculateOutboundSubtotal())}',
                      isSubtotal: true,
                    ),
                  ],
                ),
              ),
            ),

            // Return Flight Pricing if it's a round trip
            if (widget.isReturn && piaController.selectedReturnFareOption != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: TColors.background,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _animatedShadow,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Return Flight',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: TColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (travelersController.adultCount.value > 0)
                        _buildPriceRow(
                          'Adult Price x ${travelersController.adultCount.value}',
                          '$returnCurrency ${_formatPrice(returnAdultPrice * travelersController.adultCount.value)}',
                        ),

                      if (travelersController.childrenCount.value > 0)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildPriceRow(
                              'Child Price x ${travelersController.childrenCount.value}',
                              '$returnCurrency ${_formatPrice(returnChildPrice * travelersController.childrenCount.value)}',
                            ),
                          ],
                        ),

                      if (travelersController.infantCount.value > 0)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildPriceRow(
                              'Infant Price x ${travelersController.infantCount.value}',
                              '$returnCurrency ${_formatPrice(returnInfantPrice * travelersController.infantCount.value)}',
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),
                      _buildPriceRow(
                        'Subtotal',
                        '$returnCurrency ${_formatPrice(_calculateInboundSubtotal())}',
                        isSubtotal: true,
                      ),
                    ],
                  ),
                ),
              ),

            // Combined Total Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: TColors.background,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _animatedShadow,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _buildPriceRow(
                  'Total Amount',
                  '$currency ${_formatPrice(combinedTotalPrice)}',
                  isTotal: true,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Review Details',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: TColors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$currency ${_formatPrice(combinedTotalPrice)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => PIAFlightBookingForm(
                          flight: piaController.selectedOutboundFlight ?? widget.flight,
                          returnFlight: widget.isReturn ? piaController.selectedReturnFlight : null,
                          totalPrice: combinedTotalPrice,
                          currency: currency,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: TColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48),
                        ),
                      ),
                      child: const Text(
                        'Book',
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  // Add this helper method to calculate outbound subtotal
  double _calculateOutboundSubtotal() {
    double subtotal = 0.0;
    if (travelersController.adultCount.value > 0 && adultPrice > 0) {
      subtotal += adultPrice * travelersController.adultCount.value;
    }
    if (travelersController.childrenCount.value > 0 && childPrice > 0) {
      subtotal += childPrice * travelersController.childrenCount.value;
    }
    if (travelersController.infantCount.value > 0 && infantPrice > 0) {
      subtotal += infantPrice * travelersController.infantCount.value;
    }
    return subtotal;
  }
  double _calculateInboundSubtotal() {
    double returnedSubTotal = 0.0;
    if (travelersController.adultCount.value > 0 && returnAdultPrice > 0) {
      returnedSubTotal += returnAdultPrice * travelersController.adultCount.value;
    }
    if (travelersController.childrenCount.value > 0 && returnChildPrice > 0) {
      returnedSubTotal += returnChildPrice * travelersController.childrenCount.value;
    }
    if (travelersController.infantCount.value > 0 && returnInfantPrice > 0) {
      returnedSubTotal += returnInfantPrice * travelersController.infantCount.value;
    }
    return returnedSubTotal;
  }
  Widget _buildPriceRow(String label, String amount, {bool isTotal = false, bool isSubtotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal || isSubtotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? TColors.primary : (isSubtotal ? Colors.black : TColors.grey),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal || isSubtotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? TColors.primary : Colors.black,
          ),
        ),
      ],
    );
  }
}