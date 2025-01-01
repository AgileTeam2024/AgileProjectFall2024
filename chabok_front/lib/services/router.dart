import 'package:chabok_front/pages/create_product.dart';
import 'package:chabok_front/pages/home.dart';
import 'package:chabok_front/pages/login_register.dart';
import 'package:chabok_front/widgets/main_app_bar.dart';
import 'package:chabok_front/widgets/main_fab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouterService {
  static final _rootNavKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final _shellNavKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  static void go(String location, {Object? extra}) =>
      GoRouter.of(_shellNavKey.currentContext!).go(location, extra: extra);

  static void pop() => GoRouter.of(_shellNavKey.currentContext!).pop();

  static final router = GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavKey,
        builder: (context, state, child) {
          return Scaffold(
            appBar: MainAppBar(),
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => NoTransitionPage(
              child: Scaffold(
                floatingActionButton: MainFAB(),
                body: HomePage(),
              ),
            ),
          ),
          GoRoute(
            path: '/login',
            redirect: (context, state) {
              // todo check if is logged in, it navigates to '/'
            },
            pageBuilder: (context, state) => NoTransitionPage(
              child: LoginPage(),
            ),
          ),
          GoRoute(
            path: '/register',
            redirect: (context, state) {
              // todo check if is logged in, it navigates to '/'
            },
            pageBuilder: (context, state) => NoTransitionPage(
              child: RegisterPage(),
            ),
          ),
          GoRoute(
            path: '/create-product',
            redirect: (context, state) {
              // todo redirect to login page if not logged in
            },
            pageBuilder: (context, state) => NoTransitionPage(
              child: CreateProductPage(),
            ),
          ),
        ],
      )
    ],
  );
}
