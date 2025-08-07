import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../../utility/colors.dart';
import 'all_hotel_booking_controller.dart';
import 'model.dart';

class AllHotelBooking extends StatelessWidget {
  final AllHotelBookingController bookingController = Get.put(
    AllHotelBookingController(),
  );
  void _handlePrintAction(HotelBookingModel booking) async {
    try {
      final bookingData = await bookingController.getBookingDataForPdf(
        booking.bookingNumber,
      );

      // Create a PDF generator instance (you'll need to create this class)
      final pdfGenerator = HotelBookingPdfGenerator();
      final pdfBytes = await pdfGenerator.generatePdf(bookingData);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Booking_Voucher_${booking.bookingNumber}',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        foregroundColor: Colors.white,

        backgroundColor: TColors.background4,
        title: Text(
          'International Bookings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => bookingController.fetchHotelBookings(),
          ),
          IconButton(
            icon: Icon(Icons.print, color: Colors.white),
            onPressed: () {
              // Handle print action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // _buildDateFilter(),
          Expanded(child: _buildBookingsList()),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return Obx(() {
      // Show loading indicator
      if (bookingController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      // Show error message if any
      if (bookingController.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                bookingController.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => bookingController.fetchHotelBookings(),
                child: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      // Show empty state
      if (bookingController.bookings.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hotel_outlined, color: TColors.grey, size: 64),
              SizedBox(height: 16),
              Text(
                'No bookings found for the selected date range',
                textAlign: TextAlign.center,
                style: TextStyle(color: TColors.grey),
              ),
            ],
          ),
        );
      }

      // Show bookings list
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: bookingController.bookings.length,
        itemBuilder: (context, index) {
          final booking = bookingController.bookings[index];
          return _buildBookingCard(booking);
        },
      );
    });
  }

  Widget _buildBookingCard(HotelBookingModel booking) {
    Color statusColor;

    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'on request':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
    }

    // Determine booking source color based on booking number prefix
    String portalCode = booking.bookingNumber.split('-')[0];
    Color portalColor;

    switch (portalCode) {
      case 'ONETRVL':
        portalColor = Colors.blue;
        break;
      case 'TOCBK':
        portalColor = Colors.teal;
        break;
      case 'TDBK':
        portalColor = Colors.red;
        break;
      default:
        portalColor = Colors.purple;
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header with Serial Number and Booking Number
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: portalColor.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: portalColor,
                  radius: 14,
                  child: Text(
                    booking.serialNumber,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  booking.bookingNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TColors.text,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Booking Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                _buildInfoRow(Icons.event, "Date", booking.date),
                SizedBox(height: 12),

                // Booker and Guest
                _buildInfoRow(Icons.person, "Booker", booking.bookerName),
                SizedBox(height: 8),
                _buildInfoRow(Icons.people, "Guest", booking.guestName),
                SizedBox(height: 12),

                // Hotel and Location
                _buildInfoRow(Icons.hotel, "Hotel", booking.hotel),
                SizedBox(height: 8),
                _buildInfoRow(
                  Icons.location_on,
                  "Destination",
                  booking.destination,
                ),
                SizedBox(height: 12),

                // Check-in/Check-out
                _buildInfoRow(
                  Icons.calendar_month,
                  "Check-in/Check-out",
                  booking.checkinCheckout,
                ),
                SizedBox(height: 12),

                Divider(),
                SizedBox(height: 12),

                // Bottom Row with Price and Cancellation
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.attach_money,
                        "Price",
                        booking.price,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        Icons.event_busy,
                        "Cancellation",
                        booking.cancellationDeadline,
                        valueColor:
                            booking.cancellationDeadline.contains(
                                  "Non-Refundable",
                                )
                                ? Colors.red
                                : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Print Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.print),
                  label: Text('Print'),
                  onPressed: () => _handlePrintAction(booking),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: TColors.grey),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: TColors.grey)),
              SizedBox(height: 2),
              Text(value, style: TextStyle(color: valueColor ?? TColors.text)),
            ],
          ),
        ),
      ],
    );
  }
}

class HotelBookingPdfGenerator {
  Future<Uint8List> generatePdf(Map<String, dynamic> bookingData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(bookingData),
            pw.SizedBox(height: 20),
            _buildHotelInformation(bookingData),
            pw.SizedBox(height: 20),
            _buildGuestInformation(bookingData),
            pw.SizedBox(height: 20),
            _buildRoomDetailsTable(bookingData),
            pw.SizedBox(height: 20),
            _buildBookingPolicy(),
            pw.SizedBox(height: 20),
            _buildRefundPolicy(),
            pw.SizedBox(height: 20),
            _buildImportantNote(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(Map<String, dynamic> bookingData) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Stayinhotels.ae',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(
                  bookingData['status'] ?? 'CONFIRMED',
                  style: pw.TextStyle(
                    color: PdfColors.green800,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Booking No#: ${bookingData['bookingNumber']}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Support Contact No:\n+923219667909',
                style: pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
          pw.Divider(),
          pw.Text(
            'HOTEL VOUCHER',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildHotelInformation(Map<String, dynamic> bookingData) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'HOTEL INFORMATION',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'HOTEL NAME',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['hotelName'] ?? 'Unknown Hotel',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'LOCATION',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['destination'] ?? 'Unknown Location',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SPECIAL REQUESTS',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['specialRequests'] ?? 'None',
                      style: pw.TextStyle(fontSize: 12),
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

  pw.Widget _buildGuestInformation(Map<String, dynamic> bookingData) {
    // Parse dates for better formatting
    DateTime checkInDate;
    DateTime checkOutDate;
    try {
      checkInDate = DateTime.parse(bookingData['checkInDate']);
      checkOutDate = DateTime.parse(bookingData['checkOutDate']);
    } catch (e) {
      checkInDate = DateTime.now();
      checkOutDate = DateTime.now().add(Duration(days: 1));
    }

    final formattedCheckIn = DateFormat('dd MMM yyyy').format(checkInDate);
    final formattedCheckOut = DateFormat('dd MMM yyyy').format(checkOutDate);

    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RESERVATION INFORMATION',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LEAD GUEST',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['bookerName'] ?? 'Unknown',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CHECK-IN',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      formattedCheckIn,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CHECK-OUT',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      formattedCheckOut,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ROOMS',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['rooms'] ?? '1',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'NIGHTS',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['nights'] ?? '1',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PRICE',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['price'] ?? 'N/A',
                      style: pw.TextStyle(fontSize: 12),
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

  pw.Widget _buildRoomDetailsTable(Map<String, dynamic> bookingData) {
    final List<dynamic> guestDetails = bookingData['guestDetails'] ?? [];

    // Group guests by room number
    Map<String, List<Map<String, dynamic>>> guestsByRoom = {};
    for (var guest in guestDetails) {
      String roomNo = guest['od_rno']?.toString() ?? '1';
      if (!guestsByRoom.containsKey(roomNo)) {
        guestsByRoom[roomNo] = [];
      }
      guestsByRoom[roomNo]!.add(guest);
    }

    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ROOM DETAILS',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(3),
              3: pw.FlexColumnWidth(1),
              4: pw.FlexColumnWidth(1),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Room No.', isHeader: true),
                  _buildTableCell('Room Type / Board Basis', isHeader: true),
                  _buildTableCell('Guest Name', isHeader: true),
                  _buildTableCell('Adults', isHeader: true),
                  _buildTableCell('Children', isHeader: true),
                ],
              ),
              // Data rows
              ...guestsByRoom.entries.map((entry) {
                String roomNo = entry.key;
                List<Map<String, dynamic>> roomGuests = entry.value;

                // Count adults and children in this room
                int adultCount = 0;
                int childCount = 0;

                List<String> guestNames = [];

                for (var guest in roomGuests) {
                  String guestFor = guest['od_gfor']?.toString() ?? '';
                  String guestTitle = guest['od_gtitle']?.toString() ?? '';
                  String firstName = guest['od_gfname']?.toString() ?? '';
                  String lastName = guest['od_glname']?.toString() ?? '';

                  guestNames.add('$guestTitle $firstName $lastName');

                  if (guestFor.toLowerCase().contains('adult')) {
                    adultCount++;
                  } else if (guestFor.toLowerCase().contains('child')) {
                    childCount++;
                  }
                }

                return pw.TableRow(
                  children: [
                    _buildTableCell(roomNo),
                    _buildTableCell('Premium Room / Bed & Breakfast'),
                    _buildTableCell(guestNames.join(', ')),
                    _buildTableCell(adultCount.toString()),
                    _buildTableCell(childCount.toString()),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBookingPolicy() {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Booking Policy',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '• The usual check-in time is 12:00-14:00 PM (this may vary).',
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Rooms may not be available for early check-in unless requested.',
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Hotel reservation may be cancelled automatically after 18:00 hours if hotel is not informed about the appointment time of the arrival.',
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• The total cost is between 10-12.00 hours between the high-way (non-toll) & the toll road with different destinations.',
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildRefundPolicy() {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Booking Refund Policy',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Booking payable as per reservation details. Please collect all extras directly from (sleep in) departure. All matters issued are on the condition that all persons acknowledge that in person to taking part must be made, as people for which we shall not be held preliminary. Some may apply, delay or misconnection caused to passenger as a result of any such arrangements. We will not accept any responsibility for additional expenses due to tax changes or delay in air, road, rail, sea or indeed any form of transport.',
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildImportantNote() {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.pink50,
        border: pw.Border.all(width: 1, color: PdfColors.pink100),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'IMPORTANT NOTE',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red900,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Check your Reservation details carefully and inform us immediately if you need any further clarification, please do not hesitate to contact us.',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.red900),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }
}

Future<Uint8List> generatePdf(Map<String, dynamic> bookingData) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          _buildHeader(bookingData),
          pw.SizedBox(height: 20),
          // _buildHotelInformation(bookingData),
          pw.SizedBox(height: 20),
          _buildGuestInformation(bookingData),
          pw.SizedBox(height: 20),
          _buildBookingPolicy(),
          pw.SizedBox(height: 20),
          _buildRefundPolicy(),
          pw.SizedBox(height: 20),
          _buildImportantNote(),
        ];
      },
    ),
  );

  return pdf.save();
}

pw.Widget _buildHeader(Map<String, dynamic> bookingData) {
  return pw.Container(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Stayinhotels.ae',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Booking No#: ${bookingData['bookingNumber']}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'Support Contact No:\n+923219667909',
              style: pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.right,
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _buildHotelInformation(Map<String, dynamic> bookingData) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'HOTEL NAME',
        style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
      ),
      pw.Text(bookingData['hotelName'], style: pw.TextStyle(fontSize: 14)),
      pw.Text(bookingData['destination'], style: pw.TextStyle(fontSize: 12)),
      pw.SizedBox(height: 10),
      pw.Text(
        'HOTEL LOCATION',
        style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
      ),
      // Map placeholder since we can't include actual maps
      pw.Container(
        height: 100,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Center(child: pw.Text('Map Location')),
      ),
    ],
  );
}

pw.Widget _buildGuestInformation(Map<String, dynamic> bookingData) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('LEAD GUEST'),
              pw.Text(bookingData['bookerName']),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [pw.Text('ROOM(S)'), pw.Text(bookingData['rooms'])],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [pw.Text('NIGHT(S)'), pw.Text(bookingData['nights'])],
          ),
        ],
      ),
      pw.SizedBox(height: 15),
      _buildDateInformation(bookingData),
      pw.SizedBox(height: 15),
      _buildRoomDetailsTable(bookingData),
    ],
  );
}

pw.Widget _buildDateInformation(Map<String, dynamic> bookingData) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('CHECK-IN'),
          pw.Text(
            DateFormat(
              'dd MMM yyyy',
            ).format(DateTime.parse(bookingData['checkInDate'])),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('CHECK-OUT'),
          pw.Text(
            DateFormat(
              'dd MMM yyyy',
            ).format(DateTime.parse(bookingData['checkOutDate'])),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildRoomDetailsTable(Map<String, dynamic> bookingData) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300),
    children: [
      // Header
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          _buildTableCell('Room No'),
          _buildTableCell('Room Type / Board Basis'),
          _buildTableCell('Guest Name'),
          _buildTableCell('Adult(s)'),
          _buildTableCell('Children'),
        ],
      ),
      // Data rows from bookingData['guestDetails']
      ...List<pw.TableRow>.generate(
        (bookingData['guestDetails'] as List).length,
        (index) => pw.TableRow(
          children: [
            _buildTableCell((index + 1).toString()),
            _buildTableCell('Standard Room / Bed & Breakfast'),
            _buildTableCell(
              '${bookingData['guestDetails'][index]['od_gtitle']} ${bookingData['guestDetails'][index]['od_gfname']} ${bookingData['guestDetails'][index]['od_glname']}',
            ),
            _buildTableCell('2'),
            _buildTableCell('0'),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _buildBookingPolicy() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'Booking Policy',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 5),
      pw.Text('• The usual check-in time is 12:00-14:00 PM (this may vary).'),
      pw.Text(
        '• Rooms may not be available for early check-in unless requested.',
      ),
      pw.Text(
        '• Hotel reservation may be cancelled automatically after 18:00 hours if hotel is not informed about the appointment time of the arrival.',
      ),
      pw.Text(
        '• The total cost is between 10-12.00 hours between the high-way (non-toll) & the toll road with different destinations.',
      ),
    ],
  );
}

pw.Widget _buildRefundPolicy() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'Booking Refund Policy',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 5),
      pw.Text(
        'Booking payable as per reservation details. Please collect all extras directly from (sleep in) departure. All matters issued are on the condition that all persons acknowledge that in person to taking part must be made, as people for which we shall not be held preliminary. Some may apply, delay or misconnection caused to passenger as a result of any such arrangements. We will not accept any responsibility for additional expenses due to tax changes or delay in air, road, rail, sea or indeed any form of transport.',
        style: pw.TextStyle(fontSize: 10),
      ),
    ],
  );
}

pw.Widget _buildImportantNote() {
  return pw.Container(
    padding: pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.pink50,
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Text(
      'Important Note - Check your Reservation details carefully and inform us immediately if you need any further clarification, please do not hesitate to contact us.',
      style: pw.TextStyle(fontSize: 10, color: PdfColors.red900),
    ),
  );
}

pw.Widget _buildTableCell(String text) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(5),
    child: pw.Text(text, style: pw.TextStyle(fontSize: 10)),
  );
}
