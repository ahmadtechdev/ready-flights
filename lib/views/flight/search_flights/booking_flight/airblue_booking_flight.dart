// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import '../../../../services/api_service_airblue.dart';
import '../../../../utility/colors.dart';
import '../../../../widgets/travelers_selection_bottom_sheet.dart';
import '../airblue/airblue_flight_controller.dart';
import '../airblue/airblue_flight_model.dart';
import '../airblue/airblue_pnr_pricing.dart';
import '../search_flight_utils/widgets/airblue_flight_card.dart';
import 'booking_flight_controller.dart';
import 'flight_print_voucher.dart';

class AirBlueBookingFlight extends StatefulWidget {
  final AirBlueFlight flight;
  final AirBlueFlight? returnFlight;
  final double totalPrice;
  final String currency;
  final AirBlueFareOption? outboundFareOption;
  final AirBlueFareOption? returnFareOption;

  const AirBlueBookingFlight({
    super.key,
    required this.flight,
    this.returnFlight,
    required this.totalPrice,
    required this.currency,
    this.outboundFareOption,
    this.returnFareOption,
  });

  @override
  State<AirBlueBookingFlight> createState() => _AirBlueBookingFlightState();
}

class _AirBlueBookingFlightState extends State<AirBlueBookingFlight> {
  final _formKey = GlobalKey<FormState>();
  final BookingFlightController bookingController = Get.put(
    BookingFlightController(),
  );
  final TravelersController travelersController = Get.put(
    TravelersController(),
  );
  final AirBlueFlightController flightController =
      Get.find<AirBlueFlightController>();

  bool termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
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
                _buildFlightDetails(),
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

  Widget _buildFlightDetails() {
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
        children: [
          if (widget.returnFlight != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.flight_takeoff, color: TColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Outbound Flight',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: TColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            AirBlueFlightCard(flight: widget.flight, showReturnFlight: false),
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
              ),
              child: Row(
                children: [
                  Icon(Icons.flight_land, color: TColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Return Flight',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: TColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            AirBlueFlightCard(
              flight: widget.returnFlight!,
              showReturnFlight: false,
            ),
          ] else ...[
            AirBlueFlightCard(flight: widget.flight, showReturnFlight: false),
          ],
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
                // Title and Gender Row
                Row(
                  children: [
                    Expanded(
                      child: _buildCheckboxGroup(
                        label: 'Title',
                        options:
                            isInfant
                                ? ['Inf']
                                : (type == 'child'
                                    ? ['Mstr', 'Miss']
                                    : ['Mr', 'Mrs', 'Ms']),
                        controller: travelerInfo.titleController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCheckboxGroup(
                        label: 'Gender',
                        options: ['Male', 'Female'],
                        controller: travelerInfo.genderController,
                      ),
                    ),
                  ],
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
                      label:
                          bookingController.isDomesticFlight
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
                  label:
                      bookingController.isDomesticFlight
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

  Widget _buildCheckboxGroup({
    required String label,
    required List<String> options,
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
        Wrap(
          spacing: 8,
          children:
              options.map((option) {
                return InkWell(
                  onTap: () {
                    controller.text = option;
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          controller.text == option
                              ? TColors.primary
                              : Colors.white,
                      border: Border.all(
                        color:
                            controller.text == option
                                ? TColors.primary
                                : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color:
                            controller.text == option
                                ? Colors.white
                                : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
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
              onPressed: () async {
                if (_formKey.currentState!.validate() && termsAccepted) {
                  try {
                    // Show loading
                    Get.dialog(
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            TColors.primary,
                          ),
                        ),
                      ),
                      barrierDismissible: false,
                    );

                    // Call the API to save booking
                    final response = await AirBlueFlightApiService()
                        .saveAirBlueBooking(
                          bookingController: bookingController,
                          flight: widget.flight,
                          returnFlight: widget.returnFlight,
                          token: 'your_auth_token_here',
                        );

                    // Hide loading
                    Get.back();

                    if (response['status'] == 200) {
                      Get.snackbar(
                        'Success',
                        'Booking created successfully',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );

                      try {
                        final pnrResponse = await AirBlueFlightApiService()
                            .createAirBluePNR(
                              flight: widget.flight,
                              returnFlight: widget.returnFlight,
                              bookingController: bookingController,
                              clientEmail:
                                  bookingController.emailController.text,
                              clientPhone:
                                  bookingController.phoneController.text,
                              isDomestic: bookingController.isDomesticFlight,
                            );

                        // Access the pricing information
                        if (pnrResponse['pnrPricing'] != null) {
                          for (var price
                              in pnrResponse['rawPricingObjects']
                                  as List<AirBluePNRPricing>) {
                            // Handle pricing objects
                          }
                        }

                        // Update the flight with PNR pricing
                        final updatedOutboundFlight = widget.flight
                            .copyWithPNRPricing(
                              pnrResponse['rawPricingObjects'] ?? [],
                            );

                        // If you have a return flight
                        AirBlueFlight? updatedReturnFlight;
                        if (widget.returnFlight != null) {
                          updatedReturnFlight = widget.returnFlight
                              ?.copyWithPNRPricing(
                                pnrResponse['rawPricingObjects'] ?? [],
                              );
                        }

                        Get.snackbar(
                          'Success',
                          'PNR created successfully',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );

                        Get.to(
                          () => FlightBookingDetailsScreen(
                            outboundFlight: updatedOutboundFlight,
                            returnFlight: updatedReturnFlight,
                            outboundFareOption: widget.outboundFareOption,
                            returnFareOption: widget.returnFareOption,
                            pnrResponse: pnrResponse,
                          ),
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to create PNR: $e',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                    } else {
                      // Handle API success response with error status
                      String errorMessage =
                          response['message'] ?? 'Failed to create booking';
                      if (response['errors'] != null) {
                        errorMessage +=
                            '\n${(response['errors'] as Map).entries.map((e) {
                              return '${e.key}: ${e.value}';
                            }).join('\n')}';
                      }
                      Get.snackbar(
                        'Error',
                        errorMessage,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 5),
                        snackPosition: SnackPosition.TOP,
                      );
                    }
                  } on ApiException catch (e) {
                    Get.back();
                    String errorMessage = e.message;
                    if (e.errors.isNotEmpty) {
                      errorMessage +=
                          '\n${e.errors.entries.map((e) {
                            return '${e.key}: ${e.value}';
                          }).join('\n')}';
                    }
                    Get.snackbar(
                      'Error (${e.statusCode ?? 'Unknown'})',
                      errorMessage,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 5),
                      snackPosition: SnackPosition.TOP,
                    );
                  } catch (e) {
                    Get.back();
                    Get.snackbar(
                      'Error',
                      e.toString(),
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 5),
                      snackPosition: SnackPosition.TOP,
                    );
                  }
                } else if (!termsAccepted) {
                  Get.snackbar(
                    'Error',
                    'Please accept terms and conditions',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Please fill all required fields',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );
                }
              },
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

  @override
  void dispose() {
    bookingController.dispose();
    travelersController.dispose();
    super.dispose();
  }
}
