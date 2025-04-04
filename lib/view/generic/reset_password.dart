import 'package:flutter/material.dart';
import 'package:jcsd_flutter/view/generic/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();

    // Optional debug log
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = Uri.base;
      print("Reset Password URI: ${uri.toString()}");
    });
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      ToastManager().showToast(context, 'Please fill in all fields', Color.fromARGB(255, 255, 0, 0));
      return;
    }

    if (password.length < 6) {
      ToastManager().showToast(context, 'Password must be at least 6 characters long', Color.fromARGB(255, 255, 0, 0));
      return;
    }

    if (password != confirmPassword) {
      ToastManager().showToast(context, 'Passwords do not match.', Color.fromARGB(255, 255, 0, 0));
      return;
    }

    final currentSession = supabase.auth.currentSession;

    if (currentSession == null) {
      ToastManager().showToast(context, 'Session not found. Please use a valid password reset link.', Color.fromARGB(255, 255, 0, 0));

      return;
    }

    setState(() => _isResetting = true);

    try {
      await supabase.auth.updateUser(UserAttributes(password: password));
      ToastManager().showToast(context, 'Password reset successful! Please log in.', Color.fromARGB(255, 0, 143, 19));
      Navigator.pushReplacementNamed(context, '/login');
    } catch (error) {
      print('Error resetting password: $error');
      ToastManager().showToast(context, 'Error resetting password: $error', Color.fromARGB(255, 255, 0, 0));
    } finally {
      setState(() => _isResetting = false);
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
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
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
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                        color: const Color(0xFF00AEEF),
                                        width: 4),
                                  ),
                                  child: const Icon(Icons.lock,
                                      size: 50, color: Color(0xFF00AEEF)),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Reset Your Password',
                                  style: TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 10),
                                buildPasswordField(
                                  label: 'New Password',
                                  hintText: 'Enter new password',
                                  controller: _passwordController,
                                  isHidden: _isPasswordHidden,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _isPasswordHidden = !_isPasswordHidden;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                buildPasswordField(
                                  label: 'Confirm Password',
                                  hintText: 'Re-enter new password',
                                  controller: _confirmPasswordController,
                                  isHidden: _isConfirmPasswordHidden,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _isConfirmPasswordHidden =
                                          !_isConfirmPasswordHidden;
                                    });
                                  },
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
                                        _isResetting ? null : _resetPassword,
                                    child: _isResetting
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : const Text(
                                            'Reset Password',
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
                fontFamily: 'NunitoSans', fontWeight: FontWeight.normal),
          ),
          const Text(
            '*',
            style: TextStyle(color: Colors.red, fontSize: 14),
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
          suffixIcon: IconButton(
            icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility),
            onPressed: onVisibilityToggle,
          ),
        ),
      ),
    ],
  );
}
