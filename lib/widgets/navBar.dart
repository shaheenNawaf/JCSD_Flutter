import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  Navbar({Key? key})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Image.asset(
        'assets/images/logo.png',
        height: 40,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {},
          child: Text('Home', style: TextStyle(color: const Color.fromARGB(255, 0, 174, 239))),
        ),
        TextButton(
          onPressed: () {},
          child: Text('Services', style: TextStyle(color: const Color.fromARGB(255, 0, 174, 239))),
        ),
        TextButton(
          onPressed: () {},
          child: Text('About Us', style: TextStyle(color: const Color.fromARGB(255, 0, 174, 239))),
        ),
        TextButton(
          onPressed: () {},
          child: Text('Login', style: TextStyle(color: const Color.fromARGB(255, 0, 174, 239))),
        ),
      ],
    );
  }
}