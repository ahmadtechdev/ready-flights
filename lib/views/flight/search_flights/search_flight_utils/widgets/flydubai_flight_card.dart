import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ready_flights/views/flight/search_flights/flydubai/flydubai_controller.dart';

import '../../../../../utility/colors.dart';
import '../../flydubai/flydubai_model.dart';
import '../../sabre/sabre_flight_models.dart';

class FlyDubaiFlightCard extends StatefulWidget {
  final FlydubaiFlight flight;
  final bool showReturnFlight;
  final bool isShowBookButton;

  const FlyDubaiFlightCard({
    super.key,
    required this.flight,
    this.showReturnFlight = false,
    this.isShowBookButton = true,
  });

  @override
  State<FlyDubaiFlightCard> createState() => _FlyDubaiFlightCardState();
}

class _FlyDubaiFlightCardState extends State<FlyDubaiFlightCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  final FlydubaiFlightController flyDubaiController =
  Get.find<FlydubaiFlightController>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getCabinClassName(String cabinCode) {
    switch (cabinCode) {
      case 'F': return 'First Class';
      case 'C': return 'Business Class';
      case 'Y': return 'Economy Class';
      case 'W': return 'Premium Economy';
      case 'Z': return 'Business Class';
      default: return 'Economy Class';
    }
  }

  String getMealInfo(String mealCode) {
    switch (mealCode.toUpperCase()) {
      case 'P': return 'Alcoholic beverages for purchase';
      case 'C': return 'Complimentary alcoholic beverages';
      case 'B': return 'Breakfast';
      case 'K': return 'Continental breakfast';
      case 'D': return 'Dinner';
      case 'F': return 'Food for purchase';
      case 'G': return 'Food/Beverages for purchase';
      case 'M': return 'Meal';
      case 'N': return 'No meal service';
      case 'R': return 'Complimentary refreshments';
      case 'V': return 'Refreshments for purchase';
      case 'S': return 'Snack';
      default: return 'Meal included';
    }
  }

  String formatBaggageInfo() {
    if (widget.flight.baggageAllowance.pieces > 0) {
      return '${widget.flight.baggageAllowance.pieces} piece(s) included';
    } else if (widget.flight.baggageAllowance.weight > 0) {
      return '${widget.flight.baggageAllowance.weight} ${widget.flight.baggageAllowance.unit} included';
    }
    return widget.flight.baggageAllowance.type;
  }

  String formatTimeFromDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String formatFullDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('E, d MMM yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }
// Replace all the complex getter methods with simple ones:

  String getDepartureAirport() {
    return widget.flight.flightSegment.origin;
  }

  String getArrivalAirport() {
    return widget.flight.flightSegment.destination;
  }

  String getDepartureTime() {
    return DateFormat('HH:mm').format(widget.flight.flightSegment.departureDateTime);
  }

  String getArrivalTime() {
    return DateFormat('HH:mm').format(widget.flight.flightSegment.arrivalDateTime);
  }

  String getFlightNumber() {
    return widget.flight.flightSegment.flightNumber;
  }

  String getFlightDuration() {
    final duration = widget.flight.flightSegment.arrivalDateTime
        .difference(widget.flight.flightSegment.departureDateTime);
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: TColors.background,
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
        children: [
          // Main Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header with Airline Logo and Flight Info
                Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.flight.airlineImg,
                      height: 32,
                      width: 32,
                      placeholder: (context, url) => const SizedBox(
                        height: 32,
                        width: 32,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.flight,
                        size: 32,
                      ),
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.flight.airlineCode} ${getFlightNumber()}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: TColors.grey,
                          ),
                        ),
                        Text(
                          widget.flight.airlineName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Flight Details Button (replacing 30% OFF)
                    if(!widget.isShowBookButton)...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'PKR ${widget.flight.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: TColors.primary,
                            ),
                          ),
                          Container(
                            width: 60,
                            // height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2850B6),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Air Blue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]

                  ],
                ),

                const SizedBox(height: 16),

                // Flight Route Section
                Row(
                  children: [
                    // Departure
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getDepartureAirport(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            getDepartureTime(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: TColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Flight Path
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                            if (isExpanded) {
                              _controller.forward();
                            } else {
                              _controller.reverse();
                            }
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              getFlightDuration(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: TColors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: TColors.primary,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color: TColors.primary,
                                  ),
                                ),
                                const Icon(
                                  Icons.flight,
                                  size: 16,
                                  color: TColors.primary,
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color: TColors.primary,
                                  ),
                                ),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: TColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Direct',
                              style: TextStyle(
                                fontSize: 10,
                                color: TColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Arrival
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            getArrivalAirport(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            getArrivalTime(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: TColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Expanded Details Section
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFlightSegment(),


                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

        if(widget.isShowBookButton)...[
                // Bottom Section with Tags and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Flight Details Toggle

                    // Price and Airline Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Container(
                          width: 60,
                          // height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF15A29),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Fly Dubai',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PKR ${widget.flight.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: TColors.primary,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => flyDubaiController.handleFlydubaiFlightSelection(widget.flight, isReturnFlight: widget.showReturnFlight),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              TColors.primary,
                              TColors.primary.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: TColors.primary.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Book Now',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.flight_takeoff,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
        ]
              ],
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildFlightSegment() {
    final segment = widget.flight.flightSegment;
    final flightNumber = '${widget.flight.airlineCode}-${segment.flightNumber}';

    FlightSegmentInfo? segmentInfo;
    if (widget.flight.segmentInfo.isNotEmpty) {
      segmentInfo = widget.flight.segmentInfo.first;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flight_takeoff,
                size: 16,
                color: TColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Flight Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              getCabinClassName(segmentInfo?.cabinCode ?? 'Y'),
              style: const TextStyle(
                color: TColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CachedNetworkImage(
                imageUrl: widget.flight.airlineImg,
                height: 24,
                width: 24,
                placeholder: (context, url) => const SizedBox(
                  height: 24,
                  width: 24,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.flight, size: 24),
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.flight.airlineName} $flightNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment.origin,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${segment.legDetails['FromTerminal']?.toString() ?? "Main"}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      DateFormat('HH:mm').format(segment.departureDateTime),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      DateFormat('E, d MMM yyyy').format(segment.departureDateTime),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.flight, color: TColors.primary),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          size: 12,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          getMealInfo(segmentInfo?.mealCode ?? 'M'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      segment.destination,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${segment.legDetails['ToTerminal']?.toString() ?? "Main"}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      DateFormat('HH:mm').format(segment.arrivalDateTime),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      DateFormat('E, d MMM yyyy').format(segment.arrivalDateTime),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: TColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _buildFareRules() {
    return '''
• ${widget.flight.isRefundable ? 'Refundable' : 'Non-refundable'} ticket
• Date change permitted with fee
• Standard meal included
• Free seat selection
• Cabin baggage allowed
• Check-in baggage as per policy''';
  }
}