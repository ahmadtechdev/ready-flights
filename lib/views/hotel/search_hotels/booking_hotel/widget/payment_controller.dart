import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ready_flights/views/hotel/search_hotels/booking_hotel/booking_voucher/booking_voucher.dart';
import 'package:ready_flights/views/hotel/search_hotels/booking_hotel/widget/abi_webview.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class PaymentController extends GetxController {
  var selectedTab = 0.obs;
  var selectedBank = ''.obs;
  var isProcessingPayment = false.obs;
  
  final List<String> banks = [
    'HBL Bank',
    'UBL Bank',
    'Allied Bank',
    'MCB Bank',
    'NBP Bank',
    'Standard Chartered',
    'Askari Bank',
    'Bank Alfalah',
    'Faysal Bank',
    'JS Bank',
  ];

  // Abhipay Configuration
  static const String abhipayBaseUrl = 'https://api.abhipay.com.pk/api/v3';
  static const String authToken = '35117073706643A79CEDB8B192E87F0E';
  
  Timer? _paymentPollingTimer;

  // Process Abhipay Payment - Fixed version
  Future<bool> processAbhipayPayment({
    required double amount,
    required String description,
    required String clientTransactionId,
    required String callbackUrl,
    String currency = 'PKR',
    String language = 'EN',
  }) async {
    try {
      isProcessingPayment.value = true;
      
      final requestData = {
        "amount": "5", // Use actual amount, not hardcoded "5"
        "language": language,
        "currency": currency,
        "description": description,
        "clientTransactionId": clientTransactionId,
        "callbackUrl": callbackUrl,
        "cardSave": false,
        "operation": "PURCHASE"
      };

      print('Abhipay Request: ${json.encode(requestData)}');

      final response = await http.post(
        Uri.parse('$abhipayBaseUrl/orders'),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      print('Abhipay Response Status: ${response.statusCode}');
      print('Abhipay Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        // Check if the response is successful
        if (responseData['code'] == '00000') {
          final paymentUrl = responseData['payload']?['paymentUrl'];
          final orderId = responseData['payload']?['orderId'];

          print('Payment URL: $paymentUrl');
          print('Order ID: $orderId');

          if (paymentUrl != null && paymentUrl.toString().isNotEmpty) {
            // Start background polling with orderId
            _startPaymentPolling(orderId);
            
            Get.to(() => AbhipayWebView(
              paymentUrl: paymentUrl,
              transactionId: clientTransactionId,
              onPaymentComplete: _stopPollingAndNavigate,
            ));

            return true;
          } else {
            print('Error: No payment URL in response');
            return false;
          }
        } else {
          print('Error: API returned error code: ${responseData['code']} - ${responseData['message']}');
          return false;
        }
      } else {
        print('Error: HTTP ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Payment Error: $e');
      return false;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  // Fixed polling - use orderId instead of clientTransactionId
  void _startPaymentPolling(String orderId) {
    print('Starting payment polling for Order ID: $orderId');
    
    _paymentPollingTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      try {
        final status = await _getPaymentStatus(orderId);
        print('Polling status for $orderId: $status');
        
        if (status != null) {
          if (status == 'APPROVED' || status == 'COMPLETED') {
            print('PAYMENT SUCCESS: Order ID = $orderId, Status = $status');
            timer.cancel();
            _navigateToSuccess(orderId);
          } else if (status == 'DECLINED' || status == 'FAILED' || status == 'CANCELLED') {
            print('PAYMENT FAILED: Order ID = $orderId, Status = $status');
            timer.cancel();
            _navigateToFailure();
          }
          // Continue polling for CREATED, PENDING, or other statuses
        }
      } catch (e) {
        print('Polling error: $e');
        // Continue polling on error
      }
    });

    // Stop polling after 10 minutes (increased timeout)
    Timer(Duration(minutes: 10), () {
      if (_paymentPollingTimer?.isActive == true) {
        print('Payment polling timeout for $orderId');
        _paymentPollingTimer?.cancel();
      }
    });
  }

  // Get payment status from API - use orderId
  Future<String?> _getPaymentStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$abhipayBaseUrl/orders/$orderId'),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Status check response: ${response.body}');
        
        if (responseData['code'] == '00000') {
          return responseData['payload']?['paymentStatus'];
        } else {
          print('Status check error: ${responseData['message']}');
          return null;
        }
      } else {
        print('Status check HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Status check exception: $e');
      return null;
    }
  }

  // Stop polling and handle navigation
  void _stopPollingAndNavigate(bool success) {
    print('Stopping polling, success: $success');
    _paymentPollingTimer?.cancel();
    
    if (success) {
      // Success already handled by WebView, just ensure polling stops
      print('Payment completed successfully via WebView');
    }
  }

  void _navigateToSuccess(String orderId) {
    if (!Get.currentRoute.contains('HotelBookingThankYouScreen')) {
      print('Navigating to success screen for Order ID: $orderId');
      Get.offAll(() => HotelBookingThankYouScreen(), arguments: {
        'paymentMethod': 'Card Payment (Abhipay)',
        'transactionId': orderId,
        'paymentStatus': 'Success',
      });
    }
  }

  void _navigateToFailure() {
    if (Get.currentRoute.contains('AbhipayWebView')) {
      Get.back();
      Get.snackbar(
        'Payment Failed',
        'Payment was not successful. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }

  // Verify payment status (manual check) - use orderId
  Future<Map<String, dynamic>?> verifyPaymentStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$abhipayBaseUrl/orders/$orderId'),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['code'] == '00000') {
          final status = data['payload']?['paymentStatus'];
          
          // Only print the essential success information
          if (status == 'APPROVED' || status == 'COMPLETED') {
            print('Payment Success - Order ID: $orderId - Status: $status');
          }
          
          return data;
        } else {
          print('Verify payment error: ${data['message']}');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Verify payment exception: $e');
      return null;
    }
  }

  @override
  void onClose() {
    _paymentPollingTimer?.cancel();
    super.onClose();
  }

  Future<void> _launchPaymentUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch payment URL';
      }
    } catch (e) {
      print('Error launching payment URL: $e');
      Get.snackbar(
        'Payment Error',
        'Could not open payment page',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }
}