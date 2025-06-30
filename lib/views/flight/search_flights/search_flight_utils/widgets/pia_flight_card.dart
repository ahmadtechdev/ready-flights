import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../utility/colors.dart';
import '../../pia/pia_flight_model.dart';
import '../../pia/pia_flight_controller.dart';

class PIAFlightCard extends StatefulWidget {
  final PIAFlight flight;


  const PIAFlightCard({
    super.key,
    required this.flight,
  });

  @override
  State<PIAFlightCard> createState() => _PIAFlightCardState();
}

class _PIAFlightCardState extends State<PIAFlightCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  final Rx<Map<String, dynamic>> marginData = Rx<Map<String, dynamic>>({});
  final RxDouble finalPrice = 0.0.obs;
  int i=1;

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

    // Initialize with PIA flight price
    finalPrice.value = widget.flight.price;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getMealInfo(String? mealCode) {
    switch (mealCode?.toUpperCase()) {
      case 'HALAL':
        return 'Halal Meal';
      case 'VEG':
        return 'Vegetarian Meal';
      case 'CHILD':
        return 'Child Meal';
      case 'N':
        return 'No meal service';
      default:
        return 'Standard Meal';
    }
  }

  String formatBaggageInfo() {
    final piaController = Get.find<PIAFlightController>();
    final List<PIAFareOption> fareOptions = piaController
        .getFareOptionsForFlight(widget.flight);

    final package = fareOptions[0];

    return package.baggageAllowance.weight > 0
        ? '${package.baggageAllowance.weight} ${package.baggageAllowance.unit}'
        : '${package.baggageAllowance.pieces} piece(s)';
  }



  String formatFullDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('E, d MMM yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String formatTimeFromDateTime(String dateTimeString) {
    i++;
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String formatTime(String time) {
    if (time.isEmpty) return 'N/A';
    try {
      // Extract time part before timezone info
      String timePart;
      if (time.contains('T')) {
        timePart = time.split('T')[1];
        // Remove timezone info if present
        if (timePart.contains('+')) {
          timePart = timePart.split('+')[0];
        } else if (timePart.contains('-') && timePart.lastIndexOf('-') > 2) {
          timePart = timePart.split('-')[0];
        } else if (timePart.contains('Z')) {
          timePart = timePart.split('Z')[0];
        }
      } else {
        timePart = time;
      }

      final timeComponents = timePart.split(':');
      if (timeComponents.length >= 2) {
        final hour = int.parse(timeComponents[0]);
        final minute = int.parse(timeComponents[1]);
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }

      return 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

// Update the build method in _PIAFlightCardState to show all leg schedules

  // Helper to get all segments from a leg
  List<dynamic> _getAllSegments(Map<String, dynamic> leg) {
    final availFlightSegmentList = leg['availFlightSegmentList'];
    if (availFlightSegmentList == null) return [];

    if (availFlightSegmentList is List) {
      return availFlightSegmentList;
    }
    return [availFlightSegmentList];
  }

// Helper to get first departure info
  Map<String, dynamic>? _getFirstDeparture(Map<String, dynamic> leg) {
    final segments = _getAllSegments(leg);
    if (segments.isEmpty) return null;

    return segments.first['flightSegment'];
  }

// Helper to get last arrival info
  Map<String, dynamic>? _getLastArrival(Map<String, dynamic> leg) {
    final segments = _getAllSegments(leg);
    if (segments.isEmpty) return null;

    return segments.last['flightSegment'];
  }

// Helper to get via cities (intermediate stops)
  List<String> _getViaCities(Map<String, dynamic> leg) {
    final segments = _getAllSegments(leg);
    if (segments.length <= 1) return [];

    final viaCities = <String>[];
    for (int i = 1; i < segments.length; i++) {
      final segment = segments[i];
      final departureAirport = _extractNestedValue(
          segment,
          ['flightSegment', 'departureAirport', 'locationCode']
      );
      if (departureAirport != null) {
        viaCities.add(departureAirport);
      }
    }

    return viaCities;
  }

// Helper to calculate total duration for multi-segment flights
  String _getTotalDuration(Map<String, dynamic> leg) {
    final segments = _getAllSegments(leg);
    if (segments.isEmpty) return 'PT0H0M';

    int totalMinutes = 0;
    for (var segment in segments) {
      final duration = _extractStringValue(
          segment['flightSegment']?['journeyDuration']
      );
      totalMinutes += _parseDurationToMinutes(duration);
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return 'PT${hours}H${minutes}M';
  }

  static int _parseDurationToMinutes(String duration) {
    try {
      if (duration.startsWith('PT')) {
        final parts = duration.substring(2).split(RegExp(r'[HMS]'));
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        return hours * 60 + minutes;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final piaController = Get.find<PIAFlightController>();

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flight numbers and airlines row
                Row(
                  children: [
                    // Scrollable Flight Details
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var i = 0; i < widget.flight.legSchedules.length; i++)
                              Row(
                                children: [
                                  // Add vertical divider before each flight except the first one
                                  if (i > 0)
                                    Container(
                                      height: 40,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                      color: TColors.grey.withOpacity(0.3),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Flight ${i + 1}",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: TColors.third,
                                          ),
                                        ),
                                        Text(
                                          widget.flight.airline,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'PIA',
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
                    // Price section
                    Column(
                      children: [
                        Obx(
                              () => Container(
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
                              '${piaController.selectedCurrency.value} ${finalPrice.value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: TColors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Flight segments
                for (var leg in widget.flight.legSchedules)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _buildFlightSegmentRow(leg),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Rest of the code remains the same...
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
                      color: const Color(0xFF47965D),
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
                        'PIA',
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
                      piaController.handlePIAFlightSelection(widget.flight);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.third,
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
                  _buildFlightSegment(widget.flight),
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

  // New method to build the flight segment row
  Widget _buildFlightSegmentRow(Map<String, dynamic> leg) {
    final segments = _getAllSegments(leg);
    final isMultiSegment = segments.length > 1;
    final firstDeparture = _getFirstDeparture(leg);
    final lastArrival = _getLastArrival(leg);
    final viaCities = _getViaCities(leg);
    final totalDuration = _getTotalDuration(leg);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CachedNetworkImage(
          imageUrl: 'https://onerooftravel.net/assets/img/airline-logo/PIA-logo.png',
          height: 32,
          width: 32,
          placeholder: (context, url) => const SizedBox(
            height: 24,
            width: 24,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) => CachedNetworkImage(
            imageUrl: 'https://cdn-icons-png.flaticon.com/128/15700/15700374.png',
            height: 24,
            width: 24,
            errorWidget: (context, url, error) => const Icon(
              Icons.flight,
              size: 24,
            ),
          ),
          fit: BoxFit.contain,
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatTime(_extractStringValue(firstDeparture?['departureDateTime'])),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _extractNestedValue(firstDeparture, ['departureAirport', 'locationCode']) ?? 'N/A',
              style: const TextStyle(
                color: TColors.grey,
                fontSize: 15,
              ),
            ),
          ],
        ),

        Column(
          children: [
            // Show total duration for multi-segment flights
            Text(
              formatDuration(totalDuration),
              style: const TextStyle(
                color: TColors.grey,
                fontSize: 14,
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
              (segments.length - 1 == 0)
                  ? 'Nonstop'
                  : '${segments.length - 1} stop(s)',
              style: const TextStyle(
                fontSize: 14,
                color: TColors.grey,
              ),
            ),
            // Show via cities if this is a multi-segment flight
            if (isMultiSegment && viaCities.isNotEmpty)
              Text(
                'Via ${viaCities.join(', ')}',
                style: const TextStyle(
                  color: TColors.grey,
                  fontSize: 12,
                ),
              ),
          ],
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatTime(_extractStringValue(lastArrival?['arrivalDateTime'])),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _extractNestedValue(lastArrival, ['arrivalAirport', 'locationCode']) ?? 'N/A',
              style: const TextStyle(
                color: TColors.grey,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlightSegment(PIAFlight flight) {
    final segments = flight.getAllLegsSchedule();

    return Column(
      children: [
        for (int i = 0; i < segments.length; i++)
          _buildSingleSegment(segments[i], i + 1, segments.length),
      ],
    );
  }

  Widget _buildSingleSegment(Map<String, dynamic> segment, int segmentNumber, int totalSegments) {
    final flightSegment = segment['flightSegment'] ?? segment;
    final departureTime = _extractStringValue(flightSegment['departureDateTime']);
    final arrivalTime = _extractStringValue(flightSegment['arrivalDateTime']);
    final from = _extractNestedValue(flightSegment, ['departureAirport', 'locationCode']);
    final to = _extractNestedValue(flightSegment, ['arrivalAirport', 'locationCode']);
    final departureCity = _extractNestedValue(flightSegment, ['departureAirport', 'cityInfo', 'city', 'locationName']) ?? from;
    final arrivalCity = _extractNestedValue(flightSegment, ['arrivalAirport', 'cityInfo', 'city', 'locationName']) ?? to;
    final duration = _extractStringValue(flightSegment['journeyDuration']);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flight_takeoff, size: 16, color: TColors.primary),
              const SizedBox(width: 8),
              Text(
                'Segment $segmentNumber',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              if (segmentNumber < totalSegments)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, size: 16),
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
              widget.flight.cabinClass,
              style: const TextStyle(
                color: TColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Airline Info
          Row(
            children: [
              CachedNetworkImage(
                imageUrl: 'https://onerooftravel.net/assets/img/airline-logo/PIA-logo.png',
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.flight.airline} ${_extractStringValue(flightSegment['flightNumber'])}',
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Departure and Arrival Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(departureCity ?? 'N/A',  style: const TextStyle(fontWeight: FontWeight.w500),),
                    // Text('Terminal ${_extractNestedValue(flightSegment, ['departureAirport', 'terminal']) ?? 'N/A'}'),
                    Text(formatTime(departureTime),  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),),
                    Text(formatFullDateTime(departureTime),  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.flight, color: TColors.primary),
                  Text(formatDuration(duration)),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(arrivalCity ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w500),),
                    // Text('Terminal ${_extractNestedValue(flightSegment, ['arrivalAirport', 'terminal']) ?? 'N/A'}'),
                    Text(formatTime(arrivalTime), style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),),
                    Text(formatFullDateTime(arrivalTime), style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ), ),
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

  String formatDuration(String isoDuration) {
    // Remove 'PT' prefix
    String duration = isoDuration.replaceFirst('PT', '');

    String formattedDuration = '';

    // Extract hours
    RegExp hoursRegex = RegExp(r'(\d+)H');
    Match? hoursMatch = hoursRegex.firstMatch(duration);
    if (hoursMatch != null) {
      formattedDuration += '${hoursMatch.group(1)}h';
    }

    // Extract minutes
    RegExp minutesRegex = RegExp(r'(\d+)M');
    Match? minutesMatch = minutesRegex.firstMatch(duration);
    if (minutesMatch != null) {
      if (formattedDuration.isNotEmpty) {
        formattedDuration += ' '; // Add space between hours and minutes
      }
      formattedDuration += '${minutesMatch.group(1)}m';
    }

    return formattedDuration;
  }

  // Add these helper functions to your _PIAFlightCardState class

  /// Safely extracts a string value from dynamic data
  /// Returns the string value or 'N/A' if null/invalid
  String _extractStringValue(dynamic value) {
    if (value == null) return 'N/A';
    return value.toString();
  }

  /// Safely extracts nested values from dynamic data structures
  /// Takes a data object and a list of keys representing the path to the desired value
  /// Returns the value at the specified path or null if any part of the path is missing
  dynamic _extractNestedValue(dynamic data, List<String> keys) {
    if (data == null || keys.isEmpty) return null;

    dynamic current = data;

    for (String key in keys) {
      if (current is Map<String, dynamic>) {
        current = current[key];
      } else if (current is Map) {
        current = current[key];
      } else {
        return null; // Path doesn't exist
      }

      if (current == null) {
        return null; // Value is null at this level
      }
    }

    return current;
  }


  String _buildFareRules() {
    return '''
• ${widget.flight.isRefundable ? 'Refundable' : 'Non-refundable'} ticket
• Date change permitted with fee
• ${getMealInfo(widget.flight.mealCode)} included
• Free seat selection
• Cabin baggage allowed
• Check-in baggage: ${formatBaggageInfo()}''';
  }
}