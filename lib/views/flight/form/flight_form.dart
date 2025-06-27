// flight_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utility/colors.dart';
import '../../../widgets/city_selection_bottom_sheet.dart';
import 'flight_booking_controller.dart';

class FlightBookingScreen extends StatelessWidget {
  FlightBookingScreen({super.key});

  final FlightBookingController controller = Get.put(FlightBookingController());

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Obx(() {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildTripTypeSelector(),
                const SizedBox(height: 20),

                // Different content based on trip type
                if (controller.tripType.value != TripType.multiCity)
                  Column(
                    children: [
                      _buildCitySelector(context),
                      const SizedBox(height: 16),
                      _buildDateSelectors(context),
                    ],
                  )
                else
                  _buildMultiCitySelector(context),

                const SizedBox(height: 16),
                _buildTravellerAndClassSelectors(context),
                const SizedBox(height: 24),
                _buildSearchButton(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTripTypeSelector() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setTripType(TripType.oneWay),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: TColors.primary, width: 1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  color:
                      controller.tripType.value == TripType.oneWay
                          ? TColors.primary
                          : Colors.white,
                ),
                child: Text(
                  'One Way',
                  style: TextStyle(
                    color:
                        controller.tripType.value == TripType.oneWay
                            ? Colors.white
                            : TColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setTripType(TripType.roundTrip),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: TColors.primary, width: 1),
                  color:
                      controller.tripType.value == TripType.roundTrip
                          ? TColors.primary
                          : Colors.white,
                ),
                child: Text(
                  'Round Trip',
                  style: TextStyle(
                    color:
                        controller.tripType.value == TripType.roundTrip
                            ? Colors.white
                            : TColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setTripType(TripType.multiCity),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: TColors.primary, width: 1),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  color:
                      controller.tripType.value == TripType.multiCity
                          ? TColors.primary
                          : Colors.white,
                ),
                child: Text(
                  'Multi City',
                  style: TextStyle(
                    color:
                        controller.tripType.value == TripType.multiCity
                            ? Colors.white
                            : TColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelector(BuildContext context) {
    return Column(
      children: [
        // FROM field with arrow in one row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                // Move GestureDetector to wrap entire Container
                onTap:
                    () => controller.showCitySelectionBottomSheet(
                      context,
                      FieldType.departure,
                    ),
                child: Container(
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
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.flight_takeoff,
                              color: Colors.grey.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Flying From',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Text(
                            controller.fromCity.value,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Swap button
            Container(
              margin: const EdgeInsets.only(left: 12),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: TColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.swap_vert,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => controller.swapCities(),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // TO field separate - Move GestureDetector to wrap entire Container
        GestureDetector(
          onTap:
              () => controller.showCitySelectionBottomSheet(
                context,
                FieldType.destination,
              ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
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
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flight_land,
                        color: Colors.grey.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Flying To',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      controller.toCity.value,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiCitySelector(BuildContext context) {
    return Column(
      children: [
        ...List.generate(controller.cityPairs.length, (index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  'Flight ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              _buildMultiCityPair(index, context),
            ],
          );
        }),
        const SizedBox(height: 16),
        _buildAddRemoveButtons(),
      ],
    );
  }

  Widget _buildMultiCityPair(int index, BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          // FROM field with arrow in one row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  // Move GestureDetector to wrap the entire clickable area
                  onTap:
                      () => controller.showCitySelectionBottomSheet(
                        context,
                        FieldType.departure,
                        multiCityIndex: index,
                      ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.flight_takeoff,
                              color: Colors.grey.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Flying From',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Text(
                            controller.cityPairs[index].fromCity.value,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Swap button
              Container(
                margin: const EdgeInsets.only(right: 16),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: TColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.swap_vert,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => controller.swapCitiesForPair(index),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey.shade200,
          ),

          // TO field - GestureDetector already wraps the entire Container properly
          GestureDetector(
            onTap:
                () => controller.showCitySelectionBottomSheet(
                  context,
                  FieldType.destination,
                  multiCityIndex: index,
                ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.flight_land,
                              color: Colors.grey.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Flying To',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Text(
                            controller.cityPairs[index].toCity.value,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey.shade200,
          ),

          // Date field - GestureDetector already wraps the entire Container properly
          GestureDetector(
            onTap: () => controller.openDatePickerForPair(context, index),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Departure Date',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            controller.cityPairs[index].departureDate.value,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRemoveButtons() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (controller.cityPairs.length < 4)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: OutlinedButton.icon(
                onPressed: () => controller.addCityPair(),
                icon: Icon(Icons.add, color: TColors.primary, size: 18),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: TColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                label: Text(
                  'Add City',
                  style: TextStyle(
                    color: TColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          if (controller.cityPairs.length > 2)
            OutlinedButton.icon(
              onPressed: () => controller.removeCityPair(),
              icon: Icon(Icons.remove, color: Colors.grey.shade600, size: 18),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              label: Text(
                'Remove',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelectors(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          // Departure Date
          GestureDetector(
            onTap: () => controller.openDepartureDatePicker(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Departure Date',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            controller.departureDate.value,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Show return date section only for round trip
          if (controller.tripType.value == TripType.roundTrip) ...[
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey.shade200,
            ),
            GestureDetector(
              onTap: () => controller.openReturnDatePicker(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Return Date',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              controller.returnDate.value,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTravellerAndClassSelectors(BuildContext context) {
    return Container(
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
      child: GestureDetector(
        onTap: () => controller.showTravelersSelectionBottomSheet(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.grey.shade600, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Passenger and Class',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        '${controller.travellersCount.value} Passenger, ${controller.travelClass.value}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => controller.searchFlights(),
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child:
              controller.isSearching.value
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text(
                    'SEARCH FLIGHTS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }
}
