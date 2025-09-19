// airarabia_booking_flight.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:ready_flights/services/api_service_airarabia.dart';
import 'package:ready_flights/views/flight/booking_flight/airarabia/airarabia_print_voucher.dart';
import 'package:ready_flights/views/flight/search_flights/airarabia/validation_data/validation_controller.dart';

import '../../../../../utility/colors.dart';
import '../../../../../widgets/travelers_selection_bottom_sheet.dart';
import '../../search_flights/airarabia/airarabia_flight_controller.dart';
import '../../search_flights/airarabia/airarabia_flight_model.dart';
import '../booking_flight_controller.dart';

class AirArabiaBookingFlight extends StatefulWidget {
  final AirArabiaFlight flight;
  final AirArabiaPackage selectedPackage;
  final double totalPrice;
  final String currency;

  const AirArabiaBookingFlight({
    super.key,
    required this.flight,
    required this.selectedPackage,
    required this.totalPrice,
    required this.currency,
  });

  @override
  State<AirArabiaBookingFlight> createState() => _AirArabiaBookingFlightState();
}

class _AirArabiaBookingFlightState extends State<AirArabiaBookingFlight> {
  final _formKey = GlobalKey<FormState>();
  final BookingFlightController bookingController = Get.put(
    BookingFlightController(),
  );
  final TravelersController travelersController = Get.put(
    TravelersController(),
  );
  final AirArabiaFlightController flightController =
  Get.find<AirArabiaFlightController>();

  bool termsAccepted = false;

  // Auto-fill function for testing
  void _fillDummyData() {
    // Fill booker information
    bookingController.firstNameController.text = "John";
    bookingController.lastNameController.text = "Doe";
    bookingController.emailController.text = "ahmadtechdev@gmail.com";
    bookingController.phoneController.text = "1234567890";
    bookingController.remarksController.text = "Test booking";
    bookingController.bookerPhoneCountry.value = Country.parse('PK');

    // Fill adult travelers
    for (int i = 0; i < bookingController.adults.length; i++) {
      final adult = bookingController.adults[i];
      adult.titleController.text = i % 2 == 0 ? "Mr" : "Mrs";
      adult.firstNameController.text = "ahmad${i + 1}";
      adult.lastNameController.text = "Traveler";
      adult.passportCnicController.text = bookingController.isDomesticFlight
          ? "1234567890123"
          : "AB123456${i + 1}";
      adult.nationalityController.text = "Pakistan";
      adult.nationalityCountry.value = Country.parse('PK');
      adult.dateOfBirthController.text = "1990-0${(i % 9) + 1}-15";
      adult.passportExpiryController.text = "2030-12-31";
      adult.genderController.text = i % 2 == 0 ? "Male" : "Female";
      adult.phoneController.text = "300123456${i + 1}";
      adult.phoneCountry.value = Country.parse('PK');
      adult.emailController.text = "adult${i + 1}@example.com";
    }

    // Fill child travelers
    for (int i = 0; i < bookingController.children.length; i++) {
      final child = bookingController.children[i];
      child.titleController.text = i % 2 == 0 ? "Mstr" : "Miss";
      child.firstNameController.text = "Child${i + 1}";
      child.lastNameController.text = "Traveler";
      child.passportCnicController.text = bookingController.isDomesticFlight
          ? "1234567890${100 + i}"
          : "CD123456${i + 1}";
      child.nationalityController.text = "Pakistan";
      child.nationalityCountry.value = Country.parse('PK');
      child.dateOfBirthController.text = "2015-0${(i % 9) + 1}-15";
      child.passportExpiryController.text = "2030-12-31";
      child.genderController.text = i % 2 == 0 ? "Male" : "Female";
      child.phoneController.text = "";
      child.emailController.text = "";
    }

    // Fill infant travelers
    for (int i = 0; i < bookingController.infants.length; i++) {
      final infant = bookingController.infants[i];
      infant.titleController.text = "Inf";
      infant.firstNameController.text = "Infant${i + 1}";
      infant.lastNameController.text = "Traveler";
      infant.nationalityController.text = "Pakistan";
      infant.nationalityCountry.value = Country.parse('PK');
      infant.dateOfBirthController.text = "2023-0${(i % 9) + 1}-15";
      infant.genderController.text = i % 2 == 0 ? "Male" : "Female";
    }

    // Accept terms and conditions
    setState(() {
      termsAccepted = true;
    });

    // Show success message
    Get.snackbar(
      'Success',
      'Form filled with dummy data for testing',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Single tap does nothing, preserving original behavior
          },
          onDoubleTap: () {
            // Double tap fills dummy data
            _fillDummyData();
          },
          child: const Text(
            'Booking Details - Air Arabia',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flight Summary
                _buildFlightSummary(),
                const SizedBox(height: 24),
                _buildTravelersForm(),
                const SizedBox(height: 24),
                _buildBookerDetails(),
                const SizedBox(height: 24),
                _buildTermsAndConditions(),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildFlightSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Flight Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.flight.flightSegments.first['departure']['airport']} → ${widget.flight.flightSegments.last['arrival']['airport']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.currency} ${widget.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Package: ${widget.selectedPackage.packageName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Airline: ${widget.flight.airlineName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelersForm() {
    return Obx(() {
      final adults = List.generate(
        travelersController.adultCount.value,
            (index) => _buildTravelerSection(
          title: 'Adult ${index + 1}',
          isInfant: false,
          type: 'adult',
          index: index,
        ),
      );

      final children = List.generate(
        travelersController.childrenCount.value,
            (index) => _buildTravelerSection(
          title: 'Child ${index + 1}',
          isInfant: false,
          type: 'child',
          index: index,
        ),
      );

      final infants = List.generate(
        travelersController.infantCount.value,
            (index) => _buildTravelerSection(
          title: 'Infant ${index + 1}',
          isInfant: true,
          type: 'infant',
          index: index,
        ),
      );

      return Column(children: [...adults, ...children, ...infants]);
    });
  }

  Widget _buildTravelerSection({
    required String title,
    required bool isInfant,
    required String type,
    required int index,
  }) {
    TravelerInfo travelerInfo;
    if (type == 'adult') {
      travelerInfo = bookingController.adults[index];
    } else if (type == 'child') {
      travelerInfo = bookingController.children[index];
    } else {
      travelerInfo = bookingController.infants[index];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(_getTravelerIcon(type), color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Gender Row - Now using dropdowns
                _buildDropdownField(
                  label: 'Title',
                  options: isInfant
                      ? ['Inf']
                      : (type == 'child'
                      ? ['Mstr', 'Miss']
                      : ['Mr', 'Mrs', 'Ms']),
                  controller: travelerInfo.titleController,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Gender',
                  options: ['Male', 'Female'],
                  controller: travelerInfo.genderController,
                ),
                const SizedBox(height: 16),

                // Name Fields Row
                Column(
                  children: [
                    _buildTextField(
                      label: 'Given Name*',
                      controller: travelerInfo.firstNameController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Surname*',
                      controller: travelerInfo.lastNameController,
                      isRequired: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date of Birth
                _buildDateField(
                  label: 'Date of Birth*',
                  controller: travelerInfo.dateOfBirthController,
                ),

                if (type == 'adult') ...[
                  const SizedBox(height: 16),
                  // Phone and Email Row
                  Column(
                    children: [
                      _buildPhoneFieldWithCountryPicker(
                        label: 'Phone*',
                        phoneController: travelerInfo.phoneController,
                        travelerInfo: travelerInfo,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Passenger Email',
                        controller: travelerInfo.emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Nationality and Passport Row
                Column(
                  children: [
                    _buildNationalityPickerField(
                      label: 'Nationality*',
                      travelerInfo: travelerInfo,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: bookingController.isDomesticFlight
                          ? 'CNIC Number*'
                          : 'Passport Number*',
                      controller: travelerInfo.passportCnicController,
                      isRequired: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Passport Expiry
                _buildDateField(
                  label: bookingController.isDomesticFlight
                      ? 'CNIC Expire'
                      : 'Passport Expire',
                  controller: travelerInfo.passportExpiryController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookerDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Booker Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'First Name*',
                        controller: bookingController.firstNameController,
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'Last Name*',
                        controller: bookingController.lastNameController,
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    _buildTextField(
                      label: 'Email*',
                      controller: bookingController.emailController,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildBookerPhoneFieldWithCountryPicker(
                      label: 'Phone*',
                      phoneController: bookingController.phoneController,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Remarks',
                  controller: bookingController.remarksController,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneFieldWithCountryPicker({
    required String label,
    required TextEditingController phoneController,
    required TravelerInfo travelerInfo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Country Code Picker
              Obx(() {
                final country = travelerInfo.phoneCountry.value;
                return InkWell(
                  onTap: () {
                    bookingController.showPhoneCountryPicker(
                      context,
                      travelerInfo,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          country?.flagEmoji ?? '🇵🇰',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${country?.phoneCode ?? '92'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                );
              }),
              // Phone Number Field
              Expanded(
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    hintText: 'Phone Number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookerPhoneFieldWithCountryPicker({
    required String label,
    required TextEditingController phoneController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Country Code Picker
              Obx(() {
                final country = bookingController.bookerPhoneCountry.value;
                return InkWell(
                  onTap: () {
                    bookingController.showBookerPhoneCountryPicker(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          country?.flagEmoji ?? '🇵🇰',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${country?.phoneCode ?? '92'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                );
              }),
              // Phone Number Field
              Expanded(
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    hintText: 'Phone Number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNationalityPickerField({
    required String label,
    required TravelerInfo travelerInfo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final country = travelerInfo.nationalityCountry.value;
          return InkWell(
            onTap: () {
              bookingController.showNationalityPicker(context, travelerInfo);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    country?.flagEmoji ?? '🇵🇰',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      country?.displayNameNoCountryCode ?? 'Select Nationality',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                        country != null ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: termsAccepted,
            onChanged: (value) {
              setState(() {
                termsAccepted = value ?? false;
              });
            },
            activeColor: TColors.primary,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  termsAccepted = !termsAccepted;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'I read and accept all ',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      TextSpan(
                        text: 'Terms and conditions',
                        style: TextStyle(
                          fontSize: 14,
                          color: TColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator:
            isRequired
                ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please fill in this field.';
              }
              return null;
            }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: Icon(Icons.calendar_month, color: Colors.grey),
            ),
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                controller.text =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select date';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> options,
    required TextEditingController controller,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: controller.text.isNotEmpty && options.contains(controller.text)
                ? controller.text
                : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            hint: Text(
              'Select $label',
              style: TextStyle(color: Colors.grey[600]),
            ),
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.text = newValue;
                // Trigger setState to update the UI immediately
                setState(() {});
              }
            },
            validator: isRequired
                ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please select $label';
              }
              return null;
            }
                : null,
          ),
        ),
      ],
    );
  }

  IconData _getTravelerIcon(String type) {
    switch (type) {
      case 'adult':
        return Icons.person;
      case 'child':
        return Icons.child_care;
      case 'infant':
        return Icons.baby_changing_station;
      default:
        return Icons.person;
    }
  }

Widget _buildBottomBar() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.currency} ${widget.totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColors.primary,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _handleBookNow(),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}
// Updated _handleBookNow method for airarabia_booking_flight.dart
// Replace the existing _handleBookNow method with this updated version

Future<void> _handleBookNow() async {
  if (_formKey.currentState!.validate() && termsAccepted) {
    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
          ),
        ),
        barrierDismissible: false,
      );

      // Call Air Arabia booking API
      final response = await _createAirArabiaBooking();
      
      Get.back(); // Remove loading

      if (response != null && response['status'] == 200) {
        // Print successful response for debugging
        print('🎉 Booking Success Response:');
        print('Status: ${response['status']}');
        print('Message: ${response['message'] ?? 'Booking created successfully'}');
        print('Data: ${response['data']}');
        
        // Show success snackbar
        Get.snackbar(
          'Success',
          'Booking created successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Navigate to Air Arabia booking confirmation screen
        Get.off(() => AirArabiaBookingConfirmation(
          flight: widget.flight,
          selectedPackage: widget.selectedPackage,
          bookingResponse: response,
          totalPrice: widget.totalPrice,
          currency: widget.currency,
        ));
        
      } else {
        // Handle API error response
        print('❌ Booking Error Response:');
        print('Full Response: $response');
        
        final errorMessage = response?['message'] ?? 'Unknown error occurred';
        Get.snackbar(
          'Booking Failed',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }

    } catch (e, stackTrace) {
      Get.back(); // Remove loading
      
      print('❌ Booking Exception:');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      
      Get.snackbar(
        'Error',
        'Failed to create booking: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  } else if (!termsAccepted) {
    Get.snackbar(
      'Error',
      'Please accept terms and conditions',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  } else {
    Get.snackbar(
      'Error',
      'Please fill all required fields',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}

// Don't forget to add the import at the top of your airarabia_booking_flight.dart file:
// import 'air_arabia_booking_confirmation.dart';
double _getBasicFareFromRevalidation() {
  try {
    final revalidationController = Get.put(AirArabiaRevalidationController());
    final pricingInfo = revalidationController.revalidationResponse.value?.data?.pricing;
    
    if (pricingInfo?.ptcFareBreakdown.passengerFare?.baseFare?.attributes != null) {
      final baseFareAttributes = pricingInfo!.ptcFareBreakdown.passengerFare!.baseFare!.attributes;
      final amount = baseFareAttributes['Amount'];
      if (amount != null) {
        return double.tryParse(amount.toString()) ?? 0.0;
      }
    }
    
    // Fallback: calculate basic fare from total price (rough estimation)
    final totalPrice = pricingInfo?.totalPrice ?? widget.totalPrice;
    return totalPrice * 0.7; // Assuming basic fare is roughly 70% of total (adjust as needed)
    
  } catch (e) {
    print('Error extracting basic fare: $e');
    return widget.totalPrice * 0.7; // Fallback calculation
  }
}
double _getTaxFromRevalidation() {
  try {
    final revalidationController = Get.find<AirArabiaRevalidationController>();
    final pricingInfo = revalidationController.revalidationResponse.value?.data?.pricing;
    
    if (pricingInfo?.ptcFareBreakdown.passengerFare?.taxes?.taxes != null) {
      final taxes = pricingInfo!.ptcFareBreakdown.passengerFare!.taxes!.taxes;
      double totalTax = 0.0;
      
      for (final tax in taxes) {
        final amount = tax.attributes['Amount'];
        if (amount != null) {
          totalTax += double.tryParse(amount.toString()) ?? 0.0;
        }
      }
      return totalTax;
    }
    
    // Fallback: estimate tax as percentage of total price
    final totalPrice = pricingInfo?.totalPrice ?? widget.totalPrice;
    return totalPrice * 0.2; // Assuming tax is roughly 20% of total
    
  } catch (e) {
    print('Error extracting tax: $e');
    return (widget.totalPrice * 0.2); // Fallback calculation
  }
}

String _getFeesFromRevalidation() {
  try {
    final revalidationController = Get.find<AirArabiaRevalidationController>();
    final pricingInfo = revalidationController.revalidationResponse.value?.data?.pricing;
    
    if (pricingInfo?.ptcFareBreakdown.passengerFare?.fees != null && 
        pricingInfo!.ptcFareBreakdown.passengerFare!.fees.isNotEmpty) {
      
      double totalFees = 0.0;
      for (final fee in pricingInfo.ptcFareBreakdown.passengerFare!.fees) {
        if (fee is Map && fee['Amount'] != null) {
          totalFees += double.tryParse(fee['Amount'].toString()) ?? 0.0;
        }
      }
      
      return totalFees > 0 ? totalFees.toStringAsFixed(2) : "";
    }
    
    return ""; // Return empty string if no fees available
    
  } catch (e) {
    print('Error extracting fees: $e');
    return ""; // Return empty string on error
  }
}

// Add this method to create the booking API call
// Add this method to create the booking API call - FIXED VERSION
// Updated _createAirArabiaBooking method with proper bkIdArray handling
// Updated _createAirArabiaBooking method with new format
// Updated _createAirArabiaBooking method with CORRECTED format for baggage, meals, and seats
// Updated _createAirArabiaBooking method with CORRECTED array nesting
// Updated _createAirArabiaBooking method with FIXED multi-segment handling
Future<Map<String, dynamic>?> _createAirArabiaBooking() async {
  try {
    // Get API service
    final apiService = Get.put(ApiServiceAirArabia());

    // Get revalidation controller and meta info
    final revalidationController = Get.find<AirArabiaRevalidationController>();
    final metaInfo = revalidationController.revalidationResponse.value?.data?.meta;
    
    if (metaInfo == null) {
      throw Exception('No revalidation data found. Please revalidate flight first.');
    }
    final controller = Get.put(AirArabiaFlightController());

    // Get the selected package index from the controller
    final selectedPackageIndex = controller.selectedPackageIndex;
    print("Selected package index is $selectedPackageIndex");

    // Calculate number of flight segments
    final numberOfSegments = widget.flight.flightSegments.length;
    print("Number of flight segments: $numberOfSegments");

    // Add !ret! to final key if it's a return flight
    String finalKey = metaInfo.finalKey;
      // Check if !ret! is not already present to avoid duplication
      if (!finalKey.endsWith('!ret!')) {
        finalKey = finalKey + '!ret!';
      }
    
    print("Original final key: ${metaInfo.finalKey}");
    print("Modified final key: $finalKey");

    // Prepare bkIdArray and bkIdArray3 based on the selected package index and segments
    String bkIdArray = '';
    String bkIdArray3 = '';
    
    if (bkIdArray.isEmpty && bkIdArray3.isEmpty) {
      if (numberOfSegments == 1) {
        // Direct flight
        bkIdArray = "${selectedPackageIndex}_0-";
        bkIdArray3 = "${selectedPackageIndex}!0_";
      } else {
        // Multi-segment flight (with stops)
        List<String> bkIdArrayParts = [];
        List<String> bkIdArray3Parts = [];
        
        for (int i = 0; i < numberOfSegments; i++) {
          bkIdArrayParts.add("${selectedPackageIndex}_$i-");
          bkIdArray3Parts.add("${selectedPackageIndex}!${i}_");
        }
        
        bkIdArray = bkIdArrayParts.join("");
        bkIdArray3 = bkIdArray3Parts.join("");
      }
    }

    print("Final bkIdArray: $bkIdArray");
    print("Final bkIdArray3: $bkIdArray3");

    // Prepare passenger data in NEW FORMAT
    final List<Map<String, dynamic>> adultPassengers = [];
    final basicFarePerAdult = _getBasicFareFromRevalidation();
    final taxPerAdult = _getTaxFromRevalidation();
    final feesPerAdult = _getFeesFromRevalidation();

    for (int i = 0; i < bookingController.adults.length; i++) {
      final adult = bookingController.adults[i];
      adultPassengers.add({
        'title': adult.titleController.text,
        'given_name': adult.firstNameController.text.toUpperCase(),
        'surname': adult.lastNameController.text.toUpperCase(),
        'dob': adult.dateOfBirthController.text,
        'nationality': '${adult.nationalityController.text}-${adult.nationalityCountry.value?.countryCode ?? 'PK'}',
        'passport_no': adult.passportCnicController.text,
        'passport_exp': adult.passportExpiryController.text,
        'basic_fare': basicFarePerAdult.toStringAsFixed(2),
        'tax': taxPerAdult.toStringAsFixed(2),
        'fees': feesPerAdult, // Will be empty string if no fees available
      });
    }

    // Child passengers
    final List<Map<String, dynamic>> childPassengers = [];
    final basicFarePerChild = basicFarePerAdult * 0.75; // Children typically 75% of adult fare
    final taxPerChild = taxPerAdult * 0.75;
    final feesPerChild = feesPerAdult.isEmpty ? "" : (double.tryParse(feesPerAdult)! * 0.75).toStringAsFixed(2);

    for (int i = 0; i < bookingController.children.length; i++) {
      final child = bookingController.children[i];
      childPassengers.add({
        'title': child.titleController.text,
        'given_name': child.firstNameController.text.toUpperCase(),
        'surname': child.lastNameController.text.toUpperCase(),
        'dob': child.dateOfBirthController.text,
        'nationality': '${child.nationalityController.text}-${child.nationalityCountry.value?.countryCode ?? 'PK'}',
        'passport_no': child.passportCnicController.text,
        'passport_exp': child.passportExpiryController.text,
        'basic_fare': basicFarePerChild.toStringAsFixed(2),
        'tax': taxPerChild.toStringAsFixed(2),
        'fees': feesPerChild, // Will be empty string if no fees available
      });
    }

    // Infant passengers
    final List<Map<String, dynamic>> infantPassengers = [];
    final basicFarePerInfant = basicFarePerAdult * 0.1; // Infants typically 10% of adult fare
    final taxPerInfant = taxPerAdult * 0.1;
    final feesPerInfant = feesPerAdult.isEmpty ? "" : (double.tryParse(feesPerAdult)! * 0.1).toStringAsFixed(2);

    for (int i = 0; i < bookingController.infants.length; i++) {
      final infant = bookingController.infants[i];
      infantPassengers.add({
        'title': infant.titleController.text,
        'given_name': infant.firstNameController.text.toUpperCase(),
        'surname': infant.lastNameController.text.toUpperCase(),
        'dob': infant.dateOfBirthController.text,
        'nationality': '${infant.nationalityController.text}-${infant.nationalityCountry.value?.countryCode ?? 'PK'}',
        'basic_fare': basicFarePerInfant.toStringAsFixed(2),
        'tax': taxPerInfant.toStringAsFixed(2),
        'fees': feesPerInfant, // Will be empty string if no fees available
        // No passport fields for infants
      });
    }

    // Prepare flight details
    final List<Map<String, dynamic>> flightDetails = [];
    for (int segmentIndex = 0; segmentIndex < widget.flight.flightSegments.length; segmentIndex++) {
      final segment = widget.flight.flightSegments[segmentIndex];
      final departureDateTime = DateTime.parse(segment['departure']['dateTime']);
      final arrivalDateTime = DateTime.parse(segment['arrival']['dateTime']);
      
      // Calculate flight duration
      final duration = arrivalDateTime.difference(departureDateTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      final flightDuration = '${hours}h ${minutes}m';
      
      // Calculate layover for next segment (if exists)
      String layover = '0h 0m';
      if (segmentIndex < widget.flight.flightSegments.length - 1) {
        final nextSegment = widget.flight.flightSegments[segmentIndex + 1];
        final nextDepartureDateTime = DateTime.parse(nextSegment['departure']['dateTime']);
        final layoverDuration = nextDepartureDateTime.difference(arrivalDateTime);
        final layoverHours = layoverDuration.inHours;
        final layoverMinutes = layoverDuration.inMinutes % 60;
        layover = '${layoverHours}h ${layoverMinutes}m';
      }
      
      flightDetails.add({
        'depart': segment['departure']['airport'],
        'depart_date': '${departureDateTime.year}-${departureDateTime.month.toString().padLeft(2, '0')}-${departureDateTime.day.toString().padLeft(2, '0')}',
        'depart_time': '${departureDateTime.hour.toString().padLeft(2, '0')}:${departureDateTime.minute.toString().padLeft(2, '0')}',
        'dep_terminal': segment['departure']['terminal'] ?? '',
        'arr': segment['arrival']['airport'],
        'arr_date': '${arrivalDateTime.year}-${arrivalDateTime.month.toString().padLeft(2, '0')}-${arrivalDateTime.day.toString().padLeft(2, '0')}',
        'arr_time': '${arrivalDateTime.hour.toString().padLeft(2, '0')}:${arrivalDateTime.minute.toString().padLeft(2, '0')}',
        'arr_terminal': segment['arrival']['terminal'] ?? '',
        'flight_no': segment['flightNumber'],
        'airline_code': segment['flightNumber'].substring(0, 2),
        'operating_flight_no': segment['flightNumber'],
        'operating_airline_code': segment['flightNumber'].substring(0, 2),
        'class_cabin': 'Economy',
        'sub_class': 'Y',
        'hand_baggage': '7KG',
        'check_baggage': '20KG',
        'meal': 'Available',
        'layover': layover,
        'flight_duration': flightDuration,
        'flight_type': numberOfSegments == 1 ? 'Direct' : 'Connect',
        'fare_name': widget.selectedPackage.packageName,
      });
    }

    // FIXED: Handle baggage, meals, and seats with proper multi-segment support
    // Remove package index condition - if user selected something, pass it; if not, send empty arrays
    final selectedBaggage = revalidationController.selectedBaggage.values.toList();
    final selectedMealsMap = revalidationController.selectedMeals;
    final selectedSeatsMap = revalidationController.selectedSeats;

    print("Selected meals map: $selectedMealsMap");
    print("Selected seats map: $selectedSeatsMap");
    print("Number of segments: $numberOfSegments");

    // Format baggage data to match API format
    List<List<String>> adultBaggage = [];
    if (selectedBaggage.isNotEmpty) {
      for (int i = 0; i < bookingController.adults.length; i++) {
        if (i < selectedBaggage.length && selectedBaggage[i].baggageDescription.isNotEmpty) {
          adultBaggage.add([selectedBaggage[i].baggageDescription]);
        }
      }
    }

    // Format meal data for multi-segment flights
    List<List<List<String>>> adultMeal = [];
    
    print("DEBUG: selectedMealsMap contents:");
    selectedMealsMap.forEach((key, value) {
      print("Key: '$key', Values: ${value.map((m) => m.mealName).toList()}");
    });
    
    if (selectedMealsMap.isNotEmpty) {
      for (int adultIndex = 0; adultIndex < bookingController.adults.length; adultIndex++) {
        List<List<String>> adultMealForAllSegments = [];
        
        // Try to get meals from all available segment keys
        // The controller might store them with different key patterns
        for (final entry in selectedMealsMap.entries) {
          if (entry.value.isNotEmpty) {
            List<String> segmentMeals = [];
            for (var meal in entry.value) {
              segmentMeals.add("${meal.mealCode}--${meal.mealDescription}");
            }
            if (segmentMeals.isNotEmpty) {
              adultMealForAllSegments.add(segmentMeals);
            }
          }
        }
        
        // Add meals for this adult if any were selected
        if (adultMealForAllSegments.isNotEmpty) {
          adultMeal.add(adultMealForAllSegments);
          print("DEBUG: Added meals for adult $adultIndex: $adultMealForAllSegments");
        }
      }
    }

    // Format seat data for multi-segment flights  
    List<List<List<String>>> adultSeat = [];
    
    print("DEBUG: selectedSeatsMap contents:");
    selectedSeatsMap.forEach((key, value) {
      print("Key: '$key', Seat: ${value.seatNumber}");
    });
    
    if (selectedSeatsMap.isNotEmpty) {
      for (int adultIndex = 0; adultIndex < bookingController.adults.length; adultIndex++) {
        List<List<String>> adultSeatForAllSegments = [];
        
        // Try to get seats from all available segment keys
        // The controller might store them with different key patterns
        for (final entry in selectedSeatsMap.entries) {
          if (entry.value.seatNumber.isNotEmpty) {
            final seat = entry.value;
            adultSeatForAllSegments.add(["${seat.seatNumber}--${seat.seatNumber}"]);
          }
        }
        
        // Add seats for this adult if any were selected
        if (adultSeatForAllSegments.isNotEmpty) {
          adultSeat.add(adultSeatForAllSegments);
          print("DEBUG: Added seats for adult $adultIndex: $adultSeatForAllSegments");
        }
      }
    }

    // Determine flight type and stops
    String flightType = 'OneWay';
    List<int> stopsSector = [numberOfSegments - 1]; // Number of segments minus 1 = number of stops

    print('=== MULTI-SEGMENT BOOKING PARAMETERS DEBUG ===');
    print('Number of Segments: $numberOfSegments');
    print('Final Key: ${metaInfo.finalKey}');
    print('Selected Package Index: $selectedPackageIndex');
    print('bkIdArray: $bkIdArray');
    print('bkIdArray3: $bkIdArray3');
    print('Stops Sector: $stopsSector');
    print('Adult Baggage Structure: $adultBaggage');
    print('Adult Meals Structure: $adultMeal');
    print('Adult Seats Structure: $adultSeat');
    print('Flight Details Count: ${flightDetails.length}');
    print('============================================');

    final response = await apiService.createAirArabiaBooking(
      email: bookingController.emailController.text,
      finalKey: finalKey, // Use the modified final key with !ret! if needed
      echoToken: metaInfo.echoToken,
      transactionIdentifier: metaInfo.transactionId,
      jsession: metaInfo.jsession,
      adults: travelersController.adultCount.value,
      child: travelersController.childrenCount.value,
      infant: travelersController.infantCount.value,
      stopsSector: stopsSector,
      bkIdArray: bkIdArray,
      bkIdArray3: bkIdArray3,
      adultBaggage: adultBaggage,
      adultMeal: adultMeal,
      adultSeat: adultSeat,
      childBaggage: [],
      childMeal: [],
      childSeat: [],
      bookerName: '${bookingController.firstNameController.text} ${bookingController.lastNameController.text}',
      countryCode: bookingController.bookerPhoneCountry.value?.phoneCode ?? '92',
      simCode: bookingController.bookerPhoneCountry.value?.phoneCode ?? '92',
      city: 'Unknown',
      address: 'Unknown',
      phone: bookingController.phoneController.text,
      remarks: bookingController.remarksController.text,
      marginPer: 0.0,
      marginVal: 0.0,
      finalPrice: widget.totalPrice,
      totalPrice: widget.totalPrice,
      flightType: flightType,
      csId: 1,
      csName: 'Default Agent',
      adultPassengers: adultPassengers,
      childPassengers: childPassengers,
      infantPassengers: infantPassengers,
      flightDetails: flightDetails,
    );

    print('API Response received: $response');
    return response;
    
  } catch (e, stackTrace) {
    print('Error in _createAirArabiaBooking: $e');
    print('Stack Trace: $stackTrace');
    rethrow;
  }
}
void dispose() {
    super.dispose();
  }
}