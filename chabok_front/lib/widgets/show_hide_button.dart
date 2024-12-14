import 'package:chabok_front/widgets/button.dart';
import 'package:flutter/material.dart';

class ShowHideButton extends StatelessWidget {
  final bool isShown;
  final void Function() toggleIsShown;

  const ShowHideButton({
    super.key,
    required this.isShown,
    required this.toggleIsShown,
  });

  @override
  Widget build(BuildContext context) {
    return Button.text(
      text: isShown ? 'HIDE' : 'SHOW',
      onPressed: toggleIsShown,
    );
  }
}
