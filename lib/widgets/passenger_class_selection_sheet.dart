import 'package:flutter/material.dart';
import '../utility/colors.dart';
import '../utility/app_constants.dart';

class PassengerClassSelectionSheet extends StatefulWidget {
  final int adults;
  final int children;
  final int infants;
  final String travelClass;
  final Function(int adults, int children, int infants, String travelClass) onSelectionChanged;

  const PassengerClassSelectionSheet({
    super.key,
    required this.adults,
    required this.children,
    required this.infants,
    required this.travelClass,
    required this.onSelectionChanged,
  });

  @override
  State<PassengerClassSelectionSheet> createState() => _PassengerClassSelectionSheetState();
}

class _PassengerClassSelectionSheetState extends State<PassengerClassSelectionSheet> {
  late int _adults;
  late int _children;
  late int _infants;
  late String _travelClass;

  @override
  void initState() {
    super.initState();
    _adults = widget.adults;
    _children = widget.children;
    _infants = widget.infants;
    _travelClass = widget.travelClass;
  }

  void _updateAdults(int value) {
    setState(() {
      _adults = (_adults + value).clamp(1, 9);
    });
  }

  void _updateChildren(int value) {
    setState(() {
      _children = (_children + value).clamp(0, 9);
    });
  }

  void _updateInfants(int value) {
    setState(() {
      _infants = (_infants + value).clamp(0, 9);
    });
  }

  void _selectClass(String classType) {
    setState(() {
      _travelClass = classType;
    });
  }

  void _applySelection() {
    widget.onSelectionChanged(_adults, _children, _infants, _travelClass);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: TColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Travelers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Travelers Section
                  _buildTravelersSection(),
                  
                  const SizedBox(height: 30),
                  
                  // Class Section
                  _buildClassSection(),
                ],
              ),
            ),
          ),

          // Done Button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _applySelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Travelers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        
        // Adults
        _buildTravelerRow(
          icon: Icons.person,
          label: 'Adult',
          ageRange: '12 years or above',
          count: _adults,
          onDecrease: () => _updateAdults(-1),
          onIncrease: () => _updateAdults(1),
          canDecrease: _adults > 1,
        ),
        
        const SizedBox(height: 20),
        
        // Children
        _buildTravelerRow(
          icon: Icons.child_care,
          label: 'Children',
          ageRange: '2 to 11 years',
          count: _children,
          onDecrease: () => _updateChildren(-1),
          onIncrease: () => _updateChildren(1),
          canDecrease: _children > 0,
        ),
        
        const SizedBox(height: 20),
        
        // Infants
        _buildTravelerRow(
          icon: Icons.baby_changing_station,
          label: 'Infants',
          ageRange: '7 days to 23 months',
          count: _infants,
          onDecrease: () => _updateInfants(-1),
          onIncrease: () => _updateInfants(1),
          canDecrease: _infants > 0,
        ),
      ],
    );
  }

  Widget _buildTravelerRow({
    required IconData icon,
    required String label,
    required String ageRange,
    required int count,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
    required bool canDecrease,
  }) {
    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: TColors.primary,
            size: 20,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Label and Age Range
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ageRange,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        
        // Counter
        Row(
          children: [
            // Decrease Button
            GestureDetector(
              onTap: canDecrease ? onDecrease : null,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: canDecrease ? TColors.primary : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.remove,
                  color: canDecrease ? Colors.white : Colors.grey.shade500,
                  size: 16,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Count
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Increase Button
            GestureDetector(
              onTap: onIncrease,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: TColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Class',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        
        // Class Options
        _buildClassOption('Economy', 'Economy'),
        _buildClassOption('Premium Economy', 'Premium Economy'),
        _buildClassOption('Business', 'Business'),
        _buildClassOption('First', 'First'),
      ],
    );
  }

  Widget _buildClassOption(String value, String label) {
    final isSelected = _travelClass == value;
    
    return GestureDetector(
      onTap: () => _selectClass(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // Radio Button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? TColors.primary : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? TColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? TColors.primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the passenger and class selection sheet
Future<Map<String, dynamic>?> showPassengerClassSelection({
  required BuildContext context,
  required int adults,
  required int children,
  required int infants,
  required String travelClass,
}) {
  Map<String, dynamic>? result;
  
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    transitionAnimationController: AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: Navigator.of(context),
    ),
    builder: (context) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: ModalRoute.of(context)!.animation!,
        curve: Curves.easeOutCubic,
      )),
      child: PassengerClassSelectionSheet(
        adults: adults,
        children: children,
        infants: infants,
        travelClass: travelClass,
        onSelectionChanged: (newAdults, newChildren, newInfants, newTravelClass) {
          result = {
            'adults': newAdults,
            'children': newChildren,
            'infants': newInfants,
            'travelClass': newTravelClass,
          };
        },
      ),
    ),
  ).then((_) => result);
}
