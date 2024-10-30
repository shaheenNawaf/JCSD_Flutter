//Imports
import 'package:flutter/material.dart';
import 'package:jcsd_flutter/view/error.dart';
import 'package:jcsd_flutter/global_variables.dart';

//Pages for routine
import 'package:jcsd_flutter/view/users/login.dart';
import 'package:jcsd_flutter/view/generic/signup_first.dart';
import 'package:jcsd_flutter/view/generic/signup_second.dart';
import 'package:jcsd_flutter/view/employee/inventory.dart';
import 'package:jcsd_flutter/view/employee/bookings.dart';
import 'package:jcsd_flutter/view/employee/suppliers.dart';
import 'package:jcsd_flutter/view/generic/homeView.dart';
import 'package:jcsd_flutter/view/employee/profile.dart';
import 'package:jcsd_flutter/view/employee/leaveRequest.dart';
import 'package:jcsd_flutter/view/employee/bookingDetail.dart';
import 'package:jcsd_flutter/view/employee/bookingReceipt.dart';
import 'package:jcsd_flutter/view/employee/payslip.dart';

void main() async {
  supabase_init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JCSD',
      initialRoute: '/payslip',
      routes: {
        '/home': (context) => const HomeView(),
        '/login': (context) => const Login(),
        '/signup1': (context) => const SignupPage1(),
        '/signup2': (context) => const SignupPage2(),
        '/inventory': (context) => const InventoryPage(),
        '/bookings': (context) => const BookingsPage(),
        '/suppliers': (context) => const SupplierPage(),
        '/profile': (context) => const ProfilePage(),
        '/leaveRequest': (context) => const LeaveRequest(),
        '/bookingDetail': (context) => const BookingDetails(),
        '/bookingReceipt': (context) => const BookingReceipt(),
        '/payslip': (context) => const Payslip(),
        '/error': (context) => const ErrorPage(),
      },
    );
  }
}
