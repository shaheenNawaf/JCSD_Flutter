// ignore_for_file: library_private_types_in_public_api, unused_import

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isPasswordHidden = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  Future<void> _signInWithEmail() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password cannot be empty!')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful: ${response.user!.email}')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://taaxqkxerbpgftybxtws.supabase.co/auth/v1/callback',
      );

      await Future.delayed(const Duration(seconds: 3));

      final session = supabase.auth.currentSession;

      if (session != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In successful')),
        );
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in failed. Try again.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In Error: $error')),
      );
    }
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
              color: Colors.black.withValues(alpha: 0.7),
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
                                const Text(
                                  'Welcome back, friend!',
                                  style: TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Sign-in to your account to continue',
                                  style: TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                buildTextField(
                                  label: 'Username or Email',
                                  hintText: 'Enter Username or Email',
                                  controller: _emailController,
                                ),
                                const SizedBox(height: 10),
                                buildPasswordField(
                                  label: 'Password',
                                  hintText: 'Password goes here',
                                  controller: _passwordController,
                                  isHidden: _isPasswordHidden,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _isPasswordHidden = !_isPasswordHidden;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _rememberMe = value!;
                                            });
                                          },
                                        ),
                                        const Text(
                                          'Remember me',
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/forgotPassword');
                                      },
                                      child: const Text(
                                        'Forgot your details?',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                    onPressed:
                                        _isLoading ? null : _signInWithEmail,
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : const Text(
                                            'Login',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text('— or Sign in with —'),
                                const SizedBox(height: 20),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    side: const BorderSide(
                                        color: Color(0xFF00AEEF)),
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                  ),
                                  onPressed: _signInWithGoogle,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/Google.png',
                                        height: 18,
                                        width: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Google',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF00AEEF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Don’t have an Account?"),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/signup1');
                                      },
                                      child: const Text(
                                        'Register',
                                        style: TextStyle(
                                          color: Color(0xFF00AEEF),
                                          fontWeight: FontWeight.bold,
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

Widget buildPasswordField({
  required String label,
  required String hintText,
  required TextEditingController controller,
  required bool isHidden,
  required VoidCallback onVisibilityToggle,
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
        obscureText: isHidden,
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w300,
            fontSize: 12,
          ),
          suffixIcon: IconButton(
            icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility),
            onPressed: onVisibilityToggle,
          ),
        ),
      ),
    ],
  );
}
