import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../../utility/colors.dart';
import '../../../../widgets/travelers_selection_bottom_sheet.dart';
import '../airarabia/airarabia_flight_model.dart';
import '../airarabia/airarabia_flight_controller.dart';
import '../airarabia/validation_data/validation_controller.dart';
import '../search_flight_utils/widgets/airarabia_flight_card.dart';

class AirArabiaReviewTripPage extends StatefulWidget {
  final AirArabiaFlight flight;
  final AirArabiaPackage selectedPackage;
  final bool isReturn;

  const AirArabiaReviewTripPage({
    super.key,
    required this.flight,
    required this.selectedPackage,
    this.isReturn = false,
  });

  @override
  AirArabiaReviewTripPageState createState() => AirArabiaReviewTripPageState();
}

class AirArabiaReviewTripPageState extends State<AirArabiaReviewTripPage> {
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
  final airArabiaController = Get.find<AirArabiaFlightController>();
  final revalidationController = Get.find<AirArabiaRevalidationController>();

  late double flightPrice;
  late double packagePrice;
  late double extrasPrice;
  late double totalPrice;
  String currency = 'PKR';

  @override
  void initState() {
    super.initState();
    _startShadowAnimation();
    _calculatePrices();
  }

  void _calculatePrices() {
    // Base flight price
    flightPrice = widget.flight.price;
    
    // Package price (if different from base)
    packagePrice = widget.selectedPackage.totalPrice;
    
    // Calculate extras price from revalidation controller
    extrasPrice = revalidationController.totalExtrasPrice.value;
    
    // Total price calculation
    totalPrice = flightPrice + packagePrice + extrasPrice;
    
    currency = widget.flight.currency;
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
            
            // Flight Card - Using AirArabiaFlightCard if available, otherwise create custom
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
                  // Flight number and airline
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: TColors.primary.withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.flight,
                          color: TColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.flight.airlineName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: TColors.primary,
                              ),
                            ),
                            Text(
                              'Flight ${widget.flight.flightSegments.first['flightNumber']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: TColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Flight route information
                  ...widget.flight.flightSegments.map((segment) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // Departure
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  segment['departure']['airport'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: TColors.primary,
                                  ),
                                ),
                                Text(
                                  _formatDateTime(segment['departure']['dateTime']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: TColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Flight duration and arrow
                          Column(
                            children: [
                              const Icon(
                                Icons.flight_takeoff,
                                color: TColors.primary,
                                size: 20,
                              ),
                              Text(
                                _formatDuration(segment['elapsedTime']),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: TColors.grey,
                                ),
                              ),
                            ],
                          ),
                          
                          // Arrival
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  segment['arrival']['airport'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: TColors.primary,
                                  ),
                                ),
                                Text(
                                  _formatDateTime(segment['arrival']['dateTime']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: TColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            // Selected Package Section
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                'Selected Package',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: TColors.primary,
                ),
              ),
            ),
            
            Container(
              margin: const EdgeInsets.all(16),
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
                children: [
                  // Package header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getPackageColor(widget.selectedPackage.packageType),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.selectedPackage.packageName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TColors.white,
                            ),
                          ),
                        ),
                        Text(
                          '$currency ${_formatPrice(widget.selectedPackage.totalPrice)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: TColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Package details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildPackageDetail(Icons.luggage, 'Checked Baggage', widget.selectedPackage.baggageAllowance),
                        _buildPackageDetail(Icons.restaurant, 'Meals', widget.selectedPackage.mealInfo),
                        _buildPackageDetail(Icons.airline_seat_recline_normal, 'Seats', widget.selectedPackage.seatInfo),
                        _buildPackageDetail(Icons.change_circle, 'Modification', widget.selectedPackage.modificationPolicy),
                        _buildPackageDetail(Icons.cancel, 'Cancellation', widget.selectedPackage.cancellationPolicy),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Selected Extras Section
            Obx(() {
              if (revalidationController.totalExtrasPrice.value > 0) {
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
                        children: [
                          // Selected Baggage
                          if (revalidationController.selectedBaggage.isNotEmpty)
                            ...revalidationController.selectedBaggage.entries.map((entry) {
                              final baggage = entry.value;
                              return _buildExtrasItem(
                                Icons.luggage,
                                'Extra Baggage',
                                baggage.baggageDescription,
                                baggage.baggageCharge as double,
                              );
                            }).toList(),
                          
                          // Selected Meals
                          if (revalidationController.selectedMeals.isNotEmpty)
                            ...revalidationController.selectedMeals.entries.expand((segmentEntry) {
                              return segmentEntry.value.map((meal) {
                                return _buildExtrasItem(
                                  Icons.restaurant,
                                  'Meal',
                                  meal.mealName,
                                  meal.mealCharge as double,
                                );
                              });
                            }).toList(),
                          
                          // Selected Seats
                          if (revalidationController.selectedSeats.isNotEmpty)
                            ...revalidationController.selectedSeats.entries.map((entry) {
                              final seat = entry.value;
                              if (seat.seatNumber.isNotEmpty) {
                                return _buildExtrasItem(
                                  Icons.airline_seat_recline_normal,
                                  'Seat ${seat.seatNumber}',
                                  'Premium seat selection',
                                  seat.seatCharge,
                                );
                              }
                              return const SizedBox.shrink();
                            }).toList(),
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
              child: AnimatedContainer(
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
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'Package (${widget.selectedPackage.packageName})',
                      packagePrice > 0 ? '$currency ${_formatPrice(packagePrice)}' : 'Included',
                    ),
                    Obx(() {
                      if (revalidationController.totalExtrasPrice.value > 0) {
                        return Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildPriceRow(
                              'Extras',
                              '$currency ${_formatPrice(revalidationController.totalExtrasPrice.value)}',
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Obx(() => _buildPriceRow(
                      'Total Amount',
                      '$currency ${_formatPrice(flightPrice + packagePrice + revalidationController.totalExtrasPrice.value)}',
                      isTotal: true,
                    )),
                  ],
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isReturn ? 'Round Trip Total' : 'One Way Total',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: TColors.grey
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                      '$currency ${_formatPrice(flightPrice + packagePrice + revalidationController.totalExtrasPrice.value)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: TColors.primary,
                      ),
                    )),
                  ],
                ),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to AirArabiaBookingFlight with all selected data
                      // Get.to(() => AirArabiaBookingFlight(
                      //   flight: widget.flight,
                      //   selectedPackage: widget.selectedPackage,
                      //   totalPrice: flightPrice + packagePrice + revalidationController.totalExtrasPrice.value,
                      //   currency: currency,
                      // ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: TColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(48),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold
                      ),
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

  Widget _buildPackageDetail(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: TColors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: TColors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TColors.text,
            ),
          ),
        ],
      ),
    );
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

  Color _getPackageColor(String packageType) {
    switch (packageType.toLowerCase()) {
      case 'basic':
        return TColors.primary;
      case 'value':
        return Colors.blue;
      case 'ultimate':
        return Colors.purple;
      default:
        return TColors.primary;
    }
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }
}