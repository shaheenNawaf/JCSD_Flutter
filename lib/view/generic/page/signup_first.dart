import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../api/global_variables.dart';

class SignupPage1 extends StatefulWidget {
  const SignupPage1({super.key});

  @override
  _SignupPage1State createState() => _SignupPage1State();
}

class _SignupPage1State extends State<SignupPage1> {
  // Controllers for the input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  // State variables for password visibility
  bool _isPasswordHidden = true;
  bool _isLoading = false;
  bool _isConfirmPasswordHidden = true;

  // Error string to display on the modal
  String? errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final repeatPassword = _repeatPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || repeatPassword.isEmpty) {

      ToastManager().showToast(context, 'Please fill in all fields.', const Color.fromARGB(255, 255, 0, 0));
      setState(() => _isLoading = false);
      return;
    }

    if (password.length < 6) {
      ToastManager().showToast(context, 'Password must be at least 6 characters.', const Color.fromARGB(255, 255, 0, 0));
      setState(() => _isLoading = false);
      return;
    }

    if (password != repeatPassword) {
      ToastManager().showToast(context, 'Passwords do not match.', const Color.fromARGB(255, 255, 0, 0));
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await supabaseDB.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        final insertResponse = await supabaseDB
            .from('accounts')
            .insert({
              'email': user.email,
              'userID': user.id,
            })
            .select()
            .single();

        debugPrint("Insert result: $insertResponse");
      }

      if (response.user != null) {
        ToastManager().showToast(context, 'Signup successful! Check your email for verification.', const Color.fromARGB(255, 0, 143, 19));

        await supabaseDB.auth.signOut();

        if (mounted) {
          context.push(
            '/emailVerification?email=${Uri.encodeComponent(email)}',
          );
        }
      }
    } 
    on AuthException catch (error) {
      ToastManager().showToast(context, error.message, const Color.fromARGB(255, 255, 0, 0));
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      ToastManager().showToast(context, 'Something went wrong.', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double fixedHeight = 640;
    return Scaffold(
      appBar: const Navbar(activePage: 'register'),
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
                                buildTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  hintText: 'Email address',
                                ),
                                const SizedBox(height: 10),
                                buildPasswordField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hintText: 'Password goes here',
                                  isHidden: _isPasswordHidden,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _isPasswordHidden = !_isPasswordHidden;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                buildPasswordField(
                                  controller: _repeatPasswordController,
                                  label: 'Repeat Password',
                                  hintText: 'Repeat your password',
                                  isHidden: _isConfirmPasswordHidden,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _isConfirmPasswordHidden =
                                          !_isConfirmPasswordHidden;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                if (errorText != null)
                                  Text(
                                    errorText!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 16),
                                  ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00AEEF),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 100, vertical: 20),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                    ),
                                    onPressed: _isLoading
                                        ? null
                                        : _signUp, // Fixed: Calls the method properly
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : const Text(
                                            'Continue',
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
                                const Text(
                                  '— or Sign up with —',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      side: const BorderSide(
                                          color: Color(0xFF00AEEF)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                        context.go('/login');
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
    required bool isHidden,
    required VoidCallback onVisibilityToggle,
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
}