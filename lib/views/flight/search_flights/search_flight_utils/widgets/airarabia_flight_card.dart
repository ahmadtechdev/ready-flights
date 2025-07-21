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
    // Get origin and destination from the first and last segments
    final origin =
        widget.flight.flightSegments.first['departure']?['airport'] ?? 'N/A';
    final destination =
        widget.flight.flightSegments.last['arrival']?['airport'] ?? 'N/A';
    final stops = widget.flight.flightSegments.length - 1;

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
          // Main Flight Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Airline and Price Row
                Row(
                  children: [
                    // Airline Info
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (
                              var i = 0;
                              i < widget.flight.flightSegments.length;
                              i++
                            )
                              Row(
                                children: [
                                  if (i > 0)
                                    Container(
                                      height: 40,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      color: TColors.grey.withOpacity(0.3),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Flight ${i + 1}",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: TColors.third,
                                          ),
                                        ),
                                        Text(
                                          widget.flight.airlineName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.flight.airlineCode,
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Price Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: TColors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: TColors.black.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'PKR ${widget.flight.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: TColors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                Column(
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    // Outbound Flight
                    if (widget.flight.isRoundTrip && widget.flight.outboundFlight != null)
                      _buildFlightLegSection(
                        title: 'Outbound: ${widget.flight.flightSegments.first['departure']?['airport']} → '
                            '${widget.flight.flightSegments.first['arrival']?['airport']}',
                        segments: widget.flight.outboundFlight!['flightSegments'], isReturn: widget.flight.isRoundTrip,
                      ),

                    // Inbound Flight
                    if (widget.flight.isRoundTrip && widget.flight.inboundFlight != null)
                      _buildFlightLegSection(
                        title: 'Inbound: ${widget.flight.flightSegments.last['departure']?['airport']} → '
                            '${widget.flight.flightSegments.last['arrival']?['airport']}',
                        segments: widget.flight.inboundFlight!['flightSegments'], isReturn: widget.flight.isRoundTrip,
                      ),

                    // For one-way flights
                    if (!widget.flight.isRoundTrip)
                      _buildFlightLegSection(
                        title: 'Flight',
                        segments: widget.flight.flightSegments, isReturn: widget.flight.isRoundTrip,
                      ),
                  ],
                )
              ],
            ),
          ),

          // Expand/Collapse Button
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Flight Details',
                        style: TextStyle(
                          color: TColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: isExpanded ? 0.5 : 0,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: TColors.primary,
                        ),
                      ),
                    ],
                  ),
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
                  ElevatedButton(
                    onPressed: () {
                      // Add booking functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      "Book Now",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Details
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
  Widget _buildFlightLegSection({
    required String title,
    required List<dynamic> segments,
    required bool isReturn,
  }) {
    // Get origin from first segment and destination from last segment
    final origin = segments.first['origin']?['airportCode'] ?? 'N/A';
    final destination = segments.last['destination']?['airportCode'] ?? 'N/A';

    // Calculate stop count and layover cities
    final stopCount = segments.length - 1;
    final stopCities = stopCount > 0
        ? segments.sublist(0, segments.length - 1)
        .map((s) => s['destination']?['airportCode'] ?? '')
        .where((city) => city.isNotEmpty)
        .join(', ')
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 8.0),
        //   child: Text(
        //     // '$title: $origin → $destination',
        //     '',
        //     style: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       color: TColors.primary,
        //     ),
        //   ),
        // ),
        // Show only the first and last segments combined
        _buildCombinedFlightSegment(
          firstSegment: segments.first,
          lastSegment: segments.last,
          stopCount: stopCount,
          stopCities: stopCities, 
            isReturn: isReturn
        ),
        // if (stopCount > 0)
        //   Padding(
        //     padding: const EdgeInsets.symmetric(vertical: 4.0),
        //     child: Text(
        //       '${stopCount} Stop${stopCount > 1 ? 's' : ''}${stopCities.isNotEmpty ? ' via $stopCities' : ''} • Layover: ${_calculateLayoverTime(segments)}',
        //       style: TextStyle(
        //         fontSize: 12,
        //         color: TColors.grey,
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildCombinedFlightSegment({
    required Map<String, dynamic> firstSegment,
    required Map<String, dynamic> lastSegment,
    required int stopCount,
    required String stopCities,
    required isReturn,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Airline Logo
          CachedNetworkImage(
            imageUrl: widget.flight.airlineImg,
            height: 32,
            width: 32,
            placeholder: (context, url) => const SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.flight, size: 24),
          ),

          SizedBox(
            width: 6,
          ),

          // Departure Info (from first segment)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isReturn
                          ? formatTimeFromDateTime(firstSegment['departureDateTimeLocal'])
                          : formatTimeFromDateTime(firstSegment['departure']?['dateTime']),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isReturn
                          ? firstSegment['origin']['airportCode']
                          : firstSegment['departure']?['airport'],
                      style: const TextStyle(
                        color: TColors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // Flight Duration
                Column(
                  children: [
                    Text(
                      _calculateCombinedDuration(firstSegment, lastSegment, isReturn),
                      style: const TextStyle(
                        color: TColors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width * 0.4,
                          color: Colors.grey[300],
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      stopCount == 0 ? 'Nonstop' : '${stopCount} Stop${stopCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.grey,
                      ),
                    ),
                    if(stopCount > 0)...[
                      Text(
                        stopCities.isNotEmpty ? ' via $stopCities' : '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: TColors.grey,
                        ),
                      ),
                    ]
                  ],
                ),

                // Arrival Info (from last segment)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isReturn
                          ? formatTimeFromDateTime(lastSegment['arrivalDateTimeLocal'])
                          : formatTimeFromDateTime(lastSegment['arrival']?['dateTime']),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isReturn
                          ? lastSegment['destination']['airportCode'] ?? 'N/A'
                          : lastSegment['arrival']['airport'] ?? 'N/A',
                      style: const TextStyle(
                        color: TColors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  String _calculateCombinedDuration(
      Map<String, dynamic> firstSegment,
      Map<String, dynamic> lastSegment,
      bool isReturn
      ) {
    try {
      DateTime departure;
      DateTime arrival;

      if (isReturn) {
        // For return flights: use direct fields
        departure = DateTime.parse(firstSegment['departureDateTimeLocal']);
        arrival = DateTime.parse(lastSegment['arrivalDateTimeLocal']);
      } else {
        // For regular flights: use nested objects
        departure = DateTime.parse(firstSegment['departure']['dateTime']);
        arrival = DateTime.parse(lastSegment['arrival']['dateTime']);
      }

      final duration = arrival.difference(departure);
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } catch (e) {
      return 'N/A';
    }
  }

  // String _calculateLayoverTime(List<dynamic> segments) {
  //   if (segments.length < 2) return 'No layover';
  //
  //   try {
  //     Duration totalLayover = Duration.zero;
  //
  //     for (int i = 0; i < segments.length - 1; i++) {
  //       final currentArrival = DateTime.parse(segments[i]['arrivalDateTimeLocal']);
  //       final nextDeparture = DateTime.parse(segments[i+1]['departureDateTimeLocal']);
  //       totalLayover += nextDeparture.difference(currentArrival);
  //     }
  //
  //     return '${totalLayover.inHours}h ${totalLayover.inMinutes.remainder(60)}m';
  //   } catch (e) {
  //     return 'N/A';
  //   }
  // }
  Widget _buildFlightSegment(Map<String, dynamic> segment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Airline Logo
          CachedNetworkImage(
            imageUrl: widget.flight.airlineImg,
            height: 32,
            width: 32,
            placeholder: (context, url) => const SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.flight, size: 24),
          ),

          // Departure Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatTimeFromDateTime(segment['departureDateTimeLocal']),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                segment['origin']?['airportCode'] ?? 'N/A',
                style: const TextStyle(
                  color: TColors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Flight Duration
          Column(
            children: [
              Text(
                _calculateSegmentDuration(segment),
                style: const TextStyle(
                  color: TColors.grey,
                  fontSize: 12,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width * 0.2,
                    color: Colors.grey[300],
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                segment == widget.flight.flightSegments.first &&
                    segment == widget.flight.flightSegments.last
                    ? 'Nonstop'
                    : '${widget.flight.flightSegments.length - 1} Stop',
                style: const TextStyle(
                  fontSize: 12,
                  color: TColors.grey,
                ),
              ),
            ],
          ),

          // Arrival Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatTimeFromDateTime(segment['arrivalDateTimeLocal']),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                segment['destination']?['airportCode'] ?? 'N/A',
                style: const TextStyle(
                  color: TColors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  String _calculateSegmentDuration(Map<String, dynamic> segment) {
    try {
      final departure = DateTime.parse(segment['departureDateTimeLocal']);
      final arrival = DateTime.parse(segment['arrivalDateTimeLocal']);
      final duration = arrival.difference(departure);
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } catch (e) {
      return 'N/A';
    }
  }

  String _calculateLayoverTime(List<dynamic> segments) {
    if (segments.length < 2) return 'No layover';

    try {
      Duration totalLayover = Duration.zero;

      for (int i = 0; i < segments.length - 1; i++) {
        final currentArrival = DateTime.parse(segments[i]['arrivalDateTimeLocal']);
        final nextDeparture = DateTime.parse(segments[i+1]['departureDateTimeLocal']);
        totalLayover += nextDeparture.difference(currentArrival);
      }

      return '${totalLayover.inHours}h ${totalLayover.inMinutes.remainder(60)}m';
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
