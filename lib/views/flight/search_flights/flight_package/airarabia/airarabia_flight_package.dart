import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/views/flight/booking_flight/booking_flight_controller.dart';
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

  @override
  void initState() {
    super.initState();
    _loadPackages();
    _prefetchMarginData();
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

      final response = await apiService.getFlightPackages(
        type: 0, // One way
        adult: 1, // Default values - these should come from search parameters
        child: 0,
        infant: 0,
        sector: sector,
      );

      if (response['status'] == 200) {
        packageResponse.value = AirArabiaPackageResponse.fromJson(response);
      } else {
        errorMessage.value = response['message'] ?? 'Failed to load packages';
      }
    } catch (e) {
      errorMessage.value = 'Error loading packages: $e';
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
                'Loading packages...',
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

      final packages = packageResponse.value?.packages ?? [];

      if (packages.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
              SizedBox(height: 16),
              Text(
                'No packages available for this flight',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'Please select another flight',
                style: TextStyle(fontSize: 14, color: TColors.grey),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Text(
              'Available Packages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TColors.text,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                return _buildPackageCard(packages[index], index);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPackageCard(AirArabiaPackage package, int index) {
    final headerColor = _getPackageColor(package.packageType);
    final price = finalPrices['${package.packageType}-${package.packageName}']?.value ??
        (package.totalPrice + widget.flight.price);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with package name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [headerColor, headerColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Center(
              child: Text(
                package.packageName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.background,
                ),
              ),
            ),
          ),

          // Package details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPackageDetail(
                  Icons.luggage,
                  'Hand Baggage',
                  '10 KG',
                ),
                const SizedBox(height: 8),
                _buildPackageDetail(
                  Icons.luggage,
                  'Checked Baggage',
                  package.baggageAllowance,
                ),
                const SizedBox(height: 8),
                _buildPackageDetail(
                  Icons.restaurant,
                  'Meal',
                  package.mealInfo,
                ),
                const SizedBox(height: 8),
                _buildPackageDetail(
                  Icons.airline_seat_recline_normal,
                  'Seat',
                  package.seatInfo,
                ),
                const SizedBox(height: 8),
                _buildPackageDetail(
                  Icons.change_circle,
                  'Modification',
                  package.modificationPolicy,
                ),
                const SizedBox(height: 8),
                _buildPackageDetail(
                  Icons.currency_exchange,
                  'Cancellation',
                  package.cancellationPolicy,
                ),
              ],
            ),
          ),

          // Price and button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'PKR ${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => ElevatedButton(
                  onPressed: isLoading.value
                      ? null
                      : () => onSelectPackage(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerColor,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading.value
                      ? const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(TColors.background),
                  )
                      : Text(
                    widget.isReturnFlight
                        ? 'Select Return Package'
                        : 'Select Package',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColors.background,
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
          Icon(icon, color: TColors.primary, size: 20),
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
        return Colors.blue;
      case 'ultimate':
        return Colors.purple;
      default:
        return TColors.primary;
    }
  }

  // Replace the onSelectPackage method in AirArabiaPackageSelectionDialog with this:

void onSelectPackage(int selectedPackageIndex) async {
  try {
    isLoading.value = true;

    final packages = packageResponse.value?.packages ?? [];
    if (selectedPackageIndex >= packages.length) {
      throw Exception('Invalid package selection');
    }

    final selectedPackage = packages[selectedPackageIndex];

    // Store the selected package and flight in the controller
    airArabiaController.selectedPackage = selectedPackage;
    airArabiaController.selectedFlight = widget.flight;

    // Get booking controller to access travelers data
    final bookingController = Get.find<BookingFlightController>();
    
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

    // Navigate to revalidation screen with required parameters
    Get.to(() => AirArabiaRevalidationScreen(), arguments: {
      'type': 0, // One way
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