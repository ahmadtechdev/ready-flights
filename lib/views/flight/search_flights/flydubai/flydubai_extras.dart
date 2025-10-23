// flydubai_extras_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/utility/colors.dart';
import 'package:ready_flights/views/flight/search_flights/flydubai/flydubai_extras_controller.dart';

import '../review_flight/flydubai_review_flight.dart';

class FlydubaiExtrasScreen extends StatefulWidget {
  FlydubaiExtrasScreen({super.key});

  @override
  State<FlydubaiExtrasScreen> createState() => _FlydubaiExtrasScreenState();
}

class _FlydubaiExtrasScreenState extends State<FlydubaiExtrasScreen> {
  bool _isExpanded = false;
  int _segmentTab = 0;
  int _passengerTab = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlydubaiExtrasController>(
      init: FlydubaiExtrasController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: Column(
            children: [
              _buildElegantAppBar(context),
              Expanded(
                child: Obx(() {
                  final isLoading = controller.isLoading.value;
                  final errorMessage = controller.errorMessage.value;

                  if (isLoading) {
                    return _buildLoadingState();
                  }

                  if (errorMessage.isNotEmpty) {
                    return _buildErrorState(controller);
                  }

                  if (controller.availableBaggage.isEmpty &&
                      controller.availableMeals.isEmpty &&
                      controller.availableSeats.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildMainContent(controller);
                }),
              ),
              _buildCollapsiblePriceBox(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildElegantAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TColors.primary, TColors.primary.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: TColors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Flight Extras',
                    style: TextStyle(
                      color: TColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Personalize your journey',
                    style: TextStyle(
                      color: TColors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Add Skip button
            TextButton(
              onPressed: () {
                Get.toNamed('/booking-confirmation', arguments: {
                  'flight': Get.find<FlydubaiExtrasController>().selectedFlight.value,
                  'fare': Get.find<FlydubaiExtrasController>().selectedFare.value,
                  'extras': {
                    'passengers': {},
                    'total_price': Get.find<FlydubaiExtrasController>().basePrice.value
                  },
                });
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  color: TColors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: TColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading Flight Extras',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait...',
            style: TextStyle(fontSize: 14, color: TColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(FlydubaiExtrasController controller) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: TColors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: TColors.red),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: TColors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Go Back'),
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
            size: 48,
            color: TColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No extras available',
            style: TextStyle(fontSize: 16, color: TColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(FlydubaiExtrasController controller) {
    final segments = controller.getSegmentCodes();

    // Clamp segment index
    _segmentTab = _segmentTab.clamp(
      0,
      segments.isEmpty ? 0 : segments.length - 1,
    );

    // Clamp passenger index based on actual passenger count
    _passengerTab = _passengerTab.clamp(
      0,
      controller.passengerIds.isEmpty ? 0 : controller.passengerIds.length - 1,
    );

    final String currentSeg =
    segments.isNotEmpty ? segments[_segmentTab] : 'seg0';

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Show passenger count info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, color: TColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${controller.passengerIds.length} passenger${controller.passengerIds.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: TColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (controller.passengerIds.length > 1) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(Select extras for each passenger)',
                    style: TextStyle(
                      color: TColors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Flight segments tabs (only show if multiple segments)
          if (segments.length > 1) ...[
            // Your existing segment tabs code here
          ],

          // Extras category tabs
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: TColors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: TColors.primary,
              ),
              indicatorPadding: const EdgeInsets.only(bottom: 5, top: 5),
              labelColor: TColors.white,
              unselectedLabelColor: TColors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Baggage'),
                Tab(text: 'Meals'),
                Tab(text: 'Seats'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBaggageTabWithPassengers(controller, currentSeg),
                _buildMealsTabWithPassengers(controller, currentSeg),
                _buildSeatsTabWithPassengers(controller, currentSeg),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBaggageTabWithPassengers(
    FlydubaiExtrasController controller,
    String segmentCode,
  ) {
    return Obx(() {
      final passengers = controller.passengerIds;

      if (passengers.length <= 1) {
        // Single passenger - use original design
        final keyPrefix =
            'seg$segmentCode|${passengers.isNotEmpty ? passengers[0] : 'p0'}';
        return _buildBaggageTab(controller, keyPrefix);
      }

      // Multiple passengers - show passenger selector
      return Column(
        children: [
          // Passenger selection tabs
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: TColors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  final isActive = i == _passengerTab;
                  final hasSelection =
                      controller.getSelectedBaggageForPassenger(
                        segmentCode,
                        passengers[i],
                      ) !=
                      null;
                  return GestureDetector(
                    onTap: () => setState(() => _passengerTab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? TColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            hasSelection
                                ? Border.all(
                                  color: TColors.primary.withOpacity(0.3),
                                  width: 1,
                                )
                                : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.getPassengerDisplayName(i),
                            style: TextStyle(
                              color: isActive ? TColors.white : TColors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          if (hasSelection) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color:
                                    isActive ? TColors.white : TColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemCount: passengers.length,
              ),
            ),
          ),
          // Baggage selection for selected passenger
          Expanded(
            child: _buildBaggageSelectionForPassenger(
              controller,
              segmentCode,
              passengers.isNotEmpty && _passengerTab < passengers.length
                  ? passengers[_passengerTab]
                  : 'p0',
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMealsTabWithPassengers(
    FlydubaiExtrasController controller,
    String segmentCode,
  ) {
    return Obx(() {
      final passengers = controller.passengerIds;

      if (passengers.length <= 1) {
        // Single passenger - use original design
        final keyPrefix =
            'seg$segmentCode|${passengers.isNotEmpty ? passengers[0] : 'p0'}';
        return _buildMealsTab(controller, keyPrefix);
      }

      // Multiple passengers - show passenger selector
      return Column(
        children: [
          // Passenger selection tabs
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: TColors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  final isActive = i == _passengerTab;
                  final hasSelection =
                      controller.getSelectedMealForPassenger(
                        segmentCode,
                        passengers[i],
                      ) !=
                      null;
                  return GestureDetector(
                    onTap: () => setState(() => _passengerTab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? TColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            hasSelection
                                ? Border.all(
                                  color: TColors.primary.withOpacity(0.3),
                                  width: 1,
                                )
                                : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.getPassengerDisplayName(i),
                            style: TextStyle(
                              color: isActive ? TColors.white : TColors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          if (hasSelection) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color:
                                    isActive ? TColors.white : TColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemCount: passengers.length,
              ),
            ),
          ),
          // Meal selection for selected passenger
          Expanded(
            child: _buildMealSelectionForPassenger(
              controller,
              segmentCode,
              passengers.isNotEmpty && _passengerTab < passengers.length
                  ? passengers[_passengerTab]
                  : 'p0',
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSeatsTabWithPassengers(
    FlydubaiExtrasController controller,
    String segmentCode,
  ) {
    return Obx(() {
      final passengers = controller.passengerIds;

      if (passengers.length <= 1) {
        // Single passenger - use original design
        final keyPrefix =
            'seg$segmentCode|${passengers.isNotEmpty ? passengers[0] : 'p0'}';
        return _buildSeatsTab(controller, keyPrefix);
      }

      // Multiple passengers - show passenger selector
      return Column(
        children: [
          // Passenger selection tabs
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: TColors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  final isActive = i == _passengerTab;
                  final hasSelection =
                      controller.getSelectedSeatForPassenger(
                        segmentCode,
                        passengers[i],
                      ) !=
                      null;
                  return GestureDetector(
                    onTap: () => setState(() => _passengerTab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? TColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            hasSelection
                                ? Border.all(
                                  color: TColors.primary.withOpacity(0.3),
                                  width: 1,
                                )
                                : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.getPassengerDisplayName(i),
                            style: TextStyle(
                              color: isActive ? TColors.white : TColors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          if (hasSelection) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color:
                                    isActive ? TColors.white : TColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemCount: passengers.length,
              ),
            ),
          ),
          // Seat selection for selected passenger
          Expanded(
            child: _buildSeatSelectionForPassenger(
              controller,
              segmentCode,
              passengers.isNotEmpty && _passengerTab < passengers.length
                  ? passengers[_passengerTab]
                  : 'p0',
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBaggageSelectionForPassenger(
    FlydubaiExtrasController controller,
    String segmentCode,
    String passengerId,
  ) {
    final keyPrefix = 'seg$segmentCode|$passengerId';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Choose Baggage for ${controller.getPassengerDisplayName(controller.passengerIds.indexOf(passengerId))}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TColors.primary,
                  ),
                ),
              ),
              if (controller.getSelectedBaggageForPassenger(
                    segmentCode,
                    passengerId,
                  ) !=
                  null)
                TextButton(
                  onPressed:
                      () => controller.removePassengerSelection(
                        segmentCode,
                        passengerId,
                        'baggage',
                      ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      color: TColors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select additional baggage for this passenger',
            style: TextStyle(fontSize: 14, color: TColors.grey),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children:
                  controller.availableBaggage.map((baggage) {
                    final isSelected =
                        controller.selectedBaggage[keyPrefix]?['id'] ==
                        baggage['id'];
                    return _buildSelectionCard(
                      icon: Icons.luggage,
                      title: baggage['description'] ?? 'Baggage',
                      price:
                          '${controller.currency.value} ${baggage['charge'] ?? '0'}',
                      isSelected: isSelected,
                      onTap: () => controller.selectBaggage(keyPrefix, baggage),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSelectionForPassenger(
    FlydubaiExtrasController controller,
    String segmentCode,
    String passengerId,
  ) {
    final keyPrefix = 'seg$segmentCode|$passengerId';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select Meal for ${controller.getPassengerDisplayName(controller.passengerIds.indexOf(passengerId))}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TColors.primary,
                  ),
                ),
              ),
              if (controller.getSelectedMealForPassenger(
                    segmentCode,
                    passengerId,
                  ) !=
                  null)
                TextButton(
                  onPressed:
                      () => controller.removePassengerSelection(
                        segmentCode,
                        passengerId,
                        'meal',
                      ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      color: TColors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pre-order delicious meals for this passenger',
            style: TextStyle(fontSize: 14, color: TColors.grey),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children:
                  controller.availableMeals.map((meal) {
                    final isSelected =
                        controller.selectedMeals[keyPrefix]?['id'] ==
                        meal['id'];
                    return _buildSelectionCard(
                      icon: Icons.restaurant_menu,
                      title: meal['name'] ?? 'Meal',
                      subtitle: meal['description'] ?? '',
                      price:
                          '${controller.currency.value} ${meal['charge'] ?? '0'}',
                      isSelected: isSelected,
                      onTap: () => controller.selectMeal(keyPrefix, meal),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatSelectionForPassenger(
    FlydubaiExtrasController controller,
    String segmentCode,
    String passengerId,
  ) {
    final keyPrefix = 'seg$segmentCode|$passengerId';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Choose Seat for ${controller.getPassengerDisplayName(controller.passengerIds.indexOf(passengerId))}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select preferred seat for this passenger',
            style: TextStyle(fontSize: 14, color: TColors.grey),
          ),
          const SizedBox(height: 16),

          Obx(() {
            final selectedSeat = controller.selectedSeats[keyPrefix];

            // Show selected seat info if any
            if (selectedSeat != null &&
                selectedSeat['seatNumber']?.toString().isNotEmpty == true) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.airline_seat_recline_normal,
                      color: TColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seat ${selectedSeat['seatNumber']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: TColors.primary,
                            ),
                          ),
                          Text(
                            '${controller.currency.value} ${selectedSeat['charge'] ?? '0'}',
                            style: TextStyle(fontSize: 14, color: TColors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed:
                          () => controller.selectSeat(keyPrefix, {
                            'id': '',
                            'seatNumber': '',
                            'charge': '0',
                          }),
                      icon: const Icon(Icons.close, color: TColors.red),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          }),

          // Aircraft Layout - modified to work with specific passenger
          _buildAircraftLayoutForPassenger(
            controller,
            segmentCode,
            passengerId,
          ),
        ],
      ),
    );
  }

  Widget _buildAircraftLayoutForPassenger(
    FlydubaiExtrasController controller,
    String segmentCode,
    String passengerId,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Aircraft nose
          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TColors.primary.withOpacity(0.2),
                  TColors.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Icon(Icons.flight, color: TColors.primary, size: 16),
          ),
          const SizedBox(height: 12),

          // Seat layout - Boeing 737-800 configuration (32 rows)
          Column(
            children: List.generate(32, (rowIndex) {
              final rowNumber = rowIndex + 1;
              return _buildSeatRowForPassenger(
                rowNumber,
                controller,
                segmentCode,
                passengerId,
              );
            }),
          ),

          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(TColors.grey.withOpacity(0.2), 'Available'),
              _buildLegendItem(TColors.primary, 'Selected'),
              _buildLegendItem(TColors.red.withOpacity(0.3), 'Occupied'),
              _buildLegendItem(TColors.orange.withOpacity(0.3), 'Premium'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatRowForPassenger(
    int rowNumber,
    FlydubaiExtrasController controller,
    String segmentCode,
    String passengerId,
  ) {
    final columns = ['A', 'B', 'C', 'D', 'E', 'F'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Row number
          SizedBox(
            width: 20,
            child: Text(
              '$rowNumber',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: TColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),

          // Left side seats (A, B, C)
          ...columns.take(3).map((column) {
            final seatNumber = '$rowNumber$column';
            return _buildSeatForPassenger(
              seatNumber,
              rowNumber,
              controller,
              segmentCode,
              passengerId,
            );
          }),

          // Aisle
          const SizedBox(width: 12),

          // Right side seats (D, E, F)
          ...columns.skip(3).map((column) {
            final seatNumber = '$rowNumber$column';
            return _buildSeatForPassenger(
              seatNumber,
              rowNumber,
              controller,
              segmentCode,
              passengerId,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSeatForPassenger(
    String seatNumber,
    int rowNumber,
    FlydubaiExtrasController controller,
    String segmentCode,
    String passengerId,
  ) {
    return Obx(() {
      final availableSeats = controller.availableSeats;
      final keyPrefix = 'seg$segmentCode|$passengerId';
      final selectedSeat = controller.selectedSeats[keyPrefix];

      // Check if this seat is selected by ANY passenger for this segment
      bool isSeatTakenByOtherPassenger = false;
      for (final paxId in controller.passengerIds) {
        if (paxId != passengerId) {
          final otherKey = 'seg$segmentCode|$paxId';
          final otherSelection = controller.selectedSeats[otherKey];
          if (otherSelection?['seatNumber']?.toString() == seatNumber) {
            isSeatTakenByOtherPassenger = true;
            break;
          }
        }
      }

      // Find if this seat exists in available seats from API
      final apiSeat =
          availableSeats
              .where((seat) => seat['seatNumber']?.toString() == seatNumber)
              .firstOrNull;

      final isSelected = selectedSeat?['seatNumber']?.toString() == seatNumber;

      bool isOccupied = true; // Default to occupied
      bool isPremium = false;
      double price = 0;
      bool isAvailable = false;

      if (apiSeat != null) {
        // Seat exists in API data
        price = double.tryParse(apiSeat['charge']?.toString() ?? '0') ?? 0.0;
        isAvailable = apiSeat['isAvailable'] == true;
        isOccupied =
            apiSeat['isAssigned'] == true ||
            apiSeat['isBlocked'] == true ||
            !isAvailable ||
            isSeatTakenByOtherPassenger;
        isPremium = apiSeat['isPremium'] == true;
      }

      // Determine seat color
      Color seatColor;
      Color textColor;

      if (isSelected) {
        seatColor = TColors.primary;
        textColor = TColors.white;
      } else if (isOccupied) {
        seatColor = TColors.red.withOpacity(0.3);
        textColor = TColors.red.withOpacity(0.7);
      } else if (isPremium) {
        seatColor = TColors.orange.withOpacity(0.3);
        textColor = TColors.orange;
      } else {
        seatColor = TColors.grey.withOpacity(0.15);
        textColor = TColors.primary;
      }

      return GestureDetector(
        onTap:
            (isOccupied || !isAvailable)
                ? null
                : () {
                  // Create seat object for selection
                  final seatToSelect = {
                    'id': apiSeat?['id'] ?? 'SEAT_$seatNumber',
                    'seatNumber': seatNumber,
                    'charge': price.toString(),
                    'serviceCode': apiSeat?['serviceCode'] ?? 'SEAT',
                    'rowNumber': rowNumber.toString(),
                    'description': 'Seat $seatNumber',
                    'type': 'seat',
                  };

                  controller.selectSeat(keyPrefix, seatToSelect);
                },
        child: Container(
          width: 24,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: seatColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color:
                  isSelected
                      ? TColors.primary
                      : isOccupied
                      ? TColors.red.withOpacity(0.4)
                      : isPremium
                      ? TColors.orange.withOpacity(0.4)
                      : TColors.grey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                seatNumber.substring(seatNumber.length - 1),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
              if (price > 0 && !isOccupied)
                Text(
                  price < 1000
                      ? '${price.toInt()}'
                      : '${(price / 1000).toStringAsFixed(1)}k',
                  style: TextStyle(
                    color:
                        isSelected
                            ? TColors.white.withOpacity(0.8)
                            : TColors.grey.withOpacity(0.7),
                    fontSize: 6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBaggageTab(
    FlydubaiExtrasController controller,
    String keyPrefix,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Baggage',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: TColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select additional baggage for your journey',
            style: TextStyle(fontSize: 14, color: TColors.grey),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children:
                  controller.availableBaggage.map((baggage) {
                    final isSelected =
                        controller.selectedBaggage[keyPrefix]?['id'] ==
                        baggage['id'];
                    return _buildSelectionCard(
                      icon: Icons.luggage,
                      title: baggage['description'] ?? 'Baggage',
                      price:
                          '${controller.currency.value} ${baggage['charge'] ?? '0'}',
                      isSelected: isSelected,
                      onTap: () => controller.selectBaggage(keyPrefix, baggage),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsTab(FlydubaiExtrasController controller, String keyPrefix) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Your Meals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: TColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pre-order delicious meals for your flight',
            style: TextStyle(fontSize: 14, color: TColors.grey),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children:
                  controller.availableMeals.map((meal) {
                    final isSelected =
                        controller.selectedMeals[keyPrefix]?['id'] ==
                        meal['id'];
                    return _buildSelectionCard(
                      icon: Icons.restaurant_menu,
                      title: meal['name'] ?? 'Meal',
                      subtitle: meal['description'] ?? '',
                      price:
                          '${controller.currency.value} ${meal['charge'] ?? '0'}',
                      isSelected: isSelected,
                      onTap: () => controller.selectMeal(keyPrefix, meal),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Replace the _buildSeatsTab method in your flydubai_extras_screen.dart

  Widget _buildSeatsTab(FlydubaiExtrasController controller, String keyPrefix) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Seat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: TColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your preferred seat for extra comfort',
            style: TextStyle(fontSize: 14, color: TColors.grey),
          ),
          const SizedBox(height: 16),

          Obx(() {
            final selectedSeat = controller.selectedSeats[keyPrefix];

            // Show selected seat info if any
            if (selectedSeat != null &&
                selectedSeat['seatNumber']?.toString().isNotEmpty == true) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.airline_seat_recline_normal,
                      color: TColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seat ${selectedSeat['seatNumber']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: TColors.primary,
                            ),
                          ),
                          Text(
                            '${controller.currency.value} ${selectedSeat['charge'] ?? '0'}',
                            style: TextStyle(fontSize: 14, color: TColors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed:
                          () => controller.selectSeat(keyPrefix, {
                            'id': '',
                            'seatNumber': '',
                            'charge': '0',
                          }),
                      icon: const Icon(Icons.close, color: TColors.red),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          }),

          // Aircraft Layout
          _buildAircraftLayout(controller),
        ],
      ),
    );
  }

  Widget _buildAircraftLayout(FlydubaiExtrasController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Aircraft nose
          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TColors.primary.withOpacity(0.2),
                  TColors.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Icon(Icons.flight, color: TColors.primary, size: 16),
          ),
          const SizedBox(height: 12),

          // Seat layout - Boeing 737-800 configuration (32 rows)
          Column(
            children: List.generate(32, (rowIndex) {
              final rowNumber = rowIndex + 1;
              return _buildSeatRow(rowNumber, controller);
            }),
          ),

          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(TColors.grey.withOpacity(0.2), 'Available'),
              _buildLegendItem(TColors.primary, 'Selected'),
              _buildLegendItem(TColors.red.withOpacity(0.3), 'Occupied'),
              _buildLegendItem(TColors.orange.withOpacity(0.3), 'Premium'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatRow(int rowNumber, FlydubaiExtrasController controller) {
    final columns = ['A', 'B', 'C', 'D', 'E', 'F'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Row number
          SizedBox(
            width: 20,
            child: Text(
              '$rowNumber',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: TColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),

          // Left side seats (A, B, C)
          ...columns.take(3).map((column) {
            final seatNumber = '$rowNumber$column';
            return _buildSeat(seatNumber, rowNumber, controller);
          }),

          // Aisle
          const SizedBox(width: 12),

          // Right side seats (D, E, F)
          ...columns.skip(3).map((column) {
            final seatNumber = '$rowNumber$column';
            return _buildSeat(seatNumber, rowNumber, controller);
          }),
        ],
      ),
    );
  }

  Widget _buildSeat(
    String seatNumber,
    int rowNumber,
    FlydubaiExtrasController controller,
  ) {
    return Obx(() {
      final availableSeats = controller.availableSeats;
      // Compute current keyPrefix from current tabs
      final segments = controller.getSegmentCodes();
      final paxList = controller.passengerIds;
      final seg =
          (_segmentTab >= 0 && _segmentTab < segments.length)
              ? segments[_segmentTab]
              : '0';
      final pax =
          (_passengerTab >= 0 && _passengerTab < paxList.length)
              ? paxList[_passengerTab]
              : 'p0';
      final keyPrefix = 'seg$seg|$pax';
      final selectedSeat = controller.selectedSeats[keyPrefix];

      // Find if this seat exists in available seats from API
      final apiSeat =
          availableSeats
              .where((seat) => seat['seatNumber']?.toString() == seatNumber)
              .firstOrNull;

      final isSelected = selectedSeat?['seatNumber']?.toString() == seatNumber;

      bool isOccupied = true; // Default to occupied
      bool isPremium = false;
      double price = 0;
      bool isAvailable = false;

      if (apiSeat != null) {
        // Seat exists in API data
        price = double.tryParse(apiSeat['charge']?.toString() ?? '0') ?? 0.0;
        isAvailable = apiSeat['isAvailable'] == true;
        isOccupied =
            apiSeat['isAssigned'] == true ||
            apiSeat['isBlocked'] == true ||
            !isAvailable;
        isPremium = apiSeat['isPremium'] == true;


      }

      // Determine seat color
      Color seatColor;
      Color textColor;

      if (isSelected) {
        seatColor = TColors.primary;
        textColor = TColors.white;
      } else if (isOccupied) {
        seatColor = TColors.red.withOpacity(0.3);
        textColor = TColors.red.withOpacity(0.7);
      } else if (isPremium) {
        seatColor = TColors.orange.withOpacity(0.3);
        textColor = TColors.orange;
      } else {
        seatColor = TColors.grey.withOpacity(0.15);
        textColor = TColors.primary;
      }

      return GestureDetector(
        onTap:
            (isOccupied || !isAvailable)
                ? null
                : () {
                  // Create seat object for selection
                  final seatToSelect = {
                    'id': apiSeat?['id'] ?? 'SEAT_$seatNumber',
                    'seatNumber': seatNumber,
                    'charge': price.toString(),
                    'serviceCode': apiSeat?['serviceCode'] ?? 'SEAT',
                    'rowNumber': rowNumber.toString(),
                    'description': 'Seat $seatNumber',
                    'type': 'seat',
                  };

                  controller.selectSeat(keyPrefix, seatToSelect);
                },
        child: Container(
          width: 24,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: seatColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color:
                  isSelected
                      ? TColors.primary
                      : isOccupied
                      ? TColors.red.withOpacity(0.4)
                      : isPremium
                      ? TColors.orange.withOpacity(0.4)
                      : TColors.grey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                seatNumber.substring(seatNumber.length - 1),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
              if (price > 0 && !isOccupied)
                Text(
                  price < 1000
                      ? '${price.toInt()}'
                      : '${(price / 1000).toStringAsFixed(1)}k',
                  style: TextStyle(
                    color:
                        isSelected
                            ? TColors.white.withOpacity(0.8)
                            : TColors.grey.withOpacity(0.7),
                    fontSize: 6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: TColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String title,
    String subtitle = '',
    required String price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? TColors.primary : TColors.lightGrey,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.black.withOpacity(isSelected ? 0.08 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? TColors.primary.withOpacity(0.1)
                            : TColors.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? TColors.primary : TColors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? TColors.primary : TColors.black,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 12, color: TColors.grey),
                        ),
                    ],
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? TColors.primary : TColors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? TColors.primary : TColors.grey,
                      width: 2,
                    ),
                  ),
                  child:
                      isSelected
                          ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: TColors.primary,
                              ),
                            ),
                          )
                          : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsiblePriceBox(BuildContext context, FlydubaiExtrasController controller) {
    return Obx(() {
      final totalPrice = controller.totalPrice;
      final basePrice = controller.basePrice.value;
      final extrasPrice = controller.totalExtrasPrice.value;
      final currency = controller.currency.value;

      return Container(
        decoration: BoxDecoration(
          color: TColors.white,
          border: Border(
            top: BorderSide(
              color: TColors.lightGrey,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: TColors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '$currency ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: TColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: TColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    _buildPriceRow('Base Fare', '$currency ${basePrice.toStringAsFixed(2)}'),
                    _buildPriceRow('Extras', '$currency ${extrasPrice.toStringAsFixed(2)}'),

                    // Passenger breakdown if multiple passengers
                    if (controller.passengerIds.length > 1) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Passenger Breakdown:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: TColors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...controller.passengerIds.asMap().entries.map((entry) {
                        final index = entry.key;
                        final passengerId = entry.value;
                        final passengerName = controller.getPassengerDisplayName(index);

                        double passengerExtrasTotal = 0;
                        for (final segmentCode in controller.getSegmentCodes()) {
                          final baggage = controller.getSelectedBaggageForPassenger(segmentCode, passengerId);
                          final meal = controller.getSelectedMealForPassenger(segmentCode, passengerId);
                          final seat = controller.getSelectedSeatForPassenger(segmentCode, passengerId);

                          if (baggage != null) {
                            passengerExtrasTotal += double.tryParse(baggage['charge']?.toString() ?? '0') ?? 0;
                          }
                          if (meal != null) {
                            passengerExtrasTotal += double.tryParse(meal['charge']?.toString() ?? '0') ?? 0;
                          }
                          if (seat != null) {
                            passengerExtrasTotal += double.tryParse(seat['charge']?.toString() ?? '0') ?? 0;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '  $passengerName extras',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TColors.grey.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                '$currency ${passengerExtrasTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TColors.grey.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],

                    const Divider(),
                    _buildPriceRow(
                      'Total',
                      '$currency ${totalPrice.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),

            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: () {
                  final summary = controller.getBookingSummary();
                  // Get.toNamed('/booking-confirmation', arguments: {
                  //   'flight': controller.selectedFlight.value,
                  //   'fare': controller.selectedFare.value,
                  //   'extras': summary,
                  // });
                  Get.to(()=> FlyDubaiReviewTripPage(flight:  controller.selectedFlight.value!, isReturn: false,));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: TColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(
                  'Continue to Booking (${controller.passengerIds.length} passenger${controller.passengerIds.length > 1 ? 's' : ''})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
 Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: TColors.grey,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? TColors.primary : TColors.black,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {
          // Navigate to booking confirmation without any extras
          Get.toNamed('/booking-confirmation', arguments: {
            'flight': Get.find<FlydubaiExtrasController>().selectedFlight.value,
            'fare': Get.find<FlydubaiExtrasController>().selectedFare.value,
            'extras': {'passengers': {}, 'total_price': Get.find<FlydubaiExtrasController>().basePrice.value},
          });
        },
        child: Text(
          'Skip Extras',
          style: TextStyle(
            color: TColors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

}
