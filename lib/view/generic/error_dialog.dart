import 'package:flutter/material.dart';

// Reusable Error Dialog Box Widget
class ErrorDialog extends StatelessWidget {
  final String title;
  final String content;

  const ErrorDialog({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}