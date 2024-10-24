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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      title: Image.asset(
        'assets/images/logo.png',
        height: 40,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {},
          child: Text('Home', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}