import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:ready_flights/views/hotel/search_hotels/booking_hotel/payment_hotel/payment_method.dart';
import 'package:ready_flights/views/hotel/search_hotels/select_room/controller/select_room_controller.dart';
import '../../../../utility/colors.dart';
import '../../../../widgets/snackbar.dart';
import '../../hotel/guests/guests_controller.dart';
import 'booking_controller.dart';
import 'booking_voucher/booking_voucher.dart';
import 'payment_hotel/important_booking_details_card.dart';

class BookingHotelScreen extends StatelessWidget {
  final BookingController bookingController = Get.put(BookingController());
  final GuestsController guestsController = Get.find<GuestsController>();

  BookingHotelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: TColors.primary,
        title: const Text(
          "Complete Your Booking",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ImportantBookingDetailsCard(),
                    _buildRoomCards(),
                    const SizedBox(height: 20),
                    _buildBookerInfoCard(),
                    const SizedBox(height: 20),
                    _buildSpecialRequestsCard(),
                    const SizedBox(height: 20),
                    _buildTermsAndConditions(),
                    const SizedBox(height: 30),
                    _buildSubmitButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (bookingController.isLoading.value)
              const Center(
                child: CircularProgressIndicator(color: TColors.primary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCards() {
    return Column(
      children: List.generate(
        bookingController.roomGuests.length,
        (roomIndex) => _buildRoomCard(roomIndex),
      ),
    );
  }

  Widget _buildRoomCard(int roomIndex) {
    final roomGuests = bookingController.roomGuests[roomIndex];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Room ${roomIndex + 1}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                ),
                const Spacer(),
                _buildBadge("Refundable"),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              roomGuests.adults.length,
              (adultIndex) => _buildGuestField(
                guestInfo: roomGuests.adults[adultIndex],
                index: adultIndex,
                isAdult: true,
              ),
            ),
            ...List.generate(
              roomGuests.children.length,
              (childIndex) => _buildGuestField(
                guestInfo: roomGuests.children[childIndex],
                index: childIndex,
                isAdult: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestField({
    required HotelGuestInfo guestInfo,
    required int index,
    required bool isAdult,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
                isAdult ? "Adult ${index + 1}" : "Child ${index + 1}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TColors.primary,
                ),
              ),
          const SizedBox(height: 10),

          // Guest Type Header and Title Dropdown
          Container(
            child: _buildDropdown(
              controller: guestInfo.titleController,
              hint: 'Title',
              items: isAdult ? ['Mr.', 'Mrs.', 'Ms.'] : ['Mstr.', 'Miss.'],
            ),
          ),
          const SizedBox(height: 12
          
          
          
          
        
          ),
          
          // First Name Field (Separate Row)
          _buildTextField(
            controller: guestInfo.firstNameController,
            hint: 'First Name',
            prefixIcon: Icons.person_outline,
            iconColor: TColors.primary,
          ),
          const SizedBox(height: 12),
          
          // Last Name Field (Separate Row)
          _buildTextField(
            controller: guestInfo.lastNameController,
            hint: 'Last Name',
            prefixIcon: Icons.person_outline,
            iconColor: TColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBookerInfoCard() {
    return Card(
      elevation: 4,
      color: TColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booker Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: TColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title Dropdown
            _buildDropdown(
              controller: bookingController.titleController,
              hint: 'Title',
              items: ['Mr.', 'Mrs.', 'Ms.'],
            ),
            const SizedBox(height: 16),
            
            // First Name Field (Separate Row)
            _buildTextField(
              controller: bookingController.firstNameController,
              hint: 'First Name',
              prefixIcon: Icons.person_outline,
              iconColor: TColors.primary,
            ),
            const SizedBox(height: 16),
            
            // Last Name Field (Separate Row)
            _buildTextField(
              controller: bookingController.lastNameController,
              hint: 'Last Name',
              prefixIcon: Icons.person_outline,
              iconColor: TColors.primary,
            ),
            const SizedBox(height: 16),
            
            // Email Field
            _buildTextField(
              controller: bookingController.emailController,
              hint: 'Email',
              prefixIcon: Icons.email_outlined,
              iconColor: TColors.primary,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            // Phone Field with Country Picker
            _buildPhoneFieldWithCountryPicker(),
            const SizedBox(height: 16),
            
            // Address Field (Separate Row)
            _buildTextField(
              controller: bookingController.addressController,
              hint: 'Address Line',
              prefixIcon: Icons.location_on_outlined,
              iconColor: TColors.primary,
            ),
            const SizedBox(height: 16),
            
            // City Field (Separate Row)
            _buildTextField(
              controller: bookingController.cityController,
              hint: 'City',
              prefixIcon: Icons.location_city_outlined,
              iconColor: TColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneFieldWithCountryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              // Country Code Picker
              Obx(() {
                return InkWell(
                  onTap: () {
                    showCountryPicker(
                      context: Get.context!,
                      showPhoneCode: true,
                      searchAutofocus: true,
                      showSearch: true,
                      exclude: <String>['KN', 'MF'], // Optional: exclude specific countries
                      favorite: <String>['PK', 'US', 'GB', 'IN', 'SA', 'AE'], // Optional: show favorite countries at top
                      countryListTheme: CountryListThemeData(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                        ),
                        inputDecoration: InputDecoration(
                          labelText: 'Search',
                          hintText: 'Start typing to search',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: const Color(0xFF8C98A8).withOpacity(0.2),
                            ),
                          ),
                        ),
                        searchTextStyle: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                      onSelect: (Country country) {
                        bookingController.selectedCountry.value = country;
                      },
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
                          bookingController.selectedCountry.value.flagEmoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${bookingController.selectedCountry.value.phoneCode}',
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
                child: TextField(
                  controller: bookingController.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    hintText: 'Phone Number',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCountryPicker() {
    // This method is no longer needed as we're using the country_picker package
    // The showCountryPicker method is called directly in the onTap of the country picker button
  }

  Widget _buildSpecialRequestsCard() {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Special Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: bookingController.specialRequestsController,
              hint: 'Enter any special requests',
              prefixIcon: Icons.note_add_outlined,
              iconColor: TColors.primary,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                children: [
                  _buildCheckboxTile(
                    'Ground Floor',
                    bookingController.isGroundFloor.value,
                    (value) => bookingController.isGroundFloor.value = value!,
                  ),
                  _buildCheckboxTile(
                    'High Floor',
                    bookingController.isHighFloor.value,
                    (value) => bookingController.isHighFloor.value = value!,
                  ),
                  _buildCheckboxTile(
                    'Late Checkout',
                    bookingController.isLateCheckout.value,
                    (value) => bookingController.isLateCheckout.value = value!,
                  ),
                  _buildCheckboxTile(
                    'Early Checkin',
                    bookingController.isEarlyCheckin.value,
                    (value) => bookingController.isEarlyCheckin.value = value!,
                  ),
                  _buildCheckboxTile(
                    'Twin Bed',
                    bookingController.isTwinBed.value,
                    (value) => bookingController.isTwinBed.value = value!,
                  ),
                  _buildCheckboxTile(
                    'Smoking Room',
                    bookingController.isSmoking.value,
                    (value) => bookingController.isSmoking.value = value!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Obx(
      () => CheckboxListTile(
        title: const Text(
          'I accept the terms and conditions',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        value: bookingController.acceptedTerms.value,
        onChanged: (value) => bookingController.acceptedTerms.value = value!,
        activeColor: TColors.primary,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hint,
    required IconData prefixIcon,
    required Color iconColor,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: iconColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required TextEditingController controller,
    required String hint,
    required List<String> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        hint: Text(
          hint,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            controller.text = value;
          }
        },
      ),
    );
  }

  Widget _buildCheckboxTile(
    String title,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: TColors.primary,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          _handleSubmit();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Complete Booking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

 void _handleSubmit() async {
  try {
    bookingController.isLoading.value = true;

    String? validationError = bookingController.getValidationError();
    if (validationError != null) {
      CustomSnackBar(
        message: validationError,
        backgroundColor: Colors.red,
      ).show();
      return;
    }

    final bool success = await bookingController.saveHotelBookingToDB();

    if (success) {
      // Get the selected rooms from SelectRoomController
      final SelectRoomController selectRoomController = Get.find<SelectRoomController>();
      selectRoomController.debugPrintRoomData();
      
      // Create a map of selected room data
      Map<int, Map<String, dynamic>> selectedRoomsData = {};
      
      for (int i = 0; i < selectRoomController.roomNames.length; i++) {
        if (selectRoomController.roomNames.containsKey(i)) {
          selectedRoomsData[i] = {
            'roomName': selectRoomController.getRoomName(i),
            'meal': selectRoomController.getRoomMeal(i),
            'rateType': selectRoomController.getRateType(i),
            'price': selectRoomController.getRoomPrice(i),
          };
        }
      }

      Get.to(() => const HotelPaymentScreen(), 
        arguments: {
          'selectedRooms': selectedRoomsData,
        }
      );
      
      CustomSnackBar(
        message: "Booking Confirmed Successfully!",
        backgroundColor: Colors.green,
      ).show();
    } else {
      CustomSnackBar(
        message: "Booking failed. Please try again.",
        backgroundColor: Colors.red,
      ).show();
    }
  } catch (e) {
    CustomSnackBar(
      message: "An error occurred. Please try again.",
      backgroundColor: Colors.red,
    ).show();
  } finally {
    bookingController.isLoading.value = false;
  }
} Widget _buildBadge(String text) {
    final isRefundable = text.toLowerCase() == 'refundable';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isRefundable ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isRefundable ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}