import 'package:chabok_front/enums/toast_type.dart';
import 'package:chabok_front/models/server_response.dart';
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

  static void showToast(BuildContext context, ServerResponse response) {
    const isTest = bool.fromEnvironment('testing_mode', defaultValue: false);
    if (isTest) return;

    final toast = FToast();
    toast.init(context);
    toast.showToast(
      child: CustomToast(
        text: response.message!,
        toastType: response.isOk ? ToastType.success : ToastType.error,
      ),
      gravity: ToastGravity.BOTTOM_LEFT,
    );
  }
}
