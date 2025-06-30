import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../services/api_service_sabre.dart';

import '../../../../../utility/colors.dart';
import '../../../form/flight_booking_controller.dart';
import '../../sabre/sabre_flight_controller.dart';
import '../../sabre/sabre_flight_models.dart';
import '../helper_functions.dart';

class FlightCard extends StatefulWidget {
  final SabreFlight flight;
  final bool showReturnFlight;

  const FlightCard({
    super.key,
    required this.flight,
    this.showReturnFlight = true,
  });

  @override
  State<FlightCard> createState() => _FlightCardState();
}

class _FlightCardState extends State<FlightCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  final Rx<Map<String, dynamic>> marginData = Rx<Map<String, dynamic>>({});
  final RxDouble finalPrice = 0.0.obs;

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

    // Fetch margin data when widget initializes
    _fetchMarginData();
  }

  // Add this method to fetch margin data
  Future<void> _fetchMarginData() async {
    try {
      final apiService = Get.find<ApiServiceSabre>();
      final data = await apiService.getMargin();
      marginData.value = data;

      // Calculate final price with margin
      finalPrice.value = apiService.calculatePriceWithMargin(
        widget.flight.price,
        data,
      );
    } catch (e) {
      // If margin fetch fails, use original price
      finalPrice.value = widget.flight.price;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Calculate total layover time

  // Add this utility function to translate cabin codes
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

  // Add this utility function for meal codes
  String getMealInfo(String mealCode) {
    switch (mealCode.toUpperCase()) {
      case 'P':
        return 'Alcoholic beverages for purchase';
      case 'C':
        return 'Complimentary alcoholic beverages';
      case 'B':
        return 'Breakfast';
      case 'K':
        return 'Continental breakfast';
      case 'D':
        return 'Dinner';
      case 'F':
        return 'Food for purchase';
      case 'G':
        return 'Food/Beverages for purchase';
      case 'M':
        return 'Meal';
      case 'N':
        return 'No meal service';
      case 'R':
        return 'Complimentary refreshments';
      case 'V':
        return 'Refreshments for purchase';
      case 'S':
        return 'Snack';
      default:
        return 'No Meal';
    }
  }

  // Format baggage information
  String formatBaggageInfo() {
    // print("baggage check");
    // print(widget.flight.baggageAllowance.pieces );
    // print(widget.flight.baggageAllowance.weight );
    if (widget.flight.baggageAllowance.pieces > 0) {
      return '${widget.flight.baggageAllowance.pieces} piece(s) included';
    } else if (widget.flight.baggageAllowance.weight > 0) {
      return '${widget.flight.baggageAllowance.weight} ${widget.flight.baggageAllowance.unit} included';
    }
    return widget.flight.baggageAllowance.type;
  }

  // Add these utility methods for date formatting
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

  @override
  Widget build(BuildContext context) {
    Get.put(FlightBookingController());
    String formatTime(String time) {
      if (time.isEmpty) return 'N/A';
      return time.split(':').sublist(0, 2).join(':'); // Extract HH:mm
    }

    // Update these methods to handle the new DateTime format

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
                                        // Use airline name from legSchedules
                                        Text(
                                          widget.flight.legSchedules[i]['airlineName'] ?? 'Unknown Airline',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        // Use flight number from legSchedules (if available)
                                        Text(
                                          widget.flight.legSchedules[i]['airlineCode'] ?? 'Unknown Code',
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
                    SizedBox(width: 12),
                    // Fixed Price Section
                    Column(
                      children: [
                        GetX<FlightController>(
                          builder:
                              (controller) => Container(
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
                                  '${controller.selectedCurrency.value} ${finalPrice.value.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: TColors.black,
                                  ),
                                ),
                              ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),

                for (var legSchedule in widget.flight.legSchedules)
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CachedNetworkImage(
                                imageUrl: legSchedule['airlineImg'],
                                height: 32,
                                width: 32,
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
                                    (context, url, error) => CachedNetworkImage(
                                      imageUrl:
                                          'https://cdn-icons-png.flaticon.com/128/15700/15700374.png',
                                      height: 24,
                                      width: 24,
                                      errorWidget:
                                          (context, url, error) => const Icon(
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
                                    formatTime(
                                      legSchedule['departure']['time']
                                          .toString(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${legSchedule['departure']['city']}',
                                    style: const TextStyle(
                                      color: TColors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${legSchedule['elapsedTime'] ~/ 60}h ${legSchedule['elapsedTime'] % 60}m',
                                    style: const TextStyle(
                                      color: TColors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Left circle
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

                                      // Line
                                      Container(
                                        height: 2,
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.4, // Adjust width as needed
                                        color: Colors.grey[300],
                                      ),

                                      // Right circle
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
                                  if (legSchedule['stops'].isEmpty)
                                    const Text(
                                      'Nonstop',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: TColors.grey,
                                      ),
                                    )
                                  else
                                    Text(
                                      '${legSchedule['stops'].length} ${legSchedule['stops'].length == 1 ? 'stop' : 'stops'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: TColors.grey,
                                      ),
                                    ),
                                  if (legSchedule['stops'].isNotEmpty)
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.4, // Limit width to 40% of screen
                                      child: Center(
                                        child: Text(
                                          legSchedule['stops'].join(', '),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: TColors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatTime(
                                      legSchedule['arrival']['time'].toString(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${legSchedule['arrival']['city']}',
                                    style: const TextStyle(
                                      color: TColors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Expandable Details Section
          // Expanded Details Section
          // Expandable Details Section
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
                    // height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBB0103),
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
                        'Sabre',
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
                      // Add booking functionality here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.third,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.flight.stopSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = widget.flight.stopSchedules[index];
                      return _buildFlightSegment(
                        schedule,
                        index,
                        widget.flight.stopSchedules.length,
                      );
                    },
                  ),

                  // Baggage Information
                  _buildSectionCard(
                    title: 'Baggage Allowance',
                    content: formatBaggageInfo(),
                    icon: Icons.luggage,
                  ),

                  // Fare Rules
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
    // Get flight number and carrier from the schedule
    final carrier = schedule['carrier'] ?? {};
    final flightNumber =
        '${carrier['marketing'] ?? 'XX'}-${carrier['marketingFlightNumber'] ?? '000'}';
    final marketingCarrier = carrier['marketing'] ?? 'Unknown';
    // final airlineInfo = getAirlineInfo(marketingCarrier);
    final ApiServiceSabre apiService = Get.find<ApiServiceSabre>();
    final airlineMap = apiService.getAirlineMap();
    final airlineInfo = getAirlineInfo(marketingCarrier, airlineMap);
    FlightSegmentInfo? segmentInfo;
    if (index < widget.flight.segmentInfo.length) {
      segmentInfo = widget.flight.segmentInfo[index];
    }

    // Calculate layover time for segments within the same leg
    String? layoverTime;

    // Update the departure and arrival time display
    final departureDateTime = schedule['departure']['dateTime'];
    final arrivalDateTime = schedule['arrival']['dateTime'];

    // Find which leg this schedule belongs to
    for (var legSchedule in widget.flight.legSchedules) {
      final schedules = legSchedule['schedules'] as List;
      final currentScheduleIndex = schedules.indexWhere(
        (s) =>
            s['departure']['time'] == schedule['departure']['time'] &&
            s['arrival']['time'] == schedule['arrival']['time'],
      );

      // If found and not the last schedule in this leg
      if (currentScheduleIndex != -1 &&
          currentScheduleIndex < schedules.length - 1) {
        // Get arrival time of current flight
        final currentArrivalTime = schedule['arrival']['time'].toString();

        // Get departure time of next flight in the same leg
        final nextSchedule = schedules[currentScheduleIndex + 1];
        final nextDepartureTime = nextSchedule['departure']['time'].toString();

        // Parse times with a fixed date to handle day changes
        final arrival = DateTime.parse("2024-01-01T$currentArrivalTime");
        DateTime departure = DateTime.parse("2024-01-01T$nextDepartureTime");

        // If departure is before arrival, it means it's next day
        if (departure.isBefore(arrival)) {
          departure = departure.add(const Duration(days: 1));
        }

        // Calculate difference in minutes
        final difference = departure.difference(arrival);
        final totalMinutes = difference.inMinutes;

        if (totalMinutes > 0) {
          final hours = totalMinutes ~/ 60;
          final minutes = totalMinutes % 60;
          layoverTime = '${hours}h ${minutes}m';
        }
        break;
      }
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
          // Flight number and carrier info
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
                imageUrl: airlineInfo.logoPath,
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
                '${airlineInfo.name} $flightNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cabin Class information
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule['departure']['city'] ?? "UNK",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${schedule['departure']['terminal'] ?? "Main"}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      formatTimeFromDateTime(departureDateTime),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formatFullDateTime(departureDateTime),
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
                          getMealInfo(segmentInfo?.mealCode ?? 'N'),
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
                      schedule['arrival']['city'] ?? "UNK",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${schedule['arrival']['terminal'] ?? "Main"}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      formatTimeFromDateTime(arrivalDateTime),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formatFullDateTime(arrivalDateTime),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Show layover time if it exists
          if (layoverTime != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Layover: $layoverTime',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
