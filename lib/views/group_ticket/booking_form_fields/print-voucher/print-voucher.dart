import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class PDFPrintScreen extends StatelessWidget {
  const PDFPrintScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Ticket Printer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Click below to print your flight ticket',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Print Ticket'),
              onPressed: () async {
                try {
                  await Printing.layoutPdf(
                    onLayout: (format) => generateFlightTicket(),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Printing failed: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> generateFlightTicket() async {
    final pdf = pw.Document();
    
    // Load fonts
    final regularFont = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    
    // Add page to the PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: _buildTicketContent(regularFont, boldFont),
          );
        },
      ),
    );
    
    return pdf.save();
  }

  pw.Widget _buildTicketContent(pw.Font regularFont, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header with date and title
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '25/04/2025, 12:10',
              style: pw.TextStyle(font: regularFont, fontSize: 10),
            ),
            pw.Text(
              'ONE ROOF TRAVEL',
              style: pw.TextStyle(font: boldFont, fontSize: 12),
            ),
          ],
        ),
        
        pw.SizedBox(height: 10),
        
        // Booking details
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left column for booking info
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildLabelValuePair(boldFont, regularFont, 'PNR', 'G202504151702012345'),
                pw.SizedBox(height: 5),
                _buildLabelValuePair(boldFont, regularFont, 'Booking #', '82090 | 2802'),
                pw.SizedBox(height: 5),
                _buildLabelValuePair(boldFont, regularFont, 'Booked By', 'Journey Online'),
                pw.SizedBox(height: 5),
                _buildLabelValuePair(boldFont, regularFont, 'Contact', '+92 337751322'),
                pw.SizedBox(height: 5),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: 'Status\n',
                        style: pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.blue900),
                      ),
                      pw.TextSpan(
                        text: 'Hold',
                        style: pw.TextStyle(font: regularFont, fontSize: 12, color: PdfColors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Airline logo on the right
            pw.Expanded(
              child: pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Container(
                  width: 80,
                  height: 40,
                  child: pw.Text('SereneAir', style: pw.TextStyle(font: boldFont, color: PdfColors.teal)),
                ),
              ),
            ),
          ],
        ),
        
        pw.SizedBox(height: 20),
        
        // Flight Details section with orange bar
        _buildSectionHeader(boldFont, 'Flight Details', 'Booking Date: Fri 25 Apr 2025 12:10', regularFont),
        
        pw.SizedBox(height: 10),
        
        // Flight details table header
        _buildTableHeader(regularFont),
        
        // Flight details table content
        _buildFlightDetailsRow(regularFont, boldFont),
        
        pw.Container(
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey300),
            ),
          ),
          padding: const pw.EdgeInsets.only(bottom: 10),
        ),
        
        pw.SizedBox(height: 10),
        
        // Passengers Information
        pw.Text(
          'Passengers Information',
          style: pw.TextStyle(font: boldFont, fontSize: 12),
        ),
        
        pw.SizedBox(height: 5),
        
        _buildPassengerInfo(regularFont),
        
        pw.SizedBox(height: 20),
        
        // Terms and Conditions
        _buildSectionHeader(boldFont, 'TERMS & CONDITIONS:', '', regularFont),
        
        pw.SizedBox(height: 10),
        
        _buildBulletPoint(regularFont, 'Passenger should report at check-in counter at least 4:00 hours prior to the flight.'),
        
        pw.SizedBox(height: 5),
        
        _buildBulletPoint(regularFont, 'After confirmation, tickets are non-refundable and non-changeable at any time.'),
      ],
    );
  }

  pw.Widget _buildLabelValuePair(pw.Font boldFont, pw.Font regularFont, String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label\n',
            style: pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.blue900),
          ),
          pw.TextSpan(
            text: value,
            style: pw.TextStyle(font: regularFont, fontSize: 12),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSectionHeader(pw.Font boldFont, String title, String subtitle, pw.Font regularFont) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.orange, width: 4),
        ),
      ),
      padding: const pw.EdgeInsets.only(left: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(font: boldFont, fontSize: 14),
          ),
          pw.Text(
            subtitle,
            style: pw.TextStyle(font: regularFont, fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeader(pw.Font regularFont) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text('Flight No.', style: pw.TextStyle(font: regularFont, color: PdfColors.grey700)),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text('Date', style: pw.TextStyle(font: regularFont, color: PdfColors.grey700)),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Text('Flight Info', style: pw.TextStyle(font: regularFont, color: PdfColors.grey700)),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text('Baggage', style: pw.TextStyle(font: regularFont, color: PdfColors.grey700)),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text('Meal', style: pw.TextStyle(font: regularFont, color: PdfColors.grey700)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFlightDetailsRow(pw.Font regularFont, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Flight number
          pw.Expanded(
            flex: 2,
            child: pw.Text('ER 723', style: pw.TextStyle(font: regularFont)),
          ),
          
          // Date and time
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('26 Apr', style: pw.TextStyle(font: regularFont)),
                pw.Text('22:55', style: pw.TextStyle(font: boldFont)),
              ],
            ),
          ),
          
          // Route info
          pw.Expanded(
            flex: 4,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('LAHORE', style: pw.TextStyle(font: boldFont, color: PdfColors.blue900)),
                pw.SizedBox(width: 5),
                pw.Text('✈️', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(width: 5),
                pw.Text('DUBAI', style: pw.TextStyle(font: boldFont, color: PdfColors.blue900)),
                pw.SizedBox(width: 5),
                pw.Text('01:20', style: pw.TextStyle(font: boldFont)),
              ],
            ),
          ),
          
          // Baggage
          pw.Expanded(
            flex: 2,
            child: pw.Text('20+7 KG', style: pw.TextStyle(font: regularFont)),
          ),
          
          // Meal
          pw.Expanded(
            flex: 1,
            child: pw.Text('Yes', style: pw.TextStyle(font: regularFont)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPassengerInfo(pw.Font regularFont) {
    return pw.Row(
      children: [
        pw.Text('1 - SIWO EWEE', style: pw.TextStyle(font: regularFont)),
        pw.SizedBox(width: 10),
        pw.Text('ee', style: pw.TextStyle(font: regularFont)),
        pw.Spacer(),
        pw.Text('Hold', style: pw.TextStyle(font: regularFont, color: PdfColors.green)),
      ],
    );
  }

  pw.Widget _buildBulletPoint(pw.Font regularFont, String text) {
    return pw.Bullet(
      text: text,
      style: pw.TextStyle(font: regularFont, fontSize: 11),
      bulletSize: 2,
    );
  }
}