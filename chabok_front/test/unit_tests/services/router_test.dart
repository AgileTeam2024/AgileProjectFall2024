import 'package:chabok_front/pages/home.dart';
import 'package:chabok_front/pages/login_register.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/services/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../tests_setup_teardown.dart';

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
  });

  group('If user is logged in', () {
    setUp(() => AuthService.instance = MockAuthService(true));

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
  });
}

class MockAuthService extends Mock implements AuthService {
  final bool _isLoggedIn;

  MockAuthService(this._isLoggedIn);

  @override
  Future<bool> get isLoggedIn async => _isLoggedIn;
}
