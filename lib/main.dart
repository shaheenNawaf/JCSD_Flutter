import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/view/generic/email_verification.dart';
import 'package:jcsd_flutter/view/generic/forgot_password.dart';
import 'package:jcsd_flutter/view/generic/reset_password.dart';
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

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase before running the app
  await Supabase.initialize(
    url: returnAccessURL(),
    anonKey: returnAnonKey(),
  );

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    // Listen for authentication state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.passwordRecovery) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/resetPassword');
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDeepLink();
    });
  }

  /// Handles deep link for password reset
  void _handleDeepLink() async {
    final Uri uri = Uri.base;
    print("Deep Link URI: ${uri.toString()}");

    final resetCode = uri.queryParameters['code'];

    if (resetCode != null) {
      print("Extracted reset code: $resetCode");

      try {
        final response =
            await Supabase.instance.client.auth.setSession(resetCode);

        if (response.user == null) {
          throw Exception("User session not found. Token might be expired.");
        }

        print("Session set successfully, redirecting to Reset Password page.");
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/resetPassword');
        }
      } catch (error) {
        print("Error setting session: $error");
      }
    } else {
      print("No reset code found in URI.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final user = session?.user;

    print('Checking Authentication State...');
    print('Current Authenticated User: ${user?.email ?? "No user logged in"}');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JCSD',
      scaffoldMessengerKey: scaffoldMessengerKey,
      initialRoute: user == null ? '/login' : '/home',
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
      routes: {
        '/home': (context) => const HomeView(),
        '/login': (context) => const Login(),
        '/signup1': (context) => const SignupPage1(),
        '/signup2': (context) => const SignupPage2(),
        '/emailVerification': (context) => const EmailVerification(),
        '/forgotPassword': (context) => const ForgotPassword(),
        '/resetPassword': (context) => const ResetPassword(),
        '/error': (context) => const ErrorPage(),
        '/accessRestricted': (context) => const AccessRestrictedPage(),
        '/accountList': (context) => const AccountListPage(),
        '/bookingsCalendar': (context) => const BookingCalendarPage(),
        '/employeeList': (context) => const EmployeeListPage(),
        '/payroll': (context) => const Payroll(),
        '/accountDetails': (context) => const ProfileAdminViewPage(),
        '/leaveRequestList': (context) => const LeaveRequestList(),
        '/booking1': (context) => const ClientBooking1(),
        '/booking2': (context) => const ClientBooking2(),
        '/profileClient': (context) => const ProfilePageClient(),
        '/employeeLogin': (context) => const LoginEmployee(),
        '/dashboard': (context) => const DashboardPage(),
        '/inventory': (context) => const InventoryPage(),
        '/suppliers': (context) => const SupplierPage(),
        '/supplierArchive': (context) => const SupplierArchivePage(),
        '/bookings': (context) => const BookingsPage(),
        '/transactions': (context) => const TransactionsPage(),
        '/archiveList': (context) => const ArchiveListPage(),
        '/orderList': (context) => const OrderListPage(),
        '/auditLog': (context) => const AuditLogPage(),
        '/services': (context) => const ServicesPage(),
        '/servicesArchive': (context) => const ServicesArchivePage(),
        '/profile': (context) => const ProfilePage(),
        '/leaveRequest': (context) => const LeaveRequest(),
        '/bookingDetail': (context) => const BookingDetails(),
        '/bookingReceipt': (context) => const BookingReceipt(),
        '/payslip': (context) => const Payslip(),
        '/itemTypes': (context) => const ItemTypesPage(),
      },
    );
  }
}
