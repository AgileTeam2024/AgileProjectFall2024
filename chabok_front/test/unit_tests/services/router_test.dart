import 'package:chabok_front/pages/home.dart';
import 'package:chabok_front/pages/login_register.dart';
import 'package:chabok_front/services/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tests_setup_teardown.dart';

void main() {
  testWidgets('Navigates to home page', (tester) async {
    setUpWidgetTest(tester);
    final router = RouterService.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.byType(HomePage), findsOneWidget);
    tearDownWidgetTest(tester);
  });

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

  testWidgets('Redirects to home if already logged in on login page',
      (tester) async {
    setUpWidgetTest(tester);
    final router = RouterService.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    // todo Simulate user is logged in

    RouterService.go('/login');
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    tearDownWidgetTest(tester);
  }, skip: true);

  testWidgets('Redirects to home if already logged in on register page',
      (tester) async {
    setUpWidgetTest(tester);
    final router = RouterService.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    // TODO: Simulate user is logged in

    RouterService.go('/register');
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    tearDownWidgetTest(tester);
  }, skip: true);
}
