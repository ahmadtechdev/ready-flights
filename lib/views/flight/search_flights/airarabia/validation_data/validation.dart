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
      appBar: AppBar(
        backgroundColor: TColors.background,
        surfaceTintColor: TColors.background,
        title: const Text(
          'Flight Extras',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading flight extras...',
                  style: TextStyle(fontSize: 16, color: TColors.grey),
                ),
              ],
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading extras',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(fontSize: 14, color: TColors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        if (controller.revalidationResponse.value == null) {
          return const Center(
            child: Text(
              'No flight extras available',
              style: TextStyle(fontSize: 16, color: TColors.grey),
            ),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Container(
                color: TColors.background,
                child: TabBar(
                  indicatorColor: TColors.primary,
                  labelColor: TColors.primary,
                  unselectedLabelColor: TColors.grey,
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
                    _buildBaggageTab(),
                    _buildMealsTab(),
                    _buildSeatsTab(),
                  ],
                ),
              ),
              _buildBottomSummary(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBaggageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Baggage Option',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...controller.availableBaggage.map((baggage) {
            final isSelected = controller.selectedBaggage['default']?.baggageCode == baggage.baggageCode;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? TColors.primary : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.luggage, color: TColors.primary),
                title: Text(
                  baggage.baggageDescription,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  'PKR ${baggage.baggageCharge}',
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: TColors.primary)
                    : null,
                onTap: () => controller.selectBaggage('default', baggage),
              ),
            );
          }).toList(),
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
          Container(
            color: TColors.background,
            child: TabBar(
              isScrollable: true,
              indicatorColor: TColors.primary,
              labelColor: TColors.primary,
              unselectedLabelColor: TColors.grey,
              tabs: segments.map((segment) {
                final attrs = segment.attributes;
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Meals',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...meals.map((meal) {
                        final isSelected = controller.isMealSelected(segmentCode, meal);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? TColors.primary : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.restaurant, color: TColors.primary),
                            title: Text(
                              meal.mealName,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meal.mealDescription,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'PKR ${meal.mealCharge}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: TColors.primary)
                                : const Icon(Icons.add_circle_outline),
                            onTap: () => controller.toggleMeal(segmentCode, meal),
                          ),
                        );
                      }).toList(),
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
          Container(
            color: TColors.background,
            child: TabBar(
              isScrollable: true,
              indicatorColor: TColors.primary,
              labelColor: TColors.primary,
              unselectedLabelColor: TColors.grey,
              tabs: segments.map((segment) {
                final attrs = segment.attributes;
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Your Seat',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (selectedSeat != null)
                        Card(
                          color: TColors.primary.withOpacity(0.1),
                          child: ListTile(
                            leading: const Icon(Icons.airline_seat_recline_normal, color: TColors.primary),
                            title: Text(
                              'Selected: ${selectedSeat.seatNumber}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('PKR ${selectedSeat.seatCharge.toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => controller.selectSeat(segmentCode, SeatOption(
                                seatNumber: '',
                                seatCharge: 0,
                                currencyCode: 'PKR',
                                seatAvailability: '',
                              )),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: controller.availableSeats.length,
                        itemBuilder: (context, index) {
                          final seat = controller.availableSeats[index];
                          final isSelected = selectedSeat?.seatNumber == seat.seatNumber;
                          
                          return GestureDetector(
                            onTap: () => controller.selectSeat(segmentCode, seat),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? TColors.primary : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? TColors.primary : Colors.grey.shade400,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    seat.seatNumber,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (seat.seatCharge > 0)
                                    Text(
                                      'PKR ${seat.seatCharge.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.grey.shade600,
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Base Fare:', style: TextStyle(fontSize: 16)),
              Text(
                'PKR ${controller.basePrice.value.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Extras:', style: TextStyle(fontSize: 16)),
              Text(
                'PKR ${controller.totalExtrasPrice.value.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'PKR ${controller.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Proceed to booking
                Get.snackbar(
                  'Success',
                  'Extras selected successfully!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
                // Navigate to booking screen
                // Get.to(() => BookingConfirmationScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue to Booking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}