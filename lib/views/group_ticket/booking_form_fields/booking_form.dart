import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../utility/colors.dart';
import 'group_ticket_booking_controller.dart';



class PassengerDetailsScreen extends StatelessWidget {
  final GroupTicketBookingController controller = Get.put(GroupTicketBookingController());
  final dateFormat = DateFormat('dd-MM-yyyy');

  PassengerDetailsScreen({super.key}) {
    // Initialize with passed arguments
    final args = Get.arguments;
    if (args != null && args['groupId'] != null) {
      // Use delayed microtask to avoid state updates during build
      Future.microtask(() {
        controller.bookingData.update((val) {
          val?.groupId = args['groupId'];
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColors.primary,
        elevation: 0,
        title: Text(
          'Passenger Details',
          style: TextStyle(color: TColors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: controller.formKey,
                onChanged: () {
                  // Debounce the validation to avoid frequent rebuilds
                  Future.microtask(() => controller.validateForm());
                },
                child: Obx(() {
                  // Wrap the content that needs reactivity in a separate Obx
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip summary card
                      _buildTripSummaryCard(),
                      SizedBox(height: 16),

                      // Passenger forms
                      ..._buildPassengerForms(),
                      SizedBox(height: 24),

                      // Booker Information Section
                      _buildBookerInformationSection(),
                    ],
                  );
                }),
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  List<Widget> _buildPassengerForms() {
    final passengers = <Widget>[];

    for (int i = 0; i < controller.bookingData.value.adults; i++) {
      passengers.add(_buildPassengerForm('Adult ${i + 1}', i, 'adult'));
    }

    for (int i = 0; i < controller.bookingData.value.children; i++) {
      passengers.add(_buildPassengerForm(
        'Child ${i + 1}',
        controller.bookingData.value.adults + i,
        'child',
      ));
    }

    for (int i = 0; i < controller.bookingData.value.infants; i++) {
      passengers.add(_buildPassengerForm(
        'Infant ${i + 1}',
        controller.bookingData.value.adults +
            controller.bookingData.value.children +
            i,
        'infant',
      ));
    }

    return passengers;
  }

  Widget _buildBottomButton() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.isFormValid.value
                  ? TColors.secondary
                  : Colors.grey[300],
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: controller.isFormValid.value
                ? controller.submitBooking
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue to Payment',
                  style: TextStyle(
                    color: controller.isFormValid.value
                        ? TColors.white
                        : TColors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: controller.isFormValid.value
                      ? TColors.white
                      : TColors.grey,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTripSummaryCard() {
    return Obx(() {
      return Card(
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [TColors.primary, TColors.primary.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.airplanemode_active, color: TColors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Flight Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(color: TColors.white.withOpacity(0.3), height: 24),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Passengers',
                        style: TextStyle(
                          color: TColors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${controller.bookingData.value.adults} Adult${controller.bookingData.value.adults > 1 ? 's' : ''}'
                            '${controller.bookingData.value.children > 0 ? ', ${controller.bookingData.value.children} Child${controller.bookingData.value.children > 1 ? 'ren' : ''}' : ''}'
                            '${controller.bookingData.value.infants > 0 ? ', ${controller.bookingData.value.infants} Infant${controller.bookingData.value.infants > 1 ? 's' : ''}' : ''}',
                        style: TextStyle(
                          color: TColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: TColors.third,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Round Trip',
                      style: TextStyle(
                        color: TColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }



  Widget _buildBookerInformationSection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: TColors.secondary),
                SizedBox(width: 8),
                Text(
                  'Booker Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            SizedBox(height: 8),
            _buildResponsiveRow([
              _buildTextField('Booker Name', (value) {
                // controller.bookingData.value.bookerName = value;
              }, Icons.person_outline),
              _buildTextField('Booker Phone', (value) {
                // controller.bookingData.value.bookerPhone = value;
              }, Icons.phone_outlined),
              _buildTextField('Booker Email', (value) {
                // controller.bookingData.value.bookerEmail = value;
              }, Icons.email_outlined),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerForm(String title, int index, String type) {
    List<String> titles =
    type == 'adult'
        ? controller.adultTitles
        : type == 'child'
        ? controller.childTitles
        : controller.infantTitles;

    IconData categoryIcon =
    type == 'adult'
        ? Icons.person
        : type == 'child'
        ? Icons.child_care
        : Icons.baby_changing_station;

    Color headerColor =
    type == 'adult'
        ? TColors.secondary
        : type == 'child'
        ? TColors.third
        : Colors.pink[300]!;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(categoryIcon, color: TColors.white),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First row with Title, Given Name, and Sur Name
                _buildResponsiveRow([
                  _buildTitleField(titles, index, type),
                  _buildTextField('Given Name', (value) {
                    controller.bookingData.value.passengers[index].firstName =
                        value;
                  }, Icons.badge_outlined),
                  _buildTextField('Sur Name', (value) {
                    controller.bookingData.value.passengers[index].lastName =
                        value;
                  }, Icons.badge_outlined),
                ]),
                SizedBox(height: 16),
                // Second row with Passport#, Date of birth, and Passport Expiry
                _buildResponsiveRow([
                  _buildTextField('Passport #', (value) {
                    controller
                        .bookingData
                        .value
                        .passengers[index]
                        .passportNumber = value;
                  }, Icons.article_outlined),
                  _buildDateField(
                    'Date of birth',
                    controller.bookingData.value.passengers[index].dateOfBirth,
                        (picked) {
                      controller
                          .bookingData
                          .value
                          .passengers[index]
                          .dateOfBirth = picked;
                      controller.bookingData.refresh();
                    },
                    type: type,
                    isExpiry: false,
                    icon: Icons.cake_outlined,
                  ),
                  _buildDateField(
                    'Passport Expiry',
                    controller
                        .bookingData
                        .value
                        .passengers[index]
                        .passportExpiry,
                        (picked) {
                      controller
                          .bookingData
                          .value
                          .passengers[index]
                          .passportExpiry = picked;
                      controller.bookingData.refresh();
                    },
                    type: type,
                    isExpiry: true,
                    icon: Icons.calendar_today_outlined,
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // On smaller screens, stack the fields vertically
        if (constraints.maxWidth < 600) {
          return Column(
            children:
            children
                .map(
                  (child) => Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: child,
              ),
            )
                .toList(),
          );
        }
        // On medium screens, arrange as 2 + 1
        else if (constraints.maxWidth < 800) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: children[0]),
                  SizedBox(width: 16),
                  Expanded(child: children[1]),
                ],
              ),
              SizedBox(height: 16),
              children[2],
            ],
          );
        }
        // On larger screens, show all fields in a row
        else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children
                .map((child) => Expanded(child: child))
                .toList()
                .fold<List<Widget>>(
              [],
                  (list, element) => [
                ...list,
                if (list.isNotEmpty) SizedBox(width: 16),
                element,
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildTitleField(List<String> titles, int index, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: TextStyle(fontWeight: FontWeight.w500, color: TColors.primary),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              prefixIcon: Icon(
                Icons.person_pin_outlined,
                color: TColors.secondary,
              ),
            ),
            isExpanded: true,
            items:
            titles
                .map(
                  (title) =>
                  DropdownMenuItem(value: title, child: Text(title)),
            )
                .toList(),
            value:
            type == 'adult'
                ? 'Mr'
                : type == 'child'
                ? 'Mstr'
                : 'INF',
            onChanged: (value) {
              if (value != null) {
                controller.bookingData.value.passengers[index].title = value;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              return null;
            },
            dropdownColor: Colors.white,
            icon: Icon(Icons.arrow_drop_down, color: TColors.secondary),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label,
      Function(String) onChanged, [
        IconData? icon,
      ]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, color: TColors.primary),
        ),
        SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            prefixIcon:
            icon != null
                ? Icon(icon, color: TColors.secondary, size: 20)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: TColors.secondary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField(
      String label,
      DateTime? currentValue,
      Function(DateTime) onDateSelected, {
        required String type,
        required bool isExpiry,
        IconData? icon,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, color: TColors.primary),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: Get.context!,
              initialDate:
              isExpiry
                  ? DateTime.now().add(Duration(days: 365))
                  : DateTime.now().subtract(
                Duration(
                  days:
                  type == 'adult'
                      ? 365 * 18
                      : type == 'child'
                      ? 365 * 5
                      : 180,
                ),
              ),
              firstDate:
              isExpiry
                  ? DateTime.now()
                  : DateTime.now().subtract(Duration(days: 365 * 100)),
              lastDate:
              isExpiry
                  ? DateTime.now().add(Duration(days: 365 * 10))
                  : DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: TColors.secondary,
                      onPrimary: TColors.white,
                      surface: TColors.white,
                      onSurface: TColors.primary,
                    ),
                    dialogBackgroundColor: TColors.white,
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
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                if (icon != null)
                  Icon(icon, color: TColors.secondary, size: 20),
                SizedBox(width: icon != null ? 8 : 0),
                Text(
                  currentValue != null
                      ? dateFormat.format(currentValue)
                      : 'DD-MM-YYYY',
                  style: TextStyle(
                    color:
                    currentValue != null
                        ? TColors.text
                        : TColors.placeholder,
                  ),
                ),
                Spacer(),
                Icon(Icons.calendar_today, size: 16, color: TColors.secondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}