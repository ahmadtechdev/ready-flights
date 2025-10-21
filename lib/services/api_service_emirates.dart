// services/api_service_emirates.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart' as xml;

class ApiServiceEmirates {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status! < 500,
    ),
  );

  Future<Map<String, dynamic>> searchFlights({
    required int type,
    required String origin,
    required String destination,
    required String depDate,
    required int adult,
    required int child,
    required int infant,
    required String cabin,
  }) async {
    try {
      List<String> origins = origin.split(',').where((e) => e.isNotEmpty).toList();
      List<String> destinations = destination.split(',').where((e) => e.isNotEmpty).toList();
      List<String> dates = depDate.split(',').where((e) => e.isNotEmpty).toList();

      String originDestinationsXml = '';
      for (int i = 0; i < origins.length; i++) {
        originDestinationsXml += '''
      <OriginDestination OriginDestinationKey="OD${i + 1}">
        <Departure>
          <AirportCode>${origins[i].toUpperCase()}</AirportCode>
          <Date>${dates[i]}</Date>
        </Departure>
        <Arrival>
          <AirportCode>${destinations[i].toUpperCase()}</AirportCode>
        </Arrival>
      </OriginDestination>''';
      }

      String sectorDetail = '';
      String cabinCode = cabin == 'Economy' ? 'Y' : cabin == 'Business' ? 'J' : 'F';
      
      for (int i = 0; i < origins.length; i++) {
        sectorDetail += '<OriginDestinationReferences>OD${i + 1}</OriginDestinationReferences>';
      }

      String passengerListXml = '';
      
      if (adult != 0) {
        for (int i = 1; i <= adult; i++) {
          passengerListXml += '''
      <Passenger PassengerID="T$i">
        <PTC>ADT</PTC>
      </Passenger>''';
          
          if (infant >= i) {
            passengerListXml += '''
      <Passenger PassengerID="T$i.1">
        <PTC>INF</PTC>
      </Passenger>''';
          }
        }
      }
      
      if (child != 0) {
        for (int j = 1; j <= child; j++) {
          int i = adult + j;
          passengerListXml += '''
      <Passenger PassengerID="T$i">
        <PTC>CNN</PTC>
      </Passenger>''';
        }
      }

      final xmlData = '''<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
  <SOAP-ENV:Header>
    <t:TransactionControl>
      <tc>
        <app version="5.0.0" language="en-US">SOAP</app>
        <iden u="emiratestoc" p="Trav3locityFSD" pseudocity="EPAO" agt="travelocityemir" agtpwd="Tocityv231elemirates" agy="27304023"/>
        <agent user="XXagentXX"/>
        <trace>EPAO_EK</trace>
        <script engine="FLXDM" name="Travelocity-ek-dispatch.flxdm"/>
      </tc>
    </t:TransactionControl>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    <ns1:XXTransaction>
      <REQ>
        <AirShoppingRQ Version="17.2" TransactionIdentifier="${_generateTransactionId()}">
          <Document id="document"/>
          <Party>
            <Sender>
              <TravelAgencySender>
                <PseudoCity>EPAO</PseudoCity>
                <AgencyID>27304023</AgencyID>
              </TravelAgencySender>
            </Sender>
          </Party>
          <CoreQuery>
            <OriginDestinations>$originDestinationsXml
            </OriginDestinations>
          </CoreQuery>
          <Preference>
            <FarePreferences>
              <Types>
                <Type>70J</Type>
                <Type>749</Type>
              </Types>
              <Exclusion>
                <NoMinStayInd>false</NoMinStayInd>
                <NoMaxStayInd>false</NoMaxStayInd>
                <NoAdvPurchaseInd>false</NoAdvPurchaseInd>
                <NoPenaltyInd>false</NoPenaltyInd>
              </Exclusion>
            </FarePreferences>
            <CabinPreferences>
              <CabinType>
                <Code>$cabinCode</Code>
                $sectorDetail
              </CabinType>
            </CabinPreferences>
          </Preference>
          <DataLists>
            <PassengerList>$passengerListXml
            </PassengerList>
          </DataLists>
        </AirShoppingRQ>
      </REQ>
    </ns1:XXTransaction>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>''';

      final headers = {
        'Ocp-Apim-Subscription-Key': '46b329e56e9f462183e1ca68e9f95fd8',
        'SOAPAction': 'AirShoppingRQ',
        'Agency': 'travelocityemir',
        'IATA': '27304023',
        'PCC': 'EPAO',
        'apiTraceId': '77d1147a-e370-16e4-d5db-24cf01b61f19',
        'clientIp': '91.108.109.86',
        'contEnc': '',
        'agencyName': '',
        'Content-Type': 'application/xml',
      };

      print("===============================================");
      print("EMIRATES SOAP REQUEST");
      print("===============================================");
      print("URL: https://ek.farelogix.com:443/sandbox-uat/oc");
      print("Headers:");
      headers.forEach((key, value) {
        print("  $key: $value");
      });
      print("XML Body:");
      print(xmlData);
      print("===============================================");

      final response = await _dio.request(
        'https://ek.farelogix.com:443/sandbox-uat/oc',
        options: Options(
          method: 'POST',
          headers: headers,
          responseType: ResponseType.plain,
        ),
        data: xmlData,
      );

      print("===============================================");
      print("EMIRATES SOAP RESPONSE - RAW XML");
      print("===============================================");
      print("Status Code: ${response.statusCode}");
      print("Response Length: ${response.data.toString().length} characters");
      print("===============================================");
      
      // Print the entire raw XML response in chunks
      _printLargeText(response.data.toString(), "RAW XML RESPONSE");
      
      print("===============================================");

      if (response.statusCode == 200) {
        print("✅ Emirates response received - Starting parsing...");
        var data = _parseXmlResponse(response.data.toString());
        
        // Print the parsed structured data
        print("\n===============================================");
        print("PARSED STRUCTURED DATA (JSON FORMAT)");
        print("===============================================");
        printJsonPretty(data);
        print("===============================================\n");
        
        return data;
      } else {
        throw Exception('Failed to load Emirates flights: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('===============================================');
      print('ERROR IN EMIRATES API');
      print('===============================================');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      print('===============================================');
      
      return {
        'success': false,
        'error': 'Error: ${e.toString()}',
      };
    }
  }
            
  // Helper method to print large text in chunks
  void _printLargeText(String text, String label) {
    const int chunkSize = 800; // Android Studio console limit per print
    final int length = text.length;
    
    print("📄 $label (Total: $length characters)");
    print("───────────────────────────────────────────────");
    
    for (int i = 0; i < length; i += chunkSize) {
      final end = (i + chunkSize < length) ? i + chunkSize : length;
      final chunk = text.substring(i, end);
      print(chunk);
    }
    
    print("───────────────────────────────────────────────");
    print("✅ End of $label\n");
  }

  String _generateTransactionId() {
    return DateTime.now().millisecondsSinceEpoch.toRadixString(16);
  }

  Map<String, dynamic> _parseXmlResponse(String xmlResponse) {
    try {
      print('=== PARSING XML RESPONSE ===');
      print('XML Length: ${xmlResponse.length} characters');
      print('===========================');
      
      if (xmlResponse.contains('<Error>') || xmlResponse.contains('error')) {
        print('⚠️ Error detected in XML response');
        return {
          'success': false,
          'error': 'Emirates API returned an error',
          'raw_xml': xmlResponse,
        };
      }
      
      // Parse XML
      print('📋 Parsing XML document...');
      final document = xml.XmlDocument.parse(xmlResponse);
      print('✅ XML document parsed successfully');
      
      // Extract the structured data we need
      print('🔍 Extracting structured data...');
      final structuredData = _extractStructuredData(document);
      
      print('✅ Structured data extracted successfully');
      print('Found ${structuredData['offers']?.length ?? 0} offers');
      
      // Print detailed offer information
      if (structuredData['offers'] != null) {
        print('\n🎫 OFFERS SUMMARY:');
        print('─────────────────────────────────────');
        final offers = structuredData['offers'] as List;
        for (int i = 0; i < offers.length; i++) {
          print('Offer ${i + 1}/${offers.length}:');
          print('  OfferID: ${offers[i]['OfferID'] ?? 'N/A'}');
          print('  Total Price: ${_extractTotalPrice(offers[i])}');
          print('  OfferItems: ${_countOfferItems(offers[i])}');
        }
        print('─────────────────────────────────────\n');
      }
      
      return {
        'success': true,
        'data': structuredData,
        'raw_xml': xmlResponse,
        'message': 'XML successfully parsed',
      };
    } catch (e, stackTrace) {
      print('❌ ERROR parsing XML: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'error': 'Failed to parse XML response: $e',
        'raw_xml': xmlResponse,
      };
    }
  }

  String _extractTotalPrice(Map<String, dynamic> offer) {
    try {
      if (offer['TotalPrice'] != null) {
        final totalPrice = offer['TotalPrice'];
        if (totalPrice is Map && totalPrice['SimpleCurrencyPrice'] != null) {
          final price = totalPrice['SimpleCurrencyPrice'];
          if (price is Map) {
            return '${price['Code'] ?? ''} ${price['\$t'] ?? price['value'] ?? ''}';
          }
        }
      }
      return 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  int _countOfferItems(Map<String, dynamic> offer) {
    try {
      if (offer['OfferItem'] != null) {
        final offerItem = offer['OfferItem'];
        if (offerItem is List) {
          return offerItem.length;
        } else if (offerItem is Map) {
          return 1;
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Map<String, dynamic> _extractStructuredData(xml.XmlDocument document) {
    final result = <String, dynamic>{};
    
    try {
      print('🔎 Looking for AirShoppingRS element...');
      // Navigate to AirShoppingRS
      final airShoppingRS = document.findAllElements('AirShoppingRS').firstOrNull;
      
      if (airShoppingRS == null) {
        print('❌ AirShoppingRS not found');
        return result;
      }
      print('✅ AirShoppingRS found');

      // Extract DataLists first (needed for offer enrichment)
      print('📊 Extracting DataLists...');
      final dataLists = _extractDataLists(airShoppingRS);
      result['DataLists'] = dataLists;
      print('✅ DataLists extracted');
      
      // Print DataLists summary
      print('\n📋 DATA LISTS SUMMARY:');
      print('─────────────────────────────────────');
      if (dataLists['FlightSegmentList'] != null) {
        final segments = dataLists['FlightSegmentList']['FlightSegment'];
        print('Flight Segments: ${segments is Map ? segments.length : 0}');
      }
      if (dataLists['BaggageAllowanceList'] != null) {
        final baggage = dataLists['BaggageAllowanceList']['BaggageAllowance'];
        print('Baggage Allowances: ${baggage is Map ? baggage.length : 0}');
      }
      if (dataLists['PriceClassList'] != null) {
        final priceClasses = dataLists['PriceClassList']['PriceClass'];
        print('Price Classes: ${priceClasses is Map ? priceClasses.length : 0}');
      }
      print('─────────────────────────────────────\n');
      
      // Extract Offers
      print('🎯 Extracting Offers...');
      final offersGroup = airShoppingRS.findElements('OffersGroup').firstOrNull;
      if (offersGroup != null) {
        final airlineOffers = offersGroup.findElements('AirlineOffers').firstOrNull;
        if (airlineOffers != null) {
          final offers = <Map<String, dynamic>>[];
          
          for (var offerElement in airlineOffers.findElements('Offer')) {
            final offer = _extractOffer(offerElement, dataLists);
            offers.add(offer);
          }
          
          result['offers'] = offers;
          print('✅ Extracted ${offers.length} offers');
        } else {
          print('⚠️ AirlineOffers not found');
        }
      } else {
        print('⚠️ OffersGroup not found');
      }
      
    } catch (e, stackTrace) {
      print('❌ Error extracting structured data: $e');
      print('Stack trace: $stackTrace');
    }
    
    return result;
  }

  Map<String, dynamic> _extractDataLists(xml.XmlElement airShoppingRS) {
    final dataLists = <String, dynamic>{};
    
    try {
      final dataListsElement = airShoppingRS.findElements('DataLists').firstOrNull;
      if (dataListsElement == null) return dataLists;

      // Extract FlightSegmentList
      final flightSegmentList = <String, dynamic>{};
      final flightSegments = dataListsElement.findElements('FlightSegmentList').firstOrNull;
      if (flightSegments != null) {
        for (var segment in flightSegments.findElements('FlightSegment')) {
          final segmentKey = segment.getAttribute('SegmentKey') ?? '';
          flightSegmentList[segmentKey] = _xmlElementToMap(segment);
        }
      }
      dataLists['FlightSegmentList'] = {'FlightSegment': flightSegmentList};

      // Extract BaggageAllowanceList
      final baggageList = <String, dynamic>{};
      final baggageAllowances = dataListsElement.findElements('BaggageAllowanceList').firstOrNull;
      if (baggageAllowances != null) {
        for (var baggage in baggageAllowances.findElements('BaggageAllowance')) {
          final baggageId = baggage.getAttribute('BaggageAllowanceID') ?? '';
          baggageList[baggageId] = _xmlElementToMap(baggage);
        }
      }
      dataLists['BaggageAllowanceList'] = {'BaggageAllowance': baggageList};

      // Extract PriceClassList
      final priceClassList = <String, dynamic>{};
      final priceClasses = dataListsElement.findElements('PriceClassList').firstOrNull;
      if (priceClasses != null) {
        for (var priceClass in priceClasses.findElements('PriceClass')) {
          final priceClassId = priceClass.getAttribute('PriceClassID') ?? '';
          priceClassList[priceClassId] = _xmlElementToMap(priceClass);
        }
      }
      dataLists['PriceClassList'] = {'PriceClass': priceClassList};

      // Extract PassengerList
      final passengerList = dataListsElement.findElements('PassengerList').firstOrNull;
      if (passengerList != null) {
        dataLists['PassengerList'] = _xmlElementToMap(passengerList);
      }

      // Extract FlightList
      final flightList = dataListsElement.findElements('FlightList').firstOrNull;
      if (flightList != null) {
        dataLists['FlightList'] = _xmlElementToMap(flightList);
      }

    } catch (e) {
      print('Error extracting DataLists: $e');
    }
    
    return dataLists;
  }

  Map<String, dynamic> _extractOffer(xml.XmlElement offerElement, Map<String, dynamic> dataLists) {
    final offer = _xmlElementToMap(offerElement);
    
    // Add DataLists reference to the offer for easy access
    offer['DataLists'] = dataLists;
    
    return offer;
  }

  Map<String, dynamic> _xmlElementToMap(xml.XmlElement element) {
    final map = <String, dynamic>{};
    
    // Add attributes
    for (var attr in element.attributes) {
      map[attr.name.local] = attr.value;
    }
    
    // Process child elements
    final childElements = element.children.whereType<xml.XmlElement>();
    
    for (var child in childElements) {
      final key = child.name.local;
      final value = _processXmlNode(child);
      
      if (map.containsKey(key)) {
        // Handle multiple elements with same name
        if (map[key] is List) {
          (map[key] as List).add(value);
        } else {
          map[key] = [map[key], value];
        }
      } else {
        map[key] = value;
      }
    }
    
    // If no children, add text content
    if (childElements.isEmpty && element.text.trim().isNotEmpty) {
      map['\$t'] = element.text.trim();
    }
    
    return map;
  }

  dynamic _processXmlNode(xml.XmlElement element) {
    final childElements = element.children.whereType<xml.XmlElement>();
    
    if (childElements.isEmpty) {
      // Leaf node - return text or map with attributes
      if (element.attributes.isEmpty) {
        return element.text.trim();
      } else {
        final map = <String, dynamic>{};
        for (var attr in element.attributes) {
          map[attr.name.local] = attr.value;
        }
        if (element.text.trim().isNotEmpty) {
          map['\$t'] = element.text.trim();
        }
        return map;
      }
    } else {
      // Has children - return as map
      return _xmlElementToMap(element);
    }
  }

  List<Map<String, dynamic>> extractOffersFromResponse(Map<String, dynamic> response) {
    final offers = <Map<String, dynamic>>[];
    
    try {
      debugPrint('🔍 Extracting offers from response...');
      
      // Get the data from the response
      final data = response['data'] ?? response;
      
      // Check if we have the offers array
      if (data.containsKey('offers') && data['offers'] is List) {
        final offersList = data['offers'] as List;
        debugPrint('✅ Found ${offersList.length} offers in structured data');
        
        for (var offer in offersList) {
          if (offer is Map<String, dynamic>) {
            offers.add(offer);
          }
        }
      } else {
        debugPrint('⚠️ No offers found in structured format, trying alternative extraction...');
        // Fallback to deep search
        offers.addAll(_deepSearchOffers(data));
      }
      
      debugPrint('📦 Total offers extracted: ${offers.length}');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error extracting offers: $e');
      debugPrint('Stack trace: $stackTrace');
    }
    
    return offers;
  }

  List<Map<String, dynamic>> _deepSearchOffers(Map<String, dynamic> data) {
    final offers = <Map<String, dynamic>>[];
    
    void search(dynamic obj, [String path = '']) {
      if (obj is Map) {
        obj.forEach((key, value) {
          final currentPath = path.isEmpty ? key : '$path.$key';
          
          if (key == 'Offer' || key == 'offer') {
            debugPrint('🎯 Found offer at path: $currentPath');
            if (value is Map) {
              offers.add(Map<String, dynamic>.from(value));
            } else if (value is List) {
              for (var item in value) {
                if (item is Map) {
                  offers.add(Map<String, dynamic>.from(item));
                }
              }
            }
          } else {
            search(value, currentPath);
          }
        });
      } else if (obj is List) {
        for (var item in obj) {
          search(item, path);
        }
      }
    }
    
    search(data);
    debugPrint('🔍 Deep search found ${offers.length} offers');
    return offers;
  }

  void printJsonPretty(dynamic jsonData) {
    const int chunkSize = 800;
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    final int totalLength = jsonString.length;
    
    print('📊 JSON Output (Total: $totalLength characters)');
    print('═══════════════════════════════════════════════');
    
    for (int i = 0; i < totalLength; i += chunkSize) {
      final chunk = jsonString.substring(
        i,
        i + chunkSize < totalLength ? i + chunkSize : totalLength,
      );
      if (kDebugMode) {
        print(chunk);
      }
    }
    
    print('═══════════════════════════════════════════════');
    print('✅ End of JSON Output\n');
  }
  // Add this method to your existing ApiServiceEmirates class

// Update the createEmiratesNdcPnr method in api_service_emirates.dart
// Replace the XML building section with this corrected version:

Future<Map<String, dynamic>> createEmiratesNdcPnr({
  required String offerId,
  required Map<String, dynamic> offerData,
  required dynamic bookingController,
  required int passengerCount,
}) async {
  try {
    debugPrint('\n🎫 === CREATING EMIRATES NDC PNR ===');
    debugPrint('Offer ID: $offerId');
    debugPrint('Passenger Count: $passengerCount');
    
    // ✅ CRITICAL: Extract ResponseID - Check multiple locations
    String responseId = '';
    
    // First try: Direct ResponseID field (injected by controller)
   
    // Second try: ShoppingResponseID structure
   if (offerData['ShoppingResponseID'] != null) {
      responseId = offerData['ShoppingResponseID']['ResponseID']?.toString() ?? '';
      debugPrint('✅ Found ResponseID in ShoppingResponseID: $responseId');
    }
    // Third try: Extract from OfferID prefix (fallback)
    else if (offerData['OfferID'] != null) {
      final offerIdStr = offerData['OfferID'].toString();
      final offerIdParts = offerIdStr.split('-');
      if (offerIdParts.isNotEmpty) {
        responseId = offerIdParts[0];
        debugPrint('⚠️ Using OfferID prefix as ResponseID: $responseId');
      }
    }
    
    if (responseId.isEmpty) {
      debugPrint('❌ CRITICAL ERROR: ResponseID is missing!');
      debugPrint('OfferData keys: ${offerData.keys}');
      return {
        'success': false,
        'error': 'Missing ResponseID in offer data. This is required for PNR creation.',
      };
    }

    // ✅ CRITICAL: Extract real OfferItemID from offerData
    String offerItemId = '';
    List<Map<String, dynamic>> offerItems = [];
    
    try {
      final offerItem = offerData['OfferItem'];
      if (offerItem != null) {
        if (offerItem is List) {
          // Multiple offer items
          for (var item in offerItem) {
            final itemId = item['OfferItemID']?.toString() ?? '';
            final passengerRefs = item['PassengerRefs']?.toString() ?? '';
            if (itemId.isNotEmpty) {
              offerItems.add({
                'id': itemId,
                'passengerRefs': passengerRefs,
              });
            }
          }
        } else if (offerItem is Map) {
          // Single offer item
          final itemId = offerItem['OfferItemID']?.toString() ?? '';
          final passengerRefs = offerItem['PassengerRefs']?.toString() ?? '';
          if (itemId.isNotEmpty) {
            offerItems.add({
              'id': itemId,
              'passengerRefs': passengerRefs,
            });
          }
        }
      }
      
      if (offerItems.isNotEmpty) {
        offerItemId = offerItems.first['id']!;
        debugPrint('✅ Extracted OfferItemID: $offerItemId');
        debugPrint('Found ${offerItems.length} offer item(s)');
      } else {
        // Fallback: use OfferID with -1 suffix
        offerItemId = '$offerId-1';
        debugPrint('⚠️ Using fallback OfferItemID: $offerItemId');
      }
      
    } catch (e) {
      offerItemId = '$offerId-1';
      debugPrint('⚠️ Error extracting OfferItemID, using fallback: $e');
    }
    
    // Build passenger list XML with proper infant linking (matching PHP logic)
    String passengerListXml = '';
    int passengerIndex = 1;
    
    // Add adults with infant references
    for (int i = 0; i < bookingController.adults.length; i++) {
      final adult = bookingController.adults[i];
      
      // Check if this adult has an infant
      String infantRef = '';
      String infantDetails = '';
      
      if (i < bookingController.infants.length) {
        final infant = bookingController.infants[i];
        
        // Create infant passenger (exactly like PHP)
        infantDetails = '''
                    <Passenger PassengerID="T$passengerIndex.1">
                        <PTC>INF</PTC>
                        <ResidenceCountryCode>${infant.nationalityCountry.value?.countryCode ?? 'PK'}</ResidenceCountryCode>
                        <Individual>
                            <Birthdate>${infant.dateOfBirthController.text}</Birthdate>
                            <Gender>${infant.genderController.text}</Gender>
                            <GivenName>${infant.firstNameController.text}</GivenName>
                            <Surname>${infant.lastNameController.text}</Surname>
                        </Individual>
                    </Passenger>''';
        
        // Add infant reference to adult
        infantRef = '<InfantRef>T$passengerIndex.1</InfantRef>';
      }
      
      // Create adult passenger (exactly like PHP)
      passengerListXml += '''
                <Passenger PassengerID="T$passengerIndex">
                         <PTC>ADT</PTC>
                         <ResidenceCountryCode>${adult.nationalityCountry.value?.countryCode ?? 'PK'}</ResidenceCountryCode>
                         <Individual>
                             <Birthdate>${adult.dateOfBirthController.text}</Birthdate>
                             <Gender>${adult.genderController.text}</Gender>
                             <NameTitle>${adult.titleController.text}</NameTitle>
                             <GivenName>${adult.firstNameController.text}</GivenName>
                             <Surname>${adult.lastNameController.text}</Surname>
                         </Individual>''';
      
      // Add ContactInfoRef only for first adult (exactly like PHP)
      if (i == 0) {
        passengerListXml += '''
                         <ContactInfoRef>CID1</ContactInfoRef>''';
      }
      
      passengerListXml += '''
                         $infantRef
                     </Passenger>''';
      
      // Add infant details after adult
      passengerListXml += infantDetails;
      
      passengerIndex++;
    }
    
    // Add children (exactly like PHP)
    for (int i = 0; i < bookingController.children.length; i++) {
      final child = bookingController.children[i];
      passengerListXml += '''
                <Passenger PassengerID="T$passengerIndex">
                         <PTC>CNN</PTC>
                         <ResidenceCountryCode>${child.nationalityCountry.value?.countryCode ?? 'PK'}</ResidenceCountryCode>
                         <Individual>
                             <Birthdate>${child.dateOfBirthController.text}</Birthdate>
                             <Gender>${child.genderController.text}</Gender>
                             <NameTitle>${child.titleController.text}</NameTitle>
                             <GivenName>${child.firstNameController.text}</GivenName>
                             <Surname>${child.lastNameController.text}</Surname>
                         </Individual> 
                     </Passenger>''';
      passengerIndex++;
    }
    
    // Build passenger refs (T1 T2 T3...)
    String passengerRefs = '';
    for (int i = 1; i <= passengerCount; i++) {
      passengerRefs += i == 1 ? 'T$i' : ' T$i';
    }
    
    
    // Extract owner
    final owner = offerData['Owner']?.toString() ?? 'EK';
    
    debugPrint('\n📋 PNR Creation Parameters:');
    debugPrint('  OfferID: $offerId');
    debugPrint('  OfferItemID: $offerItemId');
    debugPrint('  Owner: $owner');
    debugPrint('  ResponseID: $responseId');
    debugPrint('  PassengerRefs: $passengerRefs');
    debugPrint('  Total Passengers: $passengerCount');
    
    // ✅ VERIFIED: Using exact PHP credentials and structure
    final xmlData = '''<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
                                 <SOAP-ENV:Header>
                                    <t:TransactionControl>
                                       <tc>
                                            <app version="5.0.0" language="en-US">SOAP</app> 
                                            <iden u="emiratesfaizan" p="Fai1ZanDaska" pseudocity="ESNV" agt="faizemir" agtpwd="Fai231elemirates" agtrole="Ticketing Agent" agy="27323671"/>
                                            <agent user="faizemir"/>
                                            <trace admin="Y">ESNV_ek</trace>
                                            <script engine="FLXDM" name="FaizanAfzal_ToursandTravels-ek-dispatch.flxdm"/>
                                        </tc>
                                    </t:TransactionControl>
                         </SOAP-ENV:Header>
                         <SOAP-ENV:Body>
                         <ns1:XXTransaction>
                        <REQ> 
                           <OrderCreateRQ Version="17.2" TransactionIdentifier="${_generateTransactionId()}">
                          <Document id="document"/>
                          <Party>
                              <Sender>
                                <TravelAgencySender>
                                 <PseudoCity>ESNV</PseudoCity>
                                 <AgencyID>27323671</AgencyID>
                                </TravelAgencySender>
                               </Sender>
                          </Party>
                          
                          <Query>
                           <Order>
                              <Offer OfferID="$offerId" Owner="$owner" ResponseID="$responseId">
                                <OfferItem OfferItemID="$offerItemId">
                                  <PassengerRefs>$passengerRefs</PassengerRefs>
                                </OfferItem>
                              </Offer>
                          </Order>
                            <Commission>
                                <Amount Code="PKR">0</Amount>
                            </Commission>
                            <DataLists>
                                <PassengerList>
                                     $passengerListXml
                                </PassengerList>
                                <ContactList>
                                     <ContactInformation ContactID="CID1">
                                         <PostalAddress>
                                             <Label>AddressAtDestination</Label>
                                             <Street>123 STREET</Street>
                                             <PostalCode>33160</PostalCode>
                                             <CityName>MIAMI</CityName>
                                             <CountrySubdivisionName>FL</CountrySubdivisionName>
                                             <CountryCode>US</CountryCode>
                                         </PostalAddress>
                                         <ContactProvided>
                                             <EmailAddress>
                                             <Label>Personal</Label>
                                             <EmailAddressValue>${bookingController.emailController.text}</EmailAddressValue>
                                             </EmailAddress>
                                         </ContactProvided>
                                         <ContactProvided>
                                             <Phone>
                                             <Label>Home</Label>
                                             <CountryDialingCode>${bookingController.bookerPhoneCountry.value?.phoneCode ?? '92'}</CountryDialingCode>
                                             <PhoneNumber>${bookingController.phoneController.text}</PhoneNumber>
                                             </Phone>
                                         </ContactProvided>
                                     </ContactInformation>
                                </ContactList>
                            </DataLists>
                            <Metadata> 
                            </Metadata>
                         </Query>
                            </OrderCreateRQ>
                         </REQ>
                         </ns1:XXTransaction>
                         </SOAP-ENV:Body>
                        </SOAP-ENV:Envelope>''';

    // ✅ VERIFIED: Using exact PHP headers
    final headers = {
      'Ocp-Apim-Subscription-Key': '7bdbbd0e3a8c4f939b3370dddbabf1a4',
      'SOAPAction': 'OrderCreateRQ',
      'Agency': 'faizemir',
      'IATA': '27323671',
      'PCC': 'ESNV',
      'apiTraceId': '77d1147a-e370-16e4-d5db-24cf01b61f19',
      'clientIp': '91.108.109.86',
      'contEnc': '',
      'agencyName': '',
      'Content-Type': 'application/xml',
    };

    debugPrint("\n===============================================");
    debugPrint("EMIRATES PNR CREATION REQUEST");
    debugPrint("===============================================");
    debugPrint("URL: https://ek.farelogix.com:443/sandbox-uat/oc");
    debugPrint("\nHeaders:");
    headers.forEach((key, value) {
      debugPrint("  $key: $value");
    });
    debugPrint("\nXML Body:");
    _printLargeText(xmlData, "PNR REQUEST XML");
    debugPrint("===============================================\n");

    // ✅ VERIFIED: Using exact PHP URL
    final response = await _dio.request(
      'https://ek.farelogix.com:443/sandbox-uat/oc',
      options: Options(
        method: 'POST',
        headers: headers,
        responseType: ResponseType.plain,
        validateStatus: (status) => status! < 600,
      ),
      data: xmlData,
    );

    debugPrint("\n===============================================");
    debugPrint("EMIRATES PNR CREATION RESPONSE");
    debugPrint("===============================================");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Response Length: ${response.data.toString().length} characters");
    
    _printLargeText(response.data.toString(), "PNR RESPONSE XML");
    debugPrint("===============================================\n");

    if (response.statusCode == 200) {
      final parsedResponse = _parsePnrResponse(response.data.toString());
      
      debugPrint("\n📋 === PNR PARSING RESULT ===");
      debugPrint("Success: ${parsedResponse['success']}");
      if (parsedResponse['success']) {
        debugPrint("PNR: ${parsedResponse['pnr']}");
        debugPrint("Order ID: ${parsedResponse['orderId']}");
        debugPrint("Total Price: ${parsedResponse['totalPrice']}");
      } else {
        debugPrint("Error: ${parsedResponse['error']}");
      }
      debugPrint("============================\n");
      
      return parsedResponse;
    } else {
      debugPrint("\n❌ SERVER ERROR RESPONSE:");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Response: ${response.data}");
      
      return {
        'success': false,
        'error': 'Server error ${response.statusCode}: ${response.data}',
      };
    }
  } catch (e, stackTrace) {
    debugPrint('❌ ERROR creating Emirates PNR: $e');
    debugPrint('Stack trace: $stackTrace');
    return {
      'success': false,
      'error': 'Error: ${e.toString()}',
    };
  }
}Map<String, dynamic> _parsePnrResponse(String xmlResponse) {
  try {
    final document = xml.XmlDocument.parse(xmlResponse);
    
    // Check for errors first
    final errors = document.findAllElements('Error');
    if (errors.isNotEmpty) {
      final errorMsg = errors.first.text;
      return {
        'success': false,
        'error': errorMsg,
      };
    }
    
    // Look for OrderViewRS
    final orderViewRS = document.findAllElements('OrderViewRS').firstOrNull;
    if (orderViewRS == null) {
      return {
        'success': false,
        'error': 'OrderViewRS not found in response',
      };
    }
    
    // Extract Success element
    final success = orderViewRS.findElements('Success').firstOrNull;
    if (success == null) {
      return {
        'success': false,
        'error': 'Success element not found in response',
      };
    }
    
    // Extract Order information
    final response = orderViewRS.findElements('Response').firstOrNull;
    if (response == null) {
      return {
        'success': false,
        'error': 'Response element not found',
      };
    }
    
    final order = response.findElements('Order').firstOrNull;
    if (order == null) {
      return {
        'success': false,
        'error': 'Order element not found',
      };
    }
    
    // Extract PNR from BookingReferences
    String pnr = '';
    final bookingReferences = order.findElements('BookingReferences').firstOrNull;
    if (bookingReferences != null) {
      for (var bookingRef in bookingReferences.findElements('BookingReference')) {
        final airlineId = bookingRef.findElements('AirlineID').firstOrNull;
        if (airlineId != null) {
          final id = bookingRef.findElements('ID').firstOrNull;
          if (id != null) {
            pnr = id.text;
            break;
          }
        }
      }
    }
    
    // Extract Order ID
    final orderId = order.getAttribute('OrderID') ?? '';
    
    // Extract Total Price
    String totalPrice = '';
    String currency = '';
    final totalOrderPrice = order.findElements('TotalOrderPrice').firstOrNull;
    if (totalOrderPrice != null) {
      final detailCurrencyPrice = totalOrderPrice.findElements('DetailCurrencyPrice').firstOrNull;
      if (detailCurrencyPrice != null) {
        final total = detailCurrencyPrice.findElements('Total').firstOrNull;
        if (total != null) {
          totalPrice = total.text;
          currency = total.getAttribute('Code') ?? '';
        }
      }
    }
    
    return {
      'success': true,
      'pnr': pnr,
      'orderId': orderId,
      'totalPrice': totalPrice,
      'currency': currency,
      'rawResponse': xmlResponse,
    };
  } catch (e, stackTrace) {
    debugPrint('❌ Error parsing PNR response: $e');
    debugPrint('Stack trace: $stackTrace');
    return {
      'success': false,
      'error': 'Failed to parse PNR response: $e',
    };
  }
}
// Add this method to ApiServiceEmirates class
Future<Map<String, dynamic>> refreshEmiratesOffer({
  required String offerId,
  required String responseId,
  required Map<String, dynamic> originalOfferData,
}) async {
  try {
    debugPrint('\n🔄 === REFRESHING EMIRATES OFFER ===');
    debugPrint('OfferID: $offerId');
    debugPrint('ResponseID: $responseId');

    final xmlData = '''<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
  <SOAP-ENV:Header>
    <t:TransactionControl>
      <tc>
        <app version="5.0.0" language="en-US">SOAP</app>
        <iden u="emiratesfaizan" p="Fai1ZanDaska" pseudocity="ESNV" agt="faizemir" agtpwd="Fai231elemirates" agtrole="Ticketing Agent" agy="27323671"/>
        <agent user="faizemir"/>
        <trace admin="Y">ESNV_ek</trace>
        <script engine="FLXDM" name="FaizanAfzal_ToursandTravels-ek-dispatch.flxdm"/>
      </tc>
    </t:TransactionControl>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    <ns1:XXTransaction>
      <REQ>
        <OfferPriceRQ Version="17.2" TransactionIdentifier="${_generateTransactionId()}">
          <Document id="document"/>
          <Party>
            <Sender>
              <TravelAgencySender>
                <PseudoCity>ESNV</PseudoCity>
                <AgencyID>27323671</AgencyID>
              </TravelAgencySender>
            </Sender>
          </Party>
          <Query>
            <Offer OfferID="$offerId" Owner="EK" ResponseID="$responseId"/>
          </Query>
        </OfferPriceRQ>
      </REQ>
    </ns1:XXTransaction>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>''';

    final headers = {
      'Ocp-Apim-Subscription-Key': '7bdbbd0e3a8c4f939b3370dddbabf1a4',
      'SOAPAction': 'OfferPriceRQ',
      'Agency': 'faizemir',
      'IATA': '27323671',
      'PCC': 'ESNV',
      'apiTraceId': '77d1147a-e370-16e4-d5db-24cf01b61f19',
      'clientIp': '91.108.109.86',
      'contEnc': '',
      'agencyName': '',
      'Content-Type': 'application/xml',
    };

    debugPrint('Sending OfferPriceRQ to refresh offer...');

    final response = await _dio.request(
      'https://ek.farelogix.com:443/sandbox-uat/oc',
      options: Options(
        method: 'POST',
        headers: headers,
        responseType: ResponseType.plain,
        validateStatus: (status) => status! < 600,
      ),
      data: xmlData,
    );

    debugPrint('Status: ${response.statusCode}');
    _printLargeText(response.data.toString(), "OFFER REFRESH RESPONSE");

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.data.toString());
      
      // Check for errors
      final errors = document.findAllElements('Error');
      if (errors.isNotEmpty) {
        final errorMsg = errors.first.text;
        debugPrint('❌ Offer refresh failed: $errorMsg');
        return {
          'success': false,
          'error': errorMsg,
        };
      }

      // Parse refreshed offer
      final offerPriceRS = document.findAllElements('OfferPriceRS').firstOrNull;
      if (offerPriceRS != null) {
        final priceOffer = offerPriceRS.findElements('PricedOffer').firstOrNull;
        if (priceOffer != null) {
          final refreshedOfferData = _xmlElementToMap(priceOffer);
          
          debugPrint('✅ Offer refreshed successfully!');
          debugPrint('New OfferID: ${refreshedOfferData['OfferID']}');
          
          return {
            'success': true,
            'offerData': refreshedOfferData,
            'message': 'Offer refreshed successfully',
          };
        }
      }

      return {
        'success': false,
        'error': 'Could not parse refreshed offer',
      };
    } else {
      return {
        'success': false,
        'error': 'Server error ${response.statusCode}',
      };
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error refreshing offer: $e');
    debugPrint('Stack trace: $stackTrace');
    return {
      'success': false,
      'error': 'Error: ${e.toString()}',
    };
  }
}
}