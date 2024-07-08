import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
  "pk_test_51PZ6BoRqpq2yxnFzT3Y1lxm93jqAHi4WaoIwNUeHm4dKAoQHUguB4umaj0kGOkJHw60MsCx5SOrVjbEpcZIxU8Er00l4ByctDy";
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic>? paymentIntent;

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent();
      var gpay = const PaymentSheetGooglePay(
        merchantCountryCode: "US",
        currencyCode: "USD",
        testEnv: true,
      );
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!["client_secret"],
            style: ThemeMode.light,
            merchantDisplayName: "Talha Iqbal",
            googlePay: gpay,
          ));
      displayPaymentSheet();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful")),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent() async {
    try {
      Map<String, dynamic> body = {
        "amount": "1000",
        "currency": "USD",
      };

      http.Response response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: body,
        headers: {
          "Authorization":
          "Bearer sk_test_51PZ6BoRqpq2yxnFzhhYvIVIIwr5WIScCO4BQL1pvBbv8fZX0RLgbadsGJayQDZL3viAeyolxWw1splzrXmUcrGcW00aB66PMqy",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception("Failed to create payment intent: ${e.toString()}");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text("Okay"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            makePayment();
          },
          child: const Text('Pay Now'),
        ),
      ),
    );
  }
}
