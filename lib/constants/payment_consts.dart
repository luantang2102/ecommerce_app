import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentConsts {
  static String get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  static String get stripeSecretKey => dotenv.env['STRIPE_SECRET_KEY']!;
}