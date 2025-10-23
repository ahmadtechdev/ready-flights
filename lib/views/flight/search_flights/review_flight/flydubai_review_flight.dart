import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../../utility/colors.dart';
import '../../booking_flight/flydubai/flydubai_booking_flight.dart';
import '../flydubai/flydubai_controller.dart';
import '../flydubai/flydubai_extras_controller.dart';
import '../flydubai/flydubai_model.dart';
import '../search_flight_utils/widgets/flydubai_flight_card.dart';

class FlyDubaiReviewTripPage extends StatefulWidget {
  final FlydubaiFlight flight;
  final bool isReturn;

  const FlyDubaiReviewTripPage({
    super.key,
    required this.flight,
    required this.isReturn,
  });

  @override
  State<FlyDubaiReviewTripPage> createState() => _FlyDubaiReviewTripPageState();
}

class _FlyDubaiReviewTripPageState extends State<FlyDubaiReviewTripPage> {
  List<BoxShadow> _animatedShadow = [
    BoxShadow(
      color: TColors.primary.withOpacity(0.4),
      blurRadius: 5,
      spreadRadius: 8,
      offset: const Offset(0, 0),
    )
  ];
  late Timer _shadowTimer;

  final flyDubaiController = Get.find<FlydubaiFlightController>();
  final extrasController = Get.find<FlydubaiExtrasController>();

  late double flightPrice;
  late double extrasPrice;
  late double totalPrice;
  String currency = 'PKR';

  @override
  void initState() {
    super.initState();
    _startShadowAnimation();
    _calculatePrices();
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

  void _calculatePrices() {
    // Base flight price
    flightPrice = widget.flight.price;
    currency = widget.flight.currency;

    // Update will be handled reactively via Obx
  }

  String _formatPrice(double price) {
    final parts = price.toStringAsFixed(0).split('.');
    final integerPart = parts[0];

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );

    return formattedInteger;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.background,
        surfaceTintColor: TColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.isReturn ? 'Review Round Trip' : 'Review Your Trip',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Flight Information Section
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                'Flight Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: TColors.primary,
                ),
              ),
            ),

            _buildFlightInfo(),

            // Selected Extras Section
            Obx(() {
              final hasExtras = extrasController.selectedBaggage.isNotEmpty ||
                  extrasController.selectedMeals.isNotEmpty ||
                  extrasController.selectedSeats.isNotEmpty;

              if (hasExtras) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, top: 8.0),
                      child: Text(
                        'Selected Extras',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: TColors.primary,
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: TColors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Selected Baggage for all passengers
                          if (extrasController.selectedBaggage.isNotEmpty)
                            ..._buildBaggageExtras(),

                          // Selected Meals for all passengers
                          if (extrasController.selectedMeals.isNotEmpty)
                            ..._buildMealExtras(),

                          // Selected Seats for all passengers
                          if (extrasController.selectedSeats.isNotEmpty)
                            ..._buildSeatExtras(),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // Price Breakdown Section
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                'Price Breakdown',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: TColors.primary,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                final totalExtras = extrasController.totalExtrasPrice.value;
                final totalAmount = flightPrice + totalExtras;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: TColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _animatedShadow,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPriceRow(
                        'Base Flight Price',
                        '$currency ${_formatPrice(flightPrice)}',
                      ),
                      if (totalExtras > 0) ...[
                        const SizedBox(height: 8),
                        _buildPriceRow(
                          'Selected Extras',
                          '$currency ${_formatPrice(totalExtras)}',
                        ),
                      ],

                      // Passenger breakdown if multiple passengers
                      if (extrasController.passengerIds.length > 1 && totalExtras > 0) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Passenger Breakdown:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: TColors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...extrasController.passengerIds.asMap().entries.map((entry) {
                          final index = entry.key;
                          final passengerId = entry.value;
                          final passengerName = extrasController.getPassengerDisplayName(index);

                          double passengerExtrasTotal = 0;
                          for (final segmentCode in extrasController.getSegmentCodes()) {
                            final baggage = extrasController.getSelectedBaggageForPassenger(segmentCode, passengerId);
                            final meal = extrasController.getSelectedMealForPassenger(segmentCode, passengerId);
                            final seat = extrasController.getSelectedSeatForPassenger(segmentCode, passengerId);

                            if (baggage != null) {
                              passengerExtrasTotal += double.tryParse(baggage['charge']?.toString() ?? '0') ?? 0;
                            }
                            if (meal != null) {
                              passengerExtrasTotal += double.tryParse(meal['charge']?.toString() ?? '0') ?? 0;
                            }
                            if (seat != null) {
                              passengerExtrasTotal += double.tryParse(seat['charge']?.toString() ?? '0') ?? 0;
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '  $passengerName extras',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: TColors.grey.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  '$currency ${_formatPrice(passengerExtrasTotal)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: TColors.grey.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],

                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildPriceRow(
                        'Total Amount',
                        '$currency ${_formatPrice(totalAmount)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                );
              }),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isReturn ? 'Round Trip Total' : 'One Way Total',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: TColors.grey),
                    ),
                    const SizedBox(height: 2),
                    Obx(() {
                      final totalAmount = flightPrice + extrasController.totalExtrasPrice.value;
                      return Text(
                        '$currency ${_formatPrice(totalAmount)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: TColors.primary,
                        ),
                      );
                    }),
                  ],
                ),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to FlyDubaiBookingFlight with all selected data
                      Get.to(() => FlyDubaiBookingFlight(
                        flight: widget.flight,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: TColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(48),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Book Now (${extrasController.passengerIds.length} pax)',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFlightInfo() {
    return FlyDubaiFlightCard(flight: widget.flight, showReturnFlight: false);
  }

  Widget _buildFlightDetail(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: TColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: TColors.primary,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBaggageExtras() {
    List<Widget> baggageWidgets = [];

    extrasController.selectedBaggage.entries.forEach((entry) {
      final key = entry.key;
      final baggage = entry.value;

      // Extract passenger info from key (format: seg{code}|p{index})
      final parts = key.split('|');
      if (parts.length == 2) {
        final passengerId = parts[1];
        final passengerIndex = extrasController.passengerIds.indexOf(passengerId);
        final passengerName = extrasController.getPassengerDisplayName(passengerIndex);

        // Only show if there's actually a charge
        final charge = double.tryParse(baggage['charge']?.toString() ?? '0') ?? 0;
        if (charge > 0) {
          baggageWidgets.add(_buildExtrasItem(
            Icons.luggage,
            'Extra Baggage - $passengerName',
            baggage['description'] ?? 'Additional baggage allowance',
            charge,
          ));
        }
      }
    });

    return baggageWidgets;
  }

  List<Widget> _buildMealExtras() {
    List<Widget> mealWidgets = [];

    extrasController.selectedMeals.entries.forEach((entry) {
      final key = entry.key;
      final meal = entry.value;

      // Extract passenger info from key (format: seg{code}|p{index})
      final parts = key.split('|');
      if (parts.length == 2) {
        final passengerId = parts[1];
        final passengerIndex = extrasController.passengerIds.indexOf(passengerId);
        final passengerName = extrasController.getPassengerDisplayName(passengerIndex);

        final charge = double.tryParse(meal['charge']?.toString() ?? '0') ?? 0;
        if (charge > 0) {
          mealWidgets.add(_buildExtrasItem(
            Icons.restaurant,
            'Meal - $passengerName',
            meal['description'] ?? meal['name'] ?? 'Special meal selection',
            charge,
          ));
        }
      }
    });

    return mealWidgets;
  }

  List<Widget> _buildSeatExtras() {
    List<Widget> seatWidgets = [];

    extrasController.selectedSeats.entries.forEach((entry) {
      final key = entry.key;
      final seat = entry.value;

      // Extract passenger info from key (format: seg{code}|p{index})
      final parts = key.split('|');
      if (parts.length == 2) {
        final passengerId = parts[1];
        final passengerIndex = extrasController.passengerIds.indexOf(passengerId);
        final passengerName = extrasController.getPassengerDisplayName(passengerIndex);

        final charge = double.tryParse(seat['charge']?.toString() ?? '0') ?? 0;
        final seatNumber = seat['seatNumber']?.toString() ?? '';

        if (charge > 0 && seatNumber.isNotEmpty) {
          seatWidgets.add(_buildExtrasItem(
            Icons.airline_seat_recline_normal,
            'Seat $seatNumber - $passengerName',
            seat['description'] ?? 'Premium seat selection',
            charge,
          ));
        }
      }
    });

    return seatWidgets;
  }

  Widget _buildExtrasItem(IconData icon, String title, String subtitle, double price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: TColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: TColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColors.primary,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: TColors.grey,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '$currency ${_formatPrice(price)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: TColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? TColors.primary : TColors.grey,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? TColors.primary : TColors.text,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    try {
      return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime.toString();
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }
}