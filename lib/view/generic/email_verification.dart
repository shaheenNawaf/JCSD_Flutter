// ignore_for_file: library_private_types_in_public_api, unused_import

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const Navbar(activePage: 'login'),
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
                            padding: const EdgeInsets.all(32.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                  color: const Color(0xFF00AEEF),
                                  width: 4,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.email,
                                  size: 50,
                                  color: Color(0xFF00AEEF),
                                ),
                                ),
                              const SizedBox(height: 20),
                              const Text(
                                'Verify your email address',
                                style: TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 10),
                              const Center(
                              child: Text(
                                'A verification email has been sent to your email. \n Please check your email and click the link to verify your email address and complete your account registration.',
                                style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              ),
                              const SizedBox(height: 20),
                              const Center(
                                child: Text(
                                  'If you did not receive the email, please check \n your spam folder or click the button\nbelow to resend the email.',
                                  style: TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
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
                                  onPressed: () {  },
                                  child: 
                                    const Text(
                                      'Resend Verification Email',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
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