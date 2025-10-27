import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../utility/colors.dart';
import '../../flydubai/flydubai_controller.dart';

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
      return DateFormat('hh:mm a').format(dateTime);
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
    return DateFormat('hh:mm a').format(widget.flight.flightSegment.departureDateTime);
  }

  String getArrivalTime() {
    return DateFormat('hh:mm a').format(widget.flight.flightSegment.arrivalDateTime);
  }

  String getFlightNumber() {
    return widget.flight.flightSegment.flightNumber;
  }

  String getFlightDuration() {
    final duration = widget.flight.flightSegment.arrivalDateTime
        .difference(widget.flight.flightSegment.departureDateTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.isShowBookButton ? () {
        flyDubaiController.handleFlydubaiFlightSelection(widget.flight, isReturnFlight: widget.showReturnFlight);
      } : _showFlightDetailsDialog,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top section with airline logo, name, duration and info icon
            Row(
              children: [
                // Airline logo
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
                    color: Color(0xFFF15A29),
                  ),
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                // Airline name
                Expanded(
                  child: Text(
                    widget.flight.airlineName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Info icon button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showFlightDetailsDialog(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Middle section with departure and arrival
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Departure
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getDepartureTime(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getDepartureAirport(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Flight duration line
                Expanded(
                  child: Column(
                    children: [
                      // Duration above line
                      Text(
                        getFlightDuration(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Line
                      Container(
                        height: 1,
                        color: const Color(0xFFF15A29),
                      ),
                      const SizedBox(height: 4),
                      // Stop indicator below line
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF15A29).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStopText(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFF15A29),
                            fontWeight: FontWeight.w500,
                          ),
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
                        getArrivalTime(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getArrivalAirport(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Container(height: 1, color: Colors.grey.shade200),

            // Bottom section with price
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                if (widget.isShowBookButton)
                  Text(
                    'PKR ${widget.flight.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
              ],
            ),
          ],
        ),
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


// Helper method to get stop text
  String _getStopText() {
    if (widget.flight.stops == 0) {
      return 'Nonstop';
    } else if (widget.flight.stops == 1) {
      return '1 stop';
    } else {
      return '${widget.flight.stops} stops';
    }
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
                     // Flight Segment
                     _buildDialogFlightSegment(),

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

   Widget _buildDialogFlightSegment() {
     final segment = widget.flight.flightSegment;
     final flightNumber = '${widget.flight.airlineCode}-${segment.flightNumber}';

     FlightSegmentInfo? segmentInfo;
     if (widget.flight.segmentInfo.isNotEmpty) {
       segmentInfo = widget.flight.segmentInfo.first;
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
               const Text(
                 'Flight Details',
                 style: TextStyle(
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
                       formatTimeFromDateTime(segment.departureDateTime.toString()),
                       style: const TextStyle(
                         color: Colors.grey,
                         fontSize: 12,
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                     Text(
                       formatFullDateTime(segment.departureDateTime.toString()),
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
                       formatTimeFromDateTime(segment.arrivalDateTime.toString()),
                       style: const TextStyle(
                         color: Colors.grey,
                         fontSize: 12,
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                     Text(
                       formatFullDateTime(segment.arrivalDateTime.toString()),
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