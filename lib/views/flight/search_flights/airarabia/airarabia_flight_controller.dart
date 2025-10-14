// airarabia_flight_controller.dart
import 'package:get/get.dart';

import '../../../../services/api_service_airarabia.dart';
import '../../../users/login/login_api_service/login_api.dart';
import '../filters/filter_flight_model.dart';
import '../flight_package/airarabia/airarabia_flight_package.dart';
import 'airarabia_flight_model.dart';

class AirArabiaFlightController extends GetxController {
  
  final ApiServiceAirArabia apiService = Get.find<ApiServiceAirArabia>();
  int selectedPackageIndex = 0;

  final RxList<AirArabiaFlight> flights = <AirArabiaFlight>[].obs;
  final RxList<AirArabiaFlight> filteredFlights = <AirArabiaFlight>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString sortType = 'Suggested'.obs;

  // Margin data storage
  final Rx<Map<String, dynamic>> marginData = Rx<Map<String, dynamic>>({});
  final RxBool isLoadingMargin = false.obs;

  // Selected flight and package for booking
  AirArabiaFlight? selectedFlight;
  AirArabiaPackage? selectedPackage;

  @override
  void onInit() {
    super.onInit();
    _fetchMarginData();
  }

  // Fetch margin data on controller initialization
  Future<void> _fetchMarginData() async {
    try {
      isLoadingMargin.value = true;
      
      // Check if user is logged in
      final authController = Get.find<AuthController>();
      final isLoggedIn = await authController.isLoggedIn();
      
      String? userEmail;
      if (isLoggedIn) {
        final userData = await authController.getUserData();
        userEmail = userData?['cs_email'];
        print('Fetching Air Arabia margin for logged-in user: $userEmail');
      } else {
        print('Fetching Air Arabia margin for guest user (default margin)');
      }

      // Fetch margin data
      final margin = await apiService.getAirArabiaMargin(userEmail);
      marginData.value = margin;
      
      print('Air Arabia Margin Data: $margin');
      
      // Validate margin data
      final marginVal = double.tryParse(margin['margin_val']?.toString() ?? '0') ?? 0.0;
      final marginPer = double.tryParse(margin['margin_per']?.toString() ?? '0') ?? 0.0;
      
      if (marginVal == 0 && marginPer == 0) {
        print('Warning: Both margin values are zero');
      }
      
    } catch (e) {
      print('Error fetching Air Arabia margin: $e');
      // Set default margin on error
      marginData.value = {
        'margin_val': '0.00',
        'margin_per': 0,
      };
    } finally {
      isLoadingMargin.value = false;
    }
  }

  // Calculate flight price with margin
  double calculateFlightPriceWithMargin(double basePrice) {
    if (marginData.value.isEmpty) {
      return basePrice;
    }
    return apiService.calculatePriceWithMargin(basePrice, marginData.value);
  }

  void clearFlights() {
    flights.clear();
    filteredFlights.clear();
    errorMessage.value = '';
  }

  void setErrorMessage(String message) {
    errorMessage.value = message;
  }

  Future<void> loadFlights(Map<String, dynamic> apiResponse) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      flights.clear();

      if (apiResponse['status'] != 200) {
        throw Exception(apiResponse['message'] ?? 'Failed to load flights');
      }

      final data = apiResponse['data'];
      final ondWiseFlights = data['ondWiseFlightCombinations'];

      // Check if this is a round trip (has both outbound and inbound flights)
      final isRoundTrip = ondWiseFlights.keys.length > 1;

      if (isRoundTrip) {
        // Handle round trip flights
        _processRoundTripFlights(ondWiseFlights);
      } else {
        // Handle one-way flights (original logic)
        _processOneWayFlights(ondWiseFlights);
      }

      // Apply margin to all flights
      _applyMarginToFlights();

      // Initialize filtered flights with all flights
      filteredFlights.value = List.from(flights);

      // Apply any existing filters immediately
      _applySortingAndFiltering();

    } catch (e) {
      errorMessage.value = 'Failed to load Air Arabia flights: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Apply margin to all loaded flights
  void _applyMarginToFlights() {
    if (marginData.value.isEmpty) {
      print('Warning: Margin data not loaded yet');
      return;
    }

    for (int i = 0; i < flights.length; i++) {
      final flight = flights[i];
      final priceWithMargin = calculateFlightPriceWithMargin(flight.price);
      
      // Update flight price with margin
      flights[i] = AirArabiaFlight(
        id: flight.id,
        price: priceWithMargin,
        currency: flight.currency,
        flightSegments: flight.flightSegments,
        airlineCode: flight.airlineCode,
        airlineName: flight.airlineName,
        airlineImg: flight.airlineImg,
        cabinClass: flight.cabinClass,
        isRefundable: flight.isRefundable,
        availabilityStatus: flight.availabilityStatus,
        isRoundTrip: flight.isRoundTrip,
        outboundFlight: flight.outboundFlight,
        inboundFlight: flight.inboundFlight,
      );
    }
    
    print('Applied margin to ${flights.length} flights');
  }

  void _processOneWayFlights(Map<String, dynamic> ondWiseFlights) {
    ondWiseFlights.forEach((route, dateWiseFlights) {
      final dateFlights = dateWiseFlights['dateWiseFlightCombinations'];
      dateFlights.forEach((date, flightData) {
        final flightOptions = flightData['flightOptions'];
        for (var option in flightOptions) {
          if (option['availabilityStatus'] == 'AVAILABLE') {
            try {
              final flight = AirArabiaFlight.fromJson(option);
              flights.add(flight);
            } catch (e) {
              // Skip invalid flight options
            }
          }
        }
      });
    });
  }

  void _processRoundTripFlights(Map<String, dynamic> ondWiseFlights) {
    final routes = ondWiseFlights.keys.toList();
    final outboundRoute = routes[1];
    
    final outboundFlights = <Map<String, dynamic>>[];
    final inboundFlights = <Map<String, dynamic>>[];

    ondWiseFlights.forEach((route, dateWiseFlights) {
      final dateFlights = dateWiseFlights['dateWiseFlightCombinations'];

      dateFlights.forEach((date, flightData) {
        final flightOptions = flightData['flightOptions'];
        for (var option in flightOptions) {
          if (option['availabilityStatus'] == 'AVAILABLE') {
            final isOutbound = route == outboundRoute;

            if (isOutbound) {
              outboundFlights.add(option);
            } else {
              inboundFlights.add(option);
            }
          }
        }
      });
    });

    if (outboundFlights.isEmpty || inboundFlights.isEmpty) {
      errorMessage.value = 'Incomplete round trip options available';
      return;
    }

    for (var outbound in outboundFlights) {
      outbound['isOutbound'] = true;
      for (var inbound in inboundFlights) {
        inbound['isOutbound'] = false;
        try {
          final combinedFlight = _createRoundTripPackage(outbound, inbound);
          flights.add(combinedFlight);
        } catch (e) {
          // Skip invalid combinations
        }
      }
    }
  }

  AirArabiaFlight _createRoundTripPackage(
      Map<String, dynamic> outbound,
      Map<String, dynamic> inbound
  ) {
    final combinedSegments = [
      ...outbound['flightSegments'],
      ...inbound['flightSegments']
    ];

    final outboundPrice = outbound['cabinPrices'][0]['price'] as num;
    final inboundPrice = inbound['cabinPrices'][0]['price'] as num;
    final totalPrice = outboundPrice + inboundPrice;

    final combinedOption = {
      ...outbound,
      'flightSegments': combinedSegments,
      'cabinPrices': [
        {
          ...outbound['cabinPrices'][0],
          'price': totalPrice,
        }
      ],
      'isRoundTrip': true,
      'outboundFlight': outbound,
      'inboundFlight': inbound,
    };

    return AirArabiaFlight.fromJson(combinedOption);
  }

  void handleAirArabiaFlightSelection(AirArabiaFlight flight) {
    Get.to(
      () => AirArabiaPackageSelectionDialog(
        flight: flight,
        isReturnFlight: false,
      ),
    );
  }

  void applyFilters({
    List<String>? airlines,
    List<String>? stops,
    String? sortType,
  }) {
    if (sortType != null) {
      this.sortType.value = sortType;
    }
    _applySortingAndFiltering(airlines: airlines, stops: stops);
  }

  void _applySortingAndFiltering({
    List<String>? airlines,
    List<String>? stops,
  }) {
    List<AirArabiaFlight> filtered = List.from(flights);

    if (airlines != null && !airlines.contains('all')) {
      filtered = filtered.where((flight) {
        return airlines.any((airlineCode) =>
            flight.airlineCode.toUpperCase() == airlineCode.toUpperCase()
        );
      }).toList();
    }

    if (stops != null && !stops.contains('all')) {
      filtered = filtered.where((flight) {
        int stopCount = flight.flightSegments.length - 1;

        if (stops.contains('nonstop')) {
          return stopCount == 0;
        }
        if (stops.contains('1stop')) {
          return stopCount == 1;
        }
        if (stops.contains('2stop')) {
          return stopCount == 2;
        }
        if (stops.contains('3stop')) {
          return stopCount == 3;
        }
        return false;
      }).toList();
    }

    switch (sortType.value) {
      case 'Cheapest':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Fastest':
        filtered.sort((a, b) => a.totalDuration.compareTo(b.totalDuration));
        break;
      case 'Suggested':
      default:
        break;
    }

    filteredFlights.value = filtered;
  }

  List<AirArabiaFlight> getFlightsByAirline(String airlineCode) {
    return flights.where((flight) {
      return flight.airlineCode.toUpperCase() == airlineCode.toUpperCase();
    }).toList();
  }

  int getFlightCountByAirline(String airlineCode) {
    return getFlightsByAirline(airlineCode).length;
  }

  List<FilterAirline> getAvailableAirlines() {
    if (flights.isEmpty) return [];

    return [
      FilterAirline(
        code: 'G9',
        name: 'Air Arabia',
        logoPath: 'https://images.kiwi.com/airlines/64/G9.png',
      )
    ];
  }
}