// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/backend/modules/accounts/role_state.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Sidebar extends ConsumerStatefulWidget {
  final String activePage;
  final VoidCallback? onClose;

  const Sidebar({super.key, this.activePage = '', this.onClose});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  bool _isInventoryExpanded = false;
  bool _isBookingsExpanded = false;
  bool _isSuppliersExpanded = false;
  bool _isServicesExpanded = false;
  bool _isProfilingExpanded = false;
  String _activeSubItem = '';

  @override
  void initState() {
    super.initState();
    _activeSubItem = widget.activePage;

    _isInventoryExpanded = widget.activePage.startsWith('/inventory') ||
        widget.activePage == '/archiveList' ||
        widget.activePage == '/orderList' ||
        widget.activePage == '/returnOrders';
    _isBookingsExpanded = widget.activePage.startsWith('/bookings') ||
        widget.activePage == '/transactions';
    _isSuppliersExpanded = widget.activePage.startsWith('/suppliers') ||
        widget.activePage == '/supplierArchive';
    _isServicesExpanded = widget.activePage.startsWith('/services') ||
        widget.activePage == '/servicesArchive';
    _isProfilingExpanded = widget.activePage.startsWith('/accountList') ||
        widget.activePage.startsWith('/employeeList');
  }

  void _toggleDropdown(String dropdown) {
    setState(() {
      if (dropdown == 'inventory') {
        _isInventoryExpanded = !_isInventoryExpanded;
        _isBookingsExpanded = false;
        _isSuppliersExpanded = false;
        _isServicesExpanded = false;
        _isProfilingExpanded = false;
      } else if (dropdown == 'bookings') {
        _isBookingsExpanded = !_isBookingsExpanded;
        _isInventoryExpanded = false;
        _isSuppliersExpanded = false;
        _isServicesExpanded = false;
        _isProfilingExpanded = false;
      } else if (dropdown == 'suppliers') {
        _isSuppliersExpanded = !_isSuppliersExpanded;
        _isInventoryExpanded = false;
        _isBookingsExpanded = false;
        _isServicesExpanded = false;
        _isProfilingExpanded = false;
      } else if (dropdown == 'services') {
        _isServicesExpanded = !_isServicesExpanded;
        _isInventoryExpanded = false;
        _isBookingsExpanded = false;
        _isSuppliersExpanded = false;
        _isProfilingExpanded = false;
      } else if (dropdown == 'profiling') {
        _isProfilingExpanded = !_isProfilingExpanded;
        _isInventoryExpanded = false;
        _isBookingsExpanded = false;
        _isSuppliersExpanded = false;
        _isServicesExpanded = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final userRoleAsyncValue = ref.watch(userRoleProvider);

    return isMobile
        ? _buildDrawer(context)
        : Container(
            width: 250,
            color: const Color(0xFF00AEEF),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24.0, horizontal: 20),
                  child: Column(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/logo_white.png',
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 5),
                      userRoleAsyncValue.when(
                        data: (userRole) => Text(
                          'Welcome, ${userRole?[0].toUpperCase()}${userRole?.substring(1)}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => const Text(
                          'Welcome! (Loading...)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        error: (error, stackTrace) => Text(
                          'Welcome! (Error: $error)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Column(
                    children: [
                      SidebarItem(
                        icon: FontAwesomeIcons.chartLine,
                        title: 'Dashboard',
                        route: '/dashboard',
                        isActive: widget.activePage == '/dashboard',
                        onTap: () {
                          _navigateToMainPage('/dashboard');
                        },
                      ),
                      SidebarItemWithDropdown(
                        icon: FontAwesomeIcons.boxOpen,
                        title: 'Inventory',
                        isActive: false,
                        isExpanded: _isInventoryExpanded,
                        onTap: () => _toggleDropdown('inventory'),
                      ),
                      if (_isInventoryExpanded) ...[
                        SubSidebarItem(
                          icon: FontAwesomeIcons.table,
                          title: 'Table List',
                          route: '/inventory',
                          isActive: _activeSubItem == '/inventory',
                          onTap: () => _navigateTo('/inventory'),
                        ),
                        userRoleAsyncValue.when(
                          data: (role) => role != 'employee'
                              ? SubSidebarItem(
                                  icon: FontAwesomeIcons.boxArchive,
                                  title: 'Archive List',
                                  route: '/archiveList',
                                  isActive: _activeSubItem == '/archiveList',
                                  onTap: () => _navigateTo('/archiveList'),
                                )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox.shrink(),
                          error: (error, stackTrace) => const SizedBox.shrink(),
                        ),
                        userRoleAsyncValue.when(
                          data: (role) => role != 'employee'
                              ? SubSidebarItem(
                                  icon: FontAwesomeIcons.fileImport,
                                  title: 'Purchase Order',
                                  route: '/orderList',
                                  isActive: _activeSubItem == '/orderList',
                                  onTap: () => _navigateTo('/orderList'),
                                )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox.shrink(),
                          error: (error, stackTrace) => const SizedBox.shrink(),
                        )
                      ],
                      SidebarItemWithDropdown(
                        icon: FontAwesomeIcons.calendarDays,
                        title: 'Bookings',
                        isActive: false,
                        isExpanded: _isBookingsExpanded,
                        onTap: () => _toggleDropdown('bookings'),
                      ),
                      if (_isBookingsExpanded) ...[
                        SubSidebarItem(
                          icon: FontAwesomeIcons.table,
                          title: 'Table List',
                          route: '/bookings',
                          isActive: _activeSubItem == '/bookings',
                          onTap: () => _navigateTo('/bookings'),
                        ),
                      ],
                      userRoleAsyncValue.when(
                        data: (role) => role != 'employee'
                            ? Column(
                                children: [
                                  SidebarItemWithDropdown(
                                    icon: FontAwesomeIcons.truck,
                                    title: 'Suppliers',
                                    isActive: false,
                                    isExpanded: _isSuppliersExpanded,
                                    onTap: () => _toggleDropdown('suppliers'),
                                  ),
                                  if (_isSuppliersExpanded) ...[
                                    SubSidebarItem(
                                      icon: FontAwesomeIcons.table,
                                      title: 'Table List',
                                      route: '/suppliers',
                                      isActive: _activeSubItem == '/suppliers',
                                      onTap: () => _navigateTo('/suppliers'),
                                    ),
                                    SubSidebarItem(
                                      icon: FontAwesomeIcons.boxArchive,
                                      title: 'Archive List',
                                      route: '/supplierArchive',
                                      isActive:
                                          _activeSubItem == '/supplierArchive',
                                      onTap: () =>
                                          _navigateTo('/supplierArchive'),
                                    ),
                                  ],
                                ],
                              )
                            : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (error, stackTrace) => const SizedBox.shrink(),
                      ),
                      userRoleAsyncValue.when(
                        data: (role) => role != 'employee'
                            ? Column(
                                children: [
                                  SidebarItemWithDropdown(
                                    icon: FontAwesomeIcons.gears,
                                    title: 'Services',
                                    isActive: false,
                                    isExpanded: _isServicesExpanded,
                                    onTap: () => _toggleDropdown('services'),
                                  ),
                                  if (_isServicesExpanded) ...[
                                    SubSidebarItem(
                                      icon: FontAwesomeIcons.table,
                                      title: 'Table List',
                                      route: '/services',
                                      isActive: _activeSubItem == '/services',
                                      onTap: () => _navigateTo('/services'),
                                    ),
                                    SubSidebarItem(
                                      icon: FontAwesomeIcons.boxArchive,
                                      title: 'Archive List',
                                      route: '/servicesArchive',
                                      isActive:
                                          _activeSubItem == '/servicesArchive',
                                      onTap: () =>
                                          _navigateTo('/servicesArchive'),
                                    ),
                                  ],
                                ],
                              )
                            : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (error, stackTrace) => const SizedBox.shrink(),
                      ),
                      userRoleAsyncValue.when(
                        data: (role) => role != 'employee'
                            ? Column(
                                children: [
                                  SidebarItemWithDropdown(
                                    icon: FontAwesomeIcons.solidUser,
                                    title: 'Profiling',
                                    isActive: false,
                                    isExpanded: _isProfilingExpanded,
                                    onTap: () => _toggleDropdown('profiling'),
                                  ),
                                  if (_isProfilingExpanded) ...[
                                    SubSidebarItem(
                                      icon: FontAwesomeIcons.userGroup,
                                      title: 'Accounts List',
                                      route: '/accountList',
                                      isActive:
                                          _activeSubItem == '/accountList',
                                      onTap: () => _navigateTo('/accountList'),
                                    ),
                                    SubSidebarItem(
                                      icon: FontAwesomeIcons.userGroup,
                                      title: 'Employee List',
                                      route: '/employeeList',
                                      isActive:
                                          _activeSubItem == '/employeeList',
                                      onTap: () => _navigateTo('/employeeList'),
                                    ),
                                  ],
                                ],
                              )
                            : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                _buildLogoutButton(context),
                const SizedBox(height: 16),
              ],
            ),
          );
  }

  void _navigateTo(String route) {
    setState(() {
      _activeSubItem = route;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      context.go(route);
      widget.onClose?.call();
    });
  }

  void _navigateToMainPage(String route) {
    setState(() {
      _activeSubItem = '';
    });

    context.go(route);
    widget.onClose?.call();
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF00AEEF),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF00AEEF),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo_white.png',
                height: 60,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SidebarItem(
                  icon: FontAwesomeIcons.chartLine,
                  title: 'Dashboard',
                  route: '/dashboard',
                  isActive: widget.activePage == '/dashboard',
                  onTap: () {
                    _navigateToMainPage('/dashboard');
                  },
                ),
                SidebarItemWithDropdown(
                  icon: FontAwesomeIcons.boxOpen,
                  title: 'Inventory',
                  isActive: false,
                  isExpanded: _isInventoryExpanded,
                  onTap: () => _toggleDropdown('inventory'),
                ),
                if (_isInventoryExpanded) ...[
                  SubSidebarItem(
                    icon: FontAwesomeIcons.table,
                    title: 'Table List',
                    route: '/inventory',
                    isActive: _activeSubItem == '/inventory',
                    onTap: () => _navigateTo('/inventory'),
                  ),
                  SubSidebarItem(
                    icon: FontAwesomeIcons.boxArchive,
                    title: 'Archive List',
                    route: '/archiveList',
                    isActive: _activeSubItem == '/archiveList',
                    onTap: () => _navigateTo('/archiveList'),
                  ),
                  SubSidebarItem(
                    icon: FontAwesomeIcons.fileImport,
                    title: 'Order List',
                    route: '/orderList',
                    isActive: _activeSubItem == '/orderList',
                    onTap: () => _navigateTo('/orderList'),
                  ),
                  SubSidebarItem(
                    icon: FontAwesomeIcons
                        .undoAlt, // Or a more fitting icon like faTruckRampBox or faReceipt
                    title: 'Return Orders',
                    route: '/returnOrders', // Matches the GoRouter path
                    isActive: _activeSubItem == '/returnOrders',
                    onTap: () => _navigateTo('/returnOrders'),
                  ),
                ],
                SidebarItemWithDropdown(
                  icon: FontAwesomeIcons.calendarDays,
                  title: 'Bookings',
                  isActive: false,
                  isExpanded: _isBookingsExpanded,
                  onTap: () => _toggleDropdown('bookings'),
                ),
                if (_isBookingsExpanded) ...[
                  SubSidebarItem(
                    icon: FontAwesomeIcons.table,
                    title: 'Table List',
                    route: '/bookings',
                    isActive: _activeSubItem == '/bookings',
                    onTap: () => _navigateTo('/bookings'),
                  ),
                  SubSidebarItem(
                    icon: FontAwesomeIcons.calendar,
                    title: 'Calendar',
                    route: '/bookingsCalendar',
                    isActive: _activeSubItem == '/bookingsCalendar',
                    onTap: () => _navigateTo('/bookingsCalendar'),
                  ),
                  SubSidebarItem(
                    icon: FontAwesomeIcons.fileInvoiceDollar,
                    title: 'Transactions',
                    route: '/transactions',
                    isActive: _activeSubItem == '/transactions',
                    onTap: () => _navigateTo('/transactions'),
                  ),
                ],
                SidebarItemWithDropdown(
                  icon: FontAwesomeIcons.truck,
                  title: 'Suppliers',
                  isActive: false,
                  isExpanded: _isSuppliersExpanded,
                  onTap: () => _toggleDropdown('suppliers'),
                ),
                if (_isSuppliersExpanded) ...[
                  SubSidebarItem(
                    icon: FontAwesomeIcons.table,
                    title: 'Table List',
                    route: '/suppliers',
                    isActive: _activeSubItem == '/suppliers',
                    onTap: () => _navigateTo('/suppliers'),
                  ),
                  SubSidebarItem(
                    icon: FontAwesomeIcons.boxArchive,
                    title: 'Archive List',
                    route: '/supplierArchive',
                    isActive: _activeSubItem == '/supplierArchive',
                    onTap: () => _navigateTo('/supplierArchive'),
                  ),
                ],
                SidebarItemWithDropdown(
                  icon: FontAwesomeIcons.gears,
                  title: 'Services',
                  isActive: false,
                  isExpanded: _isServicesExpanded,
                  onTap: () => _toggleDropdown('services'),
                ),
                if (_isServicesExpanded) ...[
                  SubSidebarItem(
                    icon: FontAwesomeIcons.table,
                    title: 'Table List',
                    route: '/services',
                    isActive: _activeSubItem == '/services',
                    onTap: () => _navigateTo('/services'),
                  ),
                  SubSidebarItem(
                    icon: FontAwesomeIcons.boxArchive,
                    title: 'Archive List',
                    route: '/servicesArchive',
                    isActive: _activeSubItem == '/servicesArchive',
                    onTap: () => _navigateTo('/servicesArchive'),
                  ),
                ],
                SidebarItemWithDropdown(
                  icon: FontAwesomeIcons.user,
                  title: 'Profiling',
                  isActive: false,
                  isExpanded: _isProfilingExpanded,
                  onTap: () => _toggleDropdown('profiling'),
                ),
                if (_isProfilingExpanded) ...[
                  SubSidebarItem(
                    icon: FontAwesomeIcons.table,
                    title: 'Accounts List',
                    route: '/accountList',
                    isActive: _activeSubItem == '/accountList',
                    onTap: () => _navigateTo('/accountList'),
                  ),
                  SubSidebarItem(
                    icon: FontAwesomeIcons.table,
                    title: 'Employee List',
                    route: '/employeeList',
                    isActive: _activeSubItem == '/employeeList',
                    onTap: () => _navigateTo('/employeeList'),
                  ),
                ],
              ],
            ),
          ),
          _buildLogoutButton(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      context.go('/login');
    } catch (error) {
      ToastManager().showToast(context, 'Logout failed: $error',
          const Color.fromARGB(255, 255, 0, 0));
    }
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SidebarItem(
      icon: FontAwesomeIcons.rightFromBracket,
      title: 'Logout',
      route: '/login',
      isActive: false,
      onTap: _logout,
    );
  }
}

class SidebarItemWithDropdown extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback? onTap;

  const SidebarItemWithDropdown({
    super.key,
    required this.icon,
    required this.title,
    required this.isActive,
    required this.isExpanded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ListTile(
        leading: FaIcon(
          icon,
          color: Colors.white,
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: FaIcon(
          isExpanded
              ? FontAwesomeIcons.chevronDown
              : FontAwesomeIcons.chevronRight,
          color: Colors.white,
          size: 14,
        ),
        onTap: onTap,
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final bool isActive;
  final VoidCallback? onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color.fromARGB(255, 33, 199, 255);

    return Container(
      color: isActive ? activeColor : Colors.transparent,
      child: ListTile(
        leading: FaIcon(
          icon,
          color: Colors.white,
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        onTap: onTap,
      ),
    );
  }
}

class SubSidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final bool isActive;
  final VoidCallback? onTap;

  const SubSidebarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color.fromARGB(255, 33, 199, 255);

    return Padding(
      padding: const EdgeInsets.only(left: 40.0),
      child: Container(
        color: isActive ? activeColor : Colors.transparent,
        child: ListTile(
          leading: FaIcon(
            icon,
            color: Colors.white,
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
