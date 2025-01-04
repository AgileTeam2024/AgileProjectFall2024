import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final int? errorCode;
  final String? message;

  const ErrorPage({super.key, this.errorCode, this.message});

  @override
  Widget build(BuildContext context) {
    final errorStyle = Theme.of(context)
        .textTheme
        .displaySmall
        ?.copyWith(fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
      child: Center(
        child: Column(
          spacing: 15,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Image.asset(
                'assets/error/${errorCode ?? "general"}.png',
                fit: BoxFit.cover,
              ),
            ),
            if (message != null) Text(message!, style: errorStyle)
          ],
        ),
      ),
    );
  }
}
