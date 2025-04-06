import 'package:ecommerce_app/constants/payment_consts.dart';
import 'package:ecommerce_app/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

// Import các service và model
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/cart_service.dart';

// Import các màn hình
import 'screens/client/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables from .env file
    await dotenv.load(fileName: ".env");
    print("Environment variables loaded: ${dotenv.env}");
  } catch (e) {
    print("Error loading .env file: $e");
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up Stripe publishable key
  await _setupStripe();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ProductService>(create: (_) => ProductService()),
        Provider<CartService>(create: (_) => CartService()),
        Provider<OrderService>(create: (_) => OrderService()),
      ],
      child: EcommerceApp(),
    ),
  );
}

Future<void> _setupStripe() async {
  // Retrieve the Stripe publishable key from PaymentConsts
  Stripe.publishableKey = PaymentConsts.stripePublishableKey;

  // Optionally, set additional Stripe configurations
  Stripe.merchantIdentifier = 'merchant.flutter.ecommerce';
  Stripe.instance.applySettings();
}

class EcommerceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
      },
    );
  }
}