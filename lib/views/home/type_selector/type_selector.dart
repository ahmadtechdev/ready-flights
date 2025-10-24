import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../utility/colors.dart';
import '../../../utility/app_constants.dart';

class TypeSelector extends StatefulWidget {
  final ValueChanged<String> onTypeChanged;

  const TypeSelector({super.key, required this.onTypeChanged});

  @override
  TypeSelectorState createState() => TypeSelectorState();
}

class TypeSelectorState extends State<TypeSelector> {
  String selectedType = 'Flights';

  final List<Map<String, dynamic>> travelTypes = [
    {'icon': Icons.flight_takeoff, 'label': 'Flights'},
    {'icon': Icons.hotel, 'label': 'Hotels'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: travelTypes.map((type) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedType = type['label'];
                widget.onTypeChanged(selectedType);
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: selectedType == type['label']
                    ? TColors.primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedType == type['label']
                      ? TColors.primary
                      : AppConstants.fieldBorderColor,
                  width: 1,
                ),
                boxShadow: selectedType == type['label']
                    ? AppConstants.cardShadow
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type['icon'],
                    size: 16,
                    color: selectedType == type['label']
                        ? Colors.white
                        : AppConstants.tabInactiveColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    type['label'],
                    style: TextStyle(
                      color: selectedType == type['label']
                          ? Colors.white
                          : AppConstants.tabInactiveColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}