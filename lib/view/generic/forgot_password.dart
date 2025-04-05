import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';
import 'dart:async';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _emailController = TextEditingController();
  bool _isSending = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendResetPasswordEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    if (_isSending || _countdown > 0) return;

    setState(() {
      _isSending = true;
      _countdown = 60;
    });

    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: "http://localhost:3000/resetPassword",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password reset email sent! Check your inbox.')),
      );

      _startCountdown();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending reset email: $error')),
      );
      setState(() {
        _isSending = false;
        _countdown = 0;
      });
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isSending = false;
        });
      }
    });
  }

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
                                    Icons.lock_reset,
                                    size: 50,
                                    color: Color(0xFF00AEEF),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Forgot Your Password?',
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
                                    'Enter your email below, and we’ll send you a\nlink to reset your password.',
                                    style: TextStyle(
                                      fontFamily: 'NunitoSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Center(
                                  child: Text(
                                    'The reset link will be valid for 24 hours.\nIf you don’t receive an email within a few minutes, please check your spam folder or try again.',
                                    style: TextStyle(
                                      fontFamily: 'NunitoSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                buildTextField(
                                  label: 'Email Address',
                                  hintText: 'Enter your email',
                                  controller: _emailController,
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
                                    onPressed: _isSending || _countdown > 0
                                        ? null
                                        : _sendResetPasswordEmail,
                                    child: _isSending
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : Text(
                                            _countdown > 0
                                                ? 'Resend in $_countdown sec'
                                                : 'Send Reset Link',
                                            style: const TextStyle(
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

Widget buildTextField({
  required String label,
  required String hintText,
  required TextEditingController controller,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
              fontWeight: FontWeight.normal,
            ),
          ),
          const Text(
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
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w300,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}
