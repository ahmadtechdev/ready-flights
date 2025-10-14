// Create a new file: lib/views/flight/seat_selection/seat_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/services/api_service_airblue.dart';
import 'package:ready_flights/utility/colors.dart';
import 'package:ready_flights/views/flight/booking_flight/airblue/flight_print_voucher.dart';
import 'package:ready_flights/views/flight/search_flights/airblue/airblue_flight_model.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> pnrResponse;
  final int totalPassengers;
  final AirBlueFlight outboundFlight;
  final AirBlueFlight? returnFlight;
  final AirBlueFareOption? outboundFareOption;
  final AirBlueFareOption? returnFareOption;

  const SeatSelectionScreen({
    super.key,
    required this.pnrResponse,
    required this.totalPassengers,
    required this.outboundFlight,
    this.returnFlight,
    this.outboundFareOption,
    this.returnFareOption,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  Map<String, dynamic>? seatMapData;
  Map<int, String> selectedSeats = {}; // passengerIndex -> seatNumber
  Map<int, String> selectedSeatRows = {}; // passengerIndex -> rowNumber
  Map<int, double> selectedSeatPrices = {}; // passengerIndex -> price
  bool isLoading = true;
  int selectedPassengerIndex = 0;
  bool isPriceBoxExpanded = false;

  // All possible seat letters in order
  final List<String> seatLetters = ['A', 'B', 'C', 'D', 'E', 'F'];
  final int totalRows = 38;

  @override
  void initState() {
    super.initState();
    _loadSeatMap();
  }

  Future<void> _loadSeatMap() async {
    try {
      final firstLeg = widget.outboundFlight.legSchedules.first;
      final departureDateTime = firstLeg['departure']['dateTime'];
      final flightNumber = widget.outboundFlight.id.split('-').first;

      print('Loading seat map for:');
      print('Flight: $flightNumber');
      print('Departure: ${firstLeg['departure']['airport']}');
      print('Arrival: ${firstLeg['arrival']['airport']}');
      print('DateTime: $departureDateTime');

      final response = await AirBlueFlightApiService().getAirBlueSeatMap(
        departureDateTime: departureDateTime,
        flightNumber: flightNumber,
        departureAirport: firstLeg['departure']['airport'],
        arrivalAirport: firstLeg['arrival']['airport'],
        operatingAirlineCode: widget.outboundFlight.airlineCode,
        pnr: widget.pnrResponse['pnr'],
        instance: widget.pnrResponse['Instance'],
        fareType: 'EV',
        resBookDesigCode: 'H',
        cabinClass: 'Y',
      );

      print('Seat map loaded successfully');

      setState(() {
        seatMapData = response;
        isLoading = false;
      });
    } on ApiException catch (e) {
      print('API Exception: ${e.message}');
      setState(() {
        isLoading = false;
      });

      Get.dialog(
        AlertDialog(
          title: const Text('Seat Map Not Available'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unable to load seat map: ${e.message}'),
              const SizedBox(height: 16),
              const Text(
                'You can skip seat selection and proceed with your booking.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text('Go Back'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _skipSeatSelection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
              ),
              child: const Text('Skip Seat Selection'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      print('General Exception: $e');
      setState(() {
        isLoading = false;
      });

      Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to load seat map: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text('Go Back'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _skipSeatSelection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
              ),
              child: const Text('Skip Seat Selection'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  void _selectSeat(String seatNumber, String rowNumber, double price) {
    setState(() {
      // Check if seat is already selected by another passenger
      if (selectedSeats.values.contains(seatNumber)) {
        Get.snackbar(
          'Error',
          'This seat is already selected',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      selectedSeats[selectedPassengerIndex] = seatNumber;
      selectedSeatRows[selectedPassengerIndex] = rowNumber;
      selectedSeatPrices[selectedPassengerIndex] = price;

      // Auto-advance to next passenger
      if (selectedPassengerIndex < widget.totalPassengers - 1) {
        selectedPassengerIndex++;
      }
    });
  }

  Future<void> _confirmSeats() async {
    if (selectedSeats.length != widget.totalPassengers) {
      Get.snackbar(
        'Error',
        'Please select seats for all ${widget.totalPassengers} passengers',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
          ),
        ),
        barrierDismissible: false,
      );

      final pnr = widget.pnrResponse['pnr'];
      final instance = widget.pnrResponse['pnrJson']['soap\$Envelope']
          ['soap\$Body']['AirBookResponse']['AirBookResult']
          ['AirReservation']['BookingReferenceID'][0]['Instance'];

      final seatRequests = selectedSeats.entries.map((entry) {
        return {
          'flightRefNumber': '1',
          'travelerRefNumber': (entry.key + 1).toString(),
          'seatNumber': entry.value,
          'rowNumber': selectedSeatRows[entry.key]!,
        };
      }).toList();

      final response = await AirBlueFlightApiService().updateAirBlueSeats(
        pnr: pnr,
        instance: instance,
        seatRequests: seatRequests,
      );

      Get.back(); // Close loading

      Get.snackbar(
        'Success',
        'Seats updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      Get.offAll(
        () => FlightBookingDetailsScreen(
          outboundFlight: widget.outboundFlight,
          returnFlight: widget.returnFlight,
          outboundFareOption: widget.outboundFareOption,
          returnFareOption: widget.returnFareOption,
          pnrResponse: widget.pnrResponse,
          selectedSeats: selectedSeats,
        ),
      );
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Failed to update seats: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _skipSeatSelection() {
    Get.offAll(
      () => FlightBookingDetailsScreen(
        outboundFlight: widget.outboundFlight,
        returnFlight: widget.returnFlight,
        outboundFareOption: widget.outboundFareOption,
        returnFareOption: widget.returnFareOption,
        pnrResponse: widget.pnrResponse,
        selectedSeats: null,
      ),
    );
  }

  // Get seat data for a specific row and seat letter
  Map<String, dynamic>? _getSeatData(String rowNumber, String seatLetter) {
    if (seatMapData == null) return null;

    try {
      final seatMapResponse = seatMapData!['soap\$Envelope']['soap\$Body']
          ['AirSeatMapResponse']['AirSeatMapResult']['SeatMapResponses']
          ['SeatMapResponse'];

      final cabinClass = seatMapResponse['SeatMapDetails']['CabinClass'];
      final rows = cabinClass['RowInfo'] as List;

      for (var row in rows) {
        if (row['RowNumber'] == rowNumber) {
          final seats = row['SeatInfo'] as List;
          for (var seat in seats) {
            final seatNum = seat['Summary']['SeatNumber']?.toString().trim();
            if (seatNum == seatLetter) {
              return seat;
            }
          }
        }
      }
    } catch (e) {
      print('Error getting seat data: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Select Seats',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _skipSeatSelection,
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
              ),
            )
          : Column(
              children: [
                _buildPassengerSelector(),
                Expanded(child: _buildSeatMap()),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildPassengerSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select passenger:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.totalPassengers,
              itemBuilder: (context, index) {
                final isSelected = selectedPassengerIndex == index;
                final hasSeat = selectedSeats.containsKey(index);

                return GestureDetector(
                  onTap: () => setState(() => selectedPassengerIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? TColors.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: hasSeat
                            ? (isSelected ? Colors.white : Colors.green)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'P${index + 1}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (hasSeat) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.check_circle,
                            color: isSelected ? Colors.white : Colors.green,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedSeats.containsKey(selectedPassengerIndex))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.airline_seat_recline_normal,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Seat ${selectedSeats[selectedPassengerIndex]}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (selectedSeatPrices[selectedPassengerIndex] != null &&
                        selectedSeatPrices[selectedPassengerIndex]! > 0)
                      Text(
                        ' • PKR ${selectedSeatPrices[selectedPassengerIndex]!.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeatMap() {
    if (seatMapData == null) {
      return const Center(
        child: Text(
          'No seat map available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLegend(),
          const SizedBox(height: 20),
          _buildAirplaneFront(),
          const SizedBox(height: 20),
          // Build all 38 rows
          ...List.generate(totalRows, (index) {
            final rowNumber = (index + 1).toString();
            return _buildSeatRow(rowNumber);
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(Colors.green[400]!, 'Available'),
          _buildLegendItem(Colors.grey[400]!, 'Occupied'),
          _buildLegendItem(TColors.primary, 'Selected'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAirplaneFront() {
    return Container(
      height: 40,
      child: CustomPaint(
        size: const Size(double.infinity, 40),
        painter: AirplaneFrontPainter(),
      ),
    );
  }

  Widget _buildSeatRow(String rowNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left row number
          SizedBox(
            width: 28,
            child: Text(
              rowNumber,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
          // Seats
          ...seatLetters.map((letter) {
            // Add aisle space after C
            if (letter == 'D') {
              return Row(
                children: [
                  const SizedBox(width: 16), // Aisle space
                  _buildSeat(rowNumber, letter),
                ],
              );
            }
            return _buildSeat(rowNumber, letter);
          }),
          // Right row number
          SizedBox(
            width: 28,
            child: Text(
              rowNumber,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(String rowNumber, String seatLetter) {
    final seatData = _getSeatData(rowNumber, seatLetter);
    final seatNumber = '$rowNumber$seatLetter';

    bool isAvailable = false;
    bool isOccupied = true; // Default to occupied if no data
    double price = 0;

    if (seatData != null) {
      isAvailable = seatData['Summary']['AvailableInd'] == 'true';
      isOccupied = seatData['Summary']['OccupiedInd'] == 'true';

      // Get price
      try {
        final service = seatData['Service'];
        if (service != null && service['Fee'] != null) {
          price = double.parse(service['Fee']['Amount'].toString());
        }
      } catch (e) {
        // Price not available
      }
    }

    final isSelectedByCurrent = selectedSeats[selectedPassengerIndex] == seatNumber;
    final isSelectedByOther = selectedSeats.values.contains(seatNumber) && !isSelectedByCurrent;

    return GestureDetector(
      onTap: (isAvailable && !isOccupied && !isSelectedByOther)
          ? () => _selectSeat(seatNumber, rowNumber, price)
          : null,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelectedByCurrent
              ? TColors.primary
              : isSelectedByOther
                  ? TColors.primary.withOpacity(0.6)
                  : (isAvailable && !isOccupied)
                      ? Colors.green[400]
                      : Colors.grey[400],
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            if (isSelectedByCurrent)
              BoxShadow(
                color: TColors.primary.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              seatLetter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (price > 0 && isAvailable)
              Text(
                price >= 1000 ? '${(price / 1000).toStringAsFixed(0)}k' : price.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final totalPrice = selectedSeatPrices.values.fold<double>(0, (sum, price) => sum + price);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Collapsible Price Details
            if (totalPrice > 0 || selectedSeats.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => isPriceBoxExpanded = !isPriceBoxExpanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPriceBoxExpanded ? Icons.expand_more : Icons.chevron_right,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Seat Details',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      if (totalPrice > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'PKR ${totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: TColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            // Expanded Details
            if (isPriceBoxExpanded && selectedSeats.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Column(
                  children: selectedSeats.entries.map((entry) {
                    final passengerNum = entry.key + 1;
                    final seat = entry.value;
                    final price = selectedSeatPrices[entry.key] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: TColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    'P$passengerNum',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: TColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Seat $seat',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            price > 0 ? 'PKR ${price.toStringAsFixed(0)}' : 'Free',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: price > 0 ? Colors.grey[700] : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${selectedSeats.length} of ${widget.totalPassengers} selected',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (selectedSeats.length < widget.totalPassengers)
                          Text(
                            'Select ${widget.totalPassengers - selectedSeats.length} more',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _confirmSeats,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
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
}

class AirplaneFrontPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width * 0.42, size.height * 0.8);
    path.lineTo(size.width * 0.58, size.height * 0.8);
    path.close();

    canvas.drawPath(path, paint);

    // Draw cockpit window
    final windowPaint = Paint()
      ..color = Colors.blue[200]!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.3),
      8,
      windowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}