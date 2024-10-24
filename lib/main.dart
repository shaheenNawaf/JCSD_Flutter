import 'package:flutter/material.dart';
import 'package:jcsd_flutter/view/homeView.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JCSD',
      home: HomeView()
    );
  }
}
