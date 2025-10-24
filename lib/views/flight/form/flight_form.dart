// flight_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/widgets/flight_date_range_slecter.dart';
import '../../../utility/colors.dart';
import '../../../utility/app_constants.dart';
import '../../../widgets/city_selection_bottom_sheet.dart';
import '../../../widgets/custom_date_picker_sheet.dart';
import '../../../widgets/passenger_class_selection_sheet.dart';
import 'flight_booking_controller.dart';

class FlightBookingScreen extends StatelessWidget {
  FlightBookingScreen({super.key});

  final FlightBookingController controller = Get.put(FlightBookingController());

  String _getCityDisplayName(String cityValue) {
    // If it's just a code, return it as is for now
    // You can enhance this to show full city names based on your data structure
    return cityValue;
  }

  String _formatDate(DateTime date) {
    // Format date as "Jan 15, 2024" or similar
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getPassengerDisplayText() {
    final adults = controller.travellersCount.value;
    final children = controller.childrenCount.value;
    final infants = controller.infantCount.value;
    final total = adults + children + infants;
    
    String passengerText = '$total Passenger';
    if (total > 1) passengerText += 's';
    
    return '$passengerText, ${controller.travelClass.value}';
  }

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
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setTripType(TripType.oneWay),
              child: Container(
                margin: const EdgeInsets.only(right: 2),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: controller.tripType.value == TripType.oneWay
                      ? TColors.primary
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: controller.tripType.value == TripType.oneWay
                        ? TColors.primary
                        : AppConstants.fieldBorderColor,
                    width: 1,
                  ),
                  boxShadow: controller.tripType.value == TripType.oneWay
                      ? AppConstants.cardShadow
                      : null,
                ),
                child: Text(
                  'One Way',
                  style: TextStyle(
                    color: controller.tripType.value == TripType.oneWay
                        ? Colors.white
                        : TColors.primary,
                    fontSize: 12,
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
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: controller.tripType.value == TripType.roundTrip
                      ? TColors.primary
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: controller.tripType.value == TripType.roundTrip
                        ? TColors.primary
                        : AppConstants.fieldBorderColor,
                    width: 1,
                  ),
                  boxShadow: controller.tripType.value == TripType.roundTrip
                      ? AppConstants.cardShadow
                      : null,
                ),
                child: Text(
                  'Return',
                  style: TextStyle(
                    color: controller.tripType.value == TripType.roundTrip
                        ? Colors.white
                        : TColors.primary,
                    fontSize: 12,
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
                margin: const EdgeInsets.only(left: 2),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: controller.tripType.value == TripType.multiCity
                      ? TColors.primary
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: controller.tripType.value == TripType.multiCity
                        ? TColors.primary
                        : AppConstants.fieldBorderColor,
                    width: 1,
                  ),
                  boxShadow: controller.tripType.value == TripType.multiCity
                      ? AppConstants.cardShadow
                      : null,
                ),
                child: Text(
                  'Multi City',
                  style: TextStyle(
                    color: controller.tripType.value == TripType.multiCity
                        ? Colors.white
                        : TColors.primary,
                    fontSize: 12,
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
    return Stack(
      children: [
        Column(
          children: [
            // FROM field
            GestureDetector(
              onTap: () => controller.showCitySelectionBottomSheet(
                context,
                FieldType.departure,
              ),
              child: Container(
                height: AppConstants.fieldHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(color: AppConstants.fieldBorderColor),
                  boxShadow: AppConstants.cardShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => controller.fromCity.value.isEmpty
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.flight_takeoff,
                                    color: AppConstants.tabInactiveColor,
                                    size: AppConstants.smallIconSize,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Flying From (City or Airport)',
                                    style: AppConstants.fieldLabelStyle,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(
                                    Icons.flight_takeoff,
                                    color: TColors.primary,
                                    size: AppConstants.smallIconSize,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _getCityDisplayName(controller.fromCity.value),
                                      style: AppConstants.fieldValueStyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // TO field
            GestureDetector(
              onTap: () => controller.showCitySelectionBottomSheet(
                context,
                FieldType.destination,
              ),
              child: Container(
                height: AppConstants.fieldHeight,
                decoration: BoxDecoration(
                  color: AppConstants.fieldBackgroundColor,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(color: AppConstants.fieldBorderColor),
                  boxShadow: AppConstants.cardShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => controller.toCity.value.isEmpty
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.flight_land,
                                    color: AppConstants.tabInactiveColor,
                                    size: AppConstants.smallIconSize,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Flying To (City or Airport)',
                                    style: AppConstants.fieldLabelStyle,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(
                                    Icons.flight_land,
                                    color: TColors.primary,
                                    size: AppConstants.smallIconSize,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _getCityDisplayName(controller.toCity.value),
                                      style: AppConstants.fieldValueStyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Swap button positioned to overlap both fields
        Positioned(
          left: 150,
          right: 0,
          top: AppConstants.fieldHeight - (AppConstants.swapperIconSize / 2),
          child: Center(
            child: Container(
              width: AppConstants.swapperIconSize,
              height: AppConstants.swapperIconSize,
              decoration: BoxDecoration(
                color: AppConstants.swapperIconColor,
                shape: BoxShape.circle,
                boxShadow: AppConstants.swapperShadow,
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
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppConstants.fieldBorderColor),
        boxShadow: AppConstants.cardShadow,
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
                    height: AppConstants.fieldHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(
                          () => controller.cityPairs[index].fromCity.value.isEmpty
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.flight_takeoff,
                                      color: AppConstants.tabInactiveColor,
                                      size: AppConstants.smallIconSize,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Flying From (City or Airport)',
                                      style: AppConstants.fieldLabelStyle,
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Icon(
                                      Icons.flight_takeoff,
                                      color: TColors.primary,
                                      size: AppConstants.smallIconSize,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _getCityDisplayName(controller.cityPairs[index].fromCity.value),
                                        style: AppConstants.fieldValueStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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
                width: AppConstants.swapperIconSize,
                height: AppConstants.swapperIconSize,
                decoration: BoxDecoration(
                  color: AppConstants.swapperIconColor,
                  shape: BoxShape.circle,
                  boxShadow: AppConstants.swapperShadow,
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
              height: AppConstants.fieldHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(
                          () => controller.cityPairs[index].toCity.value.isEmpty
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.flight_land,
                                      color: AppConstants.tabInactiveColor,
                                      size: AppConstants.smallIconSize,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Flying To (City or Airport)',
                                      style: AppConstants.fieldLabelStyle,
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Icon(
                                      Icons.flight_land,
                                      color: TColors.primary,
                                      size: AppConstants.smallIconSize,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _getCityDisplayName(controller.cityPairs[index].toCity.value),
                                        style: AppConstants.fieldValueStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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

          // Date field - Beautiful custom date picker
          GestureDetector(
            onTap: () async {
              final result = await showCustomDatePicker(
                context: context,
                selectedDate: controller.cityPairs[index].departureDateTime.value,
                initialDate: controller.cityPairs[index].departureDateTime.value,
                title: 'Select Date',
                label: 'Depart on',
              );
              if (result != null) {
                controller.updateMultiCityFlightDate(index, result);
              }
            },
            child: Container(
              height: AppConstants.fieldHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: AppConstants.fieldBorderColor),
                boxShadow: AppConstants.cardShadow,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: TColors.primary,
                      size: AppConstants.smallIconSize,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDate(controller.cityPairs[index].departureDateTime.value),
                        style: AppConstants.fieldValueStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppConstants.tabInactiveColor,
                      size: 16,
                    ),
                  ],
                ),
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

  // Updated Date Selectors - Simple field showing only selected value
  Widget _buildDateSelectors(BuildContext context) {
    return Obx(() {
      if (controller.tripType.value == TripType.roundTrip) {
        // Round Trip - Show selected dates
        return GestureDetector(
          onTap: () async {
            final result = await showCustomDateRangePicker(
              context: context,
              selectedDateRange: DateTimeRange(
                start: controller.departureDateTimeValue.value,
                end: controller.returnDateTimeValue.value,
              ),
              initialDate: controller.departureDateTimeValue.value,
              title: 'Select Date Range',
              label: 'Depart & Return',
            );
            if (result != null) {
              controller.updateDepartureDate(result.start);
              controller.updateReturnDate(result.end);
            }
          },
          child: Container(
            height: AppConstants.fieldHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppConstants.fieldBorderColor),
              boxShadow: AppConstants.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: TColors.primary,
                    size: AppConstants.smallIconSize,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_formatDate(controller.departureDateTimeValue.value)} - ${_formatDate(controller.returnDateTimeValue.value)}',
                      style: AppConstants.fieldValueStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppConstants.tabInactiveColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // One Way - Show selected date
        return GestureDetector(
          onTap: () async {
            final result = await showCustomDatePicker(
              context: context,
              selectedDate: controller.departureDateTimeValue.value,
              initialDate: controller.departureDateTimeValue.value,
              title: 'Select Date',
              label: 'Depart on',
            );
            if (result != null) {
              controller.updateDepartureDate(result);
            }
          },
          child: Container(
            height: AppConstants.fieldHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppConstants.fieldBorderColor),
              boxShadow: AppConstants.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: TColors.primary,
                    size: AppConstants.smallIconSize,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatDate(controller.departureDateTimeValue.value),
                      style: AppConstants.fieldValueStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppConstants.tabInactiveColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  Widget _buildTravellerAndClassSelectors(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: () async {
        final result = await showPassengerClassSelection(
          context: context,
          adults: controller.travellersCount.value,
          children: controller.childrenCount.value,
          infants: controller.infantCount.value,
          travelClass: controller.travelClass.value,
        );
        if (result != null) {
          controller.travellersCount.value = result['adults'];
          controller.childrenCount.value = result['children'];
          controller.infantCount.value = result['infants'];
          controller.travelClass.value = result['travelClass'];
        }
      },
      child: Container(
        height: AppConstants.fieldHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: AppConstants.fieldBorderColor),
          boxShadow: AppConstants.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: TColors.primary,
                size: AppConstants.smallIconSize,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getPassengerDisplayText(),
                  style: AppConstants.fieldValueStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppConstants.tabInactiveColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildClassSelectors(BuildContext context) {
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
        onTap: () => controller.showClassSelectionBottomSheet(context),
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
                      'Class',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                          () => Text(
                        '${controller.travelClass.value}',
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
        height: AppConstants.buttonHeight,
        child: ElevatedButton(
          onPressed: () => controller.searchFlights(),
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
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
            style: AppConstants.buttonTextStyle,
          ),
        ),
      ),
    );
  }
}