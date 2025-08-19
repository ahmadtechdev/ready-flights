import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

import '../../../../../widgets/travelers_selection_bottom_sheet.dart';
import '../../../form/flight_booking_controller.dart';

class TravelerInfo {
  final TextEditingController titleController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController passportCnicController;
  final TextEditingController nationalityController;
  final TextEditingController dateOfBirthController;
  final TextEditingController passportExpiryController;
  final TextEditingController genderController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final bool isInfant;

  // Country objects for better handling
  final Rx<Country?> phoneCountry;
  final Rx<Country?> nationalityCountry;

  TravelerInfo({required this.isInfant})
      : titleController = TextEditingController(),
        firstNameController = TextEditingController(),
        lastNameController = TextEditingController(),
        passportCnicController = TextEditingController(),
        nationalityController = TextEditingController(),
        dateOfBirthController = TextEditingController(),
        passportExpiryController = TextEditingController(),
        genderController = TextEditingController(),
        phoneController = TextEditingController(),
        emailController = TextEditingController(),
        phoneCountry = Rx<Country?>(Country.parse('PK')), // Default to Pakistan
        nationalityCountry = Rx<Country?>(Country.parse('PK')) {

    // Set initial values
    nationalityController.text = nationalityCountry.value?.displayNameNoCountryCode ?? '';

    // Listen to country changes
    phoneCountry.listen((country) {
      // Phone country changes are handled in the UI
    });

    nationalityCountry.listen((country) {
      nationalityController.text = country?.displayNameNoCountryCode ?? '';
    });
  }

  void dispose() {
    titleController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passportCnicController.dispose();
    nationalityController.dispose();
    dateOfBirthController.dispose();
    passportExpiryController.dispose();
    genderController.dispose();
    phoneController.dispose();
    emailController.dispose();
  }

  bool isValid() {
    if (isInfant) {
      return titleController.text.isNotEmpty &&
          firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          dateOfBirthController.text.isNotEmpty &&
          nationalityCountry.value != null;
    } else {
      return titleController.text.isNotEmpty &&
          firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          passportCnicController.text.isNotEmpty &&
          nationalityCountry.value != null &&
          dateOfBirthController.text.isNotEmpty &&
          passportExpiryController.text.isNotEmpty &&
          genderController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          phoneCountry.value != null;
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'title': titleController.text,
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'dateOfBirth': dateOfBirthController.text,
      'nationality': nationalityCountry.value?.displayNameNoCountryCode ?? '',
      'nationalityCode': nationalityCountry.value?.countryCode ?? '',
      'gender': genderController.text,
    };

    if (!isInfant) {
      data.addAll({
        'passportNumber': passportCnicController.text,
        'passportExpiry': passportExpiryController.text,
        'phone': phoneController.text,
        'phoneCountryCode': phoneCountry.value?.phoneCode ?? '',
        'phoneCountry': phoneCountry.value?.countryCode ?? '',
        'email': emailController.text,
      });
    }

    return data;
  }
}

class BookingFlightController extends GetxController {
  final TravelersController travelersController = Get.put(TravelersController());

  // Travelers information
  final RxList<TravelerInfo> adults = <TravelerInfo>[].obs;
  final RxList<TravelerInfo> children = <TravelerInfo>[].obs;
  final RxList<TravelerInfo> infants = <TravelerInfo>[].obs;

  // Booker Information
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final remarksController = TextEditingController();

  // Booker country information
  final Rx<Country?> bookerPhoneCountry = Rx<Country?>(Country.parse('PK'));

  // Pricing information
  final totalAmount = 0.0.obs;
  final currencyCode = 'PKR'.obs;

  // Loading state
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeTravelers();
    // Listen to changes in traveler counts
    ever(travelersController.adultCount, (_) => updateAdults());
    ever(travelersController.childrenCount, (_) => updateChildren());
    ever(travelersController.infantCount, (_) => updateInfants());
  }

  void initializeTravelers() {
    updateAdults();
    updateChildren();
    updateInfants();
  }



  void updateAdults() {
    final currentCount = adults.length;
    final newCount = travelersController.adultCount.value;

    if (newCount > currentCount) {
      // Add new adult travelers
      for (var i = currentCount; i < newCount; i++) {
        adults.add(TravelerInfo(isInfant: false));
      }
    } else if (newCount < currentCount) {
      // Remove excess adult travelers
      for (var i = currentCount - 1; i >= newCount; i--) {
        adults[i].dispose();
        adults.removeAt(i);
      }
    }
  }

  void updateChildren() {
    final currentCount = children.length;
    final newCount = travelersController.childrenCount.value;

    if (newCount > currentCount) {
      // Add new child travelers
      for (var i = currentCount; i < newCount; i++) {
        children.add(TravelerInfo(isInfant: false));
      }
    } else if (newCount < currentCount) {
      // Remove excess child travelers
      for (var i = currentCount - 1; i >= newCount; i--) {
        children[i].dispose();
        children.removeAt(i);
      }
    }
  }

  void updateInfants() {
    final currentCount = infants.length;
    final newCount = travelersController.infantCount.value;

    if (newCount > currentCount) {
      // Add new infant travelers
      for (var i = currentCount; i < newCount; i++) {
        infants.add(TravelerInfo(isInfant: true));
      }
    } else if (newCount < currentCount) {
      // Remove excess infant travelers
      for (var i = currentCount - 1; i >= newCount; i--) {
        infants[i].dispose();
        infants.removeAt(i);
      }
    }
  }

  bool get isDomesticFlight {
    try {
      return Get.find<FlightBookingController>().isDomesticFlight;
    } catch (e) {
      return false; // Default to international if controller not found
    }
  }

  // Country picker methods
  void showPhoneCountryPicker(BuildContext context, TravelerInfo travelerInfo) {
    showCountryPicker(
      context: context,
      // favorite: ['PK', 'US', 'AE', 'SA', 'IN'],
      showPhoneCode: true,
      onSelect: (Country country) {
        travelerInfo.phoneCountry.value = country;
      },
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
        bottomSheetHeight: MediaQuery.of(context).size.height*0.8,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to model_controllers',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
    );
  }

  void showBookerPhoneCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      // favorite: ['PK', 'US', 'AE', 'SA', 'IN'],
      showPhoneCode: true,
      onSelect: (Country country) {
        bookerPhoneCountry.value = country;
      },
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
        bottomSheetHeight: MediaQuery.of(context).size.height*0.8,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to model_controllers',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
    );
  }

  void showNationalityPicker(BuildContext context, TravelerInfo travelerInfo) {
    showCountryPicker(
      context: context,
      // favorite: ['PK', 'US', 'AE', 'SA', 'IN'],
      showPhoneCode: false,
      onSelect: (Country country) {
        travelerInfo.nationalityCountry.value = country;
      },
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
        bottomSheetHeight: 500,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search nationality',
          hintText: 'Start typing to model_controllers',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
    );
  }

  // Validation methods
  bool isEmailValid(String email) {
    return GetUtils.isEmail(email);
  }

  bool isPhoneValid(String phone) {
    return phone.isNotEmpty && phone.length >= 7;
  }

  bool validateBookerInfo() {
    return firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        isEmailValid(emailController.text) &&
        phoneController.text.isNotEmpty &&
        isPhoneValid(phoneController.text) &&
        bookerPhoneCountry.value != null;
  }

  bool validateAllTravelersInfo() {
    bool adultsValid = adults.every((adult) => adult.isValid());
    bool childrenValid = children.every((child) => child.isValid());
    bool infantsValid = infants.every((infant) => infant.isValid());

    return adultsValid && childrenValid && infantsValid;
  }

  bool validateAll() {
    return validateBookerInfo() && validateAllTravelersInfo();
  }

  void resetForm() {
    // Reset booker information
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    remarksController.clear();
    bookerPhoneCountry.value = Country.parse('PK');

    // Reset all travelers
    adults.clear();
    children.clear();
    infants.clear();

    // Reinitialize travelers based on current counts
    initializeTravelers();
  }

  @override
  void onClose() {
    // Dispose booker information controllers
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    remarksController.dispose();

    // Dispose all traveler controllers
    for (var adult in adults) {
      adult.dispose();
    }
    for (var child in children) {
      child.dispose();
    }
    for (var infant in infants) {
      infant.dispose();
    }

    super.onClose();
  }
}