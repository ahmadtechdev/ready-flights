import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'booking_form.dart';
import 'group_ticket_booking_controller.dart';

class BookingSummaryScreen extends StatelessWidget {
  final GroupTicketBookingController controller = Get.put(GroupTicketBookingController());

  BookingSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0F3041), // Dark blue background
        title: Text('Book Seats', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(),
                SizedBox(height: 16),
                _buildPassengerTable(),
                SizedBox(height: 20),
                _buildContinueButton(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Name:',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            controller.bookingData.value.groupName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Seats:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    controller.bookingData.value.availableSeats.toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sector:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    controller.bookingData.value.sector,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF0F3041),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Passengers',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Price/Seat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildPassengerRow(
            'Adults',
            controller.bookingData.value.adults,
            'PKR ${controller.bookingData.value.adultPrice.toStringAsFixed(0)}',
            'PKR ${(controller.bookingData.value.adults * controller.bookingData.value.adultPrice).toStringAsFixed(0)}',
            () => controller.incrementAdults(),
            () => controller.decrementAdults(),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          _buildPassengerRow(
            'Child',
            controller.bookingData.value.children,
            'PKR ${controller.bookingData.value.childPrice.toStringAsFixed(0)}',
            'PKR ${(controller.bookingData.value.children * controller.bookingData.value.childPrice).toStringAsFixed(0)}',
            () => controller.incrementChildren(),
            () => controller.decrementChildren(),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          _buildPassengerRow(
            'Infants',
            controller.bookingData.value.infants,
            'PKR ${controller.bookingData.value.infantPrice.toStringAsFixed(0)}',
            'PKR ${(controller.bookingData.value.infants * controller.bookingData.value.infantPrice).toStringAsFixed(0)}',
            () => controller.incrementInfants(),
            () => controller.decrementInfants(),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${controller.bookingData.value.totalPassengers}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'PKR ${controller.bookingData.value.totalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerRow(
    String label,
    int count,
    String pricePerSeat,
    String totalPrice,
    VoidCallback onIncrement,
    VoidCallback onDecrement,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: label == 'Adults' ? Colors.blue.withOpacity(0.05) : Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$label:', style: TextStyle(fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    _buildCircleButton(Icons.remove, onDecrement),
                    SizedBox(width: 12),
                    Text(
                      '$count',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 12),
                    _buildCircleButton(Icons.add, onIncrement),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  pricePerSeat,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  totalPrice,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: count > 0 ? Colors.green : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Color(0xFF4092C5), // A nice blue color
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4092C5), // A nice blue color
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        onPressed: () {
          if (controller.bookingData.value.totalPassengers <=
              controller.bookingData.value.availableSeats) {
            Get.to(
                  () => PassengerDetailsScreen(),
              arguments: {
                'groupId': controller.bookingData.value.groupId,
                 // Pass the flight model if needed
              },
            );
          } else {
            Get.snackbar(
              'Error',
              'Number of passengers exceeds available seats',
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red,
            );
          }
        },
        child: Text(
          'Continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
