//Generic rani na Alert Box, usable anywhere fyi
import 'package:flutter/material.dart';

Future<void> showCustomNotificationDialog({
  required BuildContext context,
  required String headerBar,
  required String messageText,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, //Handles tapping outside
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
        actionsPadding: const EdgeInsets.fromLTRB(0, 10.0, 24.0, 16.0),

        title: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12.0),
            ),
          ),
          child: Text(
            headerBar,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        content: SingleChildScrollView(
          child: Text(
            messageText,
            style: const TextStyle(fontSize: 16),
          ),
        ),

        // Actions (Close Button)
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}
