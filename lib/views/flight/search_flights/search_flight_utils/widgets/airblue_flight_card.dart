import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../utility/colors.dart';
import '../../airblue/airblue_flight_model.dart';
import '../../sabre/sabre_flight_models.dart';

class AirBlueFlightCard extends StatefulWidget {
  final AirBlueFlight flight;
  final bool showReturnFlight;

  const AirBlueFlightCard({
    super.key,
    required this.flight,
    this.showReturnFlight = true,
  });

  @override
  State<AirBlueFlightCard> createState() => _AirBlueFlightCardState();
}

class _AirBlueFlightCardState extends State<AirBlueFlightCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

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

  String getFlightDuration() {
    if (widget.flight.legSchedules.isNotEmpty) {
      final elapsedTime = widget.flight.legSchedules[0]['elapsedTime'] ?? 0;
      return '${elapsedTime ~/ 60}h ${elapsedTime % 60}m';
    }
    return 'N/A';
  }

  String getDepartureAirport() {
    if (widget.flight.legSchedules.isNotEmpty) {
      return widget.flight.legSchedules[0]['departure']['airport'] ?? 'N/A';
    }
    return 'N/A';
  }

  String getArrivalAirport() {
    if (widget.flight.legSchedules.isNotEmpty) {
      return widget.flight.legSchedules[0]['arrival']['airport'] ?? 'N/A';
    }
    return 'N/A';
  }

  String getDepartureTime() {
    if (widget.flight.legSchedules.isNotEmpty) {
      return formatTimeFromDateTime(widget.flight.legSchedules[0]['departure']['dateTime']);
    }
    return 'N/A';
  }

  String getArrivalTime() {
    if (widget.flight.legSchedules.isNotEmpty) {
      return formatTimeFromDateTime(widget.flight.legSchedules[0]['arrival']['dateTime']);
    }
    return 'N/A';
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
                      imageUrl: 'https://images.kiwi.com/airlines/64/PA.png',
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
                          'PA',
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
                    InkWell(
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    ),
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
                            'Direct 1h 30m',
                            style: TextStyle(
                              fontSize: 10,
                              color: TColors.grey,
                            ),
                          ),
                        ],
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

                const SizedBox(height: 16),

                // Bottom Section with Tags and Price
                Row(
                  children: [
                    // Best Value Tag

                    InkWell(
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Flight Details',
                              style: TextStyle(
                                fontSize: 10,
                                color: TColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 300),
                              turns: isExpanded ? 0.5 : 0,
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: TColors.primary,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
                  ],
                ),
              ],
            ),
          ),

          // Expanded Details Section (keep existing)
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.flight.stopSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = widget.flight.stopSchedules[index];

                      print("flight details schedule");
                      print(schedule);
                      return _buildFlightSegment(
                        schedule,
                        index,
                        widget.flight.stopSchedules.length,
                      );
                    },
                  ),

                  _buildSectionCard(
                    title: 'Baggage Allowance',
                    content: formatBaggageInfo(),
                    icon: Icons.luggage,
                  ),

                  _buildSectionCard(
                    title: 'Policy',
                    content: _buildFareRules(),
                    icon: Icons.rule,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFlightSegment(
      Map<String, dynamic> schedule,
      int index,
      int totalSegments,
      ) {
    final carrier = schedule['carrier'] ?? {};
    final flightNumber =
        '${carrier['marketing'] ?? 'PA'}-${carrier['marketingFlightNumber'] ?? '000'}';

    FlightSegmentInfo? segmentInfo;
    if (index < widget.flight.segmentInfo.length) {
      segmentInfo = widget.flight.segmentInfo[index];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
            index < totalSegments - 1
                ? Colors.grey[300]!
                : Colors.transparent,
            width: 1,
          ),
        ),
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
              Text(
                ' Segment ${index + 1}',
                style: const TextStyle(
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
              getCabinClassName(segmentInfo?.cabinCode ?? ''),
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
                imageUrl: "https://images.kiwi.com/airlines/64/PA.png",
                height: 24,
                width: 24,
                placeholder:
                    (context, url) => const SizedBox(
                  height: 24,
                  width: 24,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget:
                    (context, url, error) => CachedNetworkImage(
                  imageUrl:
                  'https://cdn-icons-png.flaticon.com/128/15700/15700374.png',
                  height: 24,
                  width: 24,
                  errorWidget:
                      (context, url, error) =>
                  const Icon(Icons.flight, size: 24),
                ),
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
                      schedule['departure']['airport'] ?? "UNK",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${schedule['departure']['terminal'] ?? "Main"}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      formatTimeFromDateTime(schedule['departure']['dateTime']),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formatFullDateTime(schedule['departure']['dateTime']),
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
                          getMealInfo(segmentInfo?.mealCode ?? ''),
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
                      schedule['arrival']['airport'] ?? "UNK",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${schedule['arrival']['terminal'] ?? "Main"}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      formatTimeFromDateTime(schedule['arrival']['dateTime']),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formatFullDateTime(schedule['arrival']['dateTime']),
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