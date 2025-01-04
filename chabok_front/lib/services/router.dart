import 'package:chabok_front/pages/create_product.dart';
import 'package:chabok_front/pages/error.dart';
import 'package:chabok_front/pages/home.dart';
import 'package:chabok_front/pages/login_register.dart';
import 'package:chabok_front/pages/profile.dart';
import 'package:chabok_front/pages/product_view.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/widgets/main_app_bar.dart';
import 'package:chabok_front/widgets/main_fab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouterService {
  static AuthService get _authService => AuthService.instance;

  static final _rootNavKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final _shellNavKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  static void go(String location, {Object? extra}) =>
      GoRouter.of(_shellNavKey.currentContext!).go(location, extra: extra);

  static void pop() => GoRouter.of(_shellNavKey.currentContext!).pop();

  static final router = GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: '/',
    onException: (_, __, ___) => go('/error/404', extra: 'Page not found :('),
    routes: [
      ShellRoute(
        navigatorKey: _shellNavKey,
        builder: (context, state, child) {
          print('${state.fullPath} ${state.pathParameters} ${state.extra}');
          return Scaffold(
            appBar: MainAppBar(),
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            redirect: (context, state) => '/home',
          ),
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/login',
            redirect: (context, state) async {
              if (await _authService.isLoggedIn) return '/';
              return null;
            },
            pageBuilder: (context, state) =>
                NoTransitionPage(child: LoginPage()),
          ),
          GoRoute(
            path: '/register',
            redirect: (context, state) async {
              if (await _authService.isLoggedIn) return '/';
              return null;
            },
            pageBuilder: (context, state) =>
                NoTransitionPage(child: RegisterPage()),
          ),
          GoRoute(
            path: '/product/:id',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ProductViewPage(
                int.parse(state.pathParameters['id']!),
                viewerIsSeller: false,
              ),
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
          GoRoute(
            path: '/profile',
            redirect: (context, state) async {
              if (!(await _authService.isLoggedIn)) return '/';
              return null;
            },
            pageBuilder: (context, state) => NoTransitionPage(
              child: UserProfilePage(),
            ),
          ),
          GoRoute(
            path: '/error/:code',
            pageBuilder: (context, state) {
              final code = state.pathParameters['code'];
              final message = state.extra?.toString();
              return NoTransitionPage(
                child: ErrorPage(
                  errorCode: code == null ? null : int.tryParse(code),
                  message: message,
                ),
              );
            },
          ),
          GoRoute(
            path: '/error',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: ErrorPage()),
          ),
        ],
      ),
    ],
  );
}
