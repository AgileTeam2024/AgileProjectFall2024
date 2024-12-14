import 'package:chabok_front/widgets/button.dart';
import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  final bool isLogged;

  const ProfileButton({super.key, required this.isLogged});

  String get _text => isLogged ? 'Profile' : 'Login / Register';

  void Function() get _onPressed => isLogged ? _goToProfilePage : _goToAuthPage;

  @override
  Widget build(BuildContext context) {
    return Button.outlined(
      text: _text,
      icon: Icons.account_circle,
      onPressed: _onPressed,
    );
  }

  void _goToProfilePage() {
    // todo
  }

  void _goToAuthPage() {
    // todo
  }
}
