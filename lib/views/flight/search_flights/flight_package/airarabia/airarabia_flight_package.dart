import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/views/flight/booking_flight/booking_flight_controller.dart';
import 'package:ready_flights/views/flight/form/flight_booking_controller.dart';
import 'package:ready_flights/views/flight/search_flights/airarabia/validation_data/validation.dart';

import '../../../../../services/api_service_airarabia.dart';
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
    _initialize();
  }

  Future<void> _initialize() async {
    await _prefetchMarginData();
    await _loadPackages();
  }

  void _initializeStaticBasicPackage() {
    staticBasicPackage = AirArabiaPackage(
      packageType: 'Basic',
      packageName: 'Basic',
      basePrice: 0.0,
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

      final flightBookingController = Get.find<FlightBookingController>();
      
      final adult = flightBookingController.adultCount.value;
      final child = flightBookingController.childrenCount.value;
      final infant = flightBookingController.infantCount.value;

      List<Map<String, dynamic>> sector;
      int tripType;

      if (flightBookingController.tripType.value == TripType.oneWay) {
        tripType = 0;
        sector = _convertFlightToSector(widget.flight);
      } else if (flightBookingController.tripType.value == TripType.roundTrip) {
        tripType = 1;
        sector = _createRoundTripSector();
      } else {
        tripType = 2;
        sector = _convertFlightToSector(widget.flight);
      }

      print('Package API call with - Type: $tripType, Adult: $adult, Child: $child, Infant: $infant');

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
        
        // Calculate prices with margin after packages are loaded
        await _calculatePackagePrices();
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

  Future<void> _prefetchMarginData() async {
    try {
      // Use the margin data from controller
      marginData.value = airArabiaController.marginData.value;
      
      // If margin data is empty, wait a bit and try again
      if (marginData.value.isEmpty) {
        print('Margin data not available yet, waiting...');
        await Future.delayed(const Duration(milliseconds: 300));
        marginData.value = airArabiaController.marginData.value;
      }
      
      print('Using Air Arabia margin data: ${marginData.value}');
      
      // Validate margin data
      final marginVal = double.tryParse(marginData.value['margin_val']?.toString() ?? '0') ?? 0.0;
      final marginPer = double.tryParse(marginData.value['margin_per']?.toString() ?? '0') ?? 0.0;
      
      if (marginVal == 0 && marginPer == 0) {
        print('Both margin values are zero - will show base prices');
      } else {
        print('Margin configured - Value: $marginVal, Percentage: $marginPer%');
      }
    } catch (e) {
      print('Error in prefetch margin: $e');
      // Set default margin on error
      marginData.value = {'margin_val': '0.00', 'margin_per': 0};
    }
  }

  Future<void> _calculatePackagePrices() async {
    if (packageResponse.value == null || packageResponse.value!.packages.isEmpty) {
      print('No packages to calculate prices for');
      return;
    }
    
    print('Calculating prices for ${packageResponse.value!.packages.length} packages');
    
    for (var package in packageResponse.value!.packages) {
      final String packageKey = '${package.packageType}-${package.packageName}';

      if (!finalPrices.containsKey(packageKey)) {
        double totalPrice;
        
        // Only apply margin to Basic package, others show original price
        if (package.packageType.toLowerCase() == 'basic') {
          // Apply margin to package price for Basic
          final marginedPackagePrice = apiService.calculatePriceWithMargin(
            package.basePrice,
            marginData.value,
          );
          totalPrice = marginedPackagePrice + widget.flight.price;
          
          print('Basic Package (WITH margin):');
          print('  Base: ${package.basePrice}, Margined: $marginedPackagePrice');
          print('  Flight: ${widget.flight.price}, Total: $totalPrice');
        } else {
          // For Value/Ultimate, use original price WITHOUT margin
          totalPrice = package.basePrice + widget.flight.price;
          
          print('${package.packageName} Package (WITHOUT margin):');
          print('  Base: ${package.basePrice}');
          print('  Flight: ${widget.flight.price}, Total: $totalPrice');
        }
        
        finalPrices[packageKey] = totalPrice.obs;
      }
    }
  }

  List<Map<String, dynamic>> _createRoundTripSector() {
    final flightBookingController = Get.find<FlightBookingController>();
    final combinedFlight = widget.flight;
    
    if (combinedFlight.isRoundTrip && 
        combinedFlight.outboundFlight != null && 
        combinedFlight.inboundFlight != null) {
      
      final outboundData = combinedFlight.outboundFlight!;
      final inboundData = combinedFlight.inboundFlight!;
      
      final outboundSegments = _createSegmentsFromFlightData(outboundData);
      final returnSegments = _createSegmentsFromFlightData(inboundData);
      
      final outboundPrice = _extractPriceFromFlightData(outboundData);
      final inboundPrice = _extractPriceFromFlightData(inboundData);
      
      final outboundSector = {
        "index": 1,
        "flightSegments": outboundSegments,
        "cabinPrices": [{
          "cabinClass": "Y",
          "fareFamily": "Y", 
          "price": outboundPrice,
          "fareOndWiseBookingClassCodes": {
            _getSegmentCode(outboundSegments): "E30"
          },
          "availabilityStatus": "AVAILABLE",
          "paxTypeWiseBasePrices": [
            {"paxType": "ADT", "price": outboundPrice},
            {"paxType": "CHD", "price": 0},
            {"paxType": "INF", "price": 0},
          ]
        }]
      };

      final inboundSector = {
        "index": 0,
        "flightSegments": returnSegments,
        "cabinPrices": [{
          "cabinClass": "Y",
          "fareFamily": "Y",
          "price": inboundPrice,
          "fareOndWiseBookingClassCodes": {
            _getSegmentCode(returnSegments): "E33"
          },
          "availabilityStatus": "AVAILABLE", 
          "paxTypeWiseBasePrices": [
            {"paxType": "ADT", "price": inboundPrice},
            {"paxType": "CHD", "price": 0},
            {"paxType": "INF", "price": 0},
          ]
        }]
      };
      
      return [outboundSector, inboundSector];
    }
    
    print('Warning: Not a proper round trip flight, using current flight only');
    return _convertFlightToSector(combinedFlight);
  }

  double _extractPriceFromFlightData(Map<String, dynamic> flightData) {
    try {
      if (flightData['cabinPrices'] != null && flightData['cabinPrices'] is List) {
        final cabinPrices = flightData['cabinPrices'] as List;
        if (cabinPrices.isNotEmpty) {
          return (cabinPrices[0]['price'] as num).toDouble();
        }
      }
      return 0.0;
    } catch (e) {
      print('Error extracting price from flight data: $e');
      return 0.0;
    }
  }

  List<Map<String, dynamic>> _createSegmentsFromFlightData(Map<String, dynamic> flightData) {
    try {
      if (flightData['flightSegments'] != null && flightData['flightSegments'] is List) {
        final flightSegments = flightData['flightSegments'] as List;
        
        return flightSegments.map<Map<String, dynamic>>((segment) {
          final segmentMap = Map<String, dynamic>.from(segment);
          final originMap = Map<String, dynamic>.from(segmentMap['origin'] ?? {});
          final destinationMap = Map<String, dynamic>.from(segmentMap['destination'] ?? {});
          
          return {
            'flightNumber': segmentMap['flightNumber'] ?? '',
            'origin': {
              'airportCode': originMap['airportCode'] ?? '',
              'terminal': originMap['terminal'] ?? '',
              'countryCode': originMap['countryCode'] ?? _getCountryCode(originMap['airportCode'] ?? ''),
            },
            'destination': {
              'airportCode': destinationMap['airportCode'] ?? '',
              'terminal': destinationMap['terminal'] ?? '',
              'countryCode': destinationMap['countryCode'] ?? _getCountryCode(destinationMap['airportCode'] ?? ''),
            },
            'departureDateTimeLocal': segmentMap['departureDateTimeLocal'] ?? '',
            'departureDateTimeZulu': segmentMap['departureDateTimeZulu'] ?? '',
            'arrivalDateTimeLocal': segmentMap['arrivalDateTimeLocal'] ?? '',
            'arrivalDateTimeZulu': segmentMap['arrivalDateTimeZulu'] ?? '',
            'segmentCode': segmentMap['segmentCode'] ?? '',
            'availablePaxCounts': [
              {'paxType': 'ADT', 'count': 9},
              {'paxType': 'INF', 'count': 9},
            ],
            'transportMode': 'AIRCRAFT',
            'modelName': '',
            'aircraftModel': segmentMap['aircraftModel'] ?? 'A320',
            'flightSegmentRef': '${segmentMap['flightSegmentRef'] ?? DateTime.now().millisecondsSinceEpoch}',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error creating segments from flight data: $e');
      return [];
    }
  }

  String _getSegmentCode(List<Map<String, dynamic>> segments) {
    if (segments.isEmpty) return '';
    
    try {
      final firstSegment = segments.first;
      final lastSegment = segments.last;
      
      final origin = firstSegment['origin']['airportCode'];
      final destination = lastSegment['destination']['airportCode'];
      
      if (segments.length > 1) {
        final stops = segments.map((seg) => seg['destination']['airportCode']).join('/');
        return '$origin/$stops';
      }
      
      return '$origin/$destination';
    } catch (e) {
      print('Error generating segment code: $e');
      return '';
    }
  }

  String _getCountryCode(String airportCode) {
    const airportToCountry = {
      'LHE': 'PK', 'KHI': 'PK', 'ISB': 'PK', 'UET': 'PK',
      'JED': 'SA', 'RUH': 'SA', 'DXB': 'AE', 'SHJ': 'AE',
      'DAC': 'BD', 'CGP': 'BD', 'DEL': 'IN', 'BOM': 'IN',
    };
    return airportToCountry[airportCode] ?? 'PK';
  }

  List<Map<String, dynamic>> _convertFlightToSector(AirArabiaFlight flight) {
    final flightSegments = _createFlightSegments(flight, widget.isReturnFlight ? 0 : 1);

    return [{
      "index": widget.isReturnFlight ? 0 : 1,
      'flightSegments': flightSegments,
      'cabinPrices': [{
        'cabinClass': flight.cabinClass,
        'fareFamily': flight.cabinClass,
        'price': flight.price,
        'fareOndWiseBookingClassCodes': {
          '${flight.flightSegments.first['departure']['airport']}/${flight.flightSegments.last['arrival']['airport']}': widget.isReturnFlight ? 'E33' : 'E30'
        },
        'availabilityStatus': 'AVAILABLE',
        'paxTypeWiseBasePrices': [
          {'paxType': 'ADT', 'price': flight.price},
          {'paxType': 'CHD', 'price': 0},
          {'paxType': 'INF', 'price': 0},
        ]
      }]
    }];
  }

  List<Map<String, dynamic>> _createFlightSegments(AirArabiaFlight flight, int sectorIndex) {
    return flight.flightSegments.map((segment) {
      return {
        'flightNumber': segment['flightNumber'],
        'origin': {
          'airportCode': segment['departure']['airport'],
          'terminal': segment['departure']['terminal'] ?? '',
          'countryCode': _getCountryCode(segment['departure']['airport']),
        },
        'destination': {
          'airportCode': segment['arrival']['airport'], 
          'terminal': segment['arrival']['terminal'] ?? '',
          'countryCode': _getCountryCode(segment['arrival']['airport']),
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
        'flightSegmentRef': '${DateTime.now().millisecondsSinceEpoch}${sectorIndex}',
      };
    }).toList();
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
                'Loading Packages....',
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

      final dynamicPackages = packageResponse.value?.packages ?? [];
      final allPackages = [staticBasicPackage, ...dynamicPackages];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
            child: Text(
              'Available Packages',
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
    
    // Calculate final price with margin
    final double price;
    if (package.packageType == 'Basic' && package.basePrice == 0.0) {
      // Static basic package - use flight price only (already has margin)
      price = widget.flight.price;
    } else {
      // Dynamic package - use calculated price with margin
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

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildPackageDetail(Icons.work_outline_rounded, 'Hand Baggage', '7 Kg'),
                const SizedBox(height: 12),
                _buildPackageDetail(Icons.luggage, 'Checked Baggage', package.baggageAllowance),
                const SizedBox(height: 12),
                _buildPackageDetail(Icons.restaurant_rounded, 'Meal', package.mealInfo),
                const SizedBox(height: 12),
                _buildPackageDetail(Icons.airline_seat_recline_normal, 'Seat', package.seatInfo),
                const SizedBox(height: 12),
                _buildPackageDetail(Icons.swap_horiz_rounded, 'Modification', package.modificationPolicy),
                const SizedBox(height: 12),
                _buildPackageDetail(Icons.money_off_rounded, 'Cancellation', package.cancellationPolicy),
                const SizedBox(height: 16),

                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isLoading.value ? null : () => onSelectPackage(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: TColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                widget.isReturnFlight ? 'Select Return Flight ' : 'Select Flight ',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                Text(title, style: const TextStyle(fontSize: 14, color: TColors.grey)),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: TColors.text),
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

      final dynamicPackages = packageResponse.value?.packages ?? [];
      final allPackages = [staticBasicPackage, ...dynamicPackages];
      
      if (selectedPackageIndex >= allPackages.length) {
        throw Exception('Invalid package selection');
      }

      final selectedPackage = allPackages[selectedPackageIndex];

      airArabiaController.selectedPackage = selectedPackage;
      airArabiaController.selectedFlight = widget.flight;
      airArabiaController.selectedPackageIndex = selectedPackageIndex;

      final bookingController = Get.find<BookingFlightController>();
      final flightBookingController = Get.find<FlightBookingController>();

      List<Map<String, dynamic>> sector;
      if (flightBookingController.tripType.value == TripType.roundTrip) {
        sector = _createRoundTripSector();
      } else {
        sector = _convertFlightToSector(widget.flight);
      }

      final fare = {
        "bundle": {
          "cabinClass": widget.flight.cabinClass,
          "fareFamily": widget.flight.cabinClass,
          "price": widget.flight.price,
          "fareOndWiseBookingClassCodes": {
            "${widget.flight.flightSegments.first['departure']['airport']}/${widget.flight.flightSegments.last['arrival']['airport']}": widget.isReturnFlight ? "E33" : "E30"
          }
        }
      };

      Get.back();

      int tripType = 0;
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

      // Calculate margined package price
      final marginedPackagePrice = selectedPackage.packageType == 'Basic' && selectedPackage.basePrice == 0.0
          ? 0.0
          : apiService.calculatePriceWithMargin(selectedPackage.basePrice, marginData.value);

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
        'packagePrice': marginedPackagePrice,
        'flightPrice': widget.flight.price,
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
  }
}