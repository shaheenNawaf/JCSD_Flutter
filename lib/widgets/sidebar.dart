// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Sidebar extends StatelessWidget {
  final String activePage;
  final VoidCallback? onClose;

  const Sidebar({super.key, this.activePage = '', this.onClose});

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
                        route: '/',
                        isActive: activePage == 'dashboard',
                        onTap: () {
                          Navigator.pushNamed(context, '/');
                          onClose?.call();
                        },
                      ),
                      SidebarItem(
                        icon: FontAwesomeIcons.boxOpen,
                        title: 'Inventory',
                        route: '/inventory',
                        isActive: activePage == 'inventory',
                        onTap: () {
                          Navigator.pushNamed(context, '/inventory');
                          onClose?.call();
                        },
                      ),
                      SidebarItem(
                        icon: FontAwesomeIcons.truck,
                        title: 'Suppliers',
                        route: '/suppliers',
                        isActive: activePage == 'suppliers',
                        onTap: () {
                          Navigator.pushNamed(context, '/suppliers');
                          onClose?.call();
                        },
                      ),
                      SidebarItem(
                        icon: FontAwesomeIcons.calendarDays,
                        title: 'Bookings',
                        route: '/bookings',
                        isActive: activePage == 'bookings',
                        onTap: () {
                          Navigator.pushNamed(context, '/bookings');
                          onClose?.call();
                        },
                      ),
                      SidebarItem(
                        icon: FontAwesomeIcons.gears,
                        title: 'Services',
                        route: '/services',
                        isActive: activePage == 'services',
                        onTap: () {
                          Navigator.pushNamed(context, '/services');
                          onClose?.call();
                        },
                      ),
                    ],
                  ),
                ),
                _buildLogoutButton(context),
                const SizedBox(
                    height: 16), // Add spacing below the logout button
              ],
            ),
          );
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
                  route: '/',
                  isActive: activePage == 'dashboard',
                  onTap: () {
                    Navigator.pushNamed(context, '/');
                    onClose?.call();
                  },
                ),
                SidebarItem(
                  icon: FontAwesomeIcons.boxOpen,
                  title: 'Inventory',
                  route: '/inventory',
                  isActive: activePage == 'inventory',
                  onTap: () {
                    Navigator.pushNamed(context, '/inventory');
                    onClose?.call();
                  },
                ),
                SidebarItem(
                  icon: FontAwesomeIcons.truck,
                  title: 'Suppliers',
                  route: '/suppliers',
                  isActive: activePage == 'suppliers',
                  onTap: () {
                    Navigator.pushNamed(context, '/suppliers');
                    onClose?.call();
                  },
                ),
                SidebarItem(
                  icon: FontAwesomeIcons.calendarDays,
                  title: 'Bookings',
                  route: '/bookings',
                  isActive: activePage == 'bookings',
                  onTap: () {
                    Navigator.pushNamed(context, '/bookings');
                    onClose?.call();
                  },
                ),
                SidebarItem(
                  icon: FontAwesomeIcons.gears,
                  title: 'Services',
                  route: '/services',
                  isActive: activePage == 'services',
                  onTap: () {
                    Navigator.pushNamed(context, '/services');
                    onClose?.call();
                  },
                ),
              ],
            ),
          ),
          _buildLogoutButton(context),
          const SizedBox(height: 16), // Add spacing below the logout button
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
        Navigator.pushNamed(context, '/login');
        onClose?.call();
      },
    );
  }
}

class SidebarItem extends StatefulWidget {
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
  _SidebarItemState createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = const Color.fromARGB(255, 93, 211, 254).withOpacity(0.2);
    const activeColor = Color.fromARGB(255, 33, 199, 255);

    return MouseRegion(
      onEnter: (_) => setState(() {
        _isHovered = true;
      }),
      onExit: (_) => setState(() {
        _isHovered = false;
      }),
      child: Container(
        color: widget.isActive
            ? activeColor
            : _isHovered
                ? hoverColor
                : Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
          leading: FaIcon(
            widget.icon,
            color: Colors.white,
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
