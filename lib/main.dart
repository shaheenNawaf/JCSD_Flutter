import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/others/transition.dart';
import 'package:jcsd_flutter/view/bookings/booking_detail.dart';
import 'package:jcsd_flutter/view/bookings/booking_receipt.dart';
import 'package:jcsd_flutter/view/employee/leave_requests.dart';
import 'package:jcsd_flutter/view/employee/login_employee.dart';
import 'package:jcsd_flutter/view/generic/page/access_restricted_page.dart';
import 'package:jcsd_flutter/view/generic/page/error_page.dart';
import 'package:jcsd_flutter/view/generic/page/home_view.dart';
import 'package:jcsd_flutter/view/generic/page/signup_first.dart';
import 'package:jcsd_flutter/view/order_item/order_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api/supa_details.dart';
import 'package:jcsd_flutter/view/generic/page/email_verification.dart';
import 'package:jcsd_flutter/view/generic/forgot_password.dart';
import 'package:jcsd_flutter/view/generic/reset_password.dart';
import 'package:jcsd_flutter/view/admin/accountdetails.dart';
import 'package:jcsd_flutter/view/admin/bookingcalendar.dart';
import 'package:jcsd_flutter/view/admin/leaverequestlist.dart';
import 'package:jcsd_flutter/view/admin/payroll.dart';
import 'package:jcsd_flutter/view/client/profile_client.dart';
import 'package:jcsd_flutter/view/employee/dashboard.dart';
import 'package:jcsd_flutter/view/services/services.dart';
import 'package:jcsd_flutter/view/services/services_archive.dart';
import 'package:jcsd_flutter/view/inventory/item_types/item_types.dart';
import 'package:jcsd_flutter/view/suppliers/suppliers_archive.dart';
import 'package:jcsd_flutter/view/users/login.dart';
import 'package:jcsd_flutter/view/generic/page/signup_second.dart';
import 'package:jcsd_flutter/view/inventory/inventory.dart';
import 'package:jcsd_flutter/view/inventory/inventory_archive.dart';
import 'package:jcsd_flutter/view/inventory/audit_log.dart';
import 'package:jcsd_flutter/view/bookings/bookings.dart';
import 'package:jcsd_flutter/view/employee/transactions.dart';
import 'package:jcsd_flutter/view/suppliers/suppliers.dart';
import 'package:jcsd_flutter/view/employee/profile.dart';
import 'package:jcsd_flutter/view/employee/payslip.dart';
import 'package:jcsd_flutter/view/admin/accountlist.dart';
import 'package:jcsd_flutter/view/admin/employeelist.dart';
import 'package:jcsd_flutter/view/client/booking_first.dart';
import 'package:jcsd_flutter/view/client/booking_second.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final user = data.session?.user;

      if (user == null) {
        _navigatorKey.currentState?.pushReplacementNamed('/login');
        return;
      }

      await _redirectUser(user.id);
    });

    // Initial load (when user is already logged in)
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _redirectUser(currentUser.id);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.pushReplacementNamed('/login');
      });
    }
  }

  Future<void> _redirectUser(String userID) async {
    try {
      final data = await Supabase.instance.client
          .from('accounts')
          .select()
          .eq('userID', userID)
          .maybeSingle();

      bool isBlank(dynamic val) =>
          val == null || (val is String && val.trim().isEmpty);

      final requiredFields = [
        'firstName',
        'middleName',
        'lastName',
        'birthDate',
        'address',
        'city',
        'province',
        'country',
        'zipCode',
        'contactNumber',
      ];

      final isIncomplete =
          data == null || requiredFields.any((field) => isBlank(data[field]));

      final currentRoute =
          ModalRoute.of(_navigatorKey.currentContext!)?.settings.name;

      final shouldRedirectTo = isIncomplete ? '/signup2' : '/home';

      if (currentRoute != shouldRedirectTo) {
        _navigatorKey.currentState?.pushReplacementNamed(shouldRedirectTo);
      }
    } catch (e) {
      debugPrint("Redirect error: $e");
      _navigatorKey.currentState?.pushReplacementNamed('/signup2');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'JCSD',
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
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
