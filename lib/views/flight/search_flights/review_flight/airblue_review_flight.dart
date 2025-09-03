import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../../utility/colors.dart';
import '../../../../widgets/travelers_selection_bottom_sheet.dart';
import '../../booking_flight/airblue/airblue_booking_flight.dart';
import '../airblue/airblue_flight_model.dart';
import '../airblue/airblue_flight_controller.dart';
import '../search_flight_utils/widgets/airblue_flight_card.dart';

class AirBlueReviewTripPage extends StatefulWidget {
  final AirBlueFlight flight;
  final bool isReturn;
  final bool isMulticity;
  final List<AirBlueFlight>? multicityFlights;
  final List<AirBlueFareOption?>? multicityFareOptions;

  const AirBlueReviewTripPage({
    super.key,
    required this.flight,
    this.isReturn = false,
    this.isMulticity = false,
    this.multicityFlights,
    this.multicityFareOptions
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

  late List<double> adultPrices = [];
  late List<double> childPrices = [];
  late List<double> infantPrices = [];
  late List<double> flightPrices = [];
  late List<String> currencies = [];

  @override
  void initState() {
    super.initState();
    _startShadowAnimation();
    _calculatePrices();
  }

  void _calculatePrices() {
    adultPrices.clear();
    childPrices.clear();
    infantPrices.clear();
    flightPrices.clear();
    currencies.clear();

    // Calculate prices for outbound flight (only if not multicity)
    if (!widget.isMulticity && airBlueController.selectedOutboundFareOption != null) {
      _calculateFlightPrices(airBlueController.selectedOutboundFareOption!, 0);
    }

    // Calculate prices for return flight if it's a round trip
    if (widget.isReturn && airBlueController.selectedReturnFareOption != null) {
      _calculateFlightPrices(airBlueController.selectedReturnFareOption!, 1);
    }

    // Calculate prices for multicity flights if it's a multicity trip
    if (widget.isMulticity && airBlueController.selectedMultiCityFareOptions != null) {
      // Only process the actual number of multicity flights we have
      for (int i = 0; i < airBlueController.selectedMultiCityFareOptions!.length; i++) {
        _calculateFlightPrices(airBlueController.selectedMultiCityFareOptions![i], i);
      }
    }
  }

  void _calculateFlightPrices(dynamic fareOption, int index) {
    double adultPrice = 0.0;
    double childPrice = 0.0;
    double infantPrice = 0.0;
    double totalPrice = 0.0;
    String currency = 'PKR';

    final ptcFareBreakdowns = fareOption.pricingInfo['PTC_FareBreakdowns']['PTC_FareBreakdown'] ?? "";

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

    // Ensure we have enough elements in the lists
    while (adultPrices.length <= index) adultPrices.add(0.0);
    while (childPrices.length <= index) childPrices.add(0.0);
    while (infantPrices.length <= index) infantPrices.add(0.0);
    while (flightPrices.length <= index) flightPrices.add(0.0);
    while (currencies.length <= index) currencies.add('PKR');

    adultPrices[index] = adultPrice;
    childPrices[index] = childPrice;
    infantPrices[index] = infantPrice;
    flightPrices[index] = totalPrice;
    currencies[index] = currency;
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

  String _getFlightTitle(int index) {
    if (widget.isMulticity) return 'Flight ${index + 1}'; // Changed for multicity
    if (index == 0) return 'Outbound Flight';
    if (widget.isReturn && index == 1) return 'Return Flight';
    return 'Flight';
  }

// ... (keep the rest of the code the same)

  double get combinedTotalPrice {
    return flightPrices.fold(0.0, (sum, price) => sum + price);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.isMulticity
              ? 'Review Multicity Trip'
              : widget.isReturn
              ? 'Review Round Trip'
              : 'Review One Way Trip',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Only show Outbound Flight if it's not multicity
            if (!widget.isMulticity)
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
                  AirBlueFlightCard(
                    flight: airBlueController.selectedOutboundFlight ?? widget.flight,
                      isShowBookButton:false
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
                      isShowBookButton:false
                  ),
                ],
              ),

            // Multicity Flight Cards if it's a multicity trip
            // In the build method, update the multicity flights section:
            if (widget.isMulticity && airBlueController.selectedMultiCityFlights != null)
              ...airBlueController.selectedMultiCityFlights!.asMap().entries.map((entry) {
                final index = entry.key;
                final flight = entry.value;
                // Only show if we have pricing data for this flight
                if (index < flightPrices.length) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: Text(
                          'Flight ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      AirBlueFlightCard(
                        flight: flight!,
                          isShowBookButton:false
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
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

            // Flight Pricing Sections
            ...flightPrices.asMap().entries.map((entry) {
              final index = entry.key;
              return Padding(
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
                      Text(
                        _getFlightTitle(index),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: TColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (travelersController.adultCount.value > 0)
                        _buildPriceRow(
                          'Adult Price x ${travelersController.adultCount.value}',
                          '${currencies[index]} ${_formatPrice(adultPrices[index] * travelersController.adultCount.value)}',
                        ),

                      if (travelersController.childrenCount.value > 0)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildPriceRow(
                              'Child Price x ${travelersController.childrenCount.value}',
                              '${currencies[index]} ${_formatPrice(childPrices[index] * travelersController.childrenCount.value)}',
                            ),
                          ],
                        ),

                      if (travelersController.infantCount.value > 0)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildPriceRow(
                              'Infant Price x ${travelersController.infantCount.value}',
                              '${currencies[index]} ${_formatPrice(infantPrices[index] * travelersController.infantCount.value)}',
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),
                      _buildPriceRow(
                        'Subtotal',
                        '${currencies[index]} ${_formatPrice(flightPrices[index])}',
                        isSubtotal: true,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

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
                  '${currencies.isNotEmpty ? currencies[0] : 'PKR'} ${_formatPrice(combinedTotalPrice)}',
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
                        widget.isMulticity
                            ? 'Multicity Total'
                            : widget.isReturn
                            ? 'Round Trip Total'
                            : 'One Way Total',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: TColors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${currencies.isNotEmpty ? currencies[0] : 'PKR'} ${_formatPrice(combinedTotalPrice)}',
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
                        Get.to(() => AirBlueBookingFlight(
                          flight: airBlueController.selectedOutboundFlight ?? widget.flight,
                          returnFlight: widget.isReturn ? airBlueController.selectedReturnFlight : null,
                          multicityFlights: widget.multicityFlights ,
                          totalPrice: combinedTotalPrice,
                          currency: currencies.isNotEmpty ? currencies[0] : 'PKR',
                          outboundFareOption: airBlueController.selectedOutboundFareOption,
                          returnFareOption: airBlueController.selectedReturnFareOption,
                          multicityFareOptions: widget.multicityFareOptions,
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