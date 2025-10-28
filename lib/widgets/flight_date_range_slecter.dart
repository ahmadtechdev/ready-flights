import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utility/colors.dart';

enum DateSelectorMode {
  oneWay, // Single date picker with column calendar
  roundTrip, // Date range picker
  multiCity, // Single date picker with column calendar
}

class CustomDateRangeSelector extends StatelessWidget {
  // For Round Trip (Range Mode)
  final DateTimeRange? dateRange;
  final Function(DateTimeRange)? onDateRangeChanged;
  final int? nights;
  final Function(int)? onNightsChanged;

  // For One Way & Multi City (Single Date Mode)
  final DateTime? selectedDate;
  final Function(DateTime)? onDateChanged;

  // Common properties
  final DateSelectorMode mode;
  final String? label;
  final String? placeholder;

  const CustomDateRangeSelector({
    super.key,
    required this.mode,

    // Range mode properties
    this.dateRange,
    this.onDateRangeChanged,
    this.nights,
    this.onNightsChanged,

    // Single date mode properties
    this.selectedDate,
    this.onDateChanged,

    // Common properties
    this.label,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Use range picker only for RoundTrip, column calendar for OneWay and MultiCity
      child:
      mode == DateSelectorMode.roundTrip
          ? _buildRangeSelector(context)
          : _buildColumnCalendarSelector(context),
    );
  }

  Widget _buildRangeSelector(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showDateRangePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: dateRange,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: TColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: TColors.text,
                ),
              ),
              child: child!,
            );
          },
        );
        if (result != null && onDateRangeChanged != null) {
          onDateRangeChanged!(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label ?? 'Departure & Return Date',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateRange != null
                        ? '${_formatDate(dateRange!.start)} - ${_formatDate(dateRange!.end)} '
                        : placeholder ?? 'Select dates',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnCalendarSelector(BuildContext context) {
    return GestureDetector(
      onTap: () => _showGridCalendarPicker(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label ??
                        (mode == DateSelectorMode.oneWay
                            ? 'Departure Date'
                            : 'Flight Date'),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedDate != null
                        ? _formatDate(selectedDate!)
                        : placeholder ?? 'Select date',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Add calendar icon to indicate it opens custom calendar
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showGridCalendarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) => _AnimatedGridCalendarPicker(
        initialDate: selectedDate ?? DateTime.now(),
        onDateSelected: (date) {
          if (onDateChanged != null) {
            onDateChanged!(date);
          }
        },
        mode: mode,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _GridCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final DateSelectorMode mode;

  const _GridCalendarPicker({
    required this.initialDate,
    required this.onDateSelected,
    required this.mode,
  });

  @override
  State<_GridCalendarPicker> createState() => _GridCalendarPickerState();
}

class _GridCalendarPickerState extends State<_GridCalendarPicker> {
  DateTime? selectedDate;
  late PageController _pageController;
  DateTime currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    currentMonth = DateTime(selectedDate!.year, selectedDate!.month);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    List<DateTime> days = [];
    DateTime firstDay = DateTime(month.year, month.month, 1);
    DateTime lastDay = DateTime(month.year, month.month + 1, 0);

    // Add empty days for proper week alignment
    int firstWeekday = firstDay.weekday == 7 ? 0 : firstDay.weekday;
    for (int i = 0; i < firstWeekday; i++) {
      days.add(DateTime(0)); // Empty placeholder
    }

    // Add actual days
    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(month.year, month.month, day));
    }

    return days;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isToday(DateTime date) {
    DateTime today = DateTime.now();
    return _isSameDay(date, today);
  }

  bool _isValidDate(DateTime date) {
    if (date.year == 0) return false; // Empty placeholder
    DateTime today = DateTime.now();
    return date.isAfter(today) || _isSameDay(date, today);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.7,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.mode == DateSelectorMode.oneWay
                      ? 'Select Departure Date'
                      : 'Select Flight Date',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Month Navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        currentMonth.month - 1,
                      );
                    });
                  },
                  icon: Icon(Icons.chevron_left, color: TColors.primary),
                ),
                Text(
                  '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        currentMonth.month + 1,
                      );
                    });
                  },
                  icon: Icon(Icons.chevron_right, color: TColors.primary),
                ),
              ],
            ),
          ),

          // Days of week header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children:
              ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Calendar Grid
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _getDaysInMonth(currentMonth).length,
                itemBuilder: (context, index) {
                  final date = _getDaysInMonth(currentMonth)[index];

                  if (date.year == 0) {
                    return Container(); // Empty space
                  }

                  final isSelected = _isSameDay(selectedDate, date);
                  final isToday = _isToday(date);
                  final isValid = _isValidDate(date);

                  return GestureDetector(
                    onTap:
                    isValid
                        ? () {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? TColors.primary : null,
                        shape: BoxShape.circle,
                        border:
                        isToday && !isSelected
                            ? Border.all(color: TColors.primary, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                            isSelected
                                ? Colors.white
                                : isToday
                                ? TColors.primary
                                : isValid
                                ? Colors.black
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Confirm Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                selectedDate != null
                    ? () {
                  widget.onDateSelected(selectedDate!);
                  Navigator.of(context).pop();
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  selectedDate != null
                      ? 'Select - ${_formatSelectedDate(selectedDate!)}'
                      : 'Select a date',
                  style: const TextStyle(
                    color: Colors.white,
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

  String _formatSelectedDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month).substring(0, 3)}';
  }
}

class _ColumnCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final DateSelectorMode mode;

  const _ColumnCalendarPicker({
    required this.initialDate,
    required this.onDateSelected,
    required this.mode,
  });

  @override
  State<_ColumnCalendarPicker> createState() => _ColumnCalendarPickerState();
}

class _ColumnCalendarPickerState extends State<_ColumnCalendarPicker> {
  DateTime? selectedDate;
  late ScrollController _scrollController;
  final DateTime startDate = DateTime.now();
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    endDate = startDate.add(const Duration(days: 365));
    _scrollController = ScrollController();

    // Scroll to initial date after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToInitialDate();
    });
  }

  void _scrollToInitialDate() {
    final daysDifference = widget.initialDate.difference(startDate).inDays;
    final scrollPosition =
        daysDifference * 80.0; // 80 is approximate item height

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<DateTime> _generateDateList() {
    List<DateTime> dates = [];
    DateTime current = startDate;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final dates = _generateDateList();

    return Container(
      height: Get.height * 0.7,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.mode == DateSelectorMode.oneWay
                      ? 'Select Departure Date'
                      : 'Select Flight Date',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Calendar List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected =
                    selectedDate != null &&
                        date.year == selectedDate!.year &&
                        date.month == selectedDate!.month &&
                        date.day == selectedDate!.day;
                final isToday =
                    date.year == DateTime.now().year &&
                        date.month == DateTime.now().month &&
                        date.day == DateTime.now().day;

                // Show month header
                bool showMonthHeader =
                    index == 0 || date.month != dates[index - 1].month;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showMonthHeader) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: Colors.grey.shade50,
                        child: Text(
                          '${_getMonthName(date.month)} ${date.year}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],

                    // Date item
                    InkWell(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color:
                          isSelected
                              ? TColors.primary.withOpacity(0.1)
                              : null,
                          border: Border(
                            left: BorderSide(
                              width: 4,
                              color:
                              isSelected
                                  ? TColors.primary
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Date circle
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color:
                                isSelected
                                    ? TColors.primary
                                    : (isToday
                                    ? TColors.primary.withOpacity(0.1)
                                    : null),
                                shape: BoxShape.circle,
                                border:
                                isToday && !isSelected
                                    ? Border.all(
                                  color: TColors.primary,
                                  width: 2,
                                )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color:
                                    isSelected
                                        ? Colors.white
                                        : (isToday
                                        ? TColors.primary
                                        : Colors.black),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Day and date info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getDayName(date.weekday),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                      isSelected
                                          ? TColors.primary
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '${date.day} ${_getMonthName(date.month).substring(0, 3)} ${date.year}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: TColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Animated wrapper for the grid calendar picker
class _AnimatedGridCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final DateSelectorMode mode;

  const _AnimatedGridCalendarPicker({
    required this.initialDate,
    required this.onDateSelected,
    required this.mode,
  });

  @override
  State<_AnimatedGridCalendarPicker> createState() => _AnimatedGridCalendarPickerState();
}

class _AnimatedGridCalendarPickerState extends State<_AnimatedGridCalendarPicker>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Slide animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Slide animation (bottom to up)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Fade animation for backdrop
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _closeSheet() async {
    await Future.wait([
      _slideController.reverse(),
      _fadeController.reverse(),
    ]);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop with fade animation
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeSheet,
                child: Container(
                  color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
                ),
              ),
            ),
            
            // Calendar picker with slide animation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: _GridCalendarPicker(
                  initialDate: widget.initialDate,
                  onDateSelected: widget.onDateSelected,
                  mode: widget.mode,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}