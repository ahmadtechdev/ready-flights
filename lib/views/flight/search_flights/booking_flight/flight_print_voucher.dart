// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../services/api_service_sabre.dart';
import '../../../../utility/colors.dart';
import '../airblue/airblue_flight_controller.dart';
import '../airblue/airblue_flight_model.dart';
import 'airblue/booking_flight_controller.dart';

class FlightBookingDetailsScreen extends StatefulWidget {
  final AirBlueFlight outboundFlight;
  final AirBlueFlight? returnFlight;
  final List<AirBlueFlight>? multicityFlights; // Add this
  final AirBlueFareOption? outboundFareOption;
  final AirBlueFareOption? returnFareOption;
  final List<AirBlueFareOption>? multicityFareOptions; // Add this
  final Map<String, dynamic>? pnrResponse;

  const FlightBookingDetailsScreen({
    super.key,
    required this.outboundFlight,
    this.returnFlight,
    this.multicityFlights, // Add this
    this.outboundFareOption,
    this.returnFareOption,
    this.multicityFareOptions, // Add this
    this.pnrResponse,
  });

  @override
  State<FlightBookingDetailsScreen> createState() => _FlightBookingDetailsScreenState();
}

class _FlightBookingDetailsScreenState extends State<FlightBookingDetailsScreen> {
  final BookingFlightController bookingController = Get.find<BookingFlightController>();
  final AirBlueFlightController flightController = Get.find<AirBlueFlightController>();
  // Get margin data from API service
  final apiService = Get.find<ApiServiceSabre>();
  late Map<String, dynamic> marginData = <String, dynamic>{};
  DateTime selectedDate = DateTime.now();
  String bookingReference = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  String pnrNumber = 'PNR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

  // Timer related variables
  Timer? _countdownTimer;
  Duration? _timeRemaining;
  DateTime? _expiryDateTime;
  String _expiryMessage = '';

  // Agent data
  final Agent agent = Agent(
    name: 'Ahmad Raza Ali',
    email: 'ahmadtechdev@gmail.com',
    phone: '03418216319',
    designation: 'Goolaar',
  );

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _initializeTimer() {
    // Get the time limit from PNR response
    final timeLimitString = widget.pnrResponse?['TicketTimeLimit'] ?? widget.pnrResponse?['timeLimit'];

    if (timeLimitString != null) {
      try {
        _expiryDateTime = DateTime.parse(timeLimitString);
        _updateExpiryMessage();
        _startCountdown();
      } catch (e) {
        print('Error parsing time limit: $e');
      }
    }
  }

  void _updateExpiryMessage() {
    if (_expiryDateTime == null) return;

    final now = DateTime.now();
    final isToday = _expiryDateTime!.day == now.day &&
        _expiryDateTime!.month == now.month &&
        _expiryDateTime!.year == now.year;

    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM dd, yyyy');

    if (isToday) {
      _expiryMessage = 'This booking will expire today at ${timeFormat.format(_expiryDateTime!)}';
    } else {
      _expiryMessage = 'This booking will expire on ${dateFormat.format(_expiryDateTime!)} at ${timeFormat.format(_expiryDateTime!)}';
    }
  }

  void _startCountdown() {
    if (_expiryDateTime == null) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = _expiryDateTime!.difference(now);

      if (difference.isNegative) {
        setState(() {
          _timeRemaining = Duration.zero;
          _expiryMessage = 'This booking has expired';
        });
        timer.cancel();
      } else {
        setState(() {
          _timeRemaining = difference;
        });
      }
    });
  }

  String _formatTimeRemaining() {
    if (_timeRemaining == null || _timeRemaining!.isNegative) {
      return 'Expired';
    }

    final days = _timeRemaining!.inDays;
    final hours = _timeRemaining!.inHours.remainder(24);
    final minutes = _timeRemaining!.inMinutes.remainder(60);
    final seconds = _timeRemaining!.inSeconds.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m ${seconds}s';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  Color _getTimerColor() {
    if (_timeRemaining == null || _timeRemaining!.isNegative) {
      return Colors.red;
    }

    final totalMinutes = _timeRemaining!.inMinutes;
    if (totalMinutes <= 30) {
      return Colors.red;
    } else if (totalMinutes <= 120) {
      return Colors.orange;
    } else {
      return TColors.primary;
    }
  }

  Future<void> _prefetchMarginData() async {
    try {
      if (marginData.isEmpty) {
        final apiService = Get.find<ApiServiceSabre>();
        marginData = await apiService.getMargin();
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    _prefetchMarginData();
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.secondary,
        elevation: 0,
        title: const Text(
          'Airblue',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            // Add expiry notice widget
            if (_expiryDateTime != null) _buildExpiryNotice(),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryNotice() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getTimerColor().withOpacity(0.1),
        border: Border.all(color: _getTimerColor(), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: _getTimerColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _expiryMessage,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _getTimerColor(),
                  ),
                ),
              ),
            ],
          ),
          if (_timeRemaining != null && !_timeRemaining!.isNegative) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: _getTimerColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Time Left: ${_formatTimeRemaining()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Agent Info Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Logo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Airblue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TColors.black,
                    ),
                  ),
                  const Text(
                    'Booking Voucher',
                    style: TextStyle(
                      fontSize: 14,
                      color: TColors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Right side - Agent details
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: TColors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Agent Name: ${bookingController.firstNameController.text.toString()} ${bookingController.lastNameController.text.toString()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.email, size: 14, color: TColors.grey),
                      const SizedBox(width: 4),
                      Text(
                        bookingController.emailController.text.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: TColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: TColors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Phone: ${bookingController.phoneController.text.toString()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: TColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Booking reference info
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        'Reference # ',
                        style: TextStyle(
                          fontSize: 12,
                          color: TColors.grey,
                        ),
                      ),
                      Text(
                        bookingReference,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Booking Status: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: TColors.grey,
                        ),
                      ),
                      const Text(
                        'Confirmed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: TColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Date selection and print button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'PNR: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: TColors.grey,
                    ),
                  ),
                  Text(
                    widget.pnrResponse?['pnr'] ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _generatePDF(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 0,
                ),
                icon: const Icon(Icons.print, size: 18),
                label: const Text('Print'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlightSegments(AirBlueFlight flight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Flight Segments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...flight.stopSchedules.map((schedule) {
          final departure = schedule['departure'];
          final arrival = schedule['arrival'];
          final carrier = schedule['carrier'];
          final flightNumber = '${carrier['marketing']}-${carrier['marketingFlightNumber']}';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      flight.airlineName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      flightNumber,
                      style: const TextStyle(color: TColors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatTime(departure['dateTime']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(departure['airport']),
                      ],
                    ),
                    const Icon(Icons.flight, color: TColors.primary),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatTime(arrival['dateTime']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(arrival['airport']),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String formatTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  Widget _buildBody() {
    final outboundFlight = widget.outboundFlight;
    final returnFlight = widget.returnFlight;
    final multicityFlights = widget.multicityFlights;
    final outboundFareOption = widget.outboundFareOption;
    final returnFareOption = widget.returnFareOption;
    final multicityFareOptions = widget.multicityFareOptions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Flight Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: TColors.text,
            ),
          ),
          const SizedBox(height: 12),

          // Outbound Flight (only show if not multicity)
          if (multicityFlights == null || multicityFlights.isEmpty) ...[
            _buildFlightCard(
              flight: outboundFlight,
              fareOption: outboundFareOption,
              isReturn: false,
            ),
            const SizedBox(height: 16),
          ],

          // Return Flight
          if (returnFlight != null) ...[
            _buildFlightCard(
              flight: returnFlight,
              fareOption: returnFareOption,
              isReturn: true,
            ),
            const SizedBox(height: 16),
          ],

          // Multicity Flights
          if (multicityFlights != null && multicityFlights.isNotEmpty) ...[
            ...multicityFlights.asMap().entries.map((entry) {
              final index = entry.key;
              final flight = entry.value;
              return Column(
                children: [
                  _buildFlightCard(
                    flight: flight,
                    fareOption: multicityFareOptions != null && multicityFareOptions.length > index
                        ? multicityFareOptions[index]
                        : null,
                    isReturn: false,
                    flightNumber: index + 1,
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],

          _buildPassengerDetailsCard(),
          const SizedBox(height: 24),
          _buildPriceBreakdownCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  Widget _buildFlightCard({
    required AirBlueFlight flight,
    required AirBlueFareOption? fareOption,
    required bool isReturn,
    int? flightNumber,
  }) {
    final firstLeg = flight.legSchedules.first;
    final lastLeg = flight.legSchedules.last;
    final departureDateTime = DateTime.parse(firstLeg['departure']['dateTime']);
    final arrivalDateTime = DateTime.parse(lastLeg['arrival']['dateTime']);
    final duration = arrivalDateTime.difference(departureDateTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    // Update the title based on flight type
                    flightNumber != null
                        ? 'Flight $flightNumber: ${flight.airlineName} (${flight.id.split('-').first})'
                        : isReturn
                        ? 'Return Flight: ${flight.airlineName} (${flight.id.split('-').first})'
                        : 'Outbound Flight: ${flight.airlineName} (${flight.id.split('-').first})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: TColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: TColors.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    fareOption?.cabinName ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: TColors.background,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Add flight segments
            _buildFlightSegments(flight),
            const SizedBox(height: 16),

            // Baggage information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFlightDetailItem(
                  label: 'Hand Baggage',
                  value: '7 Kg',
                  icon: Icons.work_outline,
                ),
                _buildFlightDetailItem(
                  label: 'Checked Baggage',
                  value: '${flight.baggageAllowance.weight} ${flight.baggageAllowance.unit}',
                  icon: Icons.luggage,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Fare details
            if (fareOption != null) ...[
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildFlightDetailItem(
                    label: 'Fare Type',
                    value: fareOption.fareName,
                    icon: Icons.airplane_ticket,
                  ),
                  _buildFlightDetailItem(
                    label: 'Meal',
                    value: fareOption.mealCode == 'M' ? 'Included' : 'Not Included',
                    icon: Icons.restaurant,
                  ),
                  _buildFlightDetailItem(
                    label: 'Refundable',
                    value: fareOption.isRefundable ? 'Yes' : 'No',
                    icon: Icons.currency_exchange,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Connecting flight notice
            if (flight.legSchedules.length > 1) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TColors.secondary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: TColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: TColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'This is a connecting flight. Please collect your baggage and check-in again for the next flight.',
                        style: TextStyle(
                          fontSize: 12,
                          color: TColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFlightDetailItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: TColors.primary,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: TColors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerDetailsCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Passenger Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  border: TableBorder.all(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: TColors.background,
                      ),
                      children: [
                        _buildTableCell('Sr', isHeader: true),
                        _buildTableCell('Name', isHeader: true),
                        _buildTableCell('Type', isHeader: true),
                        _buildTableCell('Passport#', isHeader: true),
                        _buildTableCell('Ticket #', isHeader: true),
                      ],
                    ),
                    ...List.generate(bookingController.adults.length, (index) {
                      final adult = bookingController.adults[index];
                      return TableRow(
                        children: [
                          _buildTableCell('${index + 1}'),
                          _buildTableCell('${adult.firstNameController.text} ${adult.lastNameController.text}'),
                          _buildTableCell('Adult'),
                          _buildTableCell(adult.passportCnicController.text),
                          _buildTableCell('N/A'),
                        ],
                      );
                    }),
                    ...List.generate(bookingController.children.length, (index) {
                      final child = bookingController.children[index];
                      return TableRow(
                        children: [
                          _buildTableCell('${bookingController.adults.length + index + 1}'),
                          _buildTableCell('${child.firstNameController.text} ${child.lastNameController.text}'),
                          _buildTableCell('Child'),
                          _buildTableCell(child.passportCnicController.text),
                          _buildTableCell('N/A'),
                        ],
                      );
                    }),
                    ...List.generate(bookingController.infants.length, (index) {
                      final infant = bookingController.infants[index];
                      return TableRow(
                        children: [
                          _buildTableCell('${bookingController.adults.length + bookingController.children.length + index + 1}'),
                          _buildTableCell('${infant.firstNameController.text} ${infant.lastNameController.text}'),
                          _buildTableCell('Infant'),
                          _buildTableCell(infant.passportCnicController.text),
                          _buildTableCell('N/A'),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdownCard() {
    final outboundFlight = widget.outboundFlight;
    final returnFlight = widget.returnFlight;
    final multicityFlights = widget.multicityFlights;
    final outboundFareOption = widget.outboundFareOption;
    final returnFareOption = widget.returnFareOption;
    final multicityFareOptions = widget.multicityFareOptions;

    // Calculate prices with margin for each passenger type
    final adultPrice = _calculatePassengerPrice(
      'ADT',
      outboundFlight,
      outboundFareOption,
      returnFlight,
      returnFareOption,
      marginData,
    );

    final childPrice = _calculatePassengerPrice(
      'CHD',
      outboundFlight,
      outboundFareOption,
      returnFlight,
      returnFareOption,
      marginData,
    );

    final infantPrice = _calculatePassengerPrice(
      'INF',
      outboundFlight,
      outboundFareOption,
      returnFlight,
      returnFareOption,
      marginData,
    );

    final currency = outboundFlight.currency;

    // Calculate total price from all flights
    double totalPrice = outboundFareOption?.price ?? 0;
    if (returnFareOption != null) totalPrice += returnFareOption.price;
    if (multicityFareOptions != null) {
      totalPrice += multicityFareOptions.fold(0.0, (sum, option) => sum + option.price);
    }

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Breakdown',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // Adult pricing
            if (bookingController.adults.isNotEmpty) ...[
              _buildPassengerPriceRow('Adult', adultPrice, currency),
              const SizedBox(height: 8),
            ],

            // Child pricing
            if (bookingController.children.isNotEmpty) ...[
              _buildPassengerPriceRow('Child', childPrice, currency),
              const SizedBox(height: 8),
            ],

            // Infant pricing
            if (bookingController.infants.isNotEmpty) ...[
              _buildPassengerPriceRow('Infant', infantPrice, currency),
              const SizedBox(height: 8),
            ],

            const Divider(),
            _buildPriceRow(
              'Total Amount',
              '${outboundFlight.currency} ${totalPrice.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculatePassengerPrice(
      String passengerType,
      AirBlueFlight outboundFlight,
      AirBlueFareOption? outboundFareOption,
      AirBlueFlight? returnFlight,
      AirBlueFareOption? returnFareOption,
      Map<String, dynamic> marginData,
      ) {
    double base = 0;
    double tax = 0;
    double fee = 0;

    // Check if we have PNR pricing data
    if (outboundFlight.pnrPricing != null && outboundFlight.pnrPricing!.isNotEmpty) {
      // Find pricing for this passenger type
      for (var pricing in outboundFlight.pnrPricing!) {
        if (pricing.passengerType == passengerType) {
          base = pricing.baseFare;
          tax = pricing.totalTax;
          fee = pricing.totalFees;
          break;
        }
      }
    } else {
      Get.snackbar("Ahmad", "hello");
    }

    // Apply margin if needed (assuming apiService has calculatePriceWithMargin method)
    base = apiService.calculatePriceWithMargin(base, marginData);

    return {
      'base': base,
      'tax': tax,
      'fee': fee,
      'total': (base + tax + fee),
    };
  }

  Widget _buildPassengerPriceRow(String label, Map<String, double> price, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label Price',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        _buildPriceRow('Base Fare', '$currency ${price['base']!.toStringAsFixed(2)}'),
        _buildPriceRow('Taxes', '$currency ${price['tax']!.toStringAsFixed(2)}'),
        _buildPriceRow('Fees', '$currency ${price['fee']!.toStringAsFixed(2)}'),
        _buildPriceRow(
          'Subtotal',
          '$currency ${price['total']!.toStringAsFixed(2)}',
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? TColors.primary : TColors.text,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? TColors.primary : TColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  Future<void> _generatePDF() async {
    final outboundFlight = widget.outboundFlight;
    final returnFlight = widget.returnFlight;
    final multicityFlights = widget.multicityFlights;
    final outboundFareOption = widget.outboundFareOption;
    final returnFareOption = widget.returnFareOption;
    final multicityFareOptions = widget.multicityFareOptions;

    final pdf = pw.Document();

    // Add page
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Journey Online Booking Voucher',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Flight Booking Details',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Agent: ${bookingController.firstNameController.text} ${bookingController.lastNameController.text}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    pw.Text(
                      '${bookingController.emailController.text}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'Phone: ${bookingController.bookerPhoneCountry} ${bookingController.phoneController.text}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Reference # $bookingReference | PNR: ${widget.pnrResponse?['pnr']}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),

            // Add expiry notice to PDF
            if (_expiryDateTime != null) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.red, width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  children: [
                    pw.Icon(
                      const pw.IconData(0xe8b5), // schedule icon
                      color: PdfColors.red,
                      size: 16,
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Text(
                        _expiryMessage,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
            ],

            // Flight Details
            pw.Text(
              'Flight Details',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Divider(),

            // Flight Details
            if (multicityFlights == null || multicityFlights.isEmpty) ...[
              _buildPdfFlightSection(
                flight: outboundFlight,
                fareOption: outboundFareOption,
                isReturn: false,
              ),
              pw.SizedBox(height: 16),
            ],


            // Return Flight
            if (returnFlight != null) ...[
              _buildPdfFlightSection(
                flight: returnFlight,
                fareOption: returnFareOption,
                isReturn: true,
              ),
              pw.SizedBox(height: 16),
            ],

            if (multicityFlights != null && multicityFlights.isNotEmpty) ...[
              ...multicityFlights.asMap().entries.map((entry) {
                final index = entry.key;
                final flight = entry.value;
                return pw.Column(
                  children: [
                    _buildPdfFlightSection(
                      flight: flight,
                      fareOption: multicityFareOptions != null && multicityFareOptions.length > index
                          ? multicityFareOptions[index]
                          : null,
                      isReturn: false,
                      flightNumber: index + 1,
                    ),
                    pw.SizedBox(height: 16),
                  ],
                );
              }),
            ],

            // Passenger Details
            pw.Text(
              'Passenger Details',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Divider(),
            pw.TableHelper.fromTextArray(
              context: context,
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['Sr', 'Name', 'Type', 'Passport#', 'Ticket #'],
              data: [
                ...bookingController.adults.map((adult) => [
                  '${bookingController.adults.indexOf(adult) + 1}',
                  '${adult.firstNameController.text} ${adult.lastNameController.text}',
                  'Adult',
                  adult.passportCnicController.text,
                  'N/A',
                ]),
                ...bookingController.children.map((child) => [
                  '${bookingController.adults.length + bookingController.children.indexOf(child) + 1}',
                  '${child.firstNameController.text} ${child.lastNameController.text}',
                  'Child',
                  child.passportCnicController.text,
                  'N/A',
                ]),
                ...bookingController.infants.map((infant) => [
                  '${bookingController.adults.length + bookingController.children.length + bookingController.infants.indexOf(infant) + 1}',
                  '${infant.firstNameController.text} ${infant.lastNameController.text}',
                  'Infant',
                  infant.passportCnicController.text,
                  'N/A',
                ]),
              ],
            ),
            pw.SizedBox(height: 20),

            // Price Breakdown
            pw.Text(
              'Price Breakdown',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Divider(),
            _buildPdfPriceRow('Base Fare', '${outboundFlight.currency} ${outboundFareOption?.basePrice.toStringAsFixed(2) ?? '0.00'}'),
            if (returnFareOption != null)
              _buildPdfPriceRow('Return Base Fare', '${returnFlight?.currency} ${returnFareOption.basePrice.toStringAsFixed(2)}'),
            _buildPdfPriceRow('Taxes', '${outboundFlight.currency} ${outboundFareOption?.taxAmount.toStringAsFixed(2) ?? '0.00'}'),
            if (returnFareOption != null)
              _buildPdfPriceRow('Return Taxes', '${returnFlight?.currency} ${returnFareOption.taxAmount.toStringAsFixed(2)}'),
            _buildPdfPriceRow('Fees', '${outboundFlight.currency} ${outboundFareOption?.feeAmount.toStringAsFixed(2) ?? '0.00'}'),
            if (returnFareOption != null)
              _buildPdfPriceRow('Return Fees', '${returnFlight?.currency} ${returnFareOption.feeAmount.toStringAsFixed(2)}'),
            pw.Divider(),
            _buildPdfPriceRow(
              'Total Amount',
              '${outboundFlight.currency} ${((outboundFareOption?.price ?? 0) + (returnFareOption?.price ?? 0)).toStringAsFixed(2)}',
              isTotal: true,
            ),
            pw.SizedBox(height: 20),

            // Footer
            pw.Center(
              child: pw.Text(
                'Thank you for booking with Journey Online!',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfFlightSection({
    required AirBlueFlight flight,
    required AirBlueFareOption? fareOption,
    required bool isReturn,
    int? flightNumber,
  }) {
    final firstLeg = flight.legSchedules.first;
    final lastLeg = flight.legSchedules.last;
    final departureDateTime = DateTime.parse(firstLeg['departure']['dateTime']);
    final arrivalDateTime = DateTime.parse(lastLeg['arrival']['dateTime']);
    final duration = arrivalDateTime.difference(departureDateTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                // Update title based on flight type
                flightNumber != null
                    ? 'Flight $flightNumber: ${flight.airlineName} (${flight.id.split('-').first})'
                    : isReturn
                    ? 'Return Flight: ${flight.airlineName} (${flight.id.split('-').first})'
                    : 'Outbound Flight: ${flight.airlineName} (${flight.id.split('-').first})',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                fareOption?.cabinName ?? 'ECONOMY',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${firstLeg['departure']['airport']} → ${lastLeg['arrival']['airport']}',
            style: pw.TextStyle(
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Departure: ${departureDateTime.day}-${departureDateTime.month}-${departureDateTime.year} ${departureDateTime.hour.toString().padLeft(2, '0')}:${departureDateTime.minute.toString().padLeft(2, '0')}'),
              pw.Text('Duration: ${hours}h ${minutes}m'),
              pw.Text('Arrival: ${arrivalDateTime.day}-${arrivalDateTime.month}-${arrivalDateTime.year} ${arrivalDateTime.hour.toString().padLeft(2, '0')}:${arrivalDateTime.minute.toString().padLeft(2, '0')}'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Hand Baggage:',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text('7 Kg'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Checked Baggage:',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text('${flight.baggageAllowance.weight} ${flight.baggageAllowance.unit}'),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),
          if (fareOption != null) pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Fare Type:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(fareOption.fareName),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Meal:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(fareOption.mealCode == 'M' ? 'Included' : 'Not Included'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Refundable:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(fareOption.isRefundable ? 'Yes' : 'No'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfPriceRow(String label, String value, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal ? PdfColors.blue800 : PdfColors.black,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal ? PdfColors.blue800 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// Sample Agent model class
class Agent {
  final String name;
  final String email;
  final String phone;
  final String designation;

  Agent({
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
  });
}