import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../utility/colors.dart';
import '../../airblue/airblue_flight_controller.dart';
import '../../airblue/airblue_flight_model.dart';
import '../../sabre/sabre_flight_models.dart';

class AirBlueFlightCard extends StatefulWidget {
  final AirBlueFlight flight;
  final bool showReturnFlight;
  final bool isShowBookButton;
  final bool isMultiCity;
  final int currentSegment;

  const AirBlueFlightCard({
    super.key,
    required this.flight,
    this.showReturnFlight = false,
    this.isMultiCity = false,
    this.currentSegment = 0,
    this.isShowBookButton = true,
  });

  @override
  State<AirBlueFlightCard> createState() => _AirBlueFlightCardState();
}

class _AirBlueFlightCardState extends State<AirBlueFlightCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  final AirBlueFlightController airBlueController =
      Get.find<AirBlueFlightController>();

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
        return 'Meal included';
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
      return formatTimeFromDateTime(
        widget.flight.legSchedules[0]['departure']['dateTime'],
      );
    }
    return 'N/A';
  }

  String getArrivalTime() {
    if (widget.flight.legSchedules.isNotEmpty) {
      return formatTimeFromDateTime(
        widget.flight.legSchedules[0]['arrival']['dateTime'],
      );
    }
    return 'N/A';
  }


  void _showFlightDetailsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => _buildFlightDetailsDialog(),
    );
  }

  Widget _buildFlightDetailsDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: TColors.primary.withOpacity(0.1),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TColors.primary,
                    TColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.flight_takeoff,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Flight Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flight Segments
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.flight.stopSchedules.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildDialogFlightSegment(
                          widget.flight.stopSchedules[index],
                          index,
                          widget.flight.stopSchedules.length,
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Baggage Information
                    _buildDialogSectionCard(
                      title: 'Baggage Allowance',
                      content: formatBaggageInfo(),
                      icon: Icons.luggage,
                    ),

                    const SizedBox(height: 16),

                    // Fare Rules
                    _buildDialogSectionCard(
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
      ),
    );
  }

  Widget _buildDialogFlightSegment(
      Map<String, dynamic> schedule,
      int index,
      int totalSegments,
      ) {
    final carrier = schedule['carrier'] ?? {};
    final flightNumber = '${carrier['marketing'] ?? 'PA'}-${carrier['marketingFlightNumber'] ?? '000'}';

    FlightSegmentInfo? segmentInfo;
    if (index < widget.flight.segmentInfo.length) {
      segmentInfo = widget.flight.segmentInfo[index];
    }

    // Calculate layover time
    String? layoverTime;
    if (index < widget.flight.stopSchedules.length - 1) {
      final nextSchedule = widget.flight.stopSchedules[index + 1];
      final currentArrivalTime = schedule['arrival']['dateTime'];
      final nextDepartureTime = nextSchedule['departure']['dateTime'];

      try {
        final arrival = DateTime.parse(currentArrivalTime);
        final departure = DateTime.parse(nextDepartureTime);

        final difference = departure.difference(arrival);
        final totalMinutes = difference.inMinutes;

        if (totalMinutes > 0) {
          final hours = totalMinutes ~/ 60;
          final minutes = totalMinutes % 60;
          layoverTime = '${hours}h ${minutes}m';
        }
      } catch (e) {
        // Handle parsing errors
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flight number and carrier info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.flight_takeoff,
                  size: 16,
                  color: TColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Segment ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: TColors.primary,
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
                imageUrl: "https://images.kiwi.com/airlines/64/PA.png",
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 12,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Meal Yes",
                          style: TextStyle(
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

          // Show layover time if it exists
          if (layoverTime != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.1),
                    Colors.orange.withOpacity(0.05),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 6),
                  Text(
                    'Layover: $layoverTime',
                    style: TextStyle(
                      color: Colors.orange[700],
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

  Widget _buildDialogSectionCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: TColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: TColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              content,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
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
                      height: 45,
                      width: 45,
                      placeholder:
                          (context, url) => const SizedBox(
                            height: 45,
                            width: 32,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) =>
                              const Icon(Icons.flight, size: 45),
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PA-${widget.flight.stopSchedules[0]['carrier']['marketingFlightNumber']}',
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
                    if (!widget.isShowBookButton) ...[
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
                    ],
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
                        onTap: _showFlightDetailsDialog,
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

                const SizedBox(height: 24),
                // Expanded Details Section (keep existing)

                // Bottom Section with Tags and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.isShowBookButton) ...[

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                      InkWell(
                        onTap: () {
                          if (widget.showReturnFlight) {
                            print('DEBUG: Return flight selected');
                            print(
                              'DEBUG: Flight route: ${widget.flight.legSchedules.first['departure']['airport']} '
                              '-> ${widget.flight.legSchedules.last['arrival']['airport']}',
                            );
                            airBlueController.handleReturnFlightSelection(
                              widget.flight,
                            );
                          } else if(widget.isMultiCity){

                            // CRITICAL FIX: Force set the current segment in controller before calling handler
                            airBlueController.currentMultiCitySegment.value = widget.currentSegment;

                            // Debug: verify the controller has the right segment
                            print('DEBUG: Controller current segment set to: ${airBlueController.currentMultiCitySegment.value}');

                            // Call the flight selection handler with the correct segment index from widget
                            airBlueController.handleMultiCityFlightSelection(widget.flight, widget.currentSegment);

                          } else {
                            airBlueController.handleAirBlueFlightSelection(
                              widget.flight,
                              isReturnFlight: widget.showReturnFlight,
                            );
                          }
                        },

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
                  ],
                ),
              ],
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
                          // getMealInfo(segmentInfo?.mealCode ?? ''),
                          "Meal Yes",
                          style: const TextStyle(
                            fontSize: 12,
                            color: TColors.primary,
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
