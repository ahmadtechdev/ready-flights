import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service_group_tickets.dart';
import '../airline/data_controller.dart';
import 'pkg_model.dart';

class FlightPKGController extends GetxController {
  final GroupTicketingController apiController = Get.put(
    GroupTicketingController(),
  );
  final TravelDataController travelController = Get.put(TravelDataController());

  // Observables
  final RxString selectedSector = 'all'.obs;
  final RxString selectedAirline = 'all'.obs;
  final RxString selectedDate = 'all'.obs;
  final RxList<dynamic> groupFlights = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Formatters
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  final DateFormat displayFormatter = DateFormat('dd MMM yyyy');

  // Dynamic sector options based on available flights
  RxList<Map<String, String>> get sectorOptions {
    // Extract unique sectors from groupFlights
    final sectors = <String>{};

    for (final flight in groupFlights) {
      final sector = flight['sector']?.toString().toLowerCase();
      if (sector != null && sector.isNotEmpty) {
        sectors.add(sector);
      }
    }

    // Convert to the format needed for options
    final options =
        sectors.map((sector) {
          // Convert from "lahore-dammam" to "Lahore-Dammam" for display
          final displayName = sector
              .split('-')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join('-');

          return {'label': displayName, 'value': sector};
        }).toList();

    // Add the "All" option and sort alphabetically
    options.insert(0, {'label': 'All Sectors', 'value': 'all'});
    options.sort((a, b) => a['label']!.compareTo(b['label']!));

    return options.obs;
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      await Future.wait([travelController.loadAirlines(), fetchGroupFlights()]);
    } catch (e) {
      errorMessage.value = 'Failed to load data: ${e.toString()}';
    }
  }

  // Modification for pkg_controller.dart

  Future<void> fetchGroupFlights() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Use the stored selected region
      final region = apiController.selectedRegion.value;
      final region2 = apiController.selectedRegion2.value;

      print("FlightPKGController fetching flights for region: $region");

      // Use the combined method instead of just fetchGroups
      final response = await apiController.fetchCombinedGroups(region, region2);

      print("Got ${response.length} combined flights for region: $region");
      groupFlights.assignAll(response);
    } catch (e) {
      errorMessage.value = 'Failed to load flights: ${e.toString()}';
      print("Error in fetchGroupFlights: $e");
      groupFlights.clear();
    } finally {
      isLoading.value = false;
    }
  }

  GroupFlightModel convertToFlightModel(dynamic groupFlight) {
    final airline = groupFlight['airline'] ?? {};
    final int airlineId = airline['id'] ?? 0;
    String logoUrl = _getDefaultLogoUrl();

    // Try to get airline details if ID is available
    if (airlineId != 0) {
      final matchedAirline = travelController.getAirlineById(airlineId);
      if (matchedAirline != null) {
        logoUrl =
            matchedAirline.logoUrl.isNotEmpty
                ? matchedAirline.logoUrl
                : _getDefaultLogoUrl();
      }
    }

    final flightDetails = groupFlight['details']?.first ?? {};

    return GroupFlightModel(
      id: flightDetails['id'],
      airline: airline['airline_name'] ?? 'Unknown Airline',
      sector: airline['sector'] ?? 'Unknown sector',
      shortName: airline['short_name'] ?? '',
      groupPriceDetailId: groupFlight['group_price_detail_id'] ?? '',
      departure: _parseDate(groupFlight['dept_date']),
      departureTime: flightDetails['dept_time'] ?? '',
      arrivalTime: flightDetails['arv_time'] ?? '',
      origin: flightDetails['origin'] ?? '',
      destination: flightDetails['destination'] ?? '',
      flightNumber: flightDetails['flight_no'] ?? '',
      price: groupFlight['price'] ?? 0,
      seats: flightDetails['seats'] ?? 0,
      hasLayover: false,
      baggage: flightDetails['baggage'] ?? '',
      logoUrl: logoUrl,
    );
  }

  DateTime _parseDate(String dateString) {
    try {
      return dateFormatter.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  String _getDefaultLogoUrl() {
    return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==';
  }

  RxList<GroupFlightModel> get filteredFlights {
    return groupFlights
        .where((groupFlight) {
          final sector = groupFlight['sector']?.toString().toLowerCase() ?? '';
          final airlineName =
              groupFlight['airline']?['airline_name']
                  ?.toString()
                  .toLowerCase() ??
              '';
          final flightDate = groupFlight['dept_date']?.toString() ?? '';

          bool sectorMatch =
              selectedSector.value == 'all' ||
              sector.contains(selectedSector.value.toLowerCase());

          bool airlineMatch =
              selectedAirline.value == 'all' ||
              airlineName.contains(selectedAirline.value.toLowerCase());

          bool dateMatch =
              selectedDate.value == 'all' || flightDate == selectedDate.value;

          return sectorMatch && airlineMatch && dateMatch;
        })
        .map((groupFlight) => convertToFlightModel(groupFlight))
        .toList()
        .obs;
  }

  // Filter update methods
  void updateSector(String sector) => selectedSector.value = sector;
  void updateAirline(String airline) => selectedAirline.value = airline;
  void updateDate(String date) => selectedDate.value = date;
  void resetFilters() {
    selectedSector.value = 'all';
    selectedAirline.value = 'all';
    selectedDate.value = 'all';
  }
}
