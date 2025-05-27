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
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        title: Text("Flights Search"),
        backgroundColor: TColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'FLIGHTS',
                    style: TextStyle(
                      color: TColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildTripTypeSelector(),
                  const SizedBox(height: 16),

                  // Different content based on trip type
                  if (controller.tripType.value != TripType.multiCity)
                    Column(
                      children: [
                        _buildCitySelector( context),
                        const SizedBox(height: 16),
                        _buildDateSelectors(),
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: TColors.primary, width: 1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  color:
                      controller.tripType.value == TripType.oneWay
                          ? TColors.primary
                          : TColors.white,
                ),
                child: Text(
                  'ONE WAY',
                  style: TextStyle(
                    color:
                        controller.tripType.value == TripType.oneWay
                            ? TColors.white
                            : TColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: TColors.primary, width: 1),
                  color:
                      controller.tripType.value == TripType.roundTrip
                          ? TColors.primary
                          : TColors.white,
                ),
                child: Text(
                  'ROUND TRIP',
                  style: TextStyle(
                    color:
                        controller.tripType.value == TripType.roundTrip
                            ? TColors.white
                            : TColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: TColors.primary, width: 1),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  color:
                      controller.tripType.value == TripType.multiCity
                          ? TColors.primary
                          : TColors.white,
                ),
                child: Text(
                  'MULTICITY',
                  style: TextStyle(
                    color:
                        controller.tripType.value == TripType.multiCity
                            ? TColors.white
                            : TColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

  // flight_form.dart - Update _buildCitySelector() method

  Widget _buildCitySelector( BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.showCitySelectionBottomSheet(context, FieldType.departure),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: TColors.primary),
                    color: TColors.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'FROM',
                          style: TextStyle(
                            color: TColors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                              () => Text(
                            controller.fromCity.value,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                              () => Text(
                            controller.fromCityName.value,
                            style: TextStyle(
                              color: TColors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.showCitySelectionBottomSheet(context, FieldType.destination),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: TColors.primary),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    color: TColors.primary.withOpacity(0.1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'TO',
                          style: TextStyle(
                            color: TColors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                              () => Text(
                            controller.toCity.value,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                              () => Text(
                            controller.toCityName.value,
                            style: TextStyle(
                              color: TColors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 30,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TColors.white,
              border: Border.all(color: TColors.primary, width: 1),
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
              icon: Icon(Icons.swap_horiz, color: TColors.primary, size: 26),
              onPressed: () => controller.swapCities(),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildMultiCitySelector(BuildContext conext) {
    return Column(
      children: [
        ...List.generate(controller.cityPairs.length, (index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text(
                  'Flight ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: TColors.text,
                  ),
                ),
              ),
              _buildMultiCityPair(index, conext),
              SizedBox(height: 16)
            ],
          );
        }),
        _buildAddCityButton(),
      ],
    );
  }

  Widget _buildMultiCityPair(int index, BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // From field
            GestureDetector(
              onTap: () => controller.showCitySelectionBottomSheet(context, FieldType.departure, multiCityIndex: index),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: TColors.primary),
                  color: TColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            children: [
                              Obx(() => Text(
                                '${controller.cityPairs[index].fromCity.value} — ${controller.cityPairs[index].fromCityName.value}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100,
                      ),
                      child: Icon(
                        Icons.flight_takeoff,
                        size: 16,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // To field
            GestureDetector(
              onTap: () => controller.showCitySelectionBottomSheet(context, FieldType.destination, multiCityIndex: index),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: TColors.primary),
                  color: TColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            children: [
                              Obx(() => Text(
                                '${controller.cityPairs[index].toCity.value} — ${controller.cityPairs[index].toCityName.value}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100,
                      ),
                      child: Icon(
                        Icons.flight_land,
                        size: 16,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Date selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: TColors.primary),
                color: TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Departure',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Obx(() => Text(
                          controller.cityPairs[index].departureDate.value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700
                          ),
                        )),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: TColors.primary,
                      ),
                      onPressed: () => controller.openDatePickerForPair(Get.context!, index),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Swap button - positioned at the right side between From and To fields
        Positioned(
          right: 50,
          top: 30, // Adjust this value to position the button correctly
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: TColors.primary, width: 1),
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
              icon: Icon(Icons.swap_vert, color: TColors.primary, size: 20),
              onPressed: () => controller.swapCitiesForPair(index),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCityButton() {
    return Obx(
          () => controller.cityPairs.length < 4
          ? Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Add some spacing between buttons
          Container(
            margin: EdgeInsets.only(right: 8, bottom: 16),
            child: OutlinedButton.icon(
              onPressed: () => controller.addCityPair(),
              icon: Icon(Icons.add, color: TColors.secondary, size: 18),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: TColors.secondary),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              label: Text(
                'ADD CITY',
                style: TextStyle(
                  color: TColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          if (controller.cityPairs.length > 2) _buildRemoveCityButton(),
        ],
      )
          : SizedBox.shrink(),
    );
  }

  Widget _buildRemoveCityButton() {
    return Container(
      margin: EdgeInsets.only(right: 8, bottom: 16),
      child: OutlinedButton.icon(
        onPressed: () => controller.removeCityPair(),
        icon: Icon(Icons.remove, color: TColors.grey, size: 18),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: TColors.grey),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        label: Text(
          'REMOVE',
          style: TextStyle(
            color: TColors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelectors() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: TColors.primary),
                  color: TColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEPARTURE DATE',
                        style: TextStyle(
                          color: TColors.grey,
                          fontSize: constraints.maxWidth > 300 ? 12 : 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap:
                            () => controller.openDepartureDatePicker(context),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: TColors.grey,
                            ),
                            const SizedBox(width: 6),
                            Obx(
                              () => Flexible(
                                child: Text(
                                  controller.departureDate.value,
                                  style: TextStyle(
                                    fontSize:
                                        constraints.maxWidth > 300 ? 16 : 14,
                                    fontWeight: FontWeight.w700,
                                    color: TColors.text,
                                  ),
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
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
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Obx(
                () => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: TColors.primary),
                    borderRadius: BorderRadius.circular(8),
                    color:
                        controller.tripType.value == TripType.oneWay
                            ? Colors.grey.withOpacity(0.1)
                            : TColors.primary.withOpacity(0.1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RETURN DATE',
                          style: TextStyle(
                            color: TColors.grey,
                            fontSize: constraints.maxWidth > 300 ? 12 : 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap:
                              controller.tripType.value == TripType.oneWay
                                  ? null
                                  : () =>
                                      controller.openReturnDatePicker(context),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color:
                                    controller.tripType.value == TripType.oneWay
                                        ? TColors.grey.withOpacity(0.5)
                                        : TColors.grey,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  controller.returnDate.value,
                                  style: TextStyle(
                                    fontSize:
                                        constraints.maxWidth > 300 ? 16 : 14,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        controller.tripType.value ==
                                                TripType.oneWay
                                            ? TColors.grey.withOpacity(0.5)
                                            : TColors.text,
                                  ),
                                  softWrap: false,
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
            ),
          ],
        );
      },
    );
  }

  Widget _buildTravellerAndClassSelectors(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => controller.showTravelersSelectionBottomSheet(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: TColors.primary),
                color: TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRAVELLER(S)',
                      style: TextStyle(
                        color: TColors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      '${controller.travellersCount.value} Traveller',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TColors.text,
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => controller.showClassSelectionBottomSheet(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: TColors.primary),
                color: TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CLASS',
                      style: TextStyle(
                        color: TColors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                          controller.travelClass.value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: TColors.text,
                          ),
                        )),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: TColors.grey,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }






  Widget _buildSearchButton() {
    return Obx(
          () => Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: TColors.third,
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          onPressed: () => controller.searchFlights(),
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.third,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: controller.isSearching.value
              ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(TColors.white),
            ),
          )
              : const Text(
            'SEARCH',
            style: TextStyle(
              color: TColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
