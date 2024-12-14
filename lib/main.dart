import 'package:flutter/material.dart';
import 'package:phonepay/Phonepepayment.dart';
import 'try.dart';// Import your payment page

void main() {
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
      home: const HomePage(), // Home page where the button will be displayed
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the Phonepepayment page when the button is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Phonepepayment()),
            );
          },
          child: const Text('Go to Payment'),
        ),
      ),
    );
  }
}
