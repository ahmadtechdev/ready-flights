// travelers_selection_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utility/colors.dart';

class TravelersSelectionBottomSheet extends StatelessWidget {
  final Function(int adults, int children, int infants) onTravelersSelected;

  const TravelersSelectionBottomSheet({
    Key? key,
    required this.onTravelersSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TravelersController controller = Get.put(TravelersController());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                'No. of Travellers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  onTravelersSelected(
                    controller.adultCount.value,
                    controller.childrenCount.value,
                    controller.infantCount.value,
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.blue,
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
            'Adults (12+ yrs)',
            controller.adultCount,
                () => controller.decrementAdults(),
                () => controller.incrementAdults(),
            9,
          ),
          SizedBox(height: 20),
          // Children section
          _buildTravelerSection(
            'Children (2-12 yrs)',
            controller.childrenCount,
                () => controller.decrementChildren(),
                () => controller.incrementChildren(),
            8,
          ),
          SizedBox(height: 20),
          // Infants section
          _buildTravelerSection(
            'Infant (0-2 yrs)',
            controller.infantCount,
                () => controller.decrementInfants(),
                () => controller.incrementInfants(),
            4,
          ),
          SizedBox(height: 20),
          Text(
            'For 10 Passengers or above kindly send the email on',
            style: TextStyle(fontSize: 12),
          ),
          InkWell(
            onTap: () {
              // Handle email tap if needed
            },
            child: Text(
              'groups@exampletrip.com',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTravelerSection(
      String title,
      RxInt count,
      VoidCallback onDecrement,
      VoidCallback onIncrement,
      int maxCount,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: maxCount + 1, // Include zero as an option
            itemBuilder: (context, index) {
              final number = index; // Start from 0
              return Obx(() {
                final isSelected = count.value == number;
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      // If the number is already selected, unselect it (set to 0)
                      count.value = 0;
                    } else {
                      // Otherwise, select the number
                      if (title.contains('Adults')) {
                        if (number >= 1) {
                          count.value = number;
                          // Ensure infants don't exceed adults
                          final infantController = Get.find<TravelersController>();
                          if (infantController.infantCount.value > number) {
                            infantController.infantCount.value = number;
                          }
                        }
                      } else {
                        count.value = number;
                      }
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      color: isSelected ? Colors.blue : Colors.white,
                    ),
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }
}

class TravelersController extends GetxController {
  var adultCount = 1.obs;
  var childrenCount = 0.obs; // Starting with 0 as default
  var infantCount = 0.obs; // Starting with 0 as default
  var travelClass = 'Economy'.obs;

  // Available travel classes
  final List<String> availableTravelClasses = [
    'Economy',
    'Premium Economy',
    'Business',
    'First Class'
  ];

  void incrementAdults() {
    if (adultCount.value < 9) {
      adultCount.value++;
    }
  }

  void decrementAdults() {
    if (adultCount.value > 1) {
      adultCount.value--;
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