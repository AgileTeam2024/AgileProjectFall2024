import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final void Function()? onPressed;

  final ButtonType type;

  const Button({
    super.key,
    this.text,
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

  const Button.icon({
    super.key,
    this.icon,
    this.onPressed,
  })  : type = ButtonType.icon,
        text = '';

  @override
  Widget build(BuildContext context) {
    final child = Row(
      spacing: 3,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) Icon(icon),
        Text(
          text ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
    switch (type) {
      case ButtonType.text:
        return TextButton(onPressed: onPressed, child: child);
      case ButtonType.outlined:
        return OutlinedButton(onPressed: onPressed, child: child);
      case ButtonType.filled:
        return ElevatedButton(onPressed: onPressed, child: child);
      case ButtonType.icon:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white54,
          ),
          child: IconButton(onPressed: onPressed, icon: Icon(icon)),
        );
    }
  }
}

enum ButtonType { text, outlined, filled, icon }
