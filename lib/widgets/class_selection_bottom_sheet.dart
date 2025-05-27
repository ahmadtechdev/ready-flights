// class_selection_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../../utility/colors.dart';

class ClassSelectionBottomSheet extends StatefulWidget {
  final String initialClass;
  final Function(String selectedClass) onClassSelected;

  const ClassSelectionBottomSheet({
    Key? key,
    required this.initialClass,
    required this.onClassSelected,
  }) : super(key: key);

  @override
  State<ClassSelectionBottomSheet> createState() => _ClassSelectionBottomSheetState();
}

class _ClassSelectionBottomSheetState extends State<ClassSelectionBottomSheet> {
  late String selectedClass;

  @override
  void initState() {
    super.initState();
    selectedClass = widget.initialClass;
  }

  @override
  Widget build(BuildContext context) {
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
                'Select Class',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          _buildClassOption('Economy'),
          _buildClassOption('Premium Economy'),
          _buildClassOption('Business'),
          _buildClassOption('First Class'),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onClassSelected(selectedClass);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.third,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'DONE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassOption(String className) {
    final bool isSelected = selectedClass == className;
    return InkWell(
      onTap: () {
        setState(() {
          selectedClass = className;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              )
                  : null,
            ),
            SizedBox(width: 12),
            Text(
              className,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}