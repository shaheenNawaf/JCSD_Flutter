import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final String activePage;

  const Navbar({super.key, this.activePage = ''});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset('assets/images/logo.png', height: 40),
          const Spacer(),
          NavItem(title: 'Home', route: '/', isActive: activePage == 'home'),
          NavItem(
              title: 'Services',
              route: '/services',
              isActive: activePage == 'services'),
          NavItem(
              title: 'About Us',
              route: '/about',
              isActive: activePage == 'about'),
          NavItem(
              title: 'Login', route: '/login', isActive: activePage == 'login'),
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
