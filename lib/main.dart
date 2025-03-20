// Imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:jcsd_flutter/view/generic/email_verification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api/supa_details.dart';
import 'package:jcsd_flutter/others/transition.dart';
import 'package:jcsd_flutter/view/admin/accountdetails.dart';
import 'package:jcsd_flutter/view/admin/bookingcalendar.dart';
import 'package:jcsd_flutter/view/admin/leaverequestlist.dart';
import 'package:jcsd_flutter/view/admin/payroll.dart';
import 'package:jcsd_flutter/view/client/profile_client.dart';
import 'package:jcsd_flutter/view/employee/dashboard.dart';
import 'package:jcsd_flutter/view/employee/loginEmployee.dart';
import 'package:jcsd_flutter/view/generic/access_restricted_page.dart';
import 'package:jcsd_flutter/view/services/services.dart';
import 'package:jcsd_flutter/view/services/services_archive.dart';
import 'package:jcsd_flutter/view/inventory/item_types/item_types.dart';
import 'package:jcsd_flutter/view/suppliers/suppliers_archive.dart';
import 'package:jcsd_flutter/view/generic/error_page.dart';
import 'package:jcsd_flutter/view/users/login.dart';
import 'package:jcsd_flutter/view/generic/signup_first.dart';
import 'package:jcsd_flutter/view/generic/signup_second.dart';
import 'package:jcsd_flutter/view/inventory/inventory.dart';
import 'package:jcsd_flutter/view/inventory/inventory_archive.dart';
import 'package:jcsd_flutter/view/inventory/audit_log.dart';
import 'package:jcsd_flutter/view/inventory/order_list.dart';
import 'package:jcsd_flutter/view/bookings/bookings.dart';
import 'package:jcsd_flutter/view/employee/transactions.dart';
import 'package:jcsd_flutter/view/suppliers/suppliers.dart';
import 'package:jcsd_flutter/view/generic/home_view.dart';
import 'package:jcsd_flutter/view/employee/profile.dart';
import 'package:jcsd_flutter/view/employee/leaveRequest.dart';
import 'package:jcsd_flutter/view/bookings/bookingDetail.dart';
import 'package:jcsd_flutter/view/bookings/bookingReceipt.dart';
import 'package:jcsd_flutter/view/employee/payslip.dart';
import 'package:jcsd_flutter/view/admin/accountlist.dart';
import 'package:jcsd_flutter/view/admin/employeelist.dart';
import 'package:jcsd_flutter/view/client/booking_first.dart';
import 'package:jcsd_flutter/view/client/booking_second.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase before running the app
  await Supabase.initialize(
    url: returnAccessURL(),
    anonKey: returnAnonKey(),
  );

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final user = session?.user;

    print('Checking Authentication State...');
    print('Current Authenticated User: ${user?.email ?? "No user logged in"}');

    final GoRouter router = GoRouter(
      initialLocation: user == null ? '/login' : '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Login(),
        ),
        GoRoute(
          path: '/signup1',
          builder: (context, state) => const SignupPage1(),
        ),
        GoRoute(
          path: '/signup2',
          builder: (context, state) => const SignupPage2(),
        ),
        GoRoute(
          path: '/emailVerification',
          builder: (context, state) => const EmailVerification(),
        ),
        GoRoute(
          path: '/error',
          builder: (context, state) => const ErrorPage(),
        ),
        GoRoute(
          path: '/accessRestricted',
          builder: (context, state) => const AccessRestrictedPage(),
        ),
        GoRoute(
          path: '/accountList',
          builder: (context, state) => const AccountListPage(),
        ),
        GoRoute(
          path: '/bookingsCalendar',
          builder: (context, state) => const BookingCalendarPage(),
        ),
        GoRoute(
          path: '/employeeList',
          builder: (context, state) => const EmployeeListPage(),
        ),
        GoRoute(
          path: '/payroll',
          builder: (context, state) => const Payroll(),
        ),
        GoRoute(
          path: '/accountDetails',
          builder: (context, state) => const ProfileAdminViewPage(),
        ),
        GoRoute(
          path: '/leaveRequestList',
          builder: (context, state) => const LeaveRequestList(),
        ),
        GoRoute(
          path: '/booking1',
          builder: (context, state) => const ClientBooking1(),
        ),
        GoRoute(
          path: '/booking2',
          builder: (context, state) => const ClientBooking2(),
        ),
        GoRoute(
          path: '/profileClient',
          builder: (context, state) => const ProfilePageClient(),
        ),
        // Employee Routes
        GoRoute(
          path: '/employeeLogin',
          builder: (context, state) => const LoginEmployee(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryPage(),
        ),
        GoRoute(
          path: '/suppliers',
          builder: (context, state) => const SupplierPage(),
        ),
        GoRoute(
          path: '/supplierArchive',
          builder: (context, state) => const SupplierArchivePage(),
        ),
        GoRoute(
          path: '/bookings',
          builder: (context, state) => const BookingsPage(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionsPage(),
        ),
        GoRoute(
          path: '/archiveList',
          builder: (context, state) => const ArchiveListPage(),
        ),
        GoRoute(
          path: '/orderList',
          builder: (context, state) => const OrderListPage(),
        ),
        GoRoute(
          path: '/auditLog',
          builder: (context, state) => const AuditLogPage(),
        ),
        GoRoute(
          path: '/services',
          builder: (context, state) => const ServicesPage(),
        ),
        GoRoute(
          path: '/servicesArchive',
          builder: (context, state) => const ServicesArchivePage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/leaveRequest',
          builder: (context, state) => const LeaveRequest(),
        ),
        GoRoute(
          path: '/bookingDetail',
          builder: (context, state) => const BookingDetails(),
        ),
        GoRoute(
          path: '/bookingReceipt',
          builder: (context, state) => const BookingReceipt(),
        ),
        GoRoute(
          path: '/payslip',
          builder: (context, state) => const Payslip(),
        ),
        GoRoute(
          path: '/itemTypes',
          builder: (context, state) => const ItemTypesPage(),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'JCSD',
      builder: FToastBuilder(),
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00AEEF),
          primary: const Color(0xFF00AEEF),
          secondary: const Color(0xFF00AEEF),
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.windows: InstantPageTransitionsBuilder(),
            TargetPlatform.android: InstantPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}