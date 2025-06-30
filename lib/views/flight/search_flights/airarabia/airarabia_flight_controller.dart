// airarabia_flight_controller.dart
import 'package:get/get.dart';

import '../../../../services/api_service_airarabia.dart';
import '../search_flight_utils/filter_flight_model.dart';
import 'airarabia_flight_model.dart';

class AirArabiaFlightController extends GetxController {
  final ApiServiceAirArabia apiService = Get.find<ApiServiceAirArabia>();

  final RxList<AirArabiaFlight> flights = <AirArabiaFlight>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  void clearFlights() {
    flights.clear();
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

      // Sort flights by price
      flights.sort((a, b) => a.price.compareTo(b.price));
    } catch (e) {
      errorMessage.value = 'Failed to load Air Arabia flights: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters(FlightFilter filter) {
    List<AirArabiaFlight> filtered = [...flights];

    // Filter by airlines (Air Arabia only)
    if (filter.selectedAirlines.isNotEmpty &&
        !filter.selectedAirlines.contains('G9')) {
      filtered = [];
    }

    // Filter by stops
    if (filter.maxStops != null) {
      filtered = filtered.where((flight) {
        return flight.flightSegments.length <= filter.maxStops! + 1;
      }).toList();
    }

    // Sort
    switch (filter.sortType) {
      case 'Cheapest':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Fastest':
        filtered.sort((a, b) => a.totalDuration.compareTo(b.totalDuration));
        break;
      default:
      // Suggested sorting (price ascending)
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
    }

    flights.value = filtered;
  }
}