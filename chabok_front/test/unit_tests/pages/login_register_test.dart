import 'package:chabok_front/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chabok_front/pages/login_register.dart';

void main() {
  group('LoginPage Tests', () {
    test('title should be "Login"', () {
      final loginPage = LoginPage();
      expect(loginPage.title, 'Login');
    });

    test('fields should contain username and password fields', () {
      final loginPage = LoginPage();
      expect(loginPage.fields.length, 2);
      expect(loginPage.fields[0].label, 'Username');
      expect(loginPage.fields[1].label, 'Password');
    });

    test('navigateToOtherForm should contain "Register" button', () {
      final loginPage = LoginPage();
      expect(loginPage.navigateToOtherForm.length, 2);
      expect((loginPage.navigateToOtherForm[1] as Button).text, 'Register');
    });

    testWidgets('Form validates correctly on submission',
            (WidgetTester tester) async {
          tester.view.physicalSize = Size(1000, 1000);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(MaterialApp(home: LoginPage()));

          // Verify that the submit button is present
          final submitButton = find.widgetWithText(ElevatedButton, 'Login');
          expect(submitButton, findsOneWidget);

          // Leave the fields empty and try submitting the form
          await tester.tap(submitButton.first);
          await tester.pump();

          // Verify that the validation errors are shown
          expect(find.text('This field is Required!'), findsNWidgets(2));

          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
  });

  group('RegisterPage Tests', () {
    test('title should be "Register"', () {
      final registerPage = RegisterPage();
      expect(registerPage.title, 'Register');
    });

    test(
        'fields should contain username, password, repeat password, and email fields',
        () {
      final registerPage = RegisterPage();
      expect(registerPage.fields.length, 4);
      expect(registerPage.fields[0].label, 'Username');
      expect(registerPage.fields[1].label, 'Password');
      expect(registerPage.fields[2].label, 'Repeat Password');
      expect(registerPage.fields[3].label, 'Email');
    });

    test('RegisterPage navigateToOtherForm should contain "Login" button', () {
      final registerPage = RegisterPage();
      expect(registerPage.navigateToOtherForm.length, 2);
      expect((registerPage.navigateToOtherForm[1] as Button).text, 'Login');
    });
  });
}
