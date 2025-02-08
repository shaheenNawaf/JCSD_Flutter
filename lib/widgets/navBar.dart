// ignore: file_names
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final String activePage;

  const Navbar({super.key, this.activePage = ''});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isMobileView = screenWidth < 600;

    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Logo for all pages except Access Restricted
          if (activePage != 'accessRestricted')
            Image.asset(
              isMobileView
                  ? 'assets/images/logo_mobile.png'
                  : 'assets/images/logo.png',
              height: 40,
            ),
          if (activePage != 'accessRestricted') const Spacer(),
          // Back to Home for Access Restricted
          if (activePage == 'accessRestricted')
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF00AEEF),
                  ),
                ),
              ),
            )
          // Mobile View Navbar (PopupMenu)
          else if (isMobileView)
            PopupMenuButton<String>(
              icon: const Icon(FontAwesomeIcons.bars, color: Color(0xFF00AEEF)),
              onSelected: (value) {
                Navigator.pushNamed(context, value);
              },
              color: Colors.white,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: '/home',
                  child: Text(
                    'Home',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: activePage == 'home'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: const Color(0xFF00AEEF),
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: '/services',
                  child: Text(
                    'Services',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: activePage == 'services'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: const Color(0xFF00AEEF),
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: '/about',
                  child: Text(
                    'About Us',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: activePage == 'about'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: const Color(0xFF00AEEF),
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: activePage == 'register' ? '/signup1' : '/login',
                  child: Text(
                    activePage == 'register' ? 'Register' : 'Login',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight:
                          (activePage == 'login' || activePage == 'register')
                              ? FontWeight.bold
                              : FontWeight.normal,
                      color: const Color(0xFF00AEEF),
                    ),
                  ),
                ),
              ],
            )
          // Regular Navbar for larger screens
          else
            Row(
              children: [
                NavItem(
                  title: 'Home',
                  route: '/home',
                  isActive: activePage == 'home' || activePage == 'HomeView',
                ),
                NavItem(
                  title: 'Services',
                  route: '/services',
                  isActive: activePage == 'services',
                ),
                NavItem(
                  title: 'About Us',
                  route: '/about',
                  isActive: activePage == 'about',
                ),
                NavItem(
                  title: activePage == 'register' ? 'Register' : 'Login',
                  route: activePage == 'register' ? '/signup1' : '/login',
                  isActive: activePage == 'login' || activePage == 'register',
                ),
              ],
            ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NavItem extends StatelessWidget {
  final String title;
  final String route;
  final bool isActive;

  const NavItem({
    super.key,
    required this.title,
    required this.route,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'NunitoSans',
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF00AEEF),
        ),
      ),
    );
  }
}
