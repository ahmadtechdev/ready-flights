// all_flight_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ready_flights/b2b/all_flight_booking/model.dart';

import '../../utility/colors.dart';
import 'all_flight_booking_controler.dart';

class AllFlightBookingScreen extends StatelessWidget {
  final  AllFlightBookingController controller = Get.put(
    AllFlightBookingController(),
  );

  AllFlightBookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: TColors.background4,
        title: const Text(
          'All Flights Booking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          Obx(
            () =>
                controller.isLoading.value
                    ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                    : IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: controller.loadBookings,
                      tooltip: 'Refresh data',
                    ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateFilter(),
          _buildSearchBar(),
          _buildStatCards(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (controller.hasError.value) {
                return _buildErrorWidget();
              } else if (controller.filteredBookings.isEmpty) {
                return _buildEmptyStateWidget();
              } else {
                return _buildBookingCards();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date From',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.selectFromDate(Get.context!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(controller.fromDate.value),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date To',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.selectToDate(Get.context!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(controller.toDate.value),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade700,
      child: TextField(
        controller: controller.searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search bookings...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          filled: true,
          fillColor: Colors.blue.shade900,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black87,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children: [
              _buildStatCard(
                'Total Bookings',
                controller.totalBookings.value,
                Colors.blue,
              ),
              _buildStatCard(
                'Confirmed',
                controller.confirmedBookings.value,
                Colors.green,
              ),
              _buildStatCard(
                'On Hold',
                controller.onHoldBookings.value,
                Colors.amber,
              ),
              _buildStatCard(
                'Cancelled',
                controller.cancelledBookings.value,
                Colors.red,
              ),
              _buildStatCard(
                'Error',
                controller.errorBookings.value,
                Colors.blueGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            'Error loading bookings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: TColors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.retryLoading,
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight_takeoff, color: TColors.grey, size: 60),
          const SizedBox(height: 16),
          Text(
            'No flight bookings found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Try changing the date range or model_controllers criteria',
              textAlign: TextAlign.center,
              style: TextStyle(color: TColors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCards() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = controller.filteredBookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    Color statusColor;

    switch (booking.status) {
      case 'Confirmed':
        statusColor = Colors.green;
        break;
      case 'On Hold':
      case 'On Request':
        statusColor = Colors.orange;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.background4,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking ID',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      booking.bookingId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  'Booking Date',
                  DateFormat(
                    'E, dd MMM yyyy\nHH:mm:ss',
                  ).format(booking.creationDate),
                ),
                const Divider(),
                _buildInfoRow('PNR', booking.pnr),
                const Divider(),
                _buildInfoRow('Supplier', booking.supplier),
                const Divider(),
                _buildInfoRow('Trip', booking.trip),
                const Divider(),
                _buildInfoRow('Passenger', booking.passengerNames),
                const Divider(),
                _buildInfoRow(
                  'Travel Date',
                  DateFormat('E, dd MMM yyyy').format(booking.departureDate),
                ),
                const Divider(),
                _buildInfoRow(
                  'Total Price',
                  '${booking.currency.isNotEmpty ? booking.currency : "PKR"} ${booking.totalSell.toStringAsFixed(0)}',
                ),

                if (booking.deadlineTime != null) ...[
                  const Divider(),
                  _buildInfoRow(
                    'Deadline',
                    DateFormat(
                      'E, dd MMM yyyy HH:mm',
                    ).format(booking.deadlineTime!),
                    isHighlighted: true,
                  ),
                ],

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => controller.viewBookingDetails(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.visibility, color: Colors.white),
                      label: const Text(
                        'View',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => controller.printTicket(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.print, color: Colors.white),
                      label: const Text(
                        'Print Ticket',
                        style: TextStyle(color: Colors.white),
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

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: TColors.grey,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? TColors.third : TColors.text,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// flight_pdf_generator.dart

class FlightPdfGenerator {
  // Generate and print a PDF for the given booking
  static Future<void> generateAndPrintPdf(BookingModel booking) async {
    final pdf = await generatePdf(booking);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf);
  }

  // Generate PDF document for the booking
  static Future<Uint8List> generatePdf(BookingModel booking) async {
    // Create a PDF document
    final pdf = pw.Document();

    // Use default fonts
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return [
            _buildHeader(booking, font, fontBold),
            _buildDetailsTable(booking, font, fontBold),
            _buildPassengerDetails(booking, font, fontBold),
            _buildNoticeSection(font, fontBold),
            _buildRulesSection(font, fontBold),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Build the header section of the PDF
  static pw.Widget _buildHeader(
    BookingModel booking,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Journey Online',
              style: pw.TextStyle(font: fontBold, fontSize: 18),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Pakistan',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
                pw.Text(
                  '+92 333733 5222',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'Itinerary Receipt',
          style: pw.TextStyle(font: fontBold, fontSize: 16),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Below are the details of your electronic ticket. Note: All timings are local',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.SizedBox(),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Booking Reference:',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Agency PNR:',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.grey700),
      ],
    );
  }

  // Build the flight details table section
  static pw.Widget _buildDetailsTable(
    BookingModel booking,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 10),
        pw.Text(
          'FLIGHT INFORMATION',
          style: pw.TextStyle(font: fontBold, fontSize: 12),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Table header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _headerCell('TO - LTO', font),
                _headerCell('FROM', font),
                _headerCell('TO', font),
                _headerCell('STATUS', font),
              ],
            ),
            // Flight details
            pw.TableRow(
              children: [
                _contentCell('', font),
                _contentCell(
                  '${booking.tripSector.split("-to-")[0]}\n(${_getAirportCode(booking.tripSector.split("-to-")[0])})',
                  font,
                ),
                _contentCell(
                  '${booking.tripSector.split("-to-")[1]}\n(${_getAirportCode(booking.tripSector.split("-to-")[1])})',
                  font,
                ),
                _contentCell(
                  'Status: ${booking.status}\nClass: Y (E)\nPNR: ${booking.pnr}',
                  font,
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 30),
      ],
    );
  }

  // Helper function to get airport code (mocked for demo)
  static String _getAirportCode(String cityName) {
    final codes = {
      'Dubai': 'DXB',
      'Quaid e Azam International': 'KHI',
      'Lahore': 'LHE',
      'Islamabad': 'ISB',
      'Karachi': 'KHI',
    };
    return codes[cityName] ?? 'XXX';
  }

  // Build the passenger details section
  static pw.Widget _buildPassengerDetails(
    BookingModel booking,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PASSENGER & TICKET DETAILS',
          style: pw.TextStyle(font: fontBold, fontSize: 12),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Table header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _headerCell('TRAVELLER NAME', font),
                _headerCell('FREQUENT FLYER', font),
                _headerCell('TICKET NO.', font),
              ],
            ),
            // Passenger details
            pw.TableRow(
              children: [
                _contentCell(booking.passengerNames, font),
                _contentCell('-', font),
                _contentCell('-', font),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 30),
      ],
    );
  }

  // Build the notice section
  static pw.Widget _buildNoticeSection(pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Notice', style: pw.TextStyle(font: fontBold, fontSize: 12)),
        pw.SizedBox(height: 5),
        pw.Text(
          '1. Refund Policy All Refunds are governed by the rule published by the airline which is self explanatory and shown in the model_controllers results page.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  // Build the rules section
  static pw.Widget _buildRulesSection(pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Rules', style: pw.TextStyle(font: fontBold, fontSize: 12)),
        pw.SizedBox(height: 5),
        pw.Text(
          '1. Please Report Airline Check In Counter 4 Hour Before Flight Departure.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '2. Please Reconfirm the Ticket Before 48 Hour of Flight Departure.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '3. All Visa and Travel Documents are Traveler Own Responsibility.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '4. Please Check in with all your Essential Travel Documents.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '5. All NON-PK (market / LCC tickets are NON-Refundable / NON-Changeable.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
      ],
    );
  }

  // Helper method to create header cells
  static pw.Widget _headerCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 10)),
    );
  }

  // Helper method to create content cells
  static pw.Widget _contentCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 10)),
    );
  }
}
