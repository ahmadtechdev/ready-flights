// airarabia_revalidation_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/utility/colors.dart';
import 'package:ready_flights/views/flight/search_flights/airarabia/airarabia_flight_model.dart';
import 'package:ready_flights/views/flight/search_flights/airarabia/validation_data/validation_controller.dart';
import 'package:ready_flights/views/flight/search_flights/airarabia/validation_data/validation_model.dart';
import 'dart:math' as math;

import 'package:ready_flights/views/flight/search_flights/review_flight/airarabia_review_flight.dart';

class AirArabiaRevalidationScreen extends StatefulWidget {
  AirArabiaRevalidationScreen({super.key});

  @override
  State<AirArabiaRevalidationScreen> createState() => _AirArabiaRevalidationScreenState();
}

class _AirArabiaRevalidationScreenState extends State<AirArabiaRevalidationScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AirArabiaRevalidationController>(
      init: AirArabiaRevalidationController(),
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
                  final response = controller.revalidationResponse.value;
                  
                  if (isLoading) {
                    return _buildLoadingState();
                  }

                  if (errorMessage.isNotEmpty) {
                    return _buildErrorState(controller);
                  }

                  if (response == null) {
                    return _buildEmptyState();
                  }

                  return _buildMainContent(controller);
                }),
              ),
              _buildCollapsiblePriceBox(context),
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
          colors: [
            TColors.primary,
            TColors.primary.withOpacity(0.8),
          ],
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
            style: TextStyle(
              fontSize: 14,
              color: TColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AirArabiaRevalidationController controller) {
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
            Icon(
              Icons.error_outline,
              size: 48,
              color: TColors.red,
            ),
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
              style: TextStyle(
                fontSize: 14,
                color: TColors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            style: TextStyle(
              fontSize: 16,
              color: TColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(AirArabiaRevalidationController controller) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
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
              indicatorPadding: const EdgeInsets.only(bottom: 5,top: 5),
              labelColor: TColors.white,
              unselectedLabelColor: TColors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Container(padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Tab(text: 'Baggage')),
                Container(padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Tab(text: 'Meals')),
                Container(padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Tab(text: 'Seats')),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBaggageTab(controller),
                _buildMealsTab(controller),
                _buildSeatsTab(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaggageTab(AirArabiaRevalidationController controller) {
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
            style: TextStyle(
              fontSize: 14,
              color: TColors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => Column(
            children: controller.availableBaggage.map((baggage) {
              final isSelected = controller.selectedBaggage['default']?.baggageCode == baggage.baggageCode;
              return _buildSelectionCard(
                icon: Icons.luggage,
                title: baggage.baggageDescription,
                price: 'PKR ${baggage.baggageCharge}',
                isSelected: isSelected,
                onTap: () => controller.selectBaggage('default', baggage),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildMealsTab(AirArabiaRevalidationController controller) {
    final segments = controller.getFlightSegments();
    
    return DefaultTabController(
      length: segments.length,
      child: Column(
        children: [
          if (segments.length > 1)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                isScrollable: true,
                indicatorColor: TColors.primary,
                labelColor: TColors.primary,
                unselectedLabelColor: TColors.grey,
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
                        style: TextStyle(
                          fontSize: 14,
                          color: TColors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...meals.map((meal) {
                        final isSelected = controller.isMealSelected(segmentCode, meal);
                        return _buildSelectionCard(
                          icon: Icons.restaurant_menu,
                          title: meal.mealName,
                          subtitle: meal.mealDescription,
                          price: 'PKR ${meal.mealCharge}',
                          isSelected: isSelected,
                          onTap: () => controller.toggleMeal(segmentCode, meal),
                        );
                      }),
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

  Widget _buildSeatsTab(AirArabiaRevalidationController controller) {
    final segments = controller.getFlightSegments();
    
    return DefaultTabController(
      length: segments.length,
      child: Column(
        children: [
          if (segments.length > 1)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                isScrollable: true,
                indicatorColor: TColors.primary,
                labelColor: TColors.primary,
                unselectedLabelColor: TColors.grey,
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
                return _buildCompleteAircraftLayout(segmentCode, controller);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteAircraftLayout(String segmentCode, AirArabiaRevalidationController controller) {
    final apiSeats = controller.getSeatsForSegment(segmentCode).isEmpty 
        ? _generateDemoApiSeats() 
        : controller.getSeatsForSegment(segmentCode);
    
    final selectedSeat = controller.getSelectedSeat(segmentCode);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
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
            'Select your preferred seat',
            style: TextStyle(
              fontSize: 14,
              color: TColors.grey,
            ),
          ),
          const SizedBox(height: 16),
          
          // Selected seat display
          if (selectedSeat != null && selectedSeat.seatNumber.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.airline_seat_recline_normal, color: TColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seat ${selectedSeat.seatNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: TColors.primary,
                          ),
                        ),
                        Text(
                          'PKR ${selectedSeat.seatCharge.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: TColors.grey,
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
                    icon: const Icon(Icons.close, color: TColors.red),
                  ),
                ],
              ),
            ),
          
          // Aircraft layout
          Container(
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
                      colors: [TColors.primary.withOpacity(0.2), TColors.primary.withOpacity(0.1)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Icon(
                    Icons.flight,
                    color: TColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Complete seat layout - 29 rows
                Column(
                  children: List.generate(29, (rowIndex) {
                    final rowNumber = rowIndex + 1;
                    return _buildSeatRow(rowNumber, apiSeats, selectedSeat, controller, segmentCode);
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatRow(int rowNumber, List<SeatOption> apiSeats, SeatOption? selectedSeat, 
                      AirArabiaRevalidationController controller, String segmentCode) {
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
            return _buildSeat(seatNumber, apiSeats, selectedSeat, controller, segmentCode);
          }),
          
          // Aisle
          const SizedBox(width: 12),
          
          // Right side seats (D, E, F)
          ...columns.skip(3).map((column) {
            final seatNumber = '$rowNumber$column';
            return _buildSeat(seatNumber, apiSeats, selectedSeat, controller, segmentCode);
          }),
        ],
      ),
    );
  }

  Widget _buildSeat(String seatNumber, List<SeatOption> apiSeats, SeatOption? selectedSeat,
                   AirArabiaRevalidationController controller, String segmentCode) {
    
    // Find if this seat exists in API data
    final apiSeat = apiSeats.where((seat) => seat.seatNumber == seatNumber).firstOrNull;
    
    final isSelected = selectedSeat?.seatNumber == seatNumber;
    final bool isOccupied;
    final double price;
    
    if (apiSeat != null) {
      // Seat exists in API data
      isOccupied = apiSeat.seatAvailability == 'Occupied';
      price = apiSeat.seatCharge;
    } else {
      // Seat doesn't exist in API - mark as occupied/reserved
      isOccupied = true;
      price = 0;
    }
    
    Color seatColor;
    if (isSelected) {
      seatColor = TColors.primary;
    } else if (isOccupied) {
      seatColor = TColors.red.withOpacity(0.3);
    } else {
      seatColor = TColors.grey.withOpacity(0.15);
    }
    
    return GestureDetector(
      onTap: (isOccupied || apiSeat == null) ? null : () {
        controller.selectSeat(segmentCode, apiSeat);
      },
      child: Container(
        width: 24,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected 
                ? TColors.primary 
                : isOccupied 
                  ? TColors.red.withOpacity(0.4)
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
                color: isSelected
                    ? TColors.white
                    : isOccupied
                    ? TColors.red.withOpacity(0.7)
                    : TColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
            if (price > 0 && !isOccupied)
              Text(
                price < 1000 ? '${price.toInt()}' : '${(price/1000).toStringAsFixed(1)}k',
                style: TextStyle(
                  color: isSelected
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
  }

  // Generate demo API seats (only seats that would come from API)
  List<SeatOption> _generateDemoApiSeats() {
    final List<SeatOption> seats = [];
    final random = math.Random();
    
    // Generate seats only for specific rows that would be available from API
    final availableRows = [10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 25, 26, 27];
    final columns = ['A', 'B', 'C', 'D', 'E', 'F'];
    
    for (final row in availableRows) {
      for (final column in columns) {
        // Skip some seats in emergency rows or specific configurations
        if (row == 14 && ['A', 'F'].contains(column)) continue;
        if (row == 15 && ['A', 'F'].contains(column)) continue;
        
        final seatNumber = '$row$column';
        double charge = 0;
        
        // Realistic pricing based on row position
        if (row <= 12) {
          charge = [3130, 2739, 1956, 1565].elementAt(random.nextInt(4)) as double;
        } else if (row <= 20) {
          charge = [1174, 783].elementAt(random.nextInt(2)) as double;
        } else {
          charge = random.nextBool() ? 783 : 0;
        }
        
        seats.add(SeatOption(
          seatNumber: seatNumber,
          seatCharge: charge,
          currencyCode: 'PKR',
          seatAvailability: 'Available',
        ));
      }
    }
    
    return seats;
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
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
          color: isSelected ? TColors.primary : TColors.grey.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? TColors.primary.withOpacity(0.1) 
                : TColors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                    color: isSelected 
                        ? TColors.primary.withOpacity(0.1) 
                        : TColors.grey.withOpacity(0.05),
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
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: TColors.primary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: TColors.grey,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? TColors.primary : TColors.third,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? TColors.primary : Colors.transparent,
                    border: isSelected ? null : Border.all(
                      color: TColors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isSelected
                      ? const Icon(
                    Icons.check,
                    color: TColors.white,
                    size: 16,
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

  Widget _buildCollapsiblePriceBox(BuildContext context) {
    return GetBuilder<AirArabiaRevalidationController>(
      builder: (controller) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isExpanded ? 200 : 90,
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
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
            children: [
              // Collapsible header
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Handle indicator
                      Container(
                        width: 32,
                        height: 3,
                        decoration: BoxDecoration(
                          color: TColors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Spacer(),
                      Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 12,
                              color: TColors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'PKR ${controller.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: TColors.primary,
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: TColors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: _isExpanded ? 0.5 : 0,
                          child: Icon(
                            Icons.expand_less,
                            size: 16,
                            color: TColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Expandable content
              if (_isExpanded)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        // Price breakdown
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: TColors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Base Fare',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: TColors.grey,
                                    ),
                                  ),
                                  Obx(() => Text(
                                    'PKR ${controller.basePrice.value.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: TColors.primary,
                                    ),
                                  )),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Extras',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: TColors.grey,
                                    ),
                                  ),
                                  Obx(() => Text(
                                    'PKR ${controller.totalExtrasPrice.value.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: TColors.third,
                                    ),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Continue button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                             final arguments = Get.arguments as Map<String, dynamic>?;
                              final selectedFlight = arguments?['selectedFlight'] as AirArabiaFlight?;
                              final selectedPackage = arguments?['selectedPackage'] as AirArabiaPackage?;
                              
                              if (selectedFlight != null && selectedPackage != null) {
                                Get.to(() => AirArabiaReviewTripPage(
                                  flight: selectedFlight,
                                  selectedPackage: selectedPackage,
                                  isReturn: false, // or true for round trips
                                ));
                              }else {
                                Get.snackbar(
                                  'Error',
                                  'Missing flight or package information',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: TColors.white,
                                  borderRadius: 10,
                                  margin: const EdgeInsets.all(16),
                                  duration: const Duration(seconds: 2),
                                );
                              };
                            
                              Get.snackbar(
                                'Success',
                                'Flight extras selected successfully!',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: TColors.primary,
                                colorText: TColors.white,
                                borderRadius: 10,
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 2),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              foregroundColor: TColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Continue to Booking',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Collapsed state - just the button
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.snackbar(
                          'Success',
                          'Flight extras selected successfully!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: TColors.primary,
                          colorText: TColors.white,
                          borderRadius: 10,
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 2),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: TColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue to Booking',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,)
            ],
          ),
        );
      },
    );
  }
}