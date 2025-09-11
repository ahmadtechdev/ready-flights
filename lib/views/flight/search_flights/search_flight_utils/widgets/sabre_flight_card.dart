import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../services/api_service_sabre.dart';

import '../../../../../utility/colors.dart';
import '../../../form/flight_booking_controller.dart';
import '../../pia/pia_flight_controller.dart';
import '../../sabre/sabre_flight_controller.dart';
import '../../sabre/sabre_flight_models.dart';
import '../helper_functions.dart';

class FlightCard extends StatefulWidget {
  final SabreFlight flight;
  final bool showReturnFlight;
  final bool isShowBookButton;

  const FlightCard({
    super.key,
    required this.flight,
    this.showReturnFlight = true,
    this.isShowBookButton = true,
  });



  @override
  State<FlightCard> createState() => _FlightCardState();
}

class _FlightCardState extends State<FlightCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  final Rx<Map<String, dynamic>> marginData = Rx<Map<String, dynamic>>({});
  final RxDouble finalPrice = 0.0.obs;

  final flightController = Get.find<SabreFlightController>();
  @override
  void initState() {
    super.initState();


    // Fetch margin data when widget initializes
    _fetchMarginData();
  }

  // Add this method to fetch margin data
  Future<void> _fetchMarginData() async {
    try {
      final apiService = Get.find<ApiServiceSabre>();
      final data = await apiService.getMargin(widget.flight.airlineCode, widget.flight.airline);
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
    super.dispose();
  }

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

  String formatTime(String time) {
    if (time.isEmpty) return 'N/A';
    return time.split(':').sublist(0, 2).join(':'); // Extract HH:mm
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
                        return _buildFlightSegment(
                          widget.flight.stopSchedules[index],
                          index,
                          widget.flight.stopSchedules.length,
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Baggage Information
                    _buildSectionCard(
                      title: 'Baggage Allowance',
                      content: formatBaggageInfo(),
                      icon: Icons.luggage,
                    ),

                    const SizedBox(height: 16),

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
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    Get.put(FlightBookingController());

    // Get first leg schedule for main display
    final firstLeg = widget.flight.legSchedules.isNotEmpty ? widget.flight.legSchedules.first : null;
    final ApiServiceSabre apiService = Get.find<ApiServiceSabre>();
    final airlineMap = apiService.getAirlineMap();
    final airlineInfo = firstLeg != null ? getAirlineInfo(firstLeg['airlineCode'] ?? 'XX', airlineMap) : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
          // Main Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Row - Airline and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Airline Logo and Name
                    SizedBox(
                      width: 150,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (firstLeg != null && airlineInfo != null)
                              CachedNetworkImage(
                                imageUrl: firstLeg['airlineImg'],
                                height: 32,
                                width: 32,
                                placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                                errorWidget: (context, url, error) => const Icon(Icons.flight, size: 32),
                                fit: BoxFit.contain,
                              ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  firstLeg?['airlineName'] ?? 'Airline',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "${firstLeg?['airlineCode']}-${widget.flight.stopSchedules[0]['carrier']['marketingFlightNumber']}" ?? 'Code',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    //
                    if(!widget.isShowBookButton)...[


                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        GetX<SabreFlightController>(
                          builder: (controller) => Text(
                            '${controller.selectedCurrency.value} ${finalPrice.value.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: TColors.primary,
                            ),
                          ),
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
                          child: Center(
                            child: Text(
                              widget.flight.isNDC?'Sabre NDC':"Sabre",
                              style: const TextStyle(
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

                // Flight Route Information
                ...widget.flight.legSchedules.map((legSchedule) {

                  print("Ahmad leg schedule check");
                  print(legSchedule);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // Departure
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatTime(legSchedule['departure']['time'].toString()),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                legSchedule['departure']['airport'] ?? 'DEP',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                legSchedule['departure']['code'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Flight Duration and Line
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: _showFlightDetailsDialog,
                            child: Column(
                              children: [
                                Text(
                                  '${legSchedule['elapsedTime'] ~/ 60}h ${legSchedule['elapsedTime'] % 60}m',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
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
                                        decoration: BoxDecoration(
                                          color: TColors.primary.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.flight,
                                      size: 20,
                                      color: TColors.primary,
                                    ),
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
                                Text(
                                  legSchedule['stops'].isEmpty
                                      ? 'Direct'
                                      : '${legSchedule['stops'].length} stop${legSchedule['stops'].length > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: legSchedule['stops'].isEmpty ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Arrival
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatTime(legSchedule['arrival']['time'].toString()),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                legSchedule['arrival']['airport'] ?? 'ARR',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                legSchedule['arrival']['code'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                // Bottom Row - Flight Details Button and Book Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [


                    // Flight Details Button (instead of discount)
                    // InkWell(
                    //   onTap: () {
                    //     setState(() {
                    //       isExpanded = !isExpanded;
                    //       if (isExpanded) {
                    //         _controller.forward();
                    //       } else {
                    //         _controller.reverse();
                    //       }
                    //     });
                    //   },
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    //     decoration: BoxDecoration(
                    //       color: TColors.primary.withOpacity(0.1),
                    //       borderRadius: BorderRadius.circular(6),
                    //     ),
                    //     child: Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Text(
                    //           'Flight Details',
                    //           style: TextStyle(
                    //             fontSize: 12,
                    //             fontWeight: FontWeight.w600,
                    //             color: TColors.primary,
                    //           ),
                    //         ),
                    //         const SizedBox(width: 4),
                    //         AnimatedRotation(
                    //           duration: const Duration(milliseconds: 300),
                    //           turns: isExpanded ? 0.5 : 0,
                    //           child: Icon(
                    //             Icons.keyboard_arrow_down,
                    //             size: 16,
                    //             color: TColors.primary,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    // Provider Badge and Book Button
                    // const SizedBox(width: 12),
                    if(widget.isShowBookButton)...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            child: Center(
                              child: Text(
                                widget.flight.isNDC?'Sabre NDC':"Sabre",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          GetX<SabreFlightController>(
                            builder: (controller) => Text(
                              '${controller.selectedCurrency.value} ${finalPrice.value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: TColors.primary,
                              ),
                            ),
                          ),

                        ],
                      ),
                      InkWell(
                        onTap: () => flightController.handleFlightSelection(widget.flight),
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
                    ]
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
    // Get flight number and carrier from the schedule

    final carrier = schedule['carrier'] ?? {};
    final flightNumber =
        '${carrier['marketing'] ?? 'XX'}-${carrier['marketingFlightNumber'] ?? '000'}';
    final marketingCarrier = carrier['marketing'] ?? 'Unknown';
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
                      schedule['departure']['airport'] ?? "UNK",
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
                          carrier=="OD"? getMealInfo(widget.flight.mealCode):"MEAL YES",
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