// controllers/emirates_flight_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ready_flights/views/flight/search_flights/emirates_ndc/emirates_model.dart';
import 'package:ready_flights/services/api_service_emirates.dart';
import 'package:ready_flights/views/flight/search_flights/flight_package/emirates_ndc/emirates_ndc_package.dart';
import '../filters/filter_flight_model.dart';

class EmiratesFlightController extends GetxController {
  // Store ALL flights with their complete offer data
  final RxMap<String, EmiratesFlight> _allFlights = <String, EmiratesFlight>{}.obs;

  // Filtered list showing flights based on filters
  final RxList<EmiratesFlight> filteredFlights = <EmiratesFlight>[].obs;

  // Keep flights getter for backward compatibility
  RxList<EmiratesFlight> get flights => filteredFlights;

  // Selected flights
  EmiratesFlight? selectedOutboundFlight;
  EmiratesFarePackage? selectedOutboundPackage;

  // Loading state
  final RxBool isLoading = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  final RxString sortType = 'Suggested'.obs;

  void clearFlights() {
    _allFlights.clear();
    filteredFlights.clear();
    errorMessage.value = '';
    selectedOutboundFlight = null;
    selectedOutboundPackage = null;
  }

  void setErrorMessage(String message) {
    errorMessage.value = message;
  }

  void loadFlights(Map<String, dynamic> response, {String? searchOrigin, String? searchDestination}) {
     try {
    isLoading.value = true;
    errorMessage.value = '';
    _allFlights.clear();
    filteredFlights.clear();

    debugPrint('\n=== PARSING EMIRATES RESPONSE ===');
    
    if (response.containsKey('error')) {
      setErrorMessage(response['error'].toString());
      return;
    }

    final data = response['data'] ?? response;
    
    // ✅ Extract ResponseID from root level
    String shoppingResponseId = '';
    if (data['AirShoppingRS'] != null) {
      final shoppingRS = data['AirShoppingRS'];
      final shopRespId = shoppingRS['ShoppingResponseID'];
      if (shopRespId != null) {
        shoppingResponseId = shopRespId['ResponseID']?.toString() ?? '';
        debugPrint('✅ Found ShoppingResponseID: $shoppingResponseId');
      }
    }

    // Navigate to offers
    dynamic offersData;
    
    if (data['offers'] != null) {
      offersData = data['offers'];
    } else if (data['AirShoppingRS'] != null) {
      final airShoppingRS = data['AirShoppingRS'];
      final offersGroup = airShoppingRS['OffersGroup'];
      if (offersGroup != null) {
        final airlineOffers = offersGroup['AirlineOffers'];
        if (airlineOffers != null) {
          offersData = airlineOffers['Offers']; // ✅ CHANGED FROM 'Offer' to 'Offers'
        }
      }
    }

    List<dynamic> offersList = [];
    if (offersData is List) {
      offersList = offersData;
    } else if (offersData is Map) {
      offersList = [offersData];
    }
    
    debugPrint('📦 Total offers found: ${offersList.length}');

    if (offersList.isEmpty) {
      setErrorMessage('No flights found');
      return;
    }

    // Get DataLists
    Map<String, dynamic> dataLists = {};
    if (data['AirShoppingRS'] != null) {
      dataLists = data['AirShoppingRS']['DataLists'] ?? {};
    }

    int flightCount = 0;
    int skippedCount = 0;
    
    for (int i = 0; i < offersList.length; i++) {
      try {
        var offerData = offersList[i];
        if (offerData is! Map<String, dynamic>) continue;
        
        // ✅ Inject ResponseID into each offer
        offerData = Map<String, dynamic>.from(offerData);
        offerData['ResponseID'] = shoppingResponseId;
        
        if (!offerData.containsKey('DataLists') && dataLists.isNotEmpty) {
          offerData['DataLists'] = dataLists;
        }
        
        final flight = EmiratesFlight.fromJson(offerData, searchOrigin: searchOrigin, searchDestination: searchDestination);
        
        final uniqueKey = '${flight.offerId}-${flight.priceClassName}';
        
        if (!_allFlights.containsKey(uniqueKey)) {
          _allFlights[uniqueKey] = flight;
          flightCount++;
        } else {
          skippedCount++;
        }
        
      } catch (e, stackTrace) {
        debugPrint('❌ Error processing offer ${i + 1}: $e');
        skippedCount++;
      }
    }
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      debugPrint('\n📊 STORAGE SUMMARY:');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('Total offers received: ${offersList.length}');
      debugPrint('Successfully stored: $flightCount');
      debugPrint('Skipped (duplicates): $skippedCount');
      debugPrint('Total in storage: ${_allFlights.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      // Print all stored keys for verification
      debugPrint('🗂️  ALL STORED KEYS:');
      _allFlights.keys.forEach((key) {
        final flight = _allFlights[key]!;
        debugPrint('  - $key');
        debugPrint('    └─ ${flight.priceClassName} @ ${flight.currency} ${flight.price.toStringAsFixed(0)}');
      });
      debugPrint('');

      // Group flights by physical flight (date/time/number) for display
      Map<String, List<EmiratesFlight>> groupedByFlight = {};
      
      _allFlights.forEach((key, flight) {
        // Group by actual flight schedule (not price class)
        final flightKey = '${flight.departureDate}|${flight.departureTime}|${flight.flightNumber}|'
            '${flight.legSchedules.first['departure']['airport']}|'
            '${flight.legSchedules.last['arrival']['airport']}';
        
        if (!groupedByFlight.containsKey(flightKey)) {
          groupedByFlight[flightKey] = [];
        }
        groupedByFlight[flightKey]!.add(flight);
      });

      debugPrint('\n🛫 FLIGHT GROUPING:');
      debugPrint('Physical flights found: ${groupedByFlight.length}');
      
      // For display: show the lowest-priced option for each physical flight
      List<EmiratesFlight> displayFlights = [];
      groupedByFlight.forEach((flightKey, priceOptions) {
        debugPrint('\nFlight: $flightKey');
        debugPrint('  Price options available: ${priceOptions.length}');
        
        // Sort by price and show the cheapest (real price)
        priceOptions.sort((a, b) => a.price.compareTo(b.price));
        displayFlights.add(priceOptions.first);
        
        // Debug: show all price options
        for (var opt in priceOptions) {
          debugPrint('    - ${opt.priceClassName}: ${opt.currency} ${opt.price.toStringAsFixed(0)}');
        }
      });

      // Sort display flights by departure time
      displayFlights.sort((a, b) {
        final dateCompare = a.departureDate.compareTo(b.departureDate);
        if (dateCompare != 0) return dateCompare;
        return a.departureTime.compareTo(b.departureTime);
      });

      filteredFlights.assignAll(displayFlights);

      debugPrint('\n🎉 FINAL RESULTS:');
      debugPrint('Flights to display: ${filteredFlights.length}');
      debugPrint('Total price options stored: ${_allFlights.length}');
      debugPrint('Each flight has ${_allFlights.length} package options available');
      debugPrint('================================\n');

    } catch (e, stackTrace) {
      debugPrint('💥 Error loading Emirates flights: $e');
      debugPrint('Stack trace: $stackTrace');
      setErrorMessage('Failed to load Emirates flights: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Get all fare packages for a specific physical flight
  List<EmiratesFarePackage> getFarePackagesForFlight(EmiratesFlight flight) {
    try {
      debugPrint('\n=== GETTING PACKAGES FOR FLIGHT ===');
      debugPrint('Flight Number: EK-${flight.flightNumber}');
      debugPrint('Date: ${flight.departureDate}');
      debugPrint('Time: ${flight.departureTime}');
      debugPrint('Route: ${flight.legSchedules.first['departure']['airport']} → ${flight.legSchedules.last['arrival']['airport']}');
      debugPrint('Total stored flights: ${_allFlights.length}');

      List<EmiratesFarePackage> packages = [];
      Map<String, EmiratesFlight> uniquePackages = {};

      // Create the flight key for matching
      final targetFlightKey = '${flight.departureDate}|${flight.departureTime}|${flight.flightNumber}|'
          '${flight.legSchedules.first['departure']['airport']}|'
          '${flight.legSchedules.last['arrival']['airport']}';

      debugPrint('\nSearching for matching flights...');
      debugPrint('Target flight key: $targetFlightKey');

      // Search through ALL stored flights
      int matchCount = 0;
      _allFlights.forEach((key, storedFlight) {
        // Build the same key format for comparison
        final storedFlightKey = '${storedFlight.departureDate}|${storedFlight.departureTime}|${storedFlight.flightNumber}|'
            '${storedFlight.legSchedules.first['departure']['airport']}|'
            '${storedFlight.legSchedules.last['arrival']['airport']}';

        debugPrint('\nComparing with: $key');
        debugPrint('  Stored key: $storedFlightKey');
        debugPrint('  Price Class: ${storedFlight.priceClassName}');
        debugPrint('  Match: ${storedFlightKey == targetFlightKey ? "✓" : "✗"}');

        // Match if same physical flight
        if (storedFlightKey == targetFlightKey) {
          matchCount++;
          
          // Use offer ID + price class as unique identifier
          final packageKey = '${storedFlight.offerId}-${storedFlight.priceClassName}';
          
          // Only add if we haven't seen this exact offer yet
          if (!uniquePackages.containsKey(packageKey)) {
            uniquePackages[packageKey] = storedFlight;
            debugPrint('  ✓ ADDED: ${storedFlight.priceClassName} - ${storedFlight.currency} ${storedFlight.price.toStringAsFixed(0)}');
          } else {
            debugPrint('  ⚠️ SKIPPED: Duplicate ${storedFlight.priceClassName}');
          }
        }
      });

      debugPrint('\n📊 MATCHING RESULTS:');
      debugPrint('Total matches found: $matchCount');
      debugPrint('Unique packages: ${uniquePackages.length}');

      // Convert to packages (using real price)
      uniquePackages.forEach((packageKey, flightData) {
        packages.add(EmiratesFarePackage(
          name: flightData.priceClassName,
          code: flightData.fareBasisCode,
          price: flightData.price,
          basePrice: flightData.basePrice,
          taxAmount: flightData.taxAmount,
          currency: flightData.currency,
          isRefundable: flightData.isRefundable,
          cabinName: flightData.cabinName,
          checkedWeight: flightData.baggageAllowance.weight,
          checkedUnit: flightData.baggageAllowance.unit,
          carryOnPieces: 1,
          amenities: flightData.amenities,
          offerId: flightData.offerId,
          rawFlightData: flightData.rawData,
        ));
      });

      // Sort packages by price
      packages.sort((a, b) => a.price.compareTo(b.price));

      debugPrint('\n✅ PACKAGES READY (Total: ${packages.length}):');
      for (int i = 0; i < packages.length; i++) {
        debugPrint('  ${i + 1}. ${packages[i].name}');
        debugPrint('     Price: ${packages[i].currency} ${packages[i].price.toStringAsFixed(0)}');
        debugPrint('     Base: ${packages[i].currency} ${packages[i].basePrice.toStringAsFixed(0)}');
        debugPrint('     Tax: ${packages[i].currency} ${packages[i].taxAmount.toStringAsFixed(0)}');
        debugPrint('     Cabin: ${packages[i].cabinName}');
        debugPrint('     Baggage: ${packages[i].checkedWeight} ${packages[i].checkedUnit}');
        debugPrint('     Refundable: ${packages[i].isRefundable ? "Yes" : "No"}');
      }
      debugPrint('================================\n');

      return packages;

    } catch (e, stackTrace) {
      debugPrint('❌ Error getting fare packages: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  // Handle flight selection - show package selection dialog
  void handleEmiratesFlightSelection(EmiratesFlight flight) {
    debugPrint('\n🎯 Flight selected: EK-${flight.flightNumber}');
    debugPrint('Opening package selection dialog...\n');
    
    // Open package selection dialog
    Get.to(() => EmiratesPackageSelectionDialog(
      flight: flight,
      isReturnFlight: false,
      segmentIndex: 0,
      isMultiCity: false,
    ));
  }

  // Handle package selection
  void handlePackageSelection(EmiratesFlight flight, EmiratesFarePackage package) {
    selectedOutboundFlight = flight;
    selectedOutboundPackage = package;

    debugPrint('\n✅ Package selected:');
    debugPrint('  ${package.name}');
    debugPrint('  ${package.currency} ${package.price.toStringAsFixed(0)}\n');
    
    // TODO: Navigate to review/booking page
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
    // Group by physical flight
    Map<String, List<EmiratesFlight>> groupedByFlight = {};
    
    _allFlights.forEach((key, flight) {
      final flightKey = '${flight.departureDate}|${flight.departureTime}|${flight.flightNumber}|'
          '${flight.legSchedules.first['departure']['airport']}|'
          '${flight.legSchedules.last['arrival']['airport']}';
      
      if (!groupedByFlight.containsKey(flightKey)) {
        groupedByFlight[flightKey] = [];
      }
      groupedByFlight[flightKey]!.add(flight);
    });

    // Get lowest price for each physical flight (real price)
    List<EmiratesFlight> allDisplayFlights = [];
    groupedByFlight.forEach((flightKey, priceOptions) {
      if (priceOptions.isNotEmpty) {
        priceOptions.sort((a, b) => a.price.compareTo(b.price));
        allDisplayFlights.add(priceOptions.first);
      }
    });

    List<EmiratesFlight> filtered = List.from(allDisplayFlights);

    // Apply airline filter
    if (airlines != null && !airlines.contains('all')) {
      filtered = filtered.where((flight) {
        return airlines.any((airlineCode) =>
            flight.airlineCode.toUpperCase() == airlineCode.toUpperCase());
      }).toList();
    }

    // Apply stops filter
    if (stops != null && !stops.contains('all')) {
      filtered = filtered.where((flight) {
        int stopCount = flight.legSchedules.length - 1;
        if (stops.contains('nonstop')) return stopCount == 0;
        if (stops.contains('1stop')) return stopCount == 1;
        if (stops.contains('2stop')) return stopCount == 2;
        return false;
      }).toList();
    }

    // Apply sorting (using real price)
    switch (sortType.value) {
      case 'Cheapest':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Fastest':
        filtered.sort((a, b) {
          final aDuration = a.legSchedules.fold(0, (sum, leg) => sum + (leg['elapsedTime'] as int));
          final bDuration = b.legSchedules.fold(0, (sum, leg) => sum + (leg['elapsedTime'] as int));
          return aDuration.compareTo(bDuration);
        });
        break;
      case 'Suggested':
      default:
        filtered.sort((a, b) {
          final dateCompare = a.departureDate.compareTo(b.departureDate);
          if (dateCompare != 0) return dateCompare;
          return a.departureTime.compareTo(b.departureTime);
        });
        break;
    }

    filteredFlights.assignAll(filtered);
  }

  List<EmiratesFlight> getFlightsByAirline(String airlineCode) {
    return filteredFlights.where((flight) {
      return flight.airlineCode.toUpperCase() == airlineCode.toUpperCase();
    }).toList();
  }

  int getFlightCountByAirline(String airlineCode) {
    return getFlightsByAirline(airlineCode).length;
  }

  List<FilterAirline> getAvailableAirlines() {
    if (filteredFlights.isEmpty) return [];
    return [
      FilterAirline(
        code: 'EK',
        name: 'Emirates',
        logoPath: 'https://images.kiwi.com/airlines/64/EK.png',
      )
    ];
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('Emirates Flight Controller initialized');
  }

  @override
  void onClose() {
    clearFlights();
    super.onClose();
  }

  // Debug method to inspect stored flights
  void debugPrintStoredFlights() {
    debugPrint('\n=== STORED FLIGHTS DEBUG ===');
    debugPrint('Total stored: ${_allFlights.length}\n');
    
    debugPrint('All stored keys:');
    _allFlights.keys.forEach((key) {
      debugPrint('  - $key');
    });
    debugPrint('');
    
    Map<String, List<String>> grouped = {};
    
    _allFlights.forEach((key, flight) {
      final groupKey = '${flight.departureDate} ${flight.departureTime} EK-${flight.flightNumber}';
      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = [];
      }
      grouped[groupKey]!.add('${flight.priceClassName} (${flight.currency} ${flight.price.toStringAsFixed(0)}) [${flight.offerId}]');
    });
    
    debugPrint('Grouped by flight:');
    grouped.forEach((dateTimeFlight, priceClasses) {
      debugPrint('$dateTimeFlight:');
      for (var pc in priceClasses) {
        debugPrint('  - $pc');
      }
      debugPrint('');
    });
    
    debugPrint('===========================\n');
  }
}

class EmiratesFarePackage {
  final String name;
  final String code;
  final double price;
  final double basePrice;
  final double taxAmount;
  final String currency;
  final bool isRefundable;
  final String cabinName;
  final double checkedWeight;
  final String checkedUnit;
  final int carryOnPieces;
  final List<String> amenities;
  final String offerId;
  final Map<String, dynamic> rawFlightData;

  EmiratesFarePackage({
    required this.name,
    required this.code,
    required this.price,
    required this.basePrice,
    required this.taxAmount,
    required this.currency,
    required this.isRefundable,
    required this.cabinName,
    required this.checkedWeight,
    required this.checkedUnit,
    required this.carryOnPieces,
    required this.amenities,
    required this.offerId,
    required this.rawFlightData,
  });
}