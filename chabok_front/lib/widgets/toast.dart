import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomToast extends StatelessWidget {
  final String text;
  final ToastType toastType;

  const CustomToast({super.key, required this.text, required this.toastType});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: toastType.backgroundColor,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: toastType.foregroundColor),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 1)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: toastType.foregroundColor,
          ),
        ),
      ),
    );
  }

  static void showToast(BuildContext context, String message, ToastType type) {
    final toast = FToast();
    toast.init(context);
    toast.showToast(
      child: CustomToast(
        text: message,
        toastType: type,
      ),
      gravity: ToastGravity.BOTTOM_LEFT,
    );
  }
}

enum ToastType {
  error,
  warning,
  success;

  Color get backgroundColor {
    switch (this) {
      case ToastType.error:
        return Colors.red.shade100;
      case ToastType.warning:
        return Colors.yellow.shade100;
      case ToastType.success:
        return Colors.green.shade100;
    }
  }

  Color get foregroundColor {
    switch (this) {
      case ToastType.error:
        return Colors.red.shade900;
      case ToastType.warning:
        return Colors.yellow.shade900;
      case ToastType.success:
        return Colors.green.shade900;
    }
  }
}
