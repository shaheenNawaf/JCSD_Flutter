import 'package:flutter/material.dart';
import 'dart:async';

class ToastManager {
  static final ToastManager _instance = ToastManager._internal();
  factory ToastManager() => _instance;
  ToastManager._internal();

  final List<OverlayEntry> _toasts = [  ];
  OverlayState? _overlayState;

  void showToast(BuildContext context, String message, Color color) {
    _overlayState ??= Overlay.of(context);

    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 20 + (_toasts.indexOf(overlayEntry) * 80),
          right: 20,
          child: Material(
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.4),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: color, width: 2),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: color,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    _toasts.add(overlayEntry);
    _overlayState!.insert(overlayEntry);

    Timer(const Duration(seconds: 5), () {
      _removeToast(overlayEntry);
    });
  }

  void _removeToast(OverlayEntry overlayEntry) {
    overlayEntry.remove();
    _toasts.remove(overlayEntry);
    _updatePositions();
  }

  void _updatePositions() {
    for (final entry in _toasts) {
      entry.markNeedsBuild();
    }
  }
}