import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml2json/xml2json.dart';

class PIAFlightApiService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> piaFlightAvailability({
    required String fromCity,
    required String toCity,
    required String departureDate,
    required int adultCount,
    required int childCount,
    required int infantCount,
    String tripType = 'ONE_WAY',
    String preferredCurrency = 'PKR',
    String preferredLanguage = 'PK',
    String? returnDate, // For round trips
    List<Map<String, String>>? multiCitySegments, // For multi-city trips
  }) async {
    try {
      // Build originDestinationInformationList based on trip type
      String originDestinationInfo = '';

      if (tripType == 'ONE_WAY') {
        originDestinationInfo = '''
        <originDestinationInformationList>
          <dateOffset>0</dateOffset>
          <departureDateTime>$departureDate</departureDateTime>
          <destinationLocation>
            <locationCode>$toCity</locationCode>
          </destinationLocation>
          <flexibleFaresOnly>false</flexibleFaresOnly>
          <includeInterlineFlights>false</includeInterlineFlights>
          <openFlight>false</openFlight>
          <originLocation>
            <locationCode>$fromCity</locationCode>
          </originLocation>
        </originDestinationInformationList>
        ''';
      }
      else if (tripType == 'ROUND_TRIP') {
        originDestinationInfo = '''
        <originDestinationInformationList>
          <dateOffset>0</dateOffset>
          <departureDateTime>$departureDate</departureDateTime>
          <destinationLocation>
            <locationCode>$toCity</locationCode>
          </destinationLocation>
          <flexibleFaresOnly>false</flexibleFaresOnly>
          <includeInterlineFlights>false</includeInterlineFlights>
          <openFlight>false</openFlight>
          <originLocation>
            <locationCode>$fromCity</locationCode>
          </originLocation>
        </originDestinationInformationList>
        <originDestinationInformationList>
          <dateOffset>0</dateOffset>
          <departureDateTime>${returnDate ?? departureDate}</departureDateTime>
          <destinationLocation>
            <locationCode>$fromCity</locationCode>
          </destinationLocation>
          <flexibleFaresOnly>false</flexibleFaresOnly>
          <includeInterlineFlights>false</includeInterlineFlights>
          <openFlight>false</openFlight>
          <originLocation>
            <locationCode>$toCity</locationCode>
          </originLocation>
        </originDestinationInformationList>
        ''';
      }
      else if (tripType == 'MULTI_DIRECTIONAL') {
        if (multiCitySegments != null && multiCitySegments.isNotEmpty) {
          for (var segment in multiCitySegments) {
            originDestinationInfo += '''
            <originDestinationInformationList>
              <dateOffset>0</dateOffset>
              <departureDateTime>${segment['date'] ?? departureDate}</departureDateTime>
              <destinationLocation>
                <locationCode>${segment['to'] ?? toCity}</locationCode>
              </destinationLocation>
              <flexibleFaresOnly>false</flexibleFaresOnly>
              <includeInterlineFlights>false</includeInterlineFlights>
              <openFlight>false</openFlight>
              <originLocation>
                <locationCode>${segment['from'] ?? fromCity}</locationCode>
              </originLocation>
            </originDestinationInformationList>
            ''';
          }
        } else {
          // Default multi-city if no segments provided
          originDestinationInfo = '''
          <originDestinationInformationList>
            <dateOffset>0</dateOffset>
            <departureDateTime>$departureDate</departureDateTime>
            <destinationLocation>
              <locationCode>$toCity</locationCode>
            </destinationLocation>
            <flexibleFaresOnly>false</flexibleFaresOnly>
            <includeInterlineFlights>false</includeInterlineFlights>
            <openFlight>false</openFlight>
            <originLocation>
              <locationCode>$fromCity</locationCode>
            </originLocation>
          </originDestinationInformationList>
          <originDestinationInformationList>
            <dateOffset>0</dateOffset>
            <departureDateTime>${DateTime.parse(departureDate).add(const Duration(days: 3)).toString().substring(0, 10)}</departureDateTime>
            <destinationLocation>
              <locationCode>LHE</locationCode>
            </destinationLocation>
            <flexibleFaresOnly>false</flexibleFaresOnly>
            <includeInterlineFlights>false</includeInterlineFlights>
            <openFlight>false</openFlight>
            <originLocation>
              <locationCode>$toCity</locationCode>
            </originLocation>
          </originDestinationInformationList>
          ''';
        }
      }

      // Build the XML request with dynamic parameters
      final request = '''
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:impl="http://impl.soap.ws.crane.hititcs.com/">
  <soapenv:Header/>
  <soapenv:Body>
    <impl:GetAvailability>
      <AirAvailabilityRequest>
        <clientInformation>
          <clientIP>127.0.0.1</clientIP>
          <member>false</member>
          <password>Pia123</password>
          <preferredCurrency>$preferredCurrency</preferredCurrency>
          <preferredLanguage>$preferredLanguage</preferredLanguage>
          <userName>PSA2746487</userName>
        </clientInformation>
        $originDestinationInfo
        <travelerInformation>
          <passengerTypeQuantityList>
            <hasStrecher/>
            <passengerType>
              <code>ADLT</code>
            </passengerType>
            <quantity>$adultCount</quantity>
          </passengerTypeQuantityList>
          <passengerTypeQuantityList>
            <hasStrecher/>
            <passengerType>
              <code>CHLD</code>
            </passengerType>
            <quantity>$childCount</quantity>
          </passengerTypeQuantityList>
          <passengerTypeQuantityList>
            <hasStrecher/>
            <passengerType>
              <code>INFT</code>
            </passengerType>
            <quantity>$infantCount</quantity>
          </passengerTypeQuantityList>
        </travelerInformation>
        <tripType>$tripType</tripType>
      </AirAvailabilityRequest>
    </impl:GetAvailability>
  </soapenv:Body>
</soapenv:Envelope>
''';

      // // Print the request in pretty format
      // debugPrint('=== PIA FLIGHT AVAILABILITY REQUEST ===');
      // _printXmlPretty(request);

      // Make the API call
      final response = await _dio.post(
        'https://app-stage.crane.aero/craneota/CraneOTAService',
        data: request,
        options: Options(
          contentType: 'text/xml; charset=utf-8',
          headers: {
            'SOAPAction': 'http://impl.soap.ws.crane.hititcs.com/GetAvailability',
            'Content-Type': 'text/xml; charset=utf-8',
          },
          responseType: ResponseType.plain,
        ),
      );

      // // Print the response in pretty format
      // debugPrint('=== PIA FLIGHT AVAILABILITY RESPONSE ===');
      // _printXmlPretty(response.data.toString());

      // Convert XML to Map if needed
      return _convertXmlToJson(response.data.toString());
    } catch (e) {
      debugPrint('Error checking PIA flight availability: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _convertXmlToJson(String xmlString) {
    try {
      final cleanedXml = xmlString.trim();
      final document = xml.XmlDocument.parse(cleanedXml);

      // For debugging - print the parsed XML structure
      debugPrint('Parsed XML structure: ${document.toXmlString(pretty: true)}');

      final transformer = Xml2Json();
      transformer.parse(cleanedXml);

      // Use Parker conversion which might be simpler for this structure
      final jsonString = transformer.toParker();
      final jsonResult = jsonDecode(jsonString) as Map<String, dynamic>;

      // Debug print the converted JSON
      debugPrint('Converted JSON: $jsonResult');

      return jsonResult;
    } catch (e, stackTrace) {
      debugPrint('Error converting XML to JSON: $e');
      debugPrint('Stack trace: $stackTrace');
      return {'error': 'Failed to parse XML response'};
    }
  }

  void _parseXmlElement(xml.XmlElement element, Map<String, dynamic> jsonMap) {
    for (final child in element.children) {
      if (child is xml.XmlElement) {
        if (child.children.length == 1 && child.children.first is xml.XmlText) {
          jsonMap[child.name.local] = child.text;
        } else {
          final childMap = <String, dynamic>{};
          _parseXmlElement(child, childMap);
          jsonMap[child.name.local] = childMap;
        }
      }
    }
  }

  void _printXmlPretty(String xmlString) {
    try {
      final document = xml.XmlDocument.parse(xmlString);
      final prettyXml = document.toXmlString(pretty: true, indent: '  ');
      const chunkSize = 800;
      for (var i = 0; i < prettyXml.length; i += chunkSize) {
        debugPrint(prettyXml.substring(
          i,
          i + chunkSize < prettyXml.length ? i + chunkSize : prettyXml.length,
        ));
      }
    } catch (e) {
      debugPrint('Could not pretty print XML: $e');
      debugPrint(xmlString);
    }
  }
}