import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../widgets/colors.dart';

class TypeSelector extends StatefulWidget {
  final ValueChanged<String> onTypeChanged;

  const TypeSelector({super.key, required this.onTypeChanged});

  @override
  TypeSelectorState createState() => TypeSelectorState();
}

class TypeSelectorState extends State<TypeSelector> {
  String selectedType = 'Flights';

  final List<Map<String, dynamic>> travelTypes = [
    {'icon': Icons.flight, 'label': 'Flights'},
    {'icon': MdiIcons.bed, 'label': 'Hotels'},
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
            // Increase tap area with padding
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              // Optional: Add background color for visual feedback
              decoration: BoxDecoration(
                color: selectedType == type['label']
                    ? TColors.white.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type['icon'],
                    size: 28, // Slightly larger icon
                    color: selectedType == type['label']
                        ? TColors.primary
                        : TColors.grey,
                  ),
                  const SizedBox(height: 8), // Increased spacing
                  Text(
                    type['label'],
                    style: TextStyle(
                      color: selectedType == type['label']
                          ? TColors.primary
                          : TColors.grey,
                      fontWeight: selectedType == type['label']
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14, // Explicit font size
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