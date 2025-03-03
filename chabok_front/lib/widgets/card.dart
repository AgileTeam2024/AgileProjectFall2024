import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final EdgeInsets? padding, margin;
  final Widget child;

  const CardWidget({super.key, required this.child, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(vertical: 50, horizontal: 25),
      margin: margin ?? EdgeInsets.symmetric(vertical: 50, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(color: Colors.black12, spreadRadius: 3, blurRadius: 2),
        ],
      ),
      child: child,
    );
  }
}
