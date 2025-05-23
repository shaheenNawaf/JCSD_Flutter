// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CashAdvanceForm extends StatefulWidget {
  const CashAdvanceForm({super.key});

  @override
  _CashAdvanceFormState createState() => _CashAdvanceFormState();
}

class _CashAdvanceFormState extends State<CashAdvanceForm> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 300 ? 400 : screenWidth * 0.9;
    const double containerHeight = 300;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: Container(
        width: containerWidth,
        height: containerHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: const BoxDecoration(
                color: Color(0xFF00AEEF),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: const Center(
                child: Text(
                  'Cash Advance Request',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Amount',
                    hintText: 'Enter amount (min: 2000)',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Reason',
                    hintText: 'Enter your reason',
                    controller: _reasonController,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: const BorderSide(
                            color: Color(0xFF00AEEF),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00AEEF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final supabase = Supabase.instance.client;
                        final user = supabase.auth.currentUser;
                        final amountText = _amountController.text.trim();
                        final reason = _reasonController.text.trim();

                        if (user == null ||
                            amountText.isEmpty ||
                            reason.isEmpty) {
                          ToastManager().showToast(
                              context,
                              "Please fill in all required fields.",
                              Colors.red);
                          return;
                        }

                        final amount = double.tryParse(amountText);
                        if (amount == null || amount < 2000) {
                          ToastManager().showToast(context,
                              "Amount must be at least 2000.", Colors.red);
                          return;
                        }

                        try {
                          final employeeData = await supabase
                              .from('employee')
                              .select('employeeID, monthlySalary')
                              .eq('"userID"', user.id)
                              .maybeSingle();

                          if (employeeData == null) {
                            ToastManager().showToast(context,
                                "Employee record not found.", Colors.red);
                            return;
                          }

                          await supabase.from('cash_advance').insert({
                            'employeeID': employeeData['employeeID'],
                            'monthlySalary': employeeData['monthlySalary'],
                            'cashAdvance': amount,
                            'reason': reason,
                            'status': 'Pending',
                          });

                          if (context.mounted) {
                            Navigator.pop(context);
                            ToastManager().showToast(
                                context,
                                "Cash advance request submitted.",
                                Colors.green);
                          }
                        } catch (error) {
                          ToastManager()
                              .showToast(context, "Error: $error", Colors.red);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00AEEF),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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
}
