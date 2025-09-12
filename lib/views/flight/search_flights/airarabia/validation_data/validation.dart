// airarabia_revalidation_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/utility/colors.dart';
import 'package:ready_flights/views/flight/search_flights/airarabia/validation_data/validation_controller.dart';
import 'package:ready_flights/views/flight/search_flights/airarabia/validation_data/validation_model.dart';

class AirArabiaRevalidationScreen extends StatelessWidget {
  final AirArabiaRevalidationController controller = Get.put(AirArabiaRevalidationController());

  AirArabiaRevalidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      body: Column(
        children: [
          _buildModernAppBar(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return _buildErrorState();
              }

              if (controller.revalidationResponse.value == null) {
                return _buildEmptyState();
              }

              return _buildMainContent();
            }),
          ),
          _buildModernBottomSummary(),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 20,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TColors.primary, TColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TColors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: TColors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: TColors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flight Extras',
                  style: TextStyle(
                    color: TColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Personalize your journey',
                  style: TextStyle(
                    color: TColors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: TColors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.flight_takeoff,
              color: TColors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: TColors.primary.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Loading Flight Extras',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: TColors.primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Preparing your personalized options...',
              style: TextStyle(
                fontSize: 16,
                color: TColors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: TColors.red.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: TColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: TColors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to Load Extras',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: TColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 16,
                color: TColors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: TColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 64,
            color: TColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No extras available',
            style: TextStyle(
              fontSize: 18,
              color: TColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: TColors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: TColors.primary,
              ),
              indicatorPadding: const EdgeInsets.all(6),
              labelColor: TColors.white,
              unselectedLabelColor: TColors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.luggage, size: 20),
                      SizedBox(width: 8),
                      Text('Baggage'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu, size: 20),
                      SizedBox(width: 8),
                      Text('Meals'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.airline_seat_recline_normal, size: 20),
                      SizedBox(width: 8),
                      Text('Seats'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBaggageTab(),
                _buildMealsTab(),
                _buildSeatsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaggageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Baggage',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: TColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the perfect baggage allowance for your trip',
            style: TextStyle(
              fontSize: 16,
              color: TColors.grey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ...controller.availableBaggage.map((baggage) {
            final isSelected = controller.selectedBaggage['default']?.baggageCode == baggage.baggageCode;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? TColors.primary : TColors.grey.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? TColors.primary.withOpacity(0.15)
                        : TColors.black.withOpacity(0.04),
                    blurRadius: isSelected ? 20 : 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.selectBaggage('default', baggage),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? TColors.primary.withOpacity(0.1)
                                : TColors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.luggage,
                            color: isSelected ? TColors.primary : TColors.grey,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                baggage.baggageDescription,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: TColors.primary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'PKR ${baggage.baggageCharge}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? TColors.primary : TColors.third,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected ? TColors.primary : Colors.transparent,
                            border: isSelected ? null : Border.all(
                              color: TColors.grey.withOpacity(0.3),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: isSelected
                              ? const Icon(
                            Icons.check,
                            color: TColors.white,
                            size: 20,
                          )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 120), // Space for bottom summary
        ],
      ),
    );
  }

  Widget _buildMealsTab() {
    final segments = controller.getFlightSegments();

    return DefaultTabController(
      length: segments.length,
      child: Column(
        children: [
          if (segments.length > 1)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: TColors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                isScrollable: true,
                indicatorColor: TColors.primary,
                labelColor: TColors.primary,
                unselectedLabelColor: TColors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: segments.map((segment) {
                  final departure = segment.departureAirport['LocationCode'] ?? '';
                  final arrival = segment.arrivalAirport['LocationCode'] ?? '';
                  return Tab(text: '$departure → $arrival');
                }).toList(),
              ),
            ),
          Expanded(
            child: TabBarView(
              children: segments.map((segment) {
                final segmentCode = segment.attributes['SegmentCode'] ?? '';
                final meals = controller.getMealsForSegment(segmentCode);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Your Meals',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: TColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose delicious meals for your flight',
                        style: TextStyle(
                          fontSize: 16,
                          color: TColors.grey,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...meals.map((meal) {
                        final isSelected = controller.isMealSelected(segmentCode, meal);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: TColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? TColors.primary : TColors.grey.withOpacity(0.2),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? TColors.primary.withOpacity(0.15)
                                    : TColors.black.withOpacity(0.04),
                                blurRadius: isSelected ? 20 : 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => controller.toggleMeal(segmentCode, meal),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? TColors.primary.withOpacity(0.1)
                                            : TColors.grey.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.restaurant_menu,
                                        color: isSelected ? TColors.primary : TColors.grey,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            meal.mealName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: TColors.primary,
                                              height: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            meal.mealDescription,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: TColors.grey,
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'PKR ${meal.mealCharge}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? TColors.primary : TColors.third,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isSelected ? TColors.primary : Colors.transparent,
                                        border: isSelected ? null : Border.all(
                                          color: TColors.grey.withOpacity(0.3),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        isSelected ? Icons.check : Icons.add,
                                        color: isSelected ? TColors.white : TColors.grey,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 120),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatsTab() {
    final segments = controller.getFlightSegments();

    return DefaultTabController(
      length: segments.length,
      child: Column(
        children: [
          if (segments.length > 1)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: TColors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                isScrollable: true,
                indicatorColor: TColors.primary,
                labelColor: TColors.primary,
                unselectedLabelColor: TColors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: segments.map((segment) {
                  final departure = segment.departureAirport['LocationCode'] ?? '';
                  final arrival = segment.arrivalAirport['LocationCode'] ?? '';
                  return Tab(text: '$departure → $arrival');
                }).toList(),
              ),
            ),
          Expanded(
            child: TabBarView(
              children: segments.map((segment) {
                final segmentCode = segment.attributes['SegmentCode'] ?? '';
                final selectedSeat = controller.getSelectedSeat(segmentCode);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choose Your Seat',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: TColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select your preferred seat for comfort',
                        style: TextStyle(
                          fontSize: 16,
                          color: TColors.grey,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Selected seat info
                      if (selectedSeat != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: TColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: TColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.airline_seat_recline_normal,
                                  color: TColors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected: ${selectedSeat.seatNumber}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: TColors.primary,
                                      ),
                                    ),
                                    Text(
                                      'PKR ${selectedSeat.seatCharge.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: TColors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => controller.selectSeat(segmentCode, SeatOption(
                                  seatNumber: '',
                                  seatCharge: 0,
                                  currencyCode: 'PKR',
                                  seatAvailability: '',
                                )),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: TColors.red,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Aircraft layout
                      _buildAircraftLayout(segmentCode, selectedSeat),

                      const SizedBox(height: 120),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAircraftLayout(String segmentCode, SeatOption? selectedSeat) {
    final seatsByRow = controller.getSeatsByRowForSegment(segmentCode);
    final sortedRows = seatsByRow.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TColors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Aircraft nose
          Container(
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Icon(
              Icons.flight,
              color: TColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),

          // Seat layout
          Column(
            children: sortedRows.map((rowNumber) {
              final rowSeats = seatsByRow[rowNumber] ?? [];
              rowSeats.sort((a, b) => a.seatNumber.compareTo(b.seatNumber));

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Row number
                    SizedBox(
                      width: 30,
                      child: Text(
                        rowNumber,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: TColors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Left side seats (A, B, C)
                    ...rowSeats.where((seat) => ['A', 'B', 'C'].contains(seat.seatNumber.substring(seat.seatNumber.length - 1)))
                        .map((seat) => _buildSeatWidget(segmentCode, seat, selectedSeat)),

                    // Aisle
                    const SizedBox(width: 20),

                    // Right side seats (D, E, F)
                    ...rowSeats.where((seat) => ['D', 'E', 'F'].contains(seat.seatNumber.substring(seat.seatNumber.length - 1)))
                        .map((seat) => _buildSeatWidget(segmentCode, seat, selectedSeat)),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(TColors.grey.withOpacity(0.2), 'Available'),
              _buildLegendItem(TColors.primary, 'Selected'),
              _buildLegendItem(TColors.red.withOpacity(0.2), 'Occupied'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatWidget(String segmentCode, SeatOption seat, SeatOption? selectedSeat) {
    final isSelected = selectedSeat?.seatNumber == seat.seatNumber;
    final isOccupied = seat.seatAvailability != 'VAC' && seat.seatAvailability != 'Available';

    return GestureDetector(
      onTap: isOccupied ? null : () => controller.selectSeat(segmentCode, seat),
      child: Container(
        width: 32,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isOccupied
              ? TColors.red.withOpacity(0.2)
              : isSelected
              ? TColors.primary
              : TColors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? TColors.primary
                : isOccupied
                ? TColors.red.withOpacity(0.4)
                : TColors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              seat.seatNumber.substring(seat.seatNumber.length - 1),
              style: TextStyle(
                color: isSelected
                    ? TColors.white
                    : isOccupied
                    ? TColors.red
                    : TColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (seat.seatCharge > 0)
              Text(
                '${seat.seatCharge.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isSelected
                      ? TColors.white.withOpacity(0.8)
                      : isOccupied
                      ? TColors.red.withOpacity(0.7)
                      : TColors.grey,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color == TColors.grey.withOpacity(0.2)
                  ? TColors.grey.withOpacity(0.3)
                  : color,
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: TColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildModernBottomSummary() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TColors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Price breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Base Fare',
                      style: TextStyle(
                        fontSize: 16,
                        color: TColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'PKR ${controller.basePrice.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Extras',
                      style: TextStyle(
                        fontSize: 16,
                        color: TColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'PKR ${controller.totalExtrasPrice.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TColors.third,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: TColors.primary.withOpacity(0.1),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                    Text(
                      'PKR ${controller.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  'Success',
                  'Flight extras selected successfully!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: TColors.primary,
                  colorText: TColors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(16),
                  animationDuration: const Duration(milliseconds: 800),
                );
                // Navigate to booking screen
                // Get.to(() => BookingConfirmationScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: TColors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: TColors.primary.withOpacity(0.3),
              ),
              child: const Text(
                'Continue to Booking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}