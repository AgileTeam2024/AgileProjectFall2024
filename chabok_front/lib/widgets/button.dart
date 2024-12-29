import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final IconData? icon;
  final void Function()? onPressed;

  final ButtonType type;

  const Button({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    required this.type,
  });

  const Button.text({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
  }) : type = ButtonType.text;

  const Button.outlined({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
  }) : type = ButtonType.outlined;

  const Button.filled({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
  }) : type = ButtonType.filled;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Icon(icon),
        ),
        Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
    switch (type) {
      case ButtonType.text:
        return TextButton(onPressed: onPressed, child: child);
      case ButtonType.outlined:
        return OutlinedButton(onPressed: onPressed, child: child);
      case ButtonType.filled:
        return ElevatedButton(onPressed: onPressed, child: child);
    }
  }
}

enum ButtonType { text, outlined, filled }
