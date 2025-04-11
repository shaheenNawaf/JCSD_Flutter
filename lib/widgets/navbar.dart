import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final String activePage;

  const Navbar({super.key, this.activePage = ''});

  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: \$error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileView = screenWidth < 600;
    final session = Supabase.instance.client.auth.currentSession;
    final user = session?.user;
    final bool isLoggedIn = user != null;
    final username = user?.email ?? 'Guest';

    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (activePage != 'accessRestricted')
            Image.asset(
              isMobileView
                  ? 'assets/images/logo_mobile.png'
                  : 'assets/images/logo.png',
              height: 40,
            ),
          if (activePage != 'accessRestricted') const Spacer(),
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
          else if (isMobileView)
            PopupMenuButton<String>(
              icon: const Icon(FontAwesomeIcons.bars, color: Color(0xFF00AEEF)),
              onSelected: (value) {
                if (value == 'logout') {
                  _logout(context);
                } else {
                  Navigator.pushNamed(context, value);
                }
              },
              color: Colors.white,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: '/home',
                  child: Text('Home'),
                ),
                const PopupMenuItem<String>(
                  value: '/services',
                  child: Text('Services'),
                ),
                PopupMenuItem<String>(
                  value: isLoggedIn ? 'logout' : '/login',
                  child: Text(isLoggedIn ? 'Logout' : 'Login'),
                ),
              ],
            )
          else
            Row(
              children: [
                NavItem(
                  title: 'Home',
                  route: '/home',
                  isActive: activePage == 'home' || activePage == 'HomeView',
                ),
                const SizedBox(width: 10),
                NavItem(
                  title: 'Services',
                  route: '/services',
                  isActive: activePage == 'services',
                ),
                const SizedBox(width: 15),
                if (isLoggedIn)
                  Stack(
                    children: [
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'profile') {
                            Navigator.pushNamed(context, '/profileClient');
                          } else if (value == 'logout') {
                            _logout(context);
                          }
                        },
                        offset: const Offset(0, 40),
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'profile',
                            child: Text('Profile'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'logout',
                            child: Text('Logout'),
                          ),
                        ],
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue,
                          child: Text(
                            username.isNotEmpty
                                ? username[0].toUpperCase()
                                : '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  NavItem(
                    title: 'Login',
                    route: '/login',
                    isActive: activePage == 'login',
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
  final VoidCallback? onTap;

  const NavItem({
    super.key,
    required this.title,
    required this.route,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap ?? () => Navigator.pushNamed(context, route),
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
