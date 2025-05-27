import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../../../../utility/colors.dart';
import '../../../hotel/guests/guests_controller.dart';
import '../../../hotel/hotel_date_controller.dart';
import '../../search_hotel_controller.dart';
import '../booking_controller.dart';

class HotelVoucherScreen extends StatelessWidget {
  final SearchHotelController searchHotelController =
      Get.find<SearchHotelController>();
  final HotelDateController hotelDateController =
      Get.find<HotelDateController>();
  final GuestsController guestsController = Get.find<GuestsController>();
  final BookingController bookingController = Get.put(BookingController());

  HotelVoucherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFAB00),
        title: const Text(
          "Booking Voucher",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              _printVoucher(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [_buildVoucherCard(context)]),
        ),
      ),
    );
  }

  // Function to get a static map image
  Future<Uint8List?> getStaticMapImage(
    double latitude,
    double longitude,
    String apiKey,
  ) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude'
          '&zoom=14&size=600x300&maptype=roadmap'
          '&markers=color:red%7C$latitude,$longitude'
          '&key=$apiKey';

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Request timed out'),
          );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Error fetching map: Status ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception fetching map image: $e');
      return null;
    }
  }

  // Use this in your PDF generation
  Future<pw.Widget> buildMapWidgetWithFallback(
    double latitude,
    double longitude,
    String hotelName,
  ) async {
    try {
      // First try the API approach
      final apiKey = 'AIzaSyC41LiUPWVsRuRVG5LDSYl48PFZ3zX0tOc';
      final mapImageBytes = await getStaticMapImage(
        latitude,
        longitude,
        apiKey,
      );

      if (mapImageBytes != null) {
        return pw.Container(
          height: 120,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.ClipRRect(
            child: pw.Image(
              pw.MemoryImage(mapImageBytes),
              fit: pw.BoxFit.cover,
            ),
          ),
        );
      } else {
        // If API fails, use a pre-bundled placeholder map image from assets
        final ByteData placeholderData = await rootBundle.load(
          'assets/img/map.png',
        );
        final Uint8List placeholderBytes = placeholderData.buffer.asUint8List();

        return pw.Container(
          height: 120,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Stack(
            children: [
              pw.ClipRRect(
                child: pw.Image(
                  pw.MemoryImage(placeholderBytes),
                  fit: pw.BoxFit.cover,
                ),
              ),
              pw.Positioned(
                bottom: 4,
                right: 4,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  color: PdfColors.white,
                  child: pw.Text(
                    'Lat: $latitude, Long: $longitude',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error in buildMapWidgetWithFallback: $e');
      // Last resort text-only fallback
      return pw.Container(
        height: 120,
        width: double.infinity,
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              'Map unavailable',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 4),
            pw.Text(hotelName, textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 4),
            pw.Text(
              'Latitude: $latitude, Longitude: $longitude',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      );
    }
  }

  pw.Widget _buildPdfBulletPoint(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Expanded(
            child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Future<void> _printVoucher(BuildContext context) async {
    try {
      // Get latitude, longitude, and hotel name
      final latitude =
          double.tryParse(searchHotelController.lat.value) ?? 24.4672;
      final longitude =
          double.tryParse(searchHotelController.lon.value) ?? 39.6170;
      final hotelName =
          searchHotelController.hotelName.value.isNotEmpty
              ? searchHotelController.hotelName.value
              : 'Leader Al Muna Kareem Hotel';

      // Call generatePdf with latitude, longitude, and hotelName
      final pdf = await generatePdf(latitude, longitude, hotelName);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf,
        name: 'Hotel_Voucher_${bookingController.booking_num.value}',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Printing failed: $e')));
    }
  }

  Future<pw.MemoryImage?> _loadLogoImage() async {
    try {
      final ByteData data = await rootBundle.load('assets/img/newLogo.png');
      final Uint8List bytes = data.buffer.asUint8List();
      return pw.MemoryImage(bytes);
    } catch (e) {
      print('Error loading logo: $e');
      return null; // Return null if there's an error
    }
  }

  Future<Uint8List> generatePdf(
    double latitude,
    double longitude,
    String hotelName,
  ) async {
    final pdf = pw.Document();
    final mapWidget = await buildMapWidgetWithFallback(
      latitude,
      longitude,
      hotelName,
    );
    final hotelAddress =
        'Omar Bin Al Katab Street PO Box 2961, Central Area, Madina 9055';

    pw.MemoryImage? logoImage = await _loadLogoImage();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        // Set maxPages to a higher number to allow for overflow
        maxPages: 10,
        build: (pw.Context context) {
          return [
            // Header
            // pw.Container(
            //   padding: const pw.EdgeInsets.all(10),
            //   decoration: pw.BoxDecoration(
            //     color: PdfColors.amber,
            //     borderRadius: pw.BorderRadius.circular(8),
            //   ),
            //   child: pw.Text(
            //     'Booking Voucher',
            //     style: pw.TextStyle(
            //       color: PdfColors.white,
            //       fontWeight: pw.FontWeight.bold,
            //       fontSize: 24,
            //     ),
            //   ),
            // ),
            pw.SizedBox(height: 20),
            // Rest of the content follows...
            // (all the existing content from the current build method)
            // Voucher Header
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      logoImage != null
                          ? pw.Image(logoImage, height: 30)
                          : pw.Container(
                            color: PdfColors.black,
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: pw.Text(
                              'Stayinhotels.ae',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Booking No#',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.Text(
                        '${bookingController.booking_num.value.toString()}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Supp. Ref:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Support Contact No:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.Text(
                        '+923219667909',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            // Hotel Info
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'HOTEL NAME',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    hotelName,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    hotelAddress,
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      pw.Text(
                        'CITY / COUNTRY',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        'country',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'HOTEL LOCATION',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Container(
                    height: 80,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Stack(
                      children: [
                        mapWidget,
                        pw.Positioned(
                          right: 8,
                          bottom: 8,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(4),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Row(
                              children: [
                                pw.Text(
                                  'Google Maps Location',
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            // Guest Info
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'LEAD GUEST',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${bookingController.firstNameController.text} ${bookingController.lastNameController.text}',
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'ROOM(S)',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${guestsController.roomCount.value}',
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'NIGHT(S)',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${hotelDateController.nights.value}',
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            // Date Info
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CHECK-IN',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(hotelDateController.checkInDate.value),
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'CHECK-OUT',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(hotelDateController.checkOutDate.value),
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            // Room Info
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'ROOM DETAILS',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(2),
                      2: const pw.FlexColumnWidth(3),
                      3: const pw.FlexColumnWidth(1),
                      4: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          _buildPdfTableHeaderCell('Room No'),
                          _buildPdfTableHeaderCell('Room Type / Board Basis'),
                          _buildPdfTableHeaderCell('Guest Name'),
                          _buildPdfTableHeaderCell('Adult(s)'),
                          _buildPdfTableHeaderCell('Children'),
                        ],
                      ),
                      ...List.generate(
                        guestsController.roomCount.value,
                        (index) => _buildPdfRoomRow(index + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            // Booking Policy
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Booking Policy',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  _buildPdfBulletPoint(
                    'The usual check-in time is 12:00-14:00 PM (this may vary).',
                  ),
                  _buildPdfBulletPoint(
                    'Rooms may not be available for early check-in unless requested.',
                  ),
                  _buildPdfBulletPoint(
                    'Hotel reservation may be canceled automatically after 18:00 hours if hotel is not informed about the appointment time of the arrival.',
                  ),
                  _buildPdfBulletPoint(
                    'The total cost is between 10-12.00 hours between the high-way (non-toll) & the toll road with different destinations. And the checkout may involve additional charges.',
                  ),
                  _buildPdfBulletPoint(
                    'For any specific system related to particular hotel, kindly reach out to our support team for assistance.',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            // Booking Refund Policy
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Booking Refund Policy',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Booking payable as per reservation details. Please collect all extras directly from (sleep in) departure. All matters issued are on the condition that all persons acknowledge that in person to taking part must be made, as people for which we shall not be liable for damage, loss, injury, delay or inconvenience caused to passenger as a result of any such arrangements. We will not accept any responsibility for additional expenses due to the changes or delay in air, road, rail sea or indeed any form of transport.',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            // Important Notes
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.red50,
                border: pw.Border.all(color: PdfColors.red200),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '! ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Important Notes - Check your Reservation details carefully and inform us immediately if you need any further clarification; please do not hesitate to contact us.',
                      style: pw.TextStyle(
                        color: PdfColors.red700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfTableHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      ),
    );
  }

  pw.Widget _buildPdfTableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: pw.Alignment.center,
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }

  pw.TableRow _buildPdfRoomRow(int roomNo) {
    final roomType = "Standard Room";
    final boardBasis = "Bed & Breakfast";

    final adultCount =
        roomNo <= guestsController.rooms.length
            ? guestsController.rooms[roomNo - 1].adults.value
            : 2;

    final childrenCount =
        roomNo <= guestsController.rooms.length
            ? guestsController.rooms[roomNo - 1].children.value
            : 0;

    return pw.TableRow(
      children: [
        _buildPdfTableCell(roomNo.toString()),
        _buildPdfTableCell('$roomType / $boardBasis'),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: _getPdfGuestNames(roomNo - 1),
          ),
        ),
        _buildPdfTableCell(adultCount.toString()),
        _buildPdfTableCell(childrenCount.toString()),
      ],
    );
  }

  List<pw.Widget> _getPdfGuestNames(int roomIndex) {
    List<pw.Widget> names = [];

    // Check if we have data from the booking controller
    if (roomIndex < bookingController.roomGuests.length) {
      // Add adult names
      for (
        var i = 0;
        i < bookingController.roomGuests[roomIndex].adults.length;
        i++
      ) {
        final adult = bookingController.roomGuests[roomIndex].adults[i];
        if (adult.firstNameController.text.isNotEmpty) {
          names.add(
            pw.Text(
              'Adult ${i + 1}: ${adult.titleController.text} ${adult.firstNameController.text} ${adult.lastNameController.text}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          );
        }
      }

      // Add child names
      for (
        var i = 0;
        i < bookingController.roomGuests[roomIndex].children.length;
        i++
      ) {
        final child = bookingController.roomGuests[roomIndex].children[i];
        if (child.firstNameController.text.isNotEmpty) {
          names.add(
            pw.Text(
              'Child ${i + 1}: ${child.titleController.text} ${child.firstNameController.text} ${child.lastNameController.text}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          );
        }
      }
    }

    // If no names found, add dummy data
    if (names.isEmpty) {
      names.add(
        pw.Text(
          'Adult 1: Mrs Hadam Rashid',
          style: const pw.TextStyle(fontSize: 9),
        ),
      );
      names.add(
        pw.Text(
          'Adult 2: Mrs Sana Aham',
          style: const pw.TextStyle(fontSize: 9),
        ),
      );
    }

    return names;
  }

  Widget _buildVoucherCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVoucherHeader(),
          _buildDivider(),
          _buildHotelInfo(context),
          _buildDivider(),
          _buildGuestInfo(),
          _buildDivider(),
          _buildDateInfo(),
          _buildDivider(),
          _buildRoomInfo(),
          _buildDivider(),
          _buildImportantNotes(),
        ],
      ),
    );
  }

  Widget _buildVoucherHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/img/newLogo.png',
                height: 30,
                // If you don't have this asset, use a placeholder:
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: const Text(
                        'Stayinhotels.ae',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Booking No#',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                '${bookingController.booking_num.value.toString()}',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 5),
              const Text(
                'Supp. Ref:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Support Contact No:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              GestureDetector(
                onTap: () => _makePhoneCall('+923219667909'),
                child: const Text(
                  '+923219667909',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotelInfo(BuildContext context) {
    final hotelName =
        searchHotelController.hotelName.value.isNotEmpty
            ? searchHotelController.hotelName.value
            : 'Leader Al Muna Kareem Hotel';

    final hotelAddress =
        'Omar Bin Al Katab Street PO Box 2961, Central Area, Madina 9055';
    final country = 'Saudi Arabia';

    // Get the latitude and longitude from your controller
    final latitude =
        double.tryParse(searchHotelController.lat.value) ?? 24.4672;
    final longitude =
        double.tryParse(searchHotelController.lon.value) ?? 39.6170;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOTEL NAME',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hotelName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(hotelAddress, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'CITY / COUNTRY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(country, style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'HOTEL LOCATION',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              // Navigate to the map screen with the actual coordinates
              Get.to(
                () => MapScreen(
                  hotelName: hotelName,
                  latitude: latitude,
                  longitude: longitude,
                ),
              );
            },
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                color:
                    Colors
                        .grey[200], // Background color in case image fails to load
              ),
              child: Stack(
                children: [
                  // Static map image for preview
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    // Use a small GoogleMap widget instead of a static image
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GoogleMap(
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(latitude, longitude),
                          zoom: 14,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(hotelName),
                            position: LatLng(latitude, longitude),
                          ),
                        },
                        liteModeEnabled:
                            true, // This makes it less resource-intensive
                      ),
                    ),
                  ),

                  // View on Google Maps label
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'View on Google Maps',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
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

  Widget _buildGuestInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LEAD GUEST',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${bookingController.firstNameController.text} ${bookingController.lastNameController.text}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'ROOM(S)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${guestsController.roomCount.value}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'NIGHT(S)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${hotelDateController.nights.value}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CHECK-IN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat(
                  'dd MMM yyyy',
                ).format(hotelDateController.checkInDate.value),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'CHECK-OUT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat(
                  'dd MMM yyyy',
                ).format(hotelDateController.checkOutDate.value),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(3),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
            },
            border: TableBorder.all(color: Colors.grey.shade300),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                children: [
                  _buildTableHeaderCell('Room No'),
                  _buildTableHeaderCell('Room Type / Board Basis'),
                  _buildTableHeaderCell('Guest Name'),
                  _buildTableHeaderCell('Adult(s)'),
                  _buildTableHeaderCell('Children'),
                ],
              ),
              ...List.generate(
                guestsController.roomCount.value,
                (index) => _buildRoomRow(index + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildRoomRow(int roomNo) {
    final roomType = "Standard Room";
    final boardBasis = "Bed & Breakfast";

    // Get guest info from BookingController if available
    final guestNames = _getGuestNames(roomNo - 1);

    final adultCount =
        roomNo <= guestsController.rooms.length
            ? guestsController.rooms[roomNo - 1].adults.value
            : 2;

    final childrenCount =
        roomNo <= guestsController.rooms.length
            ? guestsController.rooms[roomNo - 1].children.value
            : 0;

    return TableRow(
      children: [
        _buildTableCell(roomNo.toString()),
        _buildTableCell('$roomType / $boardBasis'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: guestNames,
          ),
        ),
        _buildTableCell(adultCount.toString()),
        _buildTableCell(childrenCount.toString()),
      ],
    );
  }

  List<Widget> _getGuestNames(int roomIndex) {
    List<Widget> names = [];

    // Check if we have data from the booking controller
    if (roomIndex < bookingController.roomGuests.length) {
      // Add adult names
      for (
        var i = 0;
        i < bookingController.roomGuests[roomIndex].adults.length;
        i++
      ) {
        final adult = bookingController.roomGuests[roomIndex].adults[i];
        if (adult.firstNameController.text.isNotEmpty) {
          names.add(
            Text(
              'Adult ${i + 1}: ${adult.titleController.text} ${adult.firstNameController.text} ${adult.lastNameController.text}',
              style: const TextStyle(fontSize: 12),
            ),
          );
        }
      }

      // Add child names
      for (
        var i = 0;
        i < bookingController.roomGuests[roomIndex].children.length;
        i++
      ) {
        final child = bookingController.roomGuests[roomIndex].children[i];
        if (child.firstNameController.text.isNotEmpty) {
          names.add(
            Text(
              'Child ${i + 1}: ${child.titleController.text} ${child.firstNameController.text} ${child.lastNameController.text}',
              style: const TextStyle(fontSize: 12),
            ),
          );
        }
      }
    }

    // If no names found, add dummy data
    if (names.isEmpty) {
      names.add(
        const Text('Adult 1: Mrs Hadam Rashid', style: TextStyle(fontSize: 12)),
      );
      names.add(
        const Text('Adult 2: Mrs Sana Aham', style: TextStyle(fontSize: 12)),
      );
    }

    return names;
  }

  Widget _buildTableHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildImportantNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Policy',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            'The usual check-in time is 12:00-14:00 PM (hours however this might vary from hotel to hotel and with different destinations.',
          ),
          _buildBulletPoint(
            'Rooms may not be available for early check-in unless specially requested in advance.',
          ),
          _buildBulletPoint(
            'Hotel reservation may be canceled automatically after 18:00 hours if hotel is not informed about the appointment time of the arrival.',
          ),
          _buildBulletPoint(
            'The total cost is between 10-12.00 hours between the high-way (non-toll) & the toll road with different destinations. And the checkout may involve additional charges. Please check with the hotel reception in advance.',
          ),
          _buildBulletPoint(
            'For any specific system related to particular hotel, kindly reach out to our support team for assistance.',
          ),
          const SizedBox(height: 12),
          const Text(
            'Booking Refund Policy',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Booking payable as per reservation details.Please collect all extras directly from (sleep in) departure.All matters issued are on the condition that all persons acknowledge that in person to taking part must be made, as people for which we shall not be liable for damage, loss, injury, delay or inconvenience caused to passenger as a result of any such arrangements. We will not accept any responsibility for additional expenses due to the changes or delay in air, road, rail sea or indeed any form of transport.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Important Notes - Check your Reservation details carefully and inform us immediately if you need any further clarification; please do not hesitate to contact us.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1);
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          icon: Icons.email_outlined,
          label: 'Email Voucher',
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Sending email...')));
          },
        ),
        _buildActionButton(
          context,
          icon: Icons.print,
          label: 'Print Voucher',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preparing to print...')),
            );
          },
        ),
        _buildActionButton(
          context,
          icon: Icons.support_agent,
          label: 'Contact Support',
          onTap: () => _makePhoneCall('+8227889769'),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFAB00),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

 
}

class MapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String hotelName;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.hotelName,
  });

  @override
  Widget build(BuildContext context) {
    final CameraPosition initialPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 15,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, color: TColors.primary),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: initialPosition,
        markers: {
          Marker(
            markerId: MarkerId(hotelName),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: hotelName),
          ),
        },
      ),
    );
  }
}