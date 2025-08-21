// ignore_for_file: empty_catches
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:url_launcher/url_launcher.dart';


class FlightBookingDetailsScreen extends StatefulWidget {
  final AirBlueFlight outboundFlight;
  final AirBlueFlight? returnFlight;
  final List<AirBlueFlight>? multicityFlights;
  final AirBlueFareOption? outboundFareOption;
  final AirBlueFareOption? returnFareOption;
  final List<AirBlueFareOption>? multicityFareOptions;
  final Map<String, dynamic>? pnrResponse;

  const FlightBookingDetailsScreen({
    super.key,
    required this.outboundFlight,
    this.returnFlight,
    this.multicityFlights,
    this.outboundFareOption,
    this.returnFareOption,
    this.multicityFareOptions,
    this.pnrResponse,
  });

  @override
  State<FlightBookingDetailsScreen> createState() =>
      _FlightBookingDetailsScreenState();
}

class _FlightBookingDetailsScreenState extends State<FlightBookingDetailsScreen>
    with TickerProviderStateMixin {
  final BookingFlightController bookingController =
      Get.find<BookingFlightController>();
  final AirBlueFlightController flightController =
      Get.find<AirBlueFlightController>();
  final apiService = Get.find<ApiServiceSabre>();
  late Map<String, dynamic> marginData = <String, dynamic>{};
  DateTime selectedDate = DateTime.now();
  String bookingReference =
      'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  String pnrNumber =
      'PNR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

  // Timer related variables
  Timer? _countdownTimer;
  Duration? _timeRemaining;
  DateTime? _expiryDateTime;
  String _expiryMessage = '';

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final Agent agent = Agent(
    name: 'Ahmad Raza Ali',
    email: 'ahmadtechdev@gmail.com',
    phone: '03418216319',
    designation: 'Goolaar',
  );

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTimer();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _initializeTimer() {
    final timeLimitString =
        widget.pnrResponse?['TicketTimeLimit'] ??
        widget.pnrResponse?['timeLimit'];

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
    final isToday =
        _expiryDateTime!.day == now.day &&
        _expiryDateTime!.month == now.month &&
        _expiryDateTime!.year == now.year;

    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM dd, yyyy');

    if (isToday) {
      _expiryMessage =
          'This booking will expire today at ${timeFormat.format(_expiryDateTime!)}';
    } else {
      _expiryMessage =
          'This booking will expire on ${dateFormat.format(_expiryDateTime!)} at ${timeFormat.format(_expiryDateTime!)}';
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
      return const Color(0xFF10B981);
    }
  }

  Future<void> _prefetchMarginData() async {
    try {
      if (marginData.isEmpty) {
        final apiService = Get.find<ApiServiceSabre>();
        marginData = await apiService.getMargin();
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    _prefetchMarginData();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildThankYouSection(),
                    if (_expiryDateTime != null) _buildExpiryNotice(),
                    _buildBookingHeader(),
                    _buildFlightDetailsSection(),
                    _buildPassengerDetailsCard(),
                    _buildPriceBreakdownCard(),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingPrintButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1E293B),
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF334155)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 60,
                right: 80,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


// Function to launch phone dialer
  Future<void> _launchDialer(String phoneNumber) async {
    final url = "tel:$phoneNumber";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

// Function to launch WhatsApp chat
  Future<void> _launchWhatsApp(String phoneNumber) async {
    String message = "Ready FLights ";
    final url = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildThankYouSection() {
    String customerName = bookingController.firstNameController.text.isNotEmpty
        ? bookingController.firstNameController.text
        : bookingController.adults.isNotEmpty
        ? bookingController.adults.first.firstNameController.text
        : 'Valued Customer';

    const String supportNumber = "923007240421"; // without +

    return Container(
      margin: const EdgeInsets.all(16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TColors.primary,
                TColors.primary.withOpacity(0.9),
              ],
            ),
          ),
          child: Column(
            children: [
              // Success icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              const SizedBox(height: 16),

              // Thank you message
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Dear ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: customerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const TextSpan(
                      text: ', your booking is created successfully!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Contact section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Need help? Contact us:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Phone icon
                    GestureDetector(
                      onTap: () {
                        _launchDialer("+$supportNumber");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // WhatsApp icon
                    GestureDetector(
                      onTap: () {
                        _launchWhatsApp(supportNumber);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 20,),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpiryNotice() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.background,
        border: Border.all(color: _getTimerColor(), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: _getTimerColor(), size: 20),
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
                  const Icon(Icons.timer, color: Colors.white, size: 16),
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

  Widget _buildBookingHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient:  LinearGradient(
                        colors: [TColors.primary, TColors.primary.withOpacity(0.9)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.flight_takeoff,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Airblue Booking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            'CONFIRMED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    // _buildInfoRow(
                    //   'Booking Reference',
                    //   bookingReference,
                    //   Icons.confirmation_number_outlined,
                    // ),
                    // const SizedBox(height: 12),
                    _buildInfoRow(
                      'PNR',
                      widget.pnrResponse?['pnr'] ?? 'N/A',
                      Icons.airplane_ticket_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Booker',
                      '${bookingController.firstNameController.text} ${bookingController.lastNameController.text}',
                      Icons.person_outline,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlightDetailsSection() {
    final outboundFlight = widget.outboundFlight;
    final returnFlight = widget.returnFlight;
    final multicityFlights = widget.multicityFlights;
    final outboundFareOption = widget.outboundFareOption;
    final returnFareOption = widget.returnFareOption;
    final multicityFareOptions = widget.multicityFareOptions;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Flight Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),

          // Outbound Flight (only show if not multicity)
          if (multicityFlights == null || multicityFlights.isEmpty) ...[
            _buildModernFlightCard(
              flight: outboundFlight,
              fareOption: outboundFareOption,
              isReturn: false,
            ),
            const SizedBox(height: 12),
          ],

          // Return Flight
          if (returnFlight != null) ...[
            _buildModernFlightCard(
              flight: returnFlight,
              fareOption: returnFareOption,
              isReturn: true,
            ),
            const SizedBox(height: 12),
          ],

          // Multicity Flights
          if (multicityFlights != null && multicityFlights.isNotEmpty) ...[
            ...multicityFlights.asMap().entries.map((entry) {
              final index = entry.key;
              final flight = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildModernFlightCard(
                  flight: flight,
                  fareOption:
                      multicityFareOptions != null &&
                              multicityFareOptions.length > index
                          ? multicityFareOptions[index]
                          : null,
                  isReturn: false,
                  flightNumber: index + 1,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildModernFlightCard({
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

    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Column(
          children: [
            // Flight header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isReturn
                          ? [TColors.primary, TColors.primary.withOpacity(0.9)]
                          : flightNumber != null
                          ? [TColors.primary, TColors.primary.withOpacity(0.9)]
                          : [TColors.primary, TColors.primary.withOpacity(0.9)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isReturn ? Icons.flight_land : Icons.flight_takeoff,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      flightNumber != null
                          ? 'Flight $flightNumber • ${flight.airlineName}'
                          : isReturn
                          ? 'Return • ${flight.airlineName}'
                          : 'Outbound • ${flight.airlineName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (fareOption != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        fareOption.cabinName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Flight route
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(departureDateTime),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              firstLeg['departure']['airport'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd').format(departureDateTime),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: TColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${hours}h ${minutes}m',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: TColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 80,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [TColors.primary, Color(0xFF1D4ED8)],
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Icon(
                            Icons.flight,
                            color: TColors.primary,
                            size: 20,
                          ),
                        ],
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(arrivalDateTime),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              lastLeg['arrival']['airport'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd').format(arrivalDateTime),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Flight segments
                  _buildFlightSegments(flight),

                  // const SizedBox(height: 8),

                  // Baggage and amenities
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildAmenityChip(
                              'Hand Baggage',
                              '7 Kg',
                              Icons.work_outline,
                            ),
                            const SizedBox(width: 12),
                            _buildAmenityChip(
                              'Checked',
                              '${flight.baggageAllowance.weight} ${flight.baggageAllowance.unit}',
                              Icons.luggage,
                            ),
                          ],
                        ),
                        if (fareOption != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildAmenityChip(
                                'Meal',
                                fareOption.mealCode == 'M'
                                    ? 'Included'
                                    : 'Not Included',
                                Icons.restaurant,
                              ),
                              const SizedBox(width: 12),
                              _buildAmenityChip(
                                'Refundable',
                                fareOption.isRefundable ? 'Yes' : 'No',
                                Icons.policy,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Connecting flight notice
                  if (flight.legSchedules.length > 1) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.info,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Connecting flight - Please collect baggage and check-in again',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF92400E),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightSegments(AirBlueFlight flight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Flight Segments',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        ...flight.stopSchedules.map((schedule) {
          final departure = schedule['departure'];
          final arrival = schedule['arrival'];
          final carrier = schedule['carrier'];
          final flightNumber =
              '${carrier['marketing']}-${carrier['marketingFlightNumber']}';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.flight,
                    size: 16,
                    color: TColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flightNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${formatTime(departure['dateTime'])} - ${formatTime(arrival['dateTime'])}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${departure['airport']} → ${arrival['airport']}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
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

  Widget _buildPassengerDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.people_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Passenger Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      // const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: TColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${bookingController.adults.length + bookingController.children.length + bookingController.infants.length} Passengers',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: TColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Adults Section
              if (bookingController.adults.isNotEmpty) ...[
                _buildPassengerTypeHeader(
                  'Adults',
                  bookingController.adults.length,
                  TColors.primary,
                ),
                const SizedBox(height: 12),
                ...bookingController.adults.asMap().entries.map((entry) {
                  final index = entry.key;
                  final adult = entry.value;
                  return _buildPassengerCard(
                    index: index + 1,
                    name:
                        '${adult.firstNameController.text} ${adult.lastNameController.text}',
                    type: 'Adult',
                    passport: adult.passportCnicController.text,
                    typeColor: TColors.primary,
                    typeIcon: Icons.person,
                  );
                }),
                // const SizedBox(height: 4),
              ],

              // Children Section
              if (bookingController.children.isNotEmpty) ...[
                _buildPassengerTypeHeader(
                  'Children',
                  bookingController.children.length,
                  const Color(0xFF10B981),
                ),
                const SizedBox(height: 12),
                ...bookingController.children.asMap().entries.map((entry) {
                  final index = entry.key;
                  final child = entry.value;
                  return _buildPassengerCard(
                    index: bookingController.adults.length + index + 1,
                    name:
                        '${child.firstNameController.text} ${child.lastNameController.text}',
                    type: 'Child',
                    passport: child.passportCnicController.text,
                    typeColor: const Color(0xFF10B981),
                    typeIcon: Icons.child_care,
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Infants Section
              if (bookingController.infants.isNotEmpty) ...[
                _buildPassengerTypeHeader(
                  'Infants',
                  bookingController.infants.length,
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 12),
                ...bookingController.infants.asMap().entries.map((entry) {
                  final index = entry.key;
                  final infant = entry.value;
                  return _buildPassengerCard(
                    index:
                        bookingController.adults.length +
                        bookingController.children.length +
                        index +
                        1,
                    name:
                        '${infant.firstNameController.text} ${infant.lastNameController.text}',
                    type: 'Infant',
                    passport: infant.passportCnicController.text,
                    typeColor: const Color(0xFFF59E0B),
                    typeIcon: Icons.baby_changing_station,
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerTypeHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerCard({
    required int index,
    required String name,
    required String type,
    required String passport,
    required Color typeColor,
    required IconData typeIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Serial number circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: typeColor.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Passenger info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(typeIcon, size: 16, color: typeColor),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.credit_card,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      passport.isNotEmpty ? passport : 'Not provided',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            passport.isNotEmpty
                                ? const Color(0xFF64748B)
                                : Colors.red.withOpacity(0.7),
                        fontStyle:
                            passport.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ticket status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF64748B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ticket #',
                style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
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
      totalPrice += multicityFareOptions.fold(
        0.0,
        (sum, option) => sum + option.price,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Price Breakdown',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Adult pricing
              if (bookingController.adults.isNotEmpty) ...[
                _buildPassengerPriceSection('Adult', adultPrice, currency),
                const SizedBox(height: 16),
              ],

              // Child pricing
              if (bookingController.children.isNotEmpty) ...[
                _buildPassengerPriceSection('Child', childPrice, currency),
                const SizedBox(height: 16),
              ],

              // Infant pricing
              if (bookingController.infants.isNotEmpty) ...[
                _buildPassengerPriceSection('Infant', infantPrice, currency),
                const SizedBox(height: 16),
              ],

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E293B).withOpacity(0.05),
                      const Color(0xFF334155).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1E293B).withOpacity(0.1),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${outboundFlight.currency} ${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    if (outboundFlight.pnrPricing != null &&
        outboundFlight.pnrPricing!.isNotEmpty) {
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

    return {'base': base, 'tax': tax, 'fee': fee, 'total': (base + tax + fee)};
  }

  Widget _buildPassengerPriceSection(
    String label,
    Map<String, double> price,
    String currency,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label Price',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            'Base Fare',
            '$currency ${price['base']!.toStringAsFixed(2)}',
          ),
          _buildPriceRow(
            'Taxes',
            '$currency ${price['tax']!.toStringAsFixed(2)}',
          ),
          _buildPriceRow(
            'Fees',
            '$currency ${price['fee']!.toStringAsFixed(2)}',
          ),
          const Divider(color: Color(0xFFE2E8F0)),
          _buildPriceRow(
            'Subtotal',
            '$currency ${price['total']!.toStringAsFixed(2)}',
            isSubtotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isSubtotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  isTotal || isSubtotal ? FontWeight.w600 : FontWeight.normal,
              color:
                  isTotal ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  isTotal || isSubtotal ? FontWeight.w600 : FontWeight.normal,
              color:
                  isTotal ? const Color(0xFF1E293B) : const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingPrintButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () => _generatePDF(),
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          label: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.print_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'Generate & Print Voucher',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
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
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
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
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
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
                      fareOption:
                          multicityFareOptions != null &&
                                  multicityFareOptions.length > index
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
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            pw.TableHelper.fromTextArray(
              context: context,
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['Sr', 'Name', 'Type', 'Passport#', 'Ticket #'],
              data: [
                ...bookingController.adults.map(
                  (adult) => [
                    '${bookingController.adults.indexOf(adult) + 1}',
                    '${adult.firstNameController.text} ${adult.lastNameController.text}',
                    'Adult',
                    adult.passportCnicController.text,
                    'N/A',
                  ],
                ),
                ...bookingController.children.map(
                  (child) => [
                    '${bookingController.adults.length + bookingController.children.indexOf(child) + 1}',
                    '${child.firstNameController.text} ${child.lastNameController.text}',
                    'Child',
                    child.passportCnicController.text,
                    'N/A',
                  ],
                ),
                ...bookingController.infants.map(
                  (infant) => [
                    '${bookingController.adults.length + bookingController.children.length + bookingController.infants.indexOf(infant) + 1}',
                    '${infant.firstNameController.text} ${infant.lastNameController.text}',
                    'Infant',
                    infant.passportCnicController.text,
                    'N/A',
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Price Breakdown
            pw.Text(
              'Price Breakdown',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            _buildPdfPriceRow(
              'Base Fare',
              '${outboundFlight.currency} ${outboundFareOption?.basePrice.toStringAsFixed(2) ?? '0.00'}',
            ),
            if (returnFareOption != null)
              _buildPdfPriceRow(
                'Return Base Fare',
                '${returnFlight?.currency} ${returnFareOption.basePrice.toStringAsFixed(2)}',
              ),
            _buildPdfPriceRow(
              'Taxes',
              '${outboundFlight.currency} ${outboundFareOption?.taxAmount.toStringAsFixed(2) ?? '0.00'}',
            ),
            if (returnFareOption != null)
              _buildPdfPriceRow(
                'Return Taxes',
                '${returnFlight?.currency} ${returnFareOption.taxAmount.toStringAsFixed(2)}',
              ),
            _buildPdfPriceRow(
              'Fees',
              '${outboundFlight.currency} ${outboundFareOption?.feeAmount.toStringAsFixed(2) ?? '0.00'}',
            ),
            if (returnFareOption != null)
              _buildPdfPriceRow(
                'Return Fees',
                '${returnFlight?.currency} ${returnFareOption.feeAmount.toStringAsFixed(2)}',
              ),
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
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
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
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                fareOption?.cabinName ?? 'ECONOMY',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${firstLeg['departure']['airport']} → ${lastLeg['arrival']['airport']}',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Departure: ${departureDateTime.day}-${departureDateTime.month}-${departureDateTime.year} ${departureDateTime.hour.toString().padLeft(2, '0')}:${departureDateTime.minute.toString().padLeft(2, '0')}',
              ),
              pw.Text('Duration: ${hours}h ${minutes}m'),
              pw.Text(
                'Arrival: ${arrivalDateTime.day}-${arrivalDateTime.month}-${arrivalDateTime.year} ${arrivalDateTime.hour.toString().padLeft(2, '0')}:${arrivalDateTime.minute.toString().padLeft(2, '0')}',
              ),
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
                    pw.Text(
                      '${flight.baggageAllowance.weight} ${flight.baggageAllowance.unit}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),
          if (fareOption != null)
            pw.Row(
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
                    pw.Text(
                      fareOption.mealCode == 'M' ? 'Included' : 'Not Included',
                    ),
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

  pw.Widget _buildPdfPriceRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
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
