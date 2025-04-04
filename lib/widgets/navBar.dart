// ignore: file_names
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/view/generic/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final String activePage;
  final bool showBackButton;

  const Navbar({
    super.key, 
    this.activePage = '',
    this.showBackButton = false,
  });

  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (error) {
      if (context.mounted) {
        ToastManager().showToast(context, 'Logout failed: $error', Color.fromARGB(255, 255, 0, 0));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileView = screenWidth < 600;
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

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
          
          const Spacer(),

          if (showBackButton)
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'Back',
                style: TextStyle(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF00AEEF),
                ),
              ),
            )
          else if (isMobileView)
            _buildMobileMenu(context, isLoggedIn)
          else
            _buildDesktopMenu(context, isLoggedIn),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildMobileMenu(BuildContext context, bool isLoggedIn) {
    return PopupMenuButton<String>(
      icon: const Icon(FontAwesomeIcons.bars, color: Color(0xFF00AEEF)),
      onSelected: (value) {
        if (value == 'logout') {
          _logout(context);
        } else {
          context.go(value);
        }
      },
      color: Colors.white,
      itemBuilder: (BuildContext context) => [
        _buildPopupItem('Home', '/home', 'home'),
        _buildPopupItem('Services', '/services', 'services'),
        _buildPopupItem(
          isLoggedIn ? 'Logout' : 'Login',
          isLoggedIn ? 'logout' : '/login',
          isLoggedIn ? '' : 'login',
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String title, String value, String page) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'NunitoSans',
          fontWeight: activePage == page ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF00AEEF),
        ),
      ),
    );
  }

  Widget _buildDesktopMenu(BuildContext context, bool isLoggedIn) {
    return Row(
      children: [
        NavItem(
          title: 'Home',
          route: '/home',
          isActive: activePage == 'home',
          onTap: () => context.go('/home'),
        ),
        NavItem(
          title: 'Services',
          route: '/services',
          isActive: activePage == 'services',
          onTap: () => context.go('/services'),
        ),
        NavItem(
          title: isLoggedIn ? 'Logout' : 'Login',
          route: isLoggedIn ? '' : '/login',
          isActive: activePage == 'login',
          onTap: () => isLoggedIn ? _logout(context) : context.go('/login'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NavItem extends StatelessWidget {
  final String title;
  final String route;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.title,
    required this.route,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'NunitoSans',
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF00AEEF),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}