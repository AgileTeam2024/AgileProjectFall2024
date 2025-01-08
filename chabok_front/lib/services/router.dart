import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/pages/create_edit_product.dart';
import 'package:chabok_front/pages/edit_profile.dart';
import 'package:chabok_front/pages/error.dart';
import 'package:chabok_front/pages/home.dart';
import 'package:chabok_front/pages/login_register.dart';
import 'package:chabok_front/pages/product_view.dart';
import 'package:chabok_front/pages/profile.dart';
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
            floatingActionButton: state.fullPath == '/create-product'
                ? null
                : MainFAB(
                    icon: Icons.add,
                    label: 'Create Product',
                    onPressed: () => go('/create-product'),
                  ),
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
              if (_authService.isLoggedIn) return '/';
              return null;
            },
            pageBuilder: (context, state) =>
                NoTransitionPage(child: LoginPage()),
          ),
          GoRoute(
            path: '/register',
            redirect: (context, state) async {
              if (_authService.isLoggedIn) return '/';
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
                viewerIsSeller: true,
              ),
            ),
          ),
          GoRoute(
            path: '/product/:id/edit',
            redirect: (context, state) {
              // todo check if current user is the owner of the product
              // if not, redirect back to ProductViewPage
            },
            pageBuilder: (context, state) => NoTransitionPage(
              child: EditProductPage(state.extra as Product),
            ),
          ),
          GoRoute(
            path: '/create-product',
            redirect: (context, state) {
              if (!AuthService.instance.isLoggedIn) return '/login';
            },
            pageBuilder: (context, state) => NoTransitionPage(
              child: CreateProductPage(),
            ),
          ),
          GoRoute(
            path: '/profile',
            redirect: (context, state) {
              if (!_authService.isLoggedIn) return '/';
              return null;
            },
            pageBuilder: (context, state) => NoTransitionPage(
              child: UserProfilePage(),
            ),
          ),
          GoRoute(
            path: '/edit-profile',
            redirect: (context, state) {
              if (!_authService.isLoggedIn) return '/';
              return null;
            },
            pageBuilder: (context, state) => NoTransitionPage(
              child: EditProfilePage(
                user: User(
                  username: 'username',
                  email: 'email@gmail.com',
                  phoneNumber: '+9939232965',
                ),
              ),
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
