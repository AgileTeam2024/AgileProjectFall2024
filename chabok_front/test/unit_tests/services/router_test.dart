import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/pages/error.dart';
import 'package:chabok_front/pages/home.dart';
import 'package:chabok_front/pages/login_register.dart';
import 'package:chabok_front/pages/profile.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/services/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../tests_setup_teardown.dart';

class MockUserService extends Mock implements UserService {
  @override
  Future<User?> get ownProfile async =>
      User(username: 'username', email: 'email', phoneNumber: 'phoneNumber');
}

void main() {
  testWidgets('Navigates to home page', (tester) async {
    setUpWidgetTest(tester);
    final router = RouterService.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.byType(HomePage), findsOneWidget);
    tearDownWidgetTest(tester);
  });

  group('If user is not logged in', () {
    setUp(() => AuthService.instance = MockAuthService(false));

    testWidgets('Navigates to login page', (tester) async {
      setUpWidgetTest(tester);
      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/login');
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Navigates to register page', (tester) async {
      setUpWidgetTest(tester);
      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/register');
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Redirects to home going to profile page', (tester) async {
      setUpWidgetTest(tester);
      await tester.pumpAndSettle();

      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/profile');
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      tearDownWidgetTest(tester);
    });
  });

  group('If user is logged in', () {
    setUp(() {
      AuthService.instance = MockAuthService(true);
      UserService.instance = MockUserService();
    });

    testWidgets('Redirects to home going to login page', (tester) async {
      setUpWidgetTest(tester);
      await tester.pumpAndSettle();

      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/login');
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Redirects to home going to register page', (tester) async {
      setUpWidgetTest(tester);
      await tester.pumpAndSettle();

      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/register');
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Navigates to profile page', (tester) async {
      setUpWidgetTest(tester);
      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/profile');
      await tester.pumpAndSettle();

      expect(find.byType(UserProfilePage), findsOneWidget);
      tearDownWidgetTest(tester);
    });
  });

  testWidgets('Navigates to error page with correct code and message',
      (tester) async {
    setUpWidgetTest(tester);
    final router = RouterService.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    RouterService.go('/error/404', extra: 'Page not found :(');
    await tester.pumpAndSettle();

    expect(find.byType(ErrorPage), findsOneWidget);
    tearDownWidgetTest(tester);
  });

  testWidgets("Navigates to error page if page doesn't exist", (tester) async {
    setUpWidgetTest(tester);
    final router = RouterService.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    RouterService.go('/abc');
    await tester.pumpAndSettle();

    expect(find.byType(ErrorPage), findsOneWidget);
    expect(find.text('Page not found :('), findsOneWidget);
    tearDownWidgetTest(tester);
  });
}

class MockAuthService extends Mock implements AuthService {
  final bool _isLoggedIn;

  MockAuthService(this._isLoggedIn);

  @override
  bool get isLoggedIn => _isLoggedIn;
}
