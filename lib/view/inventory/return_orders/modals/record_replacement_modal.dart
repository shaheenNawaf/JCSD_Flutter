// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

class RecordReplacementModal extends StatefulWidget {
  final String productName;
  final String originalSerial;

  const RecordReplacementModal({
    super.key,
    required this.productName,
    required this.originalSerial,
  });

  @override
  State<RecordReplacementModal> createState() => _RecordReplacementModalState();
}

class _RecordReplacementModalState extends State<RecordReplacementModal> {
  final _formKey = GlobalKey<FormState>();
  final _newSerialController = TextEditingController();
  final _dateReceivedController = TextEditingController();
  final _costController = TextEditingController();
  DateTime _selectedDateReceived = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateReceivedController.text =
        DateFormat('MM/dd/yyyy').format(_selectedDateReceived);
  }

  @override
  void dispose() {
    _newSerialController.dispose();
    _dateReceivedController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateReceived,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null && picked != _selectedDateReceived) {
      setState(() {
        _selectedDateReceived = picked;
        _dateReceivedController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  void _submitReplacement() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'newSerialNumber': _newSerialController.text.trim(),
        'dateReceived': _selectedDateReceived,
        'cost': double.tryParse(_costController.text.trim()),
      });
    } else {
      ToastManager()
          .showToast(context, "Please correct errors.", Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Record Replacement for ${widget.productName}',
          style: const TextStyle(fontSize: 16)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Original Serial: ${widget.originalSerial}",
                  style: const TextStyle(
                      fontSize: 13, fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newSerialController,
                decoration: const InputDecoration(
                    labelText: 'New Replacement Serial Number*',
                    border: OutlineInputBorder()),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'New Serial is required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateReceivedController,
                decoration: InputDecoration(
                  labelText: 'Date Replacement Received*',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Date is required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                    labelText: 'Actual Cost of Replacement (Optional)',
                    border: OutlineInputBorder(),
                    prefixText: "₱"),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                ],
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      (double.tryParse(value) == null ||
                          double.parse(value) < 0)) {
                    return 'Invalid cost';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
            onPressed: _submitReplacement,
            child: const Text('Save Replacement')),
      ],
    );
  }
}
