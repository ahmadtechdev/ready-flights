import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../utility/colors.dart';
import '../booking_form_fields/group_ticket_booking_controller.dart';
import '../booking_form_fields/passenger_detail.dart';
import 'pkg_controller.dart';
import 'pkg_model.dart';


class SelectPkgScreen extends StatelessWidget {
  SelectPkgScreen({super.key});

  final FlightPKGController controller = Get.put(FlightPKGController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Flight Search Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(controller.errorMessage.value);
        }

        if (controller.filteredFlights.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildFiltersHeader(context),
            _buildAppliedFilters(),
            Expanded(
              child: _buildFlightsList(
                flights: controller.filteredFlights,
                context: context,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error Loading Flights',
            style: TextStyle(
              fontSize: 18,
              color: TColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.loadInitialData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight, size: 80, color: TColors.primary),
          const SizedBox(height: 16),
          const Text(
            'No flights available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Try adjusting your filters',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.resetFilters,
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(
            onPressed: controller.resetFilters,
            child: const Text('Clear All'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedFilters() {
    return Obx(() {
      final hasFilters = controller.selectedSector.value != 'all' ||
          controller.selectedAirline.value != 'all' ||
          controller.selectedDate.value != 'all';

      if (!hasFilters) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            if (controller.selectedSector.value != 'all')
              _buildFilterChip(
                label: controller.sectorOptions.firstWhere(
                      (option) => option['value'] == controller.selectedSector.value,
                )['label']!,
                onDeleted: () => controller.updateSector('all'),
              ),
            if (controller.selectedAirline.value != 'all')
              _buildFilterChip(
                label: controller.selectedAirline.value,
                onDeleted: () => controller.updateAirline('all'),
              ),
            if (controller.selectedDate.value != 'all')
              _buildFilterChip(
                label: DateFormat('dd MMM yyyy').format(
                  DateTime.parse(controller.selectedDate.value),
                ),
                onDeleted: () => controller.updateDate('all'),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildFlightsList({
    required List<GroupFlightModel> flights,
    required BuildContext context,
  }) {
    final flightsBySector = <String, List<GroupFlightModel>>{};

    for (final flight in flights) {
      final sector = '${flight.origin}-${flight.destination}'.toLowerCase();
      flightsBySector.putIfAbsent(sector, () => []).add(flight);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: flightsBySector.length,
      itemBuilder: (context, index) {
        final sector = flightsBySector.keys.elementAt(index);
        final sectorFlights = flightsBySector[sector]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                sector.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.primary,
                ),
              ),
            ),
            ...sectorFlights.map((flight) => _buildFlightCard(flight, context)),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
        backgroundColor: TColors.third,
        deleteIconColor: Colors.white,
        onDeleted: onDeleted,
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                    TextButton(
                      onPressed: controller.resetFilters,
                      child: const Text(
                        'Clear All',
                        style: TextStyle(fontSize: 14, color: TColors.third),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterSection(
                        title: 'Sector',
                        options: controller.sectorOptions,
                        currentValue: controller.selectedSector,
                        onSelect: controller.updateSector,
                      ),
                      const SizedBox(height: 25),
                      _buildAirlineFilterSection(),
                      const SizedBox(height: 25),
                      _buildDateFilterSection(),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.secondary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAirlineFilterSection() {
    final airlineOptions = controller.groupFlights
        .map((flight) => flight['airline']['airline_name'] as String) // Cast to String
        .toSet()
        .toList()
        .map((airline) => <String, String>{ // Explicitly create Map<String, String>
      'label': airline,
      'value': airline.toLowerCase(),
    })
        .toList();

    return _buildFilterSection(
      title: 'Airlines',
      options: [
        {'label': 'All Airlines', 'value': 'all'},
        ...airlineOptions,
      ],
      currentValue: controller.selectedAirline,
      onSelect: controller.updateAirline,
    );
  }
  Widget _buildDateFilterSection() {
    final dateOptions = controller.groupFlights
        .map((flight) => flight['dept_date'] as String) // Cast to String
        .toSet()
        .toList()
        .map((date) {
      final formattedDate = DateFormat('yyyy-MM-dd').parse(date);
      return <String, String>{ // Explicitly create Map<String, String>
        'label': DateFormat('dd MMM yyyy').format(formattedDate),
        'value': date,
      };
    })
        .toList();

    return _buildFilterSection(
      title: 'Departure Dates',
      options: [
        {'label': 'All Dates', 'value': 'all'},
        ...dateOptions,
      ],
      currentValue: controller.selectedDate,
      onSelect: controller.updateDate,
    );
  }
  Widget _buildFilterSection({
    required String title,
    required List<Map<String, String>> options,
    required RxString currentValue,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.text,
          ),
        ),
        const SizedBox(height: 10),
        Obx(() => Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final isSelected = currentValue.value == option['value'];
            return GestureDetector(
              onTap: () => onSelect(option['value']!),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? TColors.third : TColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? TColors.third : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  option['label']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? TColors.white : TColors.text,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildFlightCard(GroupFlightModel flight, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: TColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildFlightHeader(flight),
            const SizedBox(height: 8),
            _buildFlightRoute(flight),
            const SizedBox(height: 8),
            _buildFlightDetails(flight),
            const SizedBox(height: 8),
            _buildFlightFooter(flight, context),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightHeader(GroupFlightModel flight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: TColors.background,
            // border: Border.all(color: TColors.primary, width: 1.5),
            image: DecorationImage(
              image: flight.logoUrl.startsWith('data:')
                  ? MemoryImage(base64Decode(flight.logoUrl.split(',')[1]))
                  : NetworkImage(flight.logoUrl) as ImageProvider,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                flight.airline,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Departure',
                style: TextStyle(
                  fontSize: 12,
                  color: TColors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: TColors.secondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            DateFormat('dd MMM').format(flight.departure),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: TColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlightRoute(GroupFlightModel flight) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flight.departureTime,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.background4,
                  ),
                ),
                Text(
                  flight.origin,
                  style: TextStyle(
                    fontSize: 14,
                    color: TColors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: TColors.third,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: TColors.third.withOpacity(0.3),
                  ),
                ),
                Transform.rotate(
                  angle: 1.5708,
                  child: Icon(
                    Icons.flight,
                    color: TColors.third,
                    size: 25,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: TColors.third.withOpacity(0.3),
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: TColors.third,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  flight.arrivalTime,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.background4,
                  ),
                ),
                Text(
                  flight.destination,
                  style: TextStyle(
                    fontSize: 14,
                    color: TColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightDetails(GroupFlightModel flight) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            flight.flightNumber,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: TColors.primary,
            ),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 14,
              color: TColors.secondary,
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: TColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'NO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: TColors.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            Icon(
              Icons.luggage,
              size: 14,
              color: TColors.third,
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: TColors.third.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                flight.baggage,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: TColors.third,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlightFooter(GroupFlightModel flight, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'PKR ',
                  style: TextStyle(
                    fontSize: 14,
                    color: TColors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '${flight.price}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: TColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              final bookingController = Get.put(GroupTicketBookingController());
              print("check 1");
              print(flight.id);
              bookingController.initializeFromFlight(flight, flight.id);
              Get.to(() => BookingSummaryScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.secondary,
              foregroundColor: TColors.background,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}