import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../utility/colors.dart';
import 'all_group_booking_controller.dart';
import 'model.dart';

class AllGroupBooking extends StatelessWidget {
  AllGroupBooking({Key? key}) : super(key: key);

  final AllGroupBookingController controller = Get.put(
    AllGroupBookingController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: TColors.background4,
        title: const Text(
          'Booking Reports',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(child: _buildBookingsList()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: TColors.background4,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => _buildDatePicker(
                        controller.fromDate.value,
                        (date) => controller.updateFromDate(date),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date To',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => _buildDatePicker(
                        controller.toDate.value,
                        (date) => controller.updateToDate(date),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Group Category',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => _buildDropdown(
                        controller.groupCategories,
                        controller.selectedGroupCategory.value,
                        (value) => controller.updateGroupCategory(value!),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => _buildDropdown(
                        controller.statusOptions,
                        controller.selectedStatus.value,
                        (value) => controller.updateStatus(value!),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.fetchBookings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'FILTER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
    DateTime selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: Get.context!,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: TColors.primary),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(selectedDate),
              style: const TextStyle(fontSize: 14),
            ),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.hasError.value) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.fetchBookings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (controller.bookings.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flight, color: Colors.grey[400], size: 64),
              const SizedBox(height: 16),
              Text(
                'No bookings found for the selected criteria',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.bookings.length,
        itemBuilder: (context, index) {
          final booking = controller.bookings[index];
          return _buildBookingCard(booking);
        },
      );
    });
  }

  Widget _buildBookingCard(BookingModel booking) {
    Color statusColor;
    if (booking.status.toUpperCase() == 'CONFIRMED') {
      statusColor = Colors.green;
    } else if (booking.status.toUpperCase() == 'CANCELLED') {
      statusColor = Colors.red;
    } else if (booking.status.toUpperCase() == 'HOLD') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header with booking details
          _buildCardHeader(booking, statusColor),

          // Body with flight details
          _buildCardBody(booking),

          // Footer with passenger details and price
          _buildCardFooter(booking),
        ],
      ),
    );
  }

  Widget _buildCardHeader(BookingModel booking, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.background4,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Text(
            '#${booking.id}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              booking.pnr,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              booking.status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBody(BookingModel booking) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking codes
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.bkf,
                      style: const TextStyle(fontSize: 14, color: TColors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.agt,
                      style: const TextStyle(fontSize: 14, color: TColors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getCountryColor(booking.country),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  booking.country,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Divider
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Flight information
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flight, color: TColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.airline,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.route,
                      style: const TextStyle(color: TColors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date and Creation
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: TColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEE dd MMM yyyy').format(booking.flightDate),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Text(
                'Created: ${DateFormat('dd MMM HH:mm').format(booking.createdDate)}',
                style: const TextStyle(fontSize: 12, color: TColors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCountryColor(String country) {
    switch (country) {
      case 'UAE':
        return Colors.red;
      case 'KSA':
        return Colors.green;
      case 'Oman':
        return Colors.blue;
      case 'UK':
        return Colors.indigo;
      case 'UMRAH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCardFooter(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          // Price and View button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(fontSize: 12, color: TColors.grey),
                  ),
                ],
              ),
              Text(
                'PKR ${NumberFormat('#,###').format(booking.price)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TColors.primary,
                ),
              ),
            ],
          ),

          // Expandable passenger status (initially collapsed)
          ExpansionTile(
            title: const Text(
              'Passenger Status',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildPassengerStatusTable(booking.passengerStatus)],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerStatusTable(PassengerStatus passengerStatus) {
    final TextStyle headerStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    final TextStyle cellStyle = const TextStyle(fontSize: 12);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              children: [
                _buildTableCell('Status', headerStyle),
                _buildTableCell('Adults', headerStyle),
                _buildTableCell('Child', headerStyle),
                _buildTableCell('Infant', headerStyle),
                _buildTableCell('Total', headerStyle),
              ],
            ),
            // Hold row
            TableRow(
              children: [
                _buildTableCell('Hold', cellStyle, textColor: Colors.orange),
                _buildTableCell('${passengerStatus.holdAdults}', cellStyle),
                _buildTableCell('${passengerStatus.holdChild}', cellStyle),
                _buildTableCell('${passengerStatus.holdInfant}', cellStyle),
                _buildTableCell('${passengerStatus.holdTotal}', cellStyle),
              ],
            ),
            // Confirm row
            TableRow(
              children: [
                _buildTableCell('Confirm', cellStyle, textColor: Colors.green),
                _buildTableCell('${passengerStatus.confirmAdults}', cellStyle),
                _buildTableCell('${passengerStatus.confirmChild}', cellStyle),
                _buildTableCell('${passengerStatus.confirmInfant}', cellStyle),
                _buildTableCell('${passengerStatus.confirmTotal}', cellStyle),
              ],
            ),
            // Cancelled row
            TableRow(
              children: [
                _buildTableCell('Cancelled', cellStyle, textColor: Colors.red),
                _buildTableCell(
                  '${passengerStatus.cancelledAdults}',
                  cellStyle,
                ),
                _buildTableCell('${passengerStatus.cancelledChild}', cellStyle),
                _buildTableCell(
                  '${passengerStatus.cancelledInfant}',
                  cellStyle,
                ),
                _buildTableCell('${passengerStatus.cancelledTotal}', cellStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, TextStyle style, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: textColor != null ? style.copyWith(color: textColor) : style,
        textAlign: TextAlign.center,
      ),
    );
  }
}
