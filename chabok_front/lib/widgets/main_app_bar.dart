import 'package:chabok_front/constants.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/widgets/profile_button.dart';
import 'package:flutter/material.dart';

class MainAppBar extends AppBar {
  final authService = AuthService.instance;

  MainAppBar({super.key});

  @override
  Widget get title => const Text(APP_NAME);

  @override
  bool get centerTitle => false;

  @override
  List<Widget>? get actions =>
      [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: FutureBuilder<bool>(
            future: authService.isLoggedIn,
            builder: (context, snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {
                return ProfileButton(
                  isLogged: snapshot.data!,
                );
              }
              return Container();
            },
          ),
        )
      ];
}
