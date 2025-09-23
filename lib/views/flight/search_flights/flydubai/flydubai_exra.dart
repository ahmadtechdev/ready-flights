// flydubai_extras_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/utility/colors.dart';
import 'package:ready_flights/views/flight/search_flights/flydubai/flydubai_extras_controller.dart';
import 'package:ready_flights/views/flight/search_flights/flydubai/flydubai_model.dart';

class FlydubaiExtrasScreen extends StatefulWidget {
  FlydubaiExtrasScreen({super.key});

  @override
  State<FlydubaiExtrasScreen> createState() => _FlydubaiExtrasScreenState();
}

class _FlydubaiExtrasScreenState extends State<FlydubaiExtrasScreen> {
  bool _isExpanded = false;

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

  Widget _buildMainContent(FlydubaiExtrasController controller) {
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
              indicatorPadding: const EdgeInsets.only(bottom: 5, top: 5),
              labelColor: TColors.white,
              unselectedLabelColor: TColors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Tab(text: 'Baggage')),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Tab(text: 'Meals')),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
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

  Widget _buildBaggageTab(FlydubaiExtrasController controller) {
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
              final isSelected = controller.selectedBaggage['default']?['id'] == baggage['id'];
              return _buildSelectionCard(
                icon: Icons.luggage,
                title: baggage['description'] ?? 'Baggage',
                price: '${controller.currency.value} ${baggage['charge'] ?? '0'}',
                isSelected: isSelected,
                onTap: () => controller.selectBaggage('default', baggage),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildMealsTab(FlydubaiExtrasController controller) {
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
          Obx(() => Column(
            children: controller.availableMeals.map((meal) {
              final isSelected = controller.selectedMeals['default']?['id'] == meal['id'];
              return _buildSelectionCard(
                icon: Icons.restaurant_menu,
                title: meal['name'] ?? 'Meal',
                subtitle: meal['description'] ?? '',
                price: '${controller.currency.value} ${meal['charge'] ?? '0'}',
                isSelected: isSelected,
                onTap: () => controller.selectMeal('default', meal),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

// Replace the _buildSeatsTab method in your flydubai_extras_screen.dart

  Widget _buildSeatsTab(FlydubaiExtrasController controller) {
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
            style: TextStyle(
              fontSize: 14,
              color: TColors.grey,
            ),
          ),
          const SizedBox(height: 16),

          Obx(() {
            final selectedSeat = controller.selectedSeats['default'];

            // Show selected seat info if any
            if (selectedSeat != null && selectedSeat['seatNumber']?.toString().isNotEmpty == true) {
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
                    Icon(Icons.airline_seat_recline_normal, color: TColors.primary),
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
                            style: TextStyle(
                              fontSize: 14,
                              color: TColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.selectSeat('default', {
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

  Widget _buildSeat(String seatNumber, int rowNumber, FlydubaiExtrasController controller) {
    return Obx(() {
      final availableSeats = controller.availableSeats;
      final selectedSeat = controller.selectedSeats['default'];

      // Find if this seat exists in available seats from API
      final apiSeat = availableSeats.where((seat) =>
      seat['seatNumber']?.toString() == seatNumber
      ).firstOrNull;

      final isSelected = selectedSeat?['seatNumber']?.toString() == seatNumber;

      bool isOccupied = true;  // Default to occupied
      bool isPremium = false;
      double price = 0;
      bool isAvailable = false;

      if (apiSeat != null) {
        // Seat exists in API data
        price = double.tryParse(apiSeat['charge']?.toString() ?? '0') ?? 0.0;
        isAvailable = apiSeat['isAvailable'] == true;
        isOccupied = apiSeat['isAssigned'] == true || apiSeat['isBlocked'] == true || !isAvailable;
        isPremium = apiSeat['isPremium'] == true;

        debugPrint('Seat $seatNumber: Available=$isAvailable, Occupied=$isOccupied, Price=$price');
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
        onTap: (isOccupied || !isAvailable) ? null : () {
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

          controller.selectSeat('default', seatToSelect);
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
                    color: isSelected ? TColors.primary.withOpacity(0.1) : TColors.lightGrey,
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
                          style: TextStyle(
                            fontSize: 12,
                            color: TColors.grey,
                          ),
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
                  child: isSelected
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
            if (_isExpanded)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    _buildPriceRow('Base Fare', '$currency ${basePrice.toStringAsFixed(2)}'),
                    _buildPriceRow('Extras', '$currency ${extrasPrice.toStringAsFixed(2)}'),
                    const Divider(),
                    _buildPriceRow(
                      'Total',
                      '$currency ${totalPrice.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: () {
                  // Proceed to booking
                  final summary = controller.getBookingSummary();
                  Get.toNamed('/booking-confirmation', arguments: {
                    'flight': controller.selectedFlight.value,
                    'fare': controller.selectedFare.value,
                    'extras': summary,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: TColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text(
                  'Continue to Booking',
                  style: TextStyle(
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
}