//Imports
import 'package:flutter/material.dart';
import 'package:jcsd_flutter/global_variables.dart'; //Stored  

//Pages for routine
import 'package:jcsd_flutter/view/users/login.dart';
import 'package:jcsd_flutter/view/generic/signup_first.dart';
import 'package:jcsd_flutter/view/generic/signup_second.dart';
import 'package:jcsd_flutter/view/employee/inventory.dart';
import 'package:jcsd_flutter/view/employee/bookings.dart';
import 'package:jcsd_flutter/view/employee/suppliers.dart';


void main() async {
  supabase_init(); //Initializing Supabase
  runApp(const MainApp());
}



class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JCSD',
      initialRoute: '/inventory',
      routes: {
        '/login': (context) => const Login(),
        '/signup1': (context) => const SignupPage1(),
        '/signup2': (context) => const SignupPage2(),
        '/inventory': (context) => const InventoryPage(),
        '/bookings': (context) => const BookingsPage(),
        '/suppliers': (context) => const SupplierPage(),
      },
    );
  }
}
