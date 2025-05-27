
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../utility/colors.dart';


class FlightBookingDetailsScreen extends StatefulWidget {
  const FlightBookingDetailsScreen({super.key});

  @override
  State<FlightBookingDetailsScreen> createState() =>
      _FlightBookingDetailsScreenState();
}

class _FlightBookingDetailsScreenState
    extends State<FlightBookingDetailsScreen> {
  DateTime selectedDate = DateTime.now();

  // Agent data from the image
  final Agent agent = Agent(
    name: 'Ali Usman',
    email: 'aliusmangulhar8@gmail.com',
    phone: '03418216319',
    designation: 'Goolaar',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.secondary,
        elevation: 0,
        title: const Text(
          'Journey Online Testing',
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
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
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
                    'Journey',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TColors.black,
                    ),
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColors.black,
                    ),
                  ),
                  const Text(
                    'testing',
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
                        'Agent Name: ${agent.name}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    agent.designation,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.email, size: 14, color: TColors.grey),
                      const SizedBox(width: 4),
                      Text(
                        agent.email,
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
                        'Phone: ${agent.phone}',
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
                      const Text(
                        '1585',
                        style: TextStyle(
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
                  const Text(
                    'TRUX3H',
                    style: TextStyle(
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  Widget _buildBody() {
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
          _buildFlightCard(
            departureCode: 'DXB',
            departureCity: 'Dubai',
            departureCountry: 'UNITED ARAB EMIRATES',
            arrivalCode: 'MUX',
            arrivalCity: 'Quaid',
            arrivalCountry: 'PAKISTAN',
            departureDate: '26-03-2025',
            departureTime: '16:25',
            arrivalDate: '26-03-2025',
            arrivalTime: '17:50',
            duration: '02 H 25 M',
            flightNumber: 'FZ-336',
            passengerName: 'Muhammad Zain Sajid',
            passengerType: 'Adult',
            extraBaggage: '10 Kg Baggage Upgrade',
            extraMeal: 'Standard meal',
            seat: '9B',
            handBaggage: '7 Kg',
            checkedBaggage: '30 Kg',
            isConnecting: false,
          ),
          const SizedBox(height: 16),
          _buildFlightCard(
            departureCode: 'DXB',
            departureCity: 'Dubai',
            departureCountry: 'UNITED ARAB EMIRATES',
            arrivalCode: 'JED',
            arrivalCity: 'Jeddah',
            arrivalCountry: 'SAUDI ARABIA',
            departureDate: '26-03-2025',
            departureTime: '19:45',
            arrivalDate: '26-03-2025',
            arrivalTime: '22:05',
            duration: '03 H 20 M',
            flightNumber: 'FZ-907',
            passengerName: 'Muhammad Zain Sajid',
            passengerType: 'Adult',
            extraBaggage: '10 Kg Baggage Upgrade',
            extraMeal: 'Standard meal',
            seat: 'N/A',
            handBaggage: '7 Kg',
            checkedBaggage: '30 Kg',
            isConnecting: true,
          ),
          const SizedBox(height: 24),
          _buildPassengerDetailsCard(),
          // const SizedBox(height: 24),
          // _buildSummaryCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFlightCard({
    required String departureCode,
    required String departureCity,
    required String departureCountry,
    required String arrivalCode,
    required String arrivalCity,
    required String arrivalCountry,
    required String departureDate,
    required String departureTime,
    required String arrivalDate,
    required String arrivalTime,
    required String duration,
    required String flightNumber,
    required String passengerName,
    required String passengerType,
    required String extraBaggage,
    required String extraMeal,
    required String seat,
    required String handBaggage,
    required String checkedBaggage,
    required bool isConnecting,
  }) {
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
                    'Fly $departureCity ($flightNumber)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: TColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: TColors.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ECONOMY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: TColors.background,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Flight timeline with responsive design
            LayoutBuilder(builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Departure section
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.flight_takeoff,
                              size: 16,
                              color: TColors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '$departureDate\n$departureTime',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                departureCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                departureCity,
                                style: const TextStyle(
                                  color: TColors.grey,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                departureCountry,
                                style: const TextStyle(
                                  color: TColors.grey,
                                  fontSize: 10,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Middle duration section
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        const Text(
                          'Duration',
                          style: TextStyle(
                            fontSize: 10,
                            color: TColors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: TColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            duration,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 1,
                                color: TColors.grey.withOpacity(0.5),
                              ),
                              const Icon(
                                Icons.flight,
                                size: 16,
                                color: TColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrival section
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                '$arrivalDate\n$arrivalTime',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.flight_land,
                              size: 16,
                              color: TColors.grey,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                arrivalCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                arrivalCity,
                                style: const TextStyle(
                                  color: TColors.grey,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                arrivalCountry,
                                style: const TextStyle(
                                  color: TColors.grey,
                                  fontSize: 10,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFlightDetailItem(
                  label: 'Hand Baggage',
                  value: handBaggage,
                  icon: Icons.work_outline,
                ),

                _buildFlightDetailItem(
                  label: 'Checked Baggage',
                  value: checkedBaggage,
                  icon: Icons.luggage,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            // Passenger info
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 16,
                  color: TColors.grey,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    passengerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($passengerType)',
                  style: const TextStyle(
                    color: TColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Flexible extra details
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildFlightDetailItem(
                  label: 'Extra Baggage',
                  value: extraBaggage,
                  icon: Icons.luggage,
                ),
                _buildFlightDetailItem(
                  label: 'Extra Meal',
                  value: extraMeal,
                  icon: Icons.restaurant,
                ),
                _buildFlightDetailItem(
                  label: 'Seat',
                  value: seat,
                  icon: Icons.event_seat,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Wrap(
            //   spacing: 16,
            //   runSpacing: 16,
            //   children: [
            //     _buildFlightDetailItem(
            //       label: 'Hand Baggage',
            //       value: handBaggage,
            //       icon: Icons.work_outline,
            //     ),
            //     _buildFlightDetailItem(
            //       label: 'Checked Baggage',
            //       value: checkedBaggage,
            //       icon: Icons.luggage,
            //     ),
            //   ],
            // ),
            if (isConnecting) ...[
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
                        _buildTableCell('Passport#', isHeader: true),
                        _buildTableCell('Ticket #', isHeader: true),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildTableCell('1'),
                        _buildTableCell('MUHAMMAD ZAIN SAJID (Adult)'),
                        _buildTableCell('345783'),
                        _buildTableCell('N/A'),
                      ],
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
    final pdf = pw.Document();

    // Add page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Journey Online Testing',
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
                        'Agent: ${agent.name}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        agent.email,
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'Phone: ${agent.phone}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Reference # 1585 | PNR: TRUX3H',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Flight Details
              pw.Text(
                'Flight Details',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),

              // First Flight
              _buildPdfFlightSection(
                'Dubai (DXB) → Quaid (MUX), PAKISTAN',
                'FZ-336',
                '26-03-2025 16:25',
                '26-03-2025 17:50',
                '02 H 25 M',
                'Muhammad Zain Sajid (Adult)',
                '10 Kg Baggage Upgrade',
                'Standard meal',
                '9B',
                '7 Kg',
                '30 Kg',
              ),
              pw.SizedBox(height: 16),

              // Second Flight
              _buildPdfFlightSection(
                'Dubai (DXB) → Jeddah (JED), SAUDI ARABIA',
                'FZ-907',
                '26-03-2025 19:45',
                '26-03-2025 22:05',
                '03 H 20 M',
                'Muhammad Zain Sajid (Adult)',
                '10 Kg Baggage Upgrade',
                'Standard meal',
                'N/A',
                '7 Kg',
                '30 Kg',
              ),
              pw.SizedBox(height: 20),

              // Passenger Details
              pw.Text(
                'Passenger Details',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildPdfTableCell('Sr', isHeader: true),
                      _buildPdfTableCell('Name', isHeader: true),
                      _buildPdfTableCell('Passport#', isHeader: true),
                      _buildPdfTableCell('Ticket #', isHeader: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildPdfTableCell('1'),
                      _buildPdfTableCell('MUHAMMAD ZAIN SAJID (Adult)'),
                      _buildPdfTableCell('345783'),
                      _buildPdfTableCell('N/A'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Payment Summary
              // pw.Text(
              //   'Payment Summary',
              //   style: pw.TextStyle(
              //     fontSize: 16,
              //     fontWeight: pw.FontWeight.bold,
              //   ),
              // ),
              // pw.Divider(),
              // _buildPdfSummaryRow('Total Amount', '₹ 1,245.00'),
              // _buildPdfSummaryRow('Payment Received', '₹ 1,245.00'),
              // pw.Divider(),
              // _buildPdfSummaryRow('Closing Balance', '₹ 0.00', isPrimary: true),

              // // Footer
              // pw.SizedBox(height: 20),
              // pw.Center(
              //   child: pw.Text(
              //     'Thank you for booking with Journey Online!',
              //     style: pw.TextStyle(
              //       fontSize: 12,
              //       color: PdfColors.grey700,
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfFlightSection(
      String route,
      String flightNumber,
      String departureDateTime,
      String arrivalDateTime,
      String duration,
      String passengerName,
      String extraBaggage,
      String extraMeal,
      String seat,
      String handBaggage,
      String checkedBaggage,
      ) {
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
                'Flight: $flightNumber',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'ECONOMY',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            route,
            style: pw.TextStyle(
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Departure: $departureDateTime'),
              pw.Text('Duration: $duration'),
              pw.Text('Arrival: $arrivalDateTime'),
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
                    pw.Text(handBaggage),
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
                    pw.Text(checkedBaggage),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'Passenger: $passengerName',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Extra Baggage:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(extraBaggage),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Extra Meal:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(extraMeal),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Seat:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(seat),
                ],
              ),
            ],
          ),

        ],
      ),
    );
  }

  pw.Widget _buildPdfTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
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

// Sample Flight model class
class VoucherFlight {
  final String departureCode;
  final String departureCity;
  final String departureCountry;
  final String arrivalCode;
  final String arrivalCity;
  final String arrivalCountry;
  final String departureDate;
  final String departureTime;
  final String arrivalDate;
  final String arrivalTime;
  final String duration;
  final String flightNumber;
  final List<Passenger> passengers;
  final String cabinClass;
  final String handBaggage;
  final String checkedBaggage;
  final bool isConnecting;

  VoucherFlight({
    required this.departureCode,
    required this.departureCity,
    required this.departureCountry,
    required this.arrivalCode,
    required this.arrivalCity,
    required this.arrivalCountry,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalDate,
    required this.arrivalTime,
    required this.duration,
    required this.flightNumber,
    required this.passengers,
    required this.cabinClass,
    required this.handBaggage,
    required this.checkedBaggage,
    this.isConnecting = false,
  });
}

// Sample Passenger model class
class Passenger {
  final String name;
  final String type;
  final String extraBaggage;
  final String extraMeal;
  final String seat;
  final String passportNumber;
  final String ticketNumber;

  Passenger({
    required this.name,
    required this.type,
    required this.extraBaggage,
    required this.extraMeal,
    required this.seat,
    required this.passportNumber,
    required this.ticketNumber,
  });
}

// Sample Booking model class
class Booking {
  final String referenceNumber;
  final String pnr;
  final String status;
  final List<VoucherFlight> flights;
  final double totalAmount;
  final double paymentReceived;
  final double closingBalance;
  final Agent agent;

  Booking({
    required this.referenceNumber,
    required this.pnr,
    required this.status,
    required this.flights,
    required this.totalAmount,
    required this.paymentReceived,
    required this.closingBalance,
    required this.agent,
  });
}