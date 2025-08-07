// travelers_selection_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utility/colors.dart';

class TravelersSelectionBottomSheet extends StatelessWidget {
  final Function(int adults, int children, int infants, String travelClass) onTravelersSelected;
  final String initialClass;

  const TravelersSelectionBottomSheet({
    Key? key,
    required this.onTravelersSelected,
    this.initialClass = 'Economy',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TravelersController controller = Get.put(TravelersController());

    // Set initial travel class
    controller.travelClass.value = initialClass;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Passengers & Class',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.text,
                ),
              ),
              TextButton(
                onPressed: () {
                  onTravelersSelected(
                    controller.adultCount.value,
                    controller.childrenCount.value,
                    controller.infantCount.value,
                    controller.travelClass.value,
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: TColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Adults section
          _buildTravelerSection(
            'Adults',
            'Ages 12+ years',
            controller.adultCount,
                () => controller.decrementAdults(),
                () => controller.incrementAdults(),
            1, // minimum
            5, // maximum
          ),
          SizedBox(height: 20),

          // Children section
          _buildTravelerSection(
            'Children',
            'Ages 2-12 years',
            controller.childrenCount,
                () => controller.decrementChildren(),
                () => controller.incrementChildren(),
            0, // minimum
            8, // maximum
          ),
          SizedBox(height: 20),

          // Infants section
          _buildTravelerSection(
            'Infant',
            'Ages 0-2 years',
            controller.infantCount,
                () => controller.decrementInfants(),
                () => controller.incrementInfants(),
            0, // minimum
            4, // maximum
          ),
          SizedBox(height: 20),

          // Class Selection Dropdown
          _buildClassDropdown(controller),
          SizedBox(height: 20),

          Text(
            'For 10 Passengers or above kindly send the email on',
            style: TextStyle(
              fontSize: 12,
              color: TColors.grey,
            ),
          ),
          InkWell(
            onTap: () {
              // Handle email tap if needed
            },
            child: Text(
              'groups@exampletrip.com',
              style: TextStyle(
                fontSize: 12,
                color: TColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelerSection(
      String title,
      String subtitle,
      RxInt count,
      VoidCallback onDecrement,
      VoidCallback onIncrement,
      int minCount,
      int maxCount,
      ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TColors.text,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: TColors.grey,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Minus Button
            Obx(() => GestureDetector(
              onTap: count.value > minCount ? onDecrement : null,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: count.value > minCount
                        ? TColors.primary
                        : TColors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                  color: TColors.white,
                ),
                child: Icon(
                  Icons.remove,
                  color: count.value > minCount
                      ? TColors.primary
                      : TColors.grey.withOpacity(0.3),
                  size: 18,
                ),
              ),
            )),

            // Count Display
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Obx(() => Text(
                count.value.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.text,
                ),
              )),
            ),

            // Plus Button
            Obx(() => GestureDetector(
              onTap: count.value < maxCount ? onIncrement : null,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: count.value < maxCount
                        ? TColors.primary
                        : TColors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                  color: TColors.white,
                ),
                child: Icon(
                  Icons.add,
                  color: count.value < maxCount
                      ? TColors.primary
                      : TColors.grey.withOpacity(0.3),
                  size: 18,
                ),
              ),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildClassDropdown(TravelersController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Class',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TColors.text,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: TColors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
            color: TColors.white,
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.travelClass.value,
              icon: Icon(Icons.keyboard_arrow_down, color: TColors.grey),
              isExpanded: true,
              style: TextStyle(
                color: TColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              items: controller.availableTravelClasses.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.updateTravelClass(newValue);
                }
              },
            ),
          )),
        ),
      ],
    );
  }
}

class TravelersController extends GetxController {
  var adultCount = 1.obs;
  var childrenCount = 0.obs;
  var infantCount = 0.obs;
  var travelClass = 'Economy'.obs;

  // Updated travel classes (removed Premium Economy)
  final List<String> availableTravelClasses = [
    'Economy',
    'Business',
    'First Class'
  ];

  void incrementAdults() {
    if (adultCount.value < 5) { // Changed max from 9 to 5
      adultCount.value++;
    }
  }

  void decrementAdults() {
    if (adultCount.value > 1) {
      adultCount.value--;
      // Ensure infants don't exceed adults
      if (infantCount.value > adultCount.value) {
        infantCount.value = adultCount.value;
      }
    }
  }

  void incrementChildren() {
    if (childrenCount.value < 8) {
      childrenCount.value++;
    }
  }

  void decrementChildren() {
    if (childrenCount.value > 0) {
      childrenCount.value--;
    }
  }

  void incrementInfants() {
    if (infantCount.value < adultCount.value && infantCount.value < 4) {
      infantCount.value++;
    }
  }

  void decrementInfants() {
    if (infantCount.value > 0) {
      infantCount.value--;
    }
  }

  void updateTravelClass(String newClass) {
    travelClass.value = newClass;
  }
}