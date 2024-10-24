// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:jcsd_flutter/widgets/navBar.dart';

class SignupPage1 extends StatefulWidget {
  const SignupPage1({super.key});

  @override
  _SignupPage1State createState() => _SignupPage1State();
}

class _SignupPage1State extends State<SignupPage1> {
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double fixedHeight = 700;

    return Scaffold(
      appBar: const Navbar(activePage: 'signup'),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double containerWidth =
                      screenWidth > 600 ? 500 : screenWidth * 0.9;

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: containerWidth,
                            height: fixedHeight,
                            padding: const EdgeInsets.all(32.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Araw-araw kalidad!',
                                  style: TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'sign-up to book!',
                                  style: TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Row(
                                  children: [
                                    AutoSizeText(
                                      'Email Address',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '*',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                const TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Email address',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w300,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Row(
                                  children: [
                                    AutoSizeText(
                                      'Username',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '*',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                const TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Enter your username',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w300,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Row(
                                  children: [
                                    AutoSizeText(
                                      'Password',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '*',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                TextField(
                                  obscureText: _isPasswordHidden,
                                  decoration: InputDecoration(
                                    hintText: 'Password goes here',
                                    hintStyle: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w300,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordHidden
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordHidden =
                                              !_isPasswordHidden;
                                        });
                                      },
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Row(
                                  children: [
                                    AutoSizeText(
                                      'Repeat Password',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '*',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                TextField(
                                  obscureText: _isConfirmPasswordHidden,
                                  decoration: InputDecoration(
                                    hintText: 'Repeat your password',
                                    hintStyle: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w300,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isConfirmPasswordHidden
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isConfirmPasswordHidden =
                                              !_isConfirmPasswordHidden;
                                        });
                                      },
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00AEEF),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 100, vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/signup2');
                                    },
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  '— or Sign up with —',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          side: const BorderSide(
                                              color: Color(0xFF00AEEF)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        onPressed: () {},
                                        child: const Text(
                                          'Google',
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF00AEEF),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          side: const BorderSide(
                                              color: Color(0xFF00AEEF)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        onPressed: () {},
                                        child: const Text(
                                          'Other option',
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF00AEEF),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Have an account?",
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/login');
                                      },
                                      child: const Text(
                                        'Login here',
                                        style: TextStyle(
                                          color: Color(0xFF00AEEF),
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
