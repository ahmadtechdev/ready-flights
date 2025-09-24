import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/views/flight/booking_flight/booking_flight_controller.dart';
import 'package:ready_flights/views/flight/form/flight_booking_controller.dart';
import 'package:ready_flights/views/flight/search_flights/airarabia/validation_data/validation.dart';

import '../../../../../services/api_service_airarabia.dart';
import '../../../../../services/api_service_sabre.dart';
import '../../../../../utility/colors.dart';
import '../../airarabia/airarabia_flight_model.dart';
import '../../airarabia/airarabia_flight_controller.dart';
import '../../search_flight_utils/widgets/airarabia_flight_card.dart';

class AirArabiaPackageSelectionDialog extends StatefulWidget {
  final AirArabiaFlight flight;
  final bool isReturnFlight;

  const AirArabiaPackageSelectionDialog({
    super.key,
    required this.flight,
    required this.isReturnFlight,
  });

  @override
  State<AirArabiaPackageSelectionDialog> createState() => _AirArabiaPackageSelectionDialogState();
}

class _AirArabiaPackageSelectionDialogState extends State<AirArabiaPackageSelectionDialog> {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingPackages = true.obs;
  final Rx<AirArabiaPackageResponse?> packageResponse = Rx<AirArabiaPackageResponse?>(null);
  final RxString errorMessage = ''.obs;

  // Cache for margin data and calculated prices
  final Rx<Map<String, dynamic>> marginData = Rx<Map<String, dynamic>>({});
  final Map<String, RxDouble> finalPrices = {};

  final airArabiaController = Get.find<AirArabiaFlightController>();
  final apiService = Get.find<ApiServiceAirArabia>();

  // Static Basic Package
  late final AirArabiaPackage staticBasicPackage;

  @override
  void initState() {
    super.initState();
    _initializeStaticBasicPackage();
    _loadPackages();
    _prefetchMarginData();
  }

  void _initializeStaticBasicPackage() {
    staticBasicPackage = AirArabiaPackage(
      packageType: 'Basic',
      packageName: 'Basic',
      basePrice: 0.0, // No additional cost for basic package
      totalPrice: 0.0,
      baggageAllowance: 'Charges Apply',
      mealInfo: 'Charges Apply',
      seatInfo: 'Charges Apply',
      modificationPolicy: 'Charges Apply',
      cancellationPolicy: 'Charges Apply',
      currency: '',
      cabinClass: '',
      isRefundable: false,
      rawData: {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.background,
        surfaceTintColor: TColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.isReturnFlight
              ? 'Select Return Flight Package'
              : 'Select Flight Package',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildFlightInfo(),
          Expanded(
            child: _buildPackagesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightInfo() {
    return AirArabiaFlightCard(flight: widget.flight, showReturnFlight: false);
  }

Future<void> _loadPackages() async {
  try {
    isLoadingPackages.value = true;
    errorMessage.value = '';

    // Convert flight segments to the format expected by the API
    final sector = _convertFlightToSector(widget.flight);

    // Get the FlightBookingController to determine the trip type
    final flightBookingController = Get.find<FlightBookingController>();
    
    // Determine the correct type based on the trip type from controller
    int tripType = 0; // Default to one way
    
    // Check the actual trip type from the controller
    switch (flightBookingController.tripType.value) {
      case TripType.oneWay:
        tripType = 0;
        break;
      case TripType.roundTrip:
        tripType = 1;
        break;
      case TripType.multiCity:
        tripType = 2;
        break;
    }

    // Override for return flight dialog - if this is marked as a return flight
    // and we're in round trip mode, still use 1 (return)
    if (widget.isReturnFlight && flightBookingController.tripType.value == TripType.roundTrip) {
      tripType = 1;
    }

    // Get traveler counts from the controller
    final adult = flightBookingController.adultCount.value;
    final child = flightBookingController.childrenCount.value;
    final infant = flightBookingController.infantCount.value;

    print('Package API call with - Type: $tripType, Adult: $adult, Child: $child, Infant: $infant');
    print('Trip type from controller: ${flightBookingController.tripType.value}');
    print('Is return flight: ${widget.isReturnFlight}');

    final response = await apiService.getFlightPackages(
      type: tripType,
      adult: adult,
      child: child,
      infant: infant,
      sector: sector,
    );

    if (response['status'] == 200) {
      packageResponse.value = AirArabiaPackageResponse.fromJson(response);
      print('Packages loaded successfully: ${packageResponse.value?.packages.length} packages');
    } else {
      errorMessage.value = response['message'] ?? 'Failed to load packages';
      print('Package API error: ${errorMessage.value}');
    }
  } catch (e) {
    errorMessage.value = 'Error loading packages: $e';
    print('Package loading exception: $e');
  } finally {
    isLoadingPackages.value = false;
  }
}
 List<Map<String, dynamic>> _convertFlightToSector(AirArabiaFlight flight) {
    // Convert AirArabiaFlight to the sector format expected by the packages API
    final List<Map<String, dynamic>> flightSegments = [];

    for (var segment in flight.flightSegments) {
      flightSegments.add({
        'flightNumber': segment['flightNumber'],
        'origin': {
          'airportCode': segment['departure']['airport'],
          'terminal': segment['departure']['terminal'] ?? '',
          'countryCode': 'PK', // Default country code
        },
        'destination': {
          'airportCode': segment['arrival']['airport'],
          'terminal': segment['arrival']['terminal'] ?? '',
          'countryCode': 'AE', // Default country code
        },
        'departureDateTimeLocal': segment['departure']['dateTime'],
        'departureDateTimeZulu': segment['departure']['dateTime'],
        'arrivalDateTimeLocal': segment['arrival']['dateTime'],
        'arrivalDateTimeZulu': segment['arrival']['dateTime'],
        'segmentCode': '${segment['departure']['airport']}/${segment['arrival']['airport']}',
        'availablePaxCounts': [
          {'paxType': 'ADT', 'count': 9},
          {'paxType': 'INF', 'count': 9},
        ],
        'transportMode': 'AIRCRAFT',
        'modelName': '',
        'aircraftModel': segment['aircraftModel'] ?? 'A320',
        'flightSegmentRef': '${DateTime.now().millisecondsSinceEpoch}',
      });
    }

    return [{
      'flightSegments': flightSegments,
      'cabinPrices': [{
        'cabinClass': flight.cabinClass,
        'fareFamily': flight.cabinClass,
        'price': flight.price,
        'fareOndWiseBookingClassCodes': {
          '${flight.flightSegments.first['departure']['airport']}/${flight.flightSegments.last['arrival']['airport']}': 'E35'
        },
        'availabilityStatus': 'UNKNOWN_AVAILABILITY_STATUS',
        'paxTypeWiseBasePrices': [
          {'paxType': 'ADT', 'price': flight.price},
          {'paxType': 'CHD', 'price': 0},
          {'paxType': 'INF', 'price': 0},
        ]
      }]
    }];
  }

  Future<void> _prefetchMarginData() async {
    try {
      if (marginData.value.isEmpty) {
        final apiService = Get.find<ApiServiceSabre>();
        marginData.value = await apiService.getMargin("FJ", "Air Arabia");
      }

      // Pre-calculate prices for all packages when they're loaded
      if (packageResponse.value != null) {
        for (var package in packageResponse.value!.packages) {
          final String packageKey = '${package.packageType}-${package.packageName}';

          if (!finalPrices.containsKey(packageKey)) {
            final apiService = Get.find<ApiServiceSabre>();
            final marginedBasePrice = apiService.calculatePriceWithMargin(
              package.basePrice,
              marginData.value,
            );
            final totalPrice = marginedBasePrice + widget.flight.price;
            finalPrices[packageKey] = totalPrice.obs;
          }
        }
      }
    } catch (e) {
      // Handle margin calculation errors silently
    }
  }

  Widget _buildPackagesList() {
    return Obx(() {
      if (isLoadingPackages.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading Flights....',
                style: TextStyle(fontSize: 16, color: TColors.grey),
              ),
            ],
          ),
        );
      }

      if (errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading packages',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage.value,
                style: const TextStyle(fontSize: 14, color: TColors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPackages,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      // Combine static basic package with dynamic packages
      final dynamicPackages = packageResponse.value?.packages ?? [];
      final allPackages = [staticBasicPackage, ...dynamicPackages];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
            child: Text(
              'Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: TColors.text,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: allPackages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPackageCard(allPackages[index], index),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPackageCard(AirArabiaPackage package, int index) {
    final headerColor = _getPackageColor(package.packageType);
    
    // For static basic package, use flight price. For others, calculate as before
    final double price;
    if (package.packageType == 'Basic' && package.basePrice == 0.0) {
      // This is our static basic package
      price = widget.flight.price;
    } else {
      // This is a dynamic package from API
      price = finalPrices['${package.packageType}-${package.packageName}']?.value ??
          (package.totalPrice + widget.flight.price);
    }

    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with package name and price
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  headerColor,
                  headerColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    package.packageName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: TColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: TColors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'PKR ${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: TColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Package details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildPackageDetail(
                  Icons.work_outline_rounded,
                  'Hand Baggage',
                  '7 Kg', // Static value for basic package
                ),
                const SizedBox(height: 12),
                _buildPackageDetail(
                  Icons.luggage,
                  'Checked Baggage',
                  package.baggageAllowance,
                ),
                const SizedBox(height: 12),
                _buildPackageDetail(
                  Icons.restaurant_rounded,
                  'Meal',
                  package.mealInfo,
                ),
                const SizedBox(height: 12),
                _buildPackageDetail(
                  Icons.airline_seat_recline_normal,
                  'Seat',
                  package.seatInfo,
                ),
                const SizedBox(height: 12),
                _buildPackageDetail(
                  Icons.swap_horiz_rounded,
                  'Modification',
                  package.modificationPolicy,
                ),
                const SizedBox(height: 12),
                _buildPackageDetail(
                  Icons.money_off_rounded,
                  'Cancellation',
                  package.cancellationPolicy,
                ),

                const SizedBox(height: 16),

                // Button
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isLoading.value
                        ? null
                        : () => onSelectPackage(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: TColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(TColors.white),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.isReturnFlight
                              ? 'Select Return Flight '
              : 'Select Flight ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDetail(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: TColors.background, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: TColors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: TColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPackageColor(String packageType) {
    switch (packageType.toLowerCase()) {
      case 'basic':
        return TColors.primary;
      case 'value':
        return TColors.primary;
      case 'ultimate':
        return TColors.primary;
      default:
        return TColors.primary;
    }
  }

void onSelectPackage(int selectedPackageIndex) async {
  try {
    isLoading.value = true;

    // Get all packages (static + dynamic)
    final dynamicPackages = packageResponse.value?.packages ?? [];
    final allPackages = [staticBasicPackage, ...dynamicPackages];
    
    if (selectedPackageIndex >= allPackages.length) {
      throw Exception('Invalid package selection');
    }

    final selectedPackage = allPackages[selectedPackageIndex];

    // Store the selected package and flight in the controller
    airArabiaController.selectedPackage = selectedPackage;
    airArabiaController.selectedFlight = widget.flight;
    airArabiaController.selectedPackageIndex = selectedPackageIndex;

    // Get booking controller to access travelers data
    final bookingController = Get.find<BookingFlightController>();
    final flightBookingController = Get.find<FlightBookingController>();

    // Prepare sector data from the selected flight
    final sector = _convertFlightToSector(widget.flight);

    // Prepare fare data
    final fare = {
      "bundle": {
        "cabinClass": widget.flight.cabinClass,
        "fareFamily": widget.flight.cabinClass,
        "price": widget.flight.price,
        "fareOndWiseBookingClassCodes": {
          "${widget.flight.flightSegments.first['departure']['airport']}/${widget.flight.flightSegments.last['arrival']['airport']}": "E35"
        }
      }
    };

    Get.back(); // Close the package selection dialog

    // Determine trip type correctly
    int tripType = 0; // Default to one way
    switch (flightBookingController.tripType.value) {
      case TripType.oneWay:
        tripType = 0;
        break;
      case TripType.roundTrip:
        tripType = 1;
        break;
      case TripType.multiCity:
        tripType = 2;
        break;
    }

    // Override for return flight dialog
    if (widget.isReturnFlight && flightBookingController.tripType.value == TripType.roundTrip) {
      tripType = 1;
    }

    print('Navigation with trip type: $tripType');

    // Navigate to revalidation screen with required parameters
    Get.to(() => AirArabiaRevalidationScreen(), arguments: {
      'type': tripType,
      'adult': bookingController.adults.length,
      'child': bookingController.children.length,
      'infant': bookingController.infants.length,
      'sector': sector,
      'fare': fare,
      'csId': 15,
      'selectedPackage': selectedPackage,
      'selectedFlight': widget.flight,
    });

  } catch (e) {
    Get.snackbar(
      'Error',
      'Package selection failed: ${e.toString()}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
    print('Package selection error: $e');
  } finally {
    isLoading.value = false;
  }
}}