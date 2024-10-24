import 'package:flutter/material.dart';
import 'package:jcsd_flutter/widgets/navBar.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: Center(
        child: Text('Welcome to Home View!'),
      ),
    );
  }
}