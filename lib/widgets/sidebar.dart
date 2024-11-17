// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Sidebar extends StatefulWidget {
  final String activePage;
  final VoidCallback? onClose;

  const Sidebar({super.key, this.activePage = '', this.onClose});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isInventoryExpanded = false;
  bool _isBookingsExpanded = false;
  String _activeSubItem = '';

  @override
  void initState() {
    super.initState();
    _activeSubItem = widget.activePage;

    // Expand dropdowns if the active page is within their subitems
    _isInventoryExpanded = widget.activePage.startsWith('/inventory') ||
        widget.activePage == '/archiveList' ||
        widget.activePage == '/auditLog';
    _isBookingsExpanded = widget.activePage.startsWith('/bookings') ||
        widget.activePage == '/bookingsCalendar' ||
        widget.activePage == '/transactions';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return isMobile
        ? _buildDrawer(context)
        : Container(
            width: 250,
            color: const Color(0xFF00AEEF),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo_white.png',
                      height: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
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
                        isActive: false, // Parent should not be active
                        isExpanded: _isInventoryExpanded,
                        onTap: () {
                          setState(() {
                            _isInventoryExpanded = !_isInventoryExpanded;
                          });
                        },
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
                          icon: FontAwesomeIcons.clockRotateLeft,
                          title: 'Audit Log',
                          route: '/auditLog',
                          isActive: _activeSubItem == '/auditLog',
                          onTap: () => _navigateTo('/auditLog'),
                        ),
                      ],
                      SidebarItemWithDropdown(
                        icon: FontAwesomeIcons.calendarDays,
                        title: 'Bookings',
                        isActive: false, // Parent should not be active
                        isExpanded: _isBookingsExpanded,
                        onTap: () {
                          setState(() {
                            _isBookingsExpanded = !_isBookingsExpanded;
                          });
                        },
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
                      SidebarItem(
                        icon: FontAwesomeIcons.truck,
                        title: 'Suppliers',
                        route: '/suppliers',
                        isActive: widget.activePage == '/suppliers',
                        onTap: () {
                          _navigateToMainPage('/suppliers');
                        },
                      ),
                      SidebarItem(
                        icon: FontAwesomeIcons.gears,
                        title: 'Services',
                        route: '/services',
                        isActive: widget.activePage == '/services',
                        onTap: () {
                          _navigateToMainPage('/services');
                        },
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

      // Only expand dropdowns if the route belongs to their group
      if (route.startsWith('/inventory')) {
        _isInventoryExpanded = true;
      } else if (route.startsWith('/bookings')) {
        _isBookingsExpanded = true;
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.pushNamed(context, route);
      widget.onClose?.call();
    });
  }

  void _navigateToMainPage(String route) {
    setState(() {
      _activeSubItem = '';
    });

    Navigator.pushNamed(context, route);
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
                  isActive: false, // Parent should not be active
                  isExpanded: _isInventoryExpanded,
                  onTap: () {
                    setState(() {
                      _isInventoryExpanded = !_isInventoryExpanded;
                    });
                  },
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
                    icon: FontAwesomeIcons.clockRotateLeft,
                    title: 'Audit Log',
                    route: '/auditLog',
                    isActive: _activeSubItem == '/auditLog',
                    onTap: () => _navigateTo('/auditLog'),
                  ),
                ],
                SidebarItemWithDropdown(
                  icon: FontAwesomeIcons.calendarDays,
                  title: 'Bookings',
                  isActive: false, // Parent should not be active
                  isExpanded: _isBookingsExpanded,
                  onTap: () {
                    setState(() {
                      _isBookingsExpanded = !_isBookingsExpanded;
                    });
                  },
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
                SidebarItem(
                  icon: FontAwesomeIcons.truck,
                  title: 'Suppliers',
                  route: '/suppliers',
                  isActive: widget.activePage == '/suppliers',
                  onTap: () {
                    _navigateToMainPage('/suppliers');
                  },
                ),
                SidebarItem(
                  icon: FontAwesomeIcons.gears,
                  title: 'Services',
                  route: '/services',
                  isActive: widget.activePage == '/services',
                  onTap: () {
                    _navigateToMainPage('/services');
                  },
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

  Widget _buildLogoutButton(BuildContext context) {
    return SidebarItem(
      icon: FontAwesomeIcons.rightFromBracket,
      title: 'Logout',
      route: '/login',
      isActive: false,
      onTap: () {
        _navigateToMainPage('/login');
      },
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
