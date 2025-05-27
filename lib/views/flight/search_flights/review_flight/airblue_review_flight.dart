import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../../utility/colors.dart';
import '../../../../widgets/travelers_selection_bottom_sheet.dart';
import '../../form/travelers/traveler_controller.dart';
import '../booking_flight/airblue_booking_flight.dart';
import '../booking_flight/booking_flight.dart';
import '../flight_package/airblue/airblue_flight_model.dart';
import '../flight_package/airblue/airblue_flight_controller.dart';
import '../search_flight_utils/widgets/airblue_flight_card.dart';

class AirBlueReviewTripPage extends StatefulWidget {
  final AirBlueFlight flight;
  final bool isReturn;

  const AirBlueReviewTripPage({
    super.key,
    required this.flight,
    this.isReturn = false,
  });

  @override
  AirBlueReviewTripPageState createState() => AirBlueReviewTripPageState();
}

class AirBlueReviewTripPageState extends State<AirBlueReviewTripPage> {
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
  final airBlueController = Get.find<AirBlueFlightController>();

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
    // Calculate outbound flight prices
    adultPrice = 0.0;
    childPrice = 0.0;
    infantPrice = 0.0;
    totalPrice = 0.0;
    currency = 'PKR';

    final ptcFareBreakdowns = airBlueController.selectedOutboundFareOption!.pricingInfo['PTC_FareBreakdowns']['PTC_FareBreakdown'];

    if (ptcFareBreakdowns is List) {
      for (var breakdown in ptcFareBreakdowns) {
        final passengerType = breakdown['PassengerTypeQuantity']['Code'];
        final passengerFare = breakdown['PassengerFare'];
        final price = double.tryParse(passengerFare['TotalFare']['Amount'].toString()) ?? 0.0;
        currency = passengerFare['TotalFare']['CurrencyCode'] ?? 'PKR';

        if (passengerType == 'ADT') {
          adultPrice = price;
        } else if (passengerType == 'CHD') {
          childPrice = price;
        } else if (passengerType == 'INF') {
          infantPrice = price;
        }

        totalPrice += price;
      }
    } else if (ptcFareBreakdowns is Map) {
      final passengerType = ptcFareBreakdowns['PassengerTypeQuantity']['Code'];
      final passengerFare = ptcFareBreakdowns['PassengerFare'];
      final price = double.tryParse(passengerFare['TotalFare']['Amount'].toString()) ?? 0.0;
      currency = passengerFare['TotalFare']['CurrencyCode'] ?? 'PKR';

      if (passengerType == 'ADT') {
        adultPrice = price;
      } else if (passengerType == 'CHD') {
        childPrice = price;
      } else if (passengerType == 'INF') {
        infantPrice = price;
      }

      totalPrice = price;
    }

    // Calculate return flight prices if available
    if (widget.isReturn && airBlueController.selectedReturnFareOption != null) {
      returnAdultPrice = 0.0;
      returnChildPrice = 0.0;
      returnInfantPrice = 0.0;
      returnTotalPrice = 0.0;
      returnCurrency = 'PKR';

      final returnPtcFareBreakdowns = airBlueController.selectedReturnFareOption!.pricingInfo['PTC_FareBreakdowns']['PTC_FareBreakdown'];

      if (returnPtcFareBreakdowns is List) {
        for (var breakdown in returnPtcFareBreakdowns) {
          final passengerType = breakdown['PassengerTypeQuantity']['Code'];
          final passengerFare = breakdown['PassengerFare'];
          final price = double.tryParse(passengerFare['TotalFare']['Amount'].toString()) ?? 0.0;
          returnCurrency = passengerFare['TotalFare']['CurrencyCode'] ?? 'PKR';

          if (passengerType == 'ADT') {
            returnAdultPrice = price;
          } else if (passengerType == 'CHD') {
            returnChildPrice = price;
          } else if (passengerType == 'INF') {
            returnInfantPrice = price;
          }

          returnTotalPrice += price;
        }
      } else if (returnPtcFareBreakdowns is Map) {
        final passengerType = returnPtcFareBreakdowns['PassengerTypeQuantity']['Code'];
        final passengerFare = returnPtcFareBreakdowns['PassengerFare'];
        final price = double.tryParse(passengerFare['TotalFare']['Amount'].toString()) ?? 0.0;
        returnCurrency = passengerFare['TotalFare']['CurrencyCode'] ?? 'PKR';

        if (passengerType == 'ADT') {
          returnAdultPrice = price;
        } else if (passengerType == 'CHD') {
          returnChildPrice = price;
        } else if (passengerType == 'INF') {
          returnInfantPrice = price;
        }

        returnTotalPrice = price;
      }
    }
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
        ? totalPrice + returnTotalPrice
        : totalPrice;

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
                // if (airBlueController.selectedOutboundFlight != null)
                  AirBlueFlightCard(
                    flight: airBlueController.selectedOutboundFlight ?? widget.flight,
                  ),

              ],
            ),

            // Return Flight Card if it's a round trip
            if (widget.isReturn && airBlueController.selectedReturnFlight != null)
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
                  AirBlueFlightCard(
                    flight: airBlueController.selectedReturnFlight!,
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
                    if (travelersController.adultCount.value > 0)
                      _buildPriceRow(
                        'Adult Price x ${travelersController.adultCount.value}',
                        '$currency ${_formatPrice(adultPrice * travelersController.adultCount.value)}',
                      ),

                    if (travelersController.childrenCount.value > 0)
                      Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildPriceRow(
                            'Child Price x ${travelersController.childrenCount.value}',
                            '$currency ${_formatPrice(childPrice * travelersController.childrenCount.value)}',
                          ),
                        ],
                      ),

                    if (travelersController.infantCount.value > 0)
                      Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildPriceRow(
                            'Infant Price x ${travelersController.infantCount.value}',
                            '$currency ${_formatPrice(infantPrice * travelersController.infantCount.value)}',
                          ),
                        ],
                      ),

                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'Subtotal',
                      '$currency ${_formatPrice(totalPrice)}',
                      isSubtotal: true,
                    ),
                  ],
                ),
              ),
            ),

            // Return Flight Pricing if it's a round trip
            if (widget.isReturn && airBlueController.selectedReturnFareOption != null)
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
                        '$returnCurrency ${_formatPrice(returnTotalPrice)}',
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
                      Text(
                        widget.isReturn ? 'Round Trip Total' : 'One Way Total',
                        style: const TextStyle(
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
                        // Get.to(() => BookingForm(
                        //   flight: widget.flight,
                        //   returnFlight: widget.isReturn ? airBlueController.selectedReturnFlight : null,
                        // ));
                        Get.to(() => AirBlueBookingFlight(
                          flight: airBlueController.selectedOutboundFlight ?? widget.flight,
                          returnFlight: widget.isReturn ? airBlueController.selectedReturnFlight : null,
                          totalPrice: combinedTotalPrice,
                          currency: currency,
                        ));

                        Get.snackbar("Its working ","you are amazing ");
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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