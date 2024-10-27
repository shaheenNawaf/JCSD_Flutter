import 'package:flutter/material.dart';
import 'package:jcsd_flutter/view/error.dart';
import 'package:jcsd_flutter/view/homeView.dart';
import 'package:jcsd_flutter/view/login.dart';
import 'package:jcsd_flutter/view/signup_first.dart';
import 'package:jcsd_flutter/view/signup_second.dart';
import 'package:jcsd_flutter/view/inventory.dart';
import 'package:jcsd_flutter/view/bookings.dart';
import 'package:jcsd_flutter/view/suppliers.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JCSD',
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeView(),
        '/login': (context) => const Login(),
        '/signup1': (context) => const SignupPage1(),
        '/signup2': (context) => const SignupPage2(),
        '/inventory': (context) => const InventoryPage(),
        '/bookings': (context) => const BookingsPage(),
        '/suppliers': (context) => const SupplierPage(),
        '/error': (context) => const ErrorPage(),
      },
    );
  }
}
