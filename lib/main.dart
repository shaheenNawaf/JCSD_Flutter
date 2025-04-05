import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/view/generic/email_verification.dart';
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

final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/home',
    ),
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
      builder: (context, state) {
        final email = state.uri.queryParameters['email'];
        return EmailVerification(email: email);
      },
    ),
    GoRoute(
      path: '/forgotPassword',
      builder: (context, state) => const ForgotPassword(),
    ),
    GoRoute(
      path: '/resetPassword',
      builder: (context, state) => const ResetPassword(),
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
      routes: <GoRoute>[
        GoRoute(
          path: 'accountDetail',
          builder: (context, state) => ProfileAdminViewPage(),
        )
      ]
    ),
    GoRoute(
      path: '/bookingsCalendar',
      builder: (context, state) => const BookingCalendarPage(),
    ),
    GoRoute(
      path: '/employeeList',
      builder: (context, state) => const EmployeeListPage(),
      routes: <GoRoute>[
        GoRoute(
          path: 'leaveRequestList',
          builder: (context, state) => LeaveRequestList(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => ProfilePage(),
          routes: <GoRoute>[
            GoRoute(
              path: 'payslip',
              builder: (context, state) => Payslip(),
            ),
            GoRoute(
              path: 'leaveRequest',
              builder: (context, state) => LeaveRequest(),
            )
          ]
        )
      ]
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
      path: '/bookingDetail',
      builder: (context, state) => const BookingDetails(),
    ),
    GoRoute(
      path: '/bookingReceipt',
      builder: (context, state) => const BookingReceipt(),
    ),
    GoRoute(
      path: '/itemTypes',
      builder: (context, state) => const ItemTypesPage(),
    ),
  ],
  errorBuilder: (context, state) => const ErrorPage(),
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final user = session?.user;

    final isPublicRoute = ['/home'].contains(state.uri.path);
    final isAuthRoute = ['/login', '/signup1', '/signup2', '/forgotPassword','/emailVerification'].contains(state.uri.path);
    
    if (isPublicRoute) {
      return null;
    }

    if (user == null && !isAuthRoute) {
      print(user);
      return '/login';
    }
    
    if (user != null && isAuthRoute) {
      return '/home';
    }
    
    return null;
  },
);

Future<void> main() async {
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