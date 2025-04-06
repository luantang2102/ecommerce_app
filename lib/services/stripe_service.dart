import 'package:dio/dio.dart';
import 'package:ecommerce_app/constants/payment_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<PaymentResult> makePayment({
    required String name, 
    required double amount, 
    String currency = "vnd"
  }) async {
    try {
      // For VND, Stripe requires whole numbers (no decimal)
      final amountInCents = amount.toInt();

      // Create payment intent
      final paymentIntent = await _createPaymentIntent(amountInCents, currency);
      
      if (paymentIntent == null) {
        return PaymentResult(
          success: false, 
          message: "Không thể tạo thanh toán"
        );
      }

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent,
          merchantDisplayName: name,
          style: ThemeMode.light,
        )
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      return PaymentResult(
        success: true, 
        message: "Thanh toán thành công"
      );
    } on StripeException catch (e) {
      // Handle specific Stripe exceptions
      return PaymentResult(
        success: false, 
        message: e.error.message ?? "Thanh toán Stripe thất bại"
      );
    } catch (e) {
      // Handle any other unexpected errors
      return PaymentResult(
        success: false, 
        message: "Đã xảy ra lỗi: $e"
      );
    }
  }
  
  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      
      // Prepare request data
      final data = {
        "amount": amount,
        "currency": currency,
      };

      // Retrieve the secret key from PaymentConsts
      final stripeSecretKey = PaymentConsts.stripeSecretKey;

      // Make API call to Stripe
      final response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType, 
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": "application/x-www-form-urlencoded"
          }
        )
      );

      // Extract and return client secret
      return response.data?["client_secret"];
    } on DioException catch (e) {
      // Log and handle Dio-specific errors
      debugPrint('Lỗi tạo thanh toán: ${e.response?.data}');
      return null;
    } catch (e) {
      // Handle any other unexpected errors
      debugPrint('Lỗi không mong muốn khi tạo thanh toán: $e');
      return null;
    }
  }
}

// Custom result class to provide more detailed payment feedback
class PaymentResult {
  final bool success;
  final String message;

  PaymentResult({
    required this.success, 
    required this.message
  });
}