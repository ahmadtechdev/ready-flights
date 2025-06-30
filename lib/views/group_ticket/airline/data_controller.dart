import 'package:get/get.dart';
import '../../../../services/api_service_group_tickets.dart';
import '../sector_model.dart';
import 'airline_model.dart';

class TravelDataController extends GetxController {
  // Observable lists
  final RxList<Airline> airlines = <Airline>[].obs;
  final RxList<Sector> sectors = <Sector>[].obs;
  final RxBool isLoading = true.obs;

  // Instance of the API controller
  final GroupTicketingController apiController = Get.put(
    GroupTicketingController(),
  );

  @override
  void onInit() {
    super.onInit();
    // You can uncomment this if you want to load data automatically when controller initializes
    // loadAllData();
  }

  // Modification for data_controller.dart

  Future<void> loadAirlines() async {
    try {
      // Use combined airlines method
      final List<dynamic> airlineData =
          await apiController.fetchCombinedAirlinesLogos();
      print("Combined airline data received: ${airlineData.length} airlines");

      airlines.value =
          airlineData
              .map((item) {
                // Ensure item is a Map<String, dynamic>
                if (item is Map<String, dynamic>) {
                  try {
                    return Airline.fromJson(item);
                  } catch (e) {
                    print('Error parsing airline: $e');
                    print('Item data: $item');
                    return null;
                  }
                } else {
                  print('Invalid airline data type: ${item.runtimeType}');
                  return null;
                }
              })
              .whereType<Airline>()
              .toList(); // Filter out null values

      print("Processed airlines: ${airlines.length}");
    } catch (e) {
      print('Error loading airlines: $e');
    }
  }

  // Method to load sectors
  Future<void> loadSectors() async {
    try {
      final List<dynamic> sectorData = await apiController.fetchSectors();
      print("Sector data received: $sectorData");

      sectors.value =
          sectorData
              .map((item) {
                // Handle string or map
                if (item is String) {
                  return Sector.fromString(item);
                } else {
                  print('Invalid sector data type: ${item.runtimeType}');
                  return null;
                }
              })
              .whereType<Sector>()
              .toList(); // Filter out null values

      print("Processed sectors: ${sectors.length}");
    } catch (e) {
      print('Error loading sectors: $e');
    }
  }

  // Get airline by ID
  Airline? getAirlineById(int id) {
    // loadAirlines();
    print("id check:");
    print(airlines);
    try {
      return airlines.firstWhere((airline) => airline.id == id);
    } catch (e) {
      print('Airline with ID $id not found');
      return null;
    }
  }

  // Get sector by name
  Sector? getSectorByName(String name) {
    try {
      return sectors.firstWhere((sector) => sector.name == name);
    } catch (e) {
      print('Sector with name $name not found');
      return null;
    }
  }
}
