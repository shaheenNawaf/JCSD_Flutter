//Default Imports
import 'dart:async';

//UI Imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/api/supa_details.dart';

//Page Routings
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/accounts/role_state.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_data.dart';
import 'package:jcsd_flutter/others/transition.dart';
import 'package:jcsd_flutter/view/admin/cashadvancelist.dart';
import 'package:jcsd_flutter/view/admin/generatepayroll.dart';
import 'package:jcsd_flutter/view/admin/payrolllist.dart';
import 'package:jcsd_flutter/view/bookings/booking_detail.dart';
import 'package:jcsd_flutter/view/bookings/booking_receipt.dart';
import 'package:jcsd_flutter/view/employee/employee_cash_advance.dart';
import 'package:jcsd_flutter/view/employee/leave_requests.dart';
import 'package:jcsd_flutter/view/employee/login_employee.dart';
import 'package:jcsd_flutter/view/generic/forgot_password.dart';
import 'package:jcsd_flutter/view/generic/page/access_restricted_page.dart';
import 'package:jcsd_flutter/view/generic/page/email_verification.dart';
import 'package:jcsd_flutter/view/generic/page/error_page.dart';
import 'package:jcsd_flutter/view/generic/page/home_view.dart';
import 'package:jcsd_flutter/view/generic/page/signup_first.dart';
import 'package:jcsd_flutter/view/generic/reset_password.dart';
import 'package:jcsd_flutter/view/admin/accountdetails.dart';
import 'package:jcsd_flutter/view/admin/bookingcalendar.dart';
import 'package:jcsd_flutter/view/admin/leaverequestlist.dart';
import 'package:jcsd_flutter/view/admin/payroll.dart';
import 'package:jcsd_flutter/view/client/profile_client.dart';
import 'package:jcsd_flutter/view/employee/dashboard.dart';
import 'package:jcsd_flutter/view/inventory/item_serials/item_serials_list.dart';
import 'package:jcsd_flutter/view/inventory/purchase_orders/purchase_order_page.dart';
import 'package:jcsd_flutter/view/manufacturers/manufacturers.dart';
import 'package:jcsd_flutter/view/manufacturers/manufacturers_archive.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final router = GoRouter(
  refreshListenable:
      GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
  initialLocation: '/login',
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
              builder: (context, state) {
                final AccountsData? user = state.extra as AccountsData?;
                return ProfileAdminViewPage(user: user);
              })
        ]),
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
          builder: (context, state) => const LeaveRequestList(),
        ),
        GoRoute(
          path: 'payrollList',
          builder: (context, state) => const PayrollList(),
          routes: <GoRoute>[
            GoRoute(
              path: 'generatePayroll',
              builder: (context, state) => const GeneratePayrollPage(),
            ),
          ],
        ),
        GoRoute(
          path: 'cashAdvanceList',
          builder: (context, state) => const CashAdvanceList(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;
            final acc = args['account'] as AccountsData?;
            final currentUser = Supabase.instance.client.auth.currentUser;
            final emp = args['employee'] as EmployeeData?;
            return ProfilePage(
              targetUser: acc,
              currentUserId: currentUser?.id,
              emp: emp,
            );
          },
          routes: <GoRoute>[
            GoRoute(
              path: 'payslip',
              builder: (context, state) {
                final args = state.extra as Map<String, dynamic>?;
                final acc = args?['account'] as AccountsData?;
                final emp = args?['employee'] as EmployeeData?;
                final payroll = args?['payroll'] as PayrollData?;
                return Payslip(acc: acc, emp: emp, payroll: payroll);
              },
              routes: [
                GoRoute(
                  path: 'cashAdvanceHistory',
                  builder: (context, state) {
                    final args = state.extra as Map<String, dynamic>?;
                    final acc = args?['account'] as AccountsData?;
                    final emp = args?['employee'] as EmployeeData?;
                    return CashAdvancePage(acc: acc, emp: emp);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/payroll',
              builder: (context, state) {
                final args = state.extra as Map<String, dynamic>?;
                final acc = args?['account'] as AccountsData?;
                final emp = args?['employee'] as EmployeeData?;
                if (acc == null || emp == null) {
                  return const ErrorPage();
                }
                return Payroll(account: acc, employee: emp);
              },
            ),
            GoRoute(
              path: 'leaveRequest',
              builder: (context, state) {
                final args = state.extra as Map<String, dynamic>?;
                final acc = args?['account'] as AccountsData?;
                final emp = args?['employee'] as EmployeeData?;
                return LeaveRequest(acc: acc, emp: emp);
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/payroll',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        final acc = args?['account'] as AccountsData;
        final emp = args?['employee'] as EmployeeData;
        return Payroll(account: acc, employee: emp);
      },
    ),
    GoRoute(
      path: '/accountDetails',
      name: 'accountDetails',
      builder: (context, state) {
        final account = state.extra as AccountsData;
        final currentUser = Supabase.instance.client.auth.currentUser;
        return ProfilePage(
          targetUser: account,
          currentUserId: currentUser?.id,
        );
      },
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
      path: '/manufacturers',
      builder: (context, state) => const ManufacturersPage(),
    ),
    GoRoute(
      path: '/archivedmanufacturers',
      builder: (context, state) => const ManufacturersArchivePage(),
    ),
    GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryPage(),
        routes: <GoRoute>[
          GoRoute(
              path: 'serials',
              builder: (context, state) {
                final Map<String, dynamic>? extraData =
                    state.extra as Map<String, dynamic>?;
                final String? prodDefID = extraData?['prodDefId'] as String?;
                final String? prodDefName =
                    extraData?['prodDefName'] as String?;
                return SerializedItemListPage(
                    prodDefID: prodDefID ?? '', prodDefName: prodDefName ?? '');
              })
        ]),
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
      builder: (context, state) => const PurchaseOrderPage(),
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
      name: 'bookingDetail',
      builder: (context, state) {
        final bookingID = state.extra as int?;

        if (bookingID == null) {
          print(
              "Error: Navigated to BookingDetailsPage without a valid bookingId.");
          return const Scaffold(
            body: Center(
              child:
                  Text("Error: Booking ID is missing. Cannot display details."),
            ),
          );
        }
        return BookingDetailsPage(bookingId: bookingID);
      },
    ),
    GoRoute(
      path: '/bookingReceipt',
      builder: (context, state) => const BookingReceipt(),
    ),
    GoRoute(
      path: '/itemTypes',
      builder: (context, state) => const ItemTypesPage(),
    ),
    GoRoute(
      path: '/error',
      builder: (context, state) => const ErrorPage(),
    ),
  ],
  errorBuilder: (context, state) => const ErrorPage(),
  redirect: (context, state) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final loggedIn = session?.user;
      final requestedLocation = state.uri.toString();
      final authRoutes = [
        '/login',
        '/signup1',
        '/forgotPassword',
        '/emailVerification'
      ];
      const profileCompletionRoute = '/signup2';
      final isGoingToAuthRoute = authRoutes.contains(requestedLocation);
      final isGoingToProfileCompletion =
          requestedLocation == profileCompletionRoute;

      final container = ProviderContainer();
      final userRole = await container.read(userRoleProvider.future);

      if (loggedIn == null) {
        return isGoingToAuthRoute ? null : '/login';
      }

      Future<bool> isProfileIncomplete(String? role) async {
        if (role == 'employee' || role == 'admin') return false;

        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) return true;

        final accountData = await Supabase.instance.client
            .from('accounts')
            .select(
                'firstName, middleName, lastName, birthDate, address, city, province, region, zipCode, contactNumber')
            .eq('userID', userId)
            .maybeSingle();

        if (accountData == null) return true;

        final List<String> requiredDbFields = [
          'firstName',
          'middleName',
          'lastName',
          'birthDate',
          'address',
          'city',
          'province',
          'region',
          'zipCode',
          'contactNumber',
        ];
        bool isBlank(dynamic val) =>
            val == null || (val is String && val.trim().isEmpty);
        return requiredDbFields.any((field) => isBlank(accountData[field]));
      }

      final isIncompleteProfile = await isProfileIncomplete(userRole);
      if (isIncompleteProfile &&
          userRole != 'employee' &&
          userRole != 'admin') {
        return !isGoingToProfileCompletion ? profileCompletionRoute : null;
      }

      const Map<String, String> initialRoutes = {
        'admin': '/dashboard',
        'employee': '/dashboard',
        'client': '/home',
      };

      const Map<String, List<String>> roleBasedRoutes = {
        'admin': [
          '/home',
          '/dashboard',
          '/accountList',
          '/accountList/accountDetail',
          '/bookingsCalendar',
          '/booking1',
          '/booking2',
          '/create-booking',
          '/profileClient',
          '/employeeList',
          '/employeeList/profile',
          '/employeeList/profile/payslip',
          '/employeeList/profile/leaveRequest',
          '/employeeList/profile/payslip/cashAdvanceHistory',
          '/employeeList/leaveRequestList',
          '/employeeList/payrollList',
          '/employeeList/payrollList/generatePayroll',
          '/employeeList/cashAdvanceList',
          '/employeeList/cashAdvanceList/generateCashAdvance',
         ' /employeeList/profile/payroll',
          '/payroll',
          '/accountDetails',
          '/manufacturers',
          '/inventory',
          '/inventory/serials',
          '/suppliers',
          '/supplierArchive',
          '/bookings',
          '/transactions',
          '/archiveList',
          '/orderList',
          '/auditLog',
          '/services',
          '/servicesArchive',
          '/bookingDetail',
          '/bookingReceipt',
          '/itemTypes',
          '/profileClient'
        ],
        'employee': [
          '/dashboard',
          '/bookingsCalendar',
          '/bookingDetail',
          '/inventory',
          '/manufacturers'
          '/suppliers',
          '/bookings',
          '/payroll',
          '/accountDetails',
          '/services',
          '/accountDetails',
          '/itemTypes',
          '/employeeList/profile',
          '/employeeList/profile/payslip',
          '/employeeList/profile/leaveRequest',
          '/employeeList/profile/payslip/cashAdvanceHistory',
          '/dashboard',
          '/itemTypes',
        ],
        'client': [
          '/home',
          '/inventory',
          '/booking1',
          '/booking2',
          '/create-booking',
          '/profileClient',
          '/transactions',
          '/bookingDetail',
          '/bookingReceipt',
        ],
      };

      if (isGoingToAuthRoute || isGoingToProfileCompletion) {
        return initialRoutes[userRole] ?? '/home';
      }

      if (userRole != null && roleBasedRoutes.containsKey(userRole)) {
        return roleBasedRoutes[userRole]!.contains(requestedLocation)
            ? null
            : '/accessRestricted';
      } else {
        debugPrint(
            "User has no determined role or route access configuration.");
        return '/error';
      }
    } catch (e) {
      debugPrint("Redirect error: $e");
      return '/error';
    }
  },
);

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

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
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'JCSD',
      routerConfig: router,
      scaffoldMessengerKey: scaffoldMessengerKey,
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
