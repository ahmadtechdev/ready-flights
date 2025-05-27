import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utility/colors.dart';
import '../login/login.dart';
import 'rejistration_controller.dart';

class RegisterAccount extends StatelessWidget {
  final RegisterController controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() => Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: TColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Header
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 14,
                        left: 16,
                        right: 16,
                        bottom: 30,
                      ),
                      child: Text(
                        'Create a new account',
                        style: TextStyle(
                          color: TColors.text,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // "Already have an account? Log in" text
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 20),
                      child: Row(
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: TColors.text.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              Get.to(()=>Login());
                            },
                            child: Text(
                              'Log in',
                              style: TextStyle(
                                color: TColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Display API error message if any
                    if (controller.apiErrorMessage.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: TColors.third.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: TColors.third),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.error_outline, color: TColors.third),
                                  SizedBox(width: 8),
                                  Text(
                                    'Registration Error',
                                    style: TextStyle(
                                      color: TColors.third,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                controller.apiErrorMessage.value,
                                style: TextStyle(color: TColors.third),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Agency Name field
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: controller.agencyNameController,
                        style: TextStyle(color: TColors.text),
                        decoration: InputDecoration(
                          labelText: 'Agency Name',
                          labelStyle: TextStyle(
                            color: TColors.text.withOpacity(0.7),
                          ),
                          errorText: controller.getErrorText(
                            controller.agencyNameError,
                          ),
                          prefixIcon: Icon(Icons.business, color: TColors.primary),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: TColors.grey.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.primary),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.third),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.third),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ),

                    // Contact Name field
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: controller.contactNameController,
                        style: TextStyle(color: TColors.text),
                        decoration: InputDecoration(
                          labelText: 'Contact Name',
                          labelStyle: TextStyle(
                            color: TColors.text.withOpacity(0.7),
                          ),
                          errorText: controller.getErrorText(
                            controller.contactNameError,
                          ),
                          prefixIcon: Icon(Icons.person, color: TColors.primary),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: TColors.grey.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.primary),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.third),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.third),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ),

                    // Email field
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: TColors.text),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: TColors.text.withOpacity(0.7),
                          ),
                          errorText: controller.getErrorText(
                            controller.emailError,
                          ),
                          prefixIcon: Icon(Icons.email, color: TColors.primary),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: TColors.grey.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.primary),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.third),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.third),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ),

                    // Country Code and Cell
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Country Code dropdown
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    border: Border.all(
                                      color:
                                      controller.countryCodeError.value.isNotEmpty
                                          ? TColors.third
                                          : TColors.grey.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12),
                                        child: Icon(Icons.flag, color: TColors.primary),
                                      ),
                                      Expanded(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: controller.selectedCountryCode.value.isEmpty
                                                ? null
                                                : controller.selectedCountryCode.value,
                                            dropdownColor: Colors.white,
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                              color: TColors.text,
                                            ),
                                            style: TextStyle(color: TColors.text),
                                            isExpanded: true,
                                            hint: Padding(
                                              padding: const EdgeInsets.only(left: 8),
                                              child: Text(
                                                'Code',
                                                style: TextStyle(
                                                  color: TColors.text.withOpacity(0.7),
                                                ),
                                              ),
                                            ),
                                            items: controller.countryCodes.map((String code) {
                                              return DropdownMenuItem<String>(
                                                value: code,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 8),
                                                  child: Text(code),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: controller.updateCountryCode,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (controller.countryCodeError.value.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      top: 6,
                                    ),
                                    child: Text(
                                      controller.countryCodeError.value,
                                      style: TextStyle(
                                        color: TColors.third,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          // Cell field
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: controller.cellController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(color: TColors.text),
                              decoration: InputDecoration(
                                labelText: 'Cell Number',
                                labelStyle: TextStyle(
                                  color: TColors.text.withOpacity(0.7),
                                ),
                                errorText: controller.getErrorText(
                                  controller.cellError,
                                ),
                                prefixIcon: Icon(Icons.phone, color: TColors.primary),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: TColors.grey.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: TColors.primary,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: TColors.third,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: TColors.third,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Address field
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: controller.addressController,
                        style: TextStyle(color: TColors.text),
                        decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle: TextStyle(
                            color: TColors.text.withOpacity(0.7),
                          ),
                          errorText: controller.getErrorText(
                            controller.addressError,
                          ),
                          prefixIcon: Icon(Icons.location_on, color: TColors.primary),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: TColors.grey.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.primary),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.third),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.third),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ),

                    // City Name field
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: controller.cityNameController,
                        style: TextStyle(color: TColors.text),
                        decoration: InputDecoration(
                          labelText: 'City Name',
                          labelStyle: TextStyle(
                            color: TColors.text.withOpacity(0.7),
                          ),
                          errorText: controller.getErrorText(
                            controller.cityNameError,
                          ),
                          prefixIcon: Icon(Icons.location_city, color: TColors.primary),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: TColors.grey.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.primary),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.third),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.third),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ),

                    // Register button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.secondary,
                          disabledBackgroundColor: TColors.secondary.withOpacity(0.5),
                          minimumSize: Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: TColors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          'Register', // Changed from "Sign In" to "Register"
                          style: TextStyle(
                            color: TColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Loading overlay
            if (controller.isLoading.value)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: TColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'Creating your account...',
                            style: TextStyle(
                              color: TColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        )),
      ),
    );
  }
}