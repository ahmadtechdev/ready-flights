// views/flight/search_flights/emirates_ndc/emirates_review_trip.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:ready_flights/views/flight/booking_flight/emirates%20_ndc/emirates_ndc_booking_flight.dart';
import 'package:ready_flights/views/flight/search_flights/emirates_ndc/emirates_flight_controller.dart';
import 'package:ready_flights/views/flight/search_flights/emirates_ndc/emirates_model.dart';
import '../../../../utility/colors.dart';
import '../../../../widgets/travelers_selection_bottom_sheet.dart';

class EmiratesReviewTripPage extends StatefulWidget {
  final EmiratesFlight flight;
  final EmiratesFarePackage selectedPackage;
  final bool isReturn;

  const EmiratesReviewTripPage({
    super.key,
    required this.flight,
    required this.selectedPackage,
    this.isReturn = false,
  });

  @override
  EmiratesReviewTripPageState createState() => EmiratesReviewTripPageState();
}

class EmiratesReviewTripPageState extends State<EmiratesReviewTripPage> {
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
  final emiratesController = Get.find<EmiratesFlightController>();

  @override
  void initState() {
    super.initState();
    _startShadowAnimation();
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

  double get totalPrice {
    final adults = travelersController.adultCount.value;
    final children = travelersController.childrenCount.value;
    final infants = travelersController.infantCount.value;
    
    return widget.selectedPackage.price * (adults + children + infants);
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
        title: const Text(
          'Review Trip',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            // Flight Card
            _buildFlightCard(),
            
            // Selected Package Info
            _buildPackageInfo(),
            
            // Pricing Breakdown
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
            
            _buildPricingCard(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildFlightCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.secondary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CachedNetworkImage(
                imageUrl: widget.flight.airlineImg,
                height: 40,
                width: 40,
                placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                errorWidget: (context, url, error) => const Icon(Icons.flight, size: 40),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EK-${widget.flight.flightNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.selectedPackage.cabinName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Flight Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAirportInfo(
                widget.flight.legSchedules.first['departure']['airport'],
                widget.flight.legSchedules.first['departure']['time'],
                widget.flight.departureDate,
                true,
              ),
              Column(
                children: [
                  const Icon(Icons.flight, color: TColors.primary),
                  const SizedBox(height: 4),
                  Text(
                    _getFlightDuration(),
                    style: const TextStyle(fontSize: 12, color: TColors.grey),
                  ),
                  Text(
                    _getStopsText(),
                    style: const TextStyle(fontSize: 10, color: TColors.grey),
                  ),
                ],
              ),
              _buildAirportInfo(
                widget.flight.legSchedules.last['arrival']['airport'],
                widget.flight.legSchedules.last['arrival']['time'],
                widget.flight.legSchedules.last['arrival']['date'],
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAirportInfo(String airport, String time, String date, bool isDeparture) {
    return Column(
      crossAxisAlignment: isDeparture ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          airport,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _formatTime(time),
          style: const TextStyle(
            fontSize: 14,
            color: TColors.grey,
          ),
        ),
        Text(
          _formatDate(date),
          style: const TextStyle(
            fontSize: 12,
            color: TColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Package',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildPackageDetail(Icons.luggage, 'Baggage', 
              '${widget.selectedPackage.checkedWeight.toStringAsFixed(0)} ${widget.selectedPackage.checkedUnit}'),
          const SizedBox(height: 8),
          _buildPackageDetail(Icons.restaurant, 'Meal', 'Included'),
          const SizedBox(height: 8),
          _buildPackageDetail(Icons.swap_horiz, 'Changes', 
              widget.selectedPackage.isRefundable ? 'Allowed' : 'Not Allowed'),
          const SizedBox(height: 8),
          _buildPackageDetail(Icons.money_off, 'Refund', 
              widget.selectedPackage.isRefundable ? 'Allowed' : 'Not Allowed'),
        ],
      ),
    );
  }

  Widget _buildPackageDetail(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: TColors.primary),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: const TextStyle(fontSize: 14, color: TColors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPricingCard() {
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
              widget.selectedPackage.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: TColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            
            if (travelersController.adultCount.value > 0)
              _buildPriceRow(
                'Adult Price x ${travelersController.adultCount.value}',
                '${widget.selectedPackage.currency} ${_formatPrice(widget.selectedPackage.price * travelersController.adultCount.value)}',
              ),
            
            if (travelersController.childrenCount.value > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                'Child Price x ${travelersController.childrenCount.value}',
                '${widget.selectedPackage.currency} ${_formatPrice(widget.selectedPackage.price * travelersController.childrenCount.value)}',
              ),
            ],
            
            if (travelersController.infantCount.value > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                'Infant Price x ${travelersController.infantCount.value}',
                '${widget.selectedPackage.currency} ${_formatPrice(widget.selectedPackage.price * travelersController.infantCount.value)}',
              ),
            ],
            
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            
            _buildPriceRow(
              'Total Amount',
              '${widget.selectedPackage.currency} ${_formatPrice(totalPrice)}',
              isTotal: true,
            ),
          ],
        ),
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
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? TColors.primary : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Column(
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
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: TColors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.selectedPackage.currency} ${_formatPrice(totalPrice)}',
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
                    Get.to(() => EmiratesNdcBookingFlight(
                      flight: widget.flight,
                      selectedPackage: widget.selectedPackage,
                      totalPrice: totalPrice,
                      currency: widget.selectedPackage.currency,
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
                    'Continue to Book',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
      ],
    );
  }

  String _getFlightDuration() {
    if (widget.flight.legSchedules.isNotEmpty) {
      final elapsedTime = widget.flight.legSchedules[0]['elapsedTime'] ?? 0;
      return '${elapsedTime ~/ 60}h ${elapsedTime % 60}m';
    }
    return 'N/A';
  }

  String _getStopsText() {
    final stops = widget.flight.legSchedules.length - 1;
    if (stops == 0) return 'Non-stop';
    return '$stops Stop${stops > 1 ? 's' : ''}';
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('EEE, d MMM').format(dateTime);
    } catch (e) {
      return date;
    }
  }
}