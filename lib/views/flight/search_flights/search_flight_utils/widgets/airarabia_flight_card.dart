import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../utility/colors.dart';
import '../../airarabia/airarabia_flight_model.dart';

class AirArabiaFlightCard extends StatefulWidget {
  final AirArabiaFlight flight;
  final bool showReturnFlight;

  const AirArabiaFlightCard({
    super.key,
    required this.flight,
    this.showReturnFlight = true,
  });

  @override
  State<AirArabiaFlightCard> createState() => _AirArabiaFlightCardState();
}

class _AirArabiaFlightCardState extends State<AirArabiaFlightCard>
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

  String formatTimeFromDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'N/A';

    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String formatFullDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'N/A';

    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('E, d MMM yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String getCabinClassName(String cabinCode) {
    switch (cabinCode) {
      case 'F':
        return 'First Class';
      case 'C':
        return 'Business Class';
      case 'Y':
        return 'Economy Class';
      case 'W':
        return 'Premium Economy';
      default:
        return 'Economy Class';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total price - ensure it's not zero
    final price =
        widget.flight.price > 0
            ? widget.flight.price
            : (widget.flight.flightSegments.first['cabinPrices']?[0]['price']
                        as num?)
                    ?.toDouble() ??
                0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Flight Card Content - NEW DESIGN
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Row - Airline and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side - Airline info
                    Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.flight.airlineImg,
                          height: 24,
                          width: 24,
                          placeholder:
                              (context, url) => const SizedBox(
                                height: 24,
                                width: 24,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) =>
                                  const Icon(Icons.flight, size: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.flight.airlineName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    // Right side - Price and status
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
                if (widget.flight.isRoundTrip &&
                    widget.flight.outboundFlight != null)
                  _buildCompactFlightRoute(
                    segments: widget.flight.outboundFlight!['flightSegments'],
                    isReturn: true,
                  ),

                if (widget.flight.isRoundTrip &&
                    widget.flight.inboundFlight != null) ...[
                  const SizedBox(height: 12),
                  _buildCompactFlightRoute(
                    segments: widget.flight.inboundFlight!['flightSegments'],
                    isReturn: true,
                  ),
                ],

                if (!widget.flight.isRoundTrip)
                  _buildCompactFlightRoute(
                    segments: widget.flight.flightSegments,
                    isReturn: false,
                  ),

                const SizedBox(height: 16),

                // Bottom Row - Details button and Book button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Flight Details Button (replaces the discount badge)
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: TColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Flight Details',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: TColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 300),
                              turns: isExpanded ? 0.5 : 0,
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: TColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Book Now Button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDF0104),
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
                              'Air Arabia',
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

          // Expanded Details (keep existing functionality)
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flight Segments
                  for (var segment in widget.flight.flightSegments)
                    _buildDetailedFlightSegment(segment),

                  // Baggage Information
                  _buildSectionCard(
                    title: 'Baggage Allowance',
                    content: '20 KGS included',
                    icon: Icons.luggage,
                  ),

                  // Policy Information
                  _buildSectionCard(
                    title: 'Policy',
                    content: '''
• Non-refundable ticket
• Date change permitted with fee
• Standard meal included
• Free seat selection
• Cabin baggage allowed
• Check-in baggage as per policy''',
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

  Widget _buildCompactFlightRoute({
    required List<dynamic> segments,
    required bool isReturn,
  }) {
    final firstSegment = segments.first;
    final lastSegment = segments.last;
    final stopCount = segments.length - 1;

    return Row(
      children: [
        // Origin
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isReturn
                    ? firstSegment['origin']['airportCode']
                    : firstSegment['departure']?['airport'] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                isReturn
                    ? formatTimeFromDateTime(
                      firstSegment['departureDateTimeLocal'],
                    )
                    : formatTimeFromDateTime(
                      firstSegment['departure']?['dateTime'],
                    ),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Flight path with stops info
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Duration
              Text(
                _calculateCombinedDuration(firstSegment, lastSegment, isReturn),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              // Flight line with stops
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
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(0.3),
                      ),
                    ),
                  ),
                  const Icon(Icons.flight, size: 20, color: TColors.primary),
                  Expanded(
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(0.3),
                      ),
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
              // Stops info
              Text(
                stopCount == 0
                    ? 'Direct'
                    : '${stopCount} stop${stopCount > 1 ? 's' : ''}',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Destination
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isReturn
                    ? lastSegment['destination']['airportCode'] ?? 'N/A'
                    : lastSegment['arrival']['airport'] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                isReturn
                    ? formatTimeFromDateTime(
                      lastSegment['arrivalDateTimeLocal'],
                    )
                    : formatTimeFromDateTime(
                      lastSegment['arrival']?['dateTime'],
                    ),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _calculateCombinedDuration(
    Map<String, dynamic> firstSegment,
    Map<String, dynamic> lastSegment,
    bool isReturn,
  ) {
    try {
      DateTime departure;
      DateTime arrival;

      if (isReturn) {
        departure = DateTime.parse(firstSegment['departureDateTimeLocal']);
        arrival = DateTime.parse(lastSegment['arrivalDateTimeLocal']);
      } else {
        departure = DateTime.parse(firstSegment['departure']['dateTime']);
        arrival = DateTime.parse(lastSegment['arrival']['dateTime']);
      }

      final duration = arrival.difference(departure);
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildDetailedFlightSegment(Map<String, dynamic> segment) {
    final departure = segment['departure'] as Map<String, dynamic>?;
    final arrival = segment['arrival'] as Map<String, dynamic>?;

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
              Text(
                'Flight ${segment['flightNumber'] ?? 'N/A'}',
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
              getCabinClassName(widget.flight.cabinClass),
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
                placeholder:
                    (context, url) => const SizedBox(
                      height: 24,
                      width: 24,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => const Icon(Icons.flight, size: 24),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.flight.airlineName} ${segment['flightNumber'] ?? ''}',
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
                      departure?['city'] ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${departure?['terminal'] ?? 'Main'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      formatTimeFromDateTime(departure?['dateTime']),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formatFullDateTime(departure?['dateTime']),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.flight, color: TColors.primary),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      arrival?['city'] ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${arrival?['terminal'] ?? 'Main'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      formatTimeFromDateTime(arrival?['dateTime']),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formatFullDateTime(arrival?['dateTime']),
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
}
