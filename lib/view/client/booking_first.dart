import 'package:flutter/material.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';

class ClientBooking1 extends StatelessWidget {
  const ClientBooking1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(activePage: 'booking'),
      body: Center(
        child: Container(
          color: const Color(0xFFDFDFDF),
        ),
      ),
    );
  }
}
