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
          Image.asset(
            isMobileView
                ? 'assets/images/logo_mobile.png'
                : 'assets/images/logo.png',
            height: 40,
          ),
          const Spacer(),
          if (isMobileView)
            PopupMenuButton<String>(
              icon: const Icon(FontAwesomeIcons.bars, color: Color(0xFF00AEEF)),
              onSelected: (value) {
                Navigator.pushNamed(context, value);
              },
              color: Colors.white, // Set the background color of the dropdown
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: '/',
                  child: Text(
                    'Home',
                    style: TextStyle(
                      fontWeight: activePage == 'home'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: const Color(0xFF00AEEF), // Set text color to blue
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: '/services',
                  child: Text(
                    'Services',
                    style: TextStyle(
                      fontWeight: activePage == 'services'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: const Color(0xFF00AEEF), // Set text color to blue
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: '/about',
                  child: Text(
                    'About Us',
                    style: TextStyle(
                      fontWeight: activePage == 'about'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: const Color(0xFF00AEEF), // Set text color to blue
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: activePage == 'register' ? '/signup1' : '/login',
                  child: Text(
                    activePage == 'register' ? 'Register' : 'Login',
                    style: TextStyle(
                      fontWeight:
                          (activePage == 'login' || activePage == 'register')
                              ? FontWeight.bold
                              : FontWeight.normal,
                      color: const Color(0xFF00AEEF), // Set text color to blue
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                NavItem(
                    title: 'Home', route: '/', isActive: activePage == 'home'),
                NavItem(
                    title: 'Services',
                    route: '/services',
                    isActive: activePage == 'services'),
                NavItem(
                    title: 'About Us',
                    route: '/about',
                    isActive: activePage == 'about'),
                NavItem(
                    title: activePage == 'register' ? 'Register' : 'Login',
                    route: activePage == 'register' ? '/signup1' : '/login',
                    isActive:
                        activePage == 'login' || activePage == 'register'),
              ],
            ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NavItem extends StatelessWidget {
  final String title;
  final String route;
  final bool isActive;

  const NavItem(
      {super.key,
      required this.title,
      required this.route,
      this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      child: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.blueAccent : Colors.black,
        ),
      ),
    );
  }
}
