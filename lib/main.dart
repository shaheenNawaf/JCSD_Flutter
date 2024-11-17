// Imports
import 'package:flutter/material.dart';
import 'package:jcsd_flutter/others/transition.dart';
import 'package:jcsd_flutter/view/admin/accountdetails.dart';
import 'package:jcsd_flutter/view/admin/leaverequestlist.dart';
import 'package:jcsd_flutter/view/admin/payroll.dart';
import 'package:jcsd_flutter/view/employee/dashboard.dart';
import 'package:jcsd_flutter/view/employee/services.dart';
import 'package:jcsd_flutter/view/generic/error.dart';
import 'package:jcsd_flutter/global_variables.dart';

// Pages for routine
import 'package:jcsd_flutter/view/users/login.dart';
import 'package:jcsd_flutter/view/generic/signup_first.dart';
import 'package:jcsd_flutter/view/generic/signup_second.dart';
import 'package:jcsd_flutter/view/employee/inventory.dart';
import 'package:jcsd_flutter/view/employee/archive.dart';
import 'package:jcsd_flutter/view/employee/auditLog.dart';
import 'package:jcsd_flutter/view/employee/bookings.dart';
import 'package:jcsd_flutter/view/employee/suppliers.dart';
import 'package:jcsd_flutter/view/generic/homeView.dart';
import 'package:jcsd_flutter/view/employee/profile.dart';
import 'package:jcsd_flutter/view/employee/leaveRequest.dart';
import 'package:jcsd_flutter/view/employee/bookingDetail.dart';
import 'package:jcsd_flutter/view/employee/bookingReceipt.dart';
import 'package:jcsd_flutter/view/employee/payslip.dart';
import 'package:jcsd_flutter/view/admin/accountlist.dart';
import 'package:jcsd_flutter/view/admin/employeelist.dart';
import 'package:jcsd_flutter/view/admin/bookingcalendar.dart';
import 'package:jcsd_flutter/view/client/booking_first.dart';
import 'package:jcsd_flutter/view/client/booking_second.dart';

void main() async {
  supabase_init(); // Initialize Supabase - DONT TOUCH GUYS
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JCSD',
      initialRoute: '/login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00AEEF),
          primary: const Color(0xFF00AEEF),
          secondary: const Color(0xFF00AEEF),
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.windows: InstantPageTransitionsBuilder(),
            TargetPlatform.android: InstantPageTransitionsBuilder()
          },
        ),
      ),

      // Will still need to finalize the segregation of routes but for now
      // segregation here is just based on location of files

      routes: {
        // Generic
        '/home': (context) => const HomeView(),
        '/login': (context) => const Login(),
        '/signup1': (context) => const SignupPage1(),
        '/signup2': (context) => const SignupPage2(),
        '/error': (context) => const ErrorPage(),

        // Admin View
        '/accountList': (context) => const AccountListPage(),
        '/bookingCalendar': (context) => const BookingCalendarPage(),
        '/employeeList': (context) => const EmployeeListPage(),
        '/payroll': (context) => const Payroll(),
        '/accountDetails': (context) => const ProfileAdminViewPage(),
        '/leaveRequestList': (context) => const LeaveRequestList(),

        // Client View
        '/booking1': (context) => const ClientBooking1(),
        '/booking2': (context) => const ClientBooking2(),

        // Employee View
        '/dashboard': (context) => const DashboardPage(),
        '/inventory': (context) => const InventoryPage(),
        '/suppliers': (context) => const SupplierPage(),
        '/bookings': (context) => const BookingsPage(),
        '/archiveList': (context) => const ArchiveListPage(),
        '/auditLog': (context) => const AuditLogPage(),
        '/services': (context) => const ServicesPage(),
        '/profile': (context) => const ProfilePage(),
        '/leaveRequest': (context) => const LeaveRequest(),
        '/bookingDetail': (context) => const BookingDetails(),
        '/bookingReceipt': (context) => const BookingReceipt(),
        '/payslip': (context) => const Payslip(),
      },
    );
  }
}
