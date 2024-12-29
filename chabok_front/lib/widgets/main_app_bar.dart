import 'package:chabok_front/constants.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/widgets/profile_button.dart';
import 'package:flutter/material.dart';

class MainAppBar extends AppBar {
  final authService = AuthService.instance;

  MainAppBar({super.key});

  @override
  double? get elevation => 2;

  @override
  Widget get title => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => RouterService.go('/'),
          child: Row(
            children: [
              Icon(Icons.heart_broken),
              const Text(APP_NAME),
            ],
          ),
        ),
      );

  @override
  bool get centerTitle => false;

  @override
  List<Widget>? get actions => [
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

  @override
  Widget? get flexibleSpace => Padding(
        padding: const EdgeInsets.only(
          left: 200,
          right: 300,
          top: 10,
          bottom: 10,
        ),
        child: SearchBar(
          leading: const Icon(Icons.search),
          hintText: 'Search Products...',
          backgroundColor: WidgetStateProperty.all(Colors.white),
          onSubmitted: _submitSearch,
        ),
      );

  @override
  Widget? get leading => Container();

  @override
  double? get leadingWidth => 0;

  void _submitSearch(String search) {
    // todo
  }
}
