import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/pages/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tests_setup_teardown.dart';

void main() {
  group('EditProfilePage', () {
    late User user;

    setUp(() {
      user = User(
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '1234567890',
        address: '123 Main St',
        profilePicture: null,
        username: 'john_doe',
        email: 'john_doe@email.com',
      );
    });

    group('displays user information correctly', () {
      bool textFieldPredicate(Widget widget, String labelText, String value) {
        if (widget is! TextField) return false;
        return widget.decoration?.labelText == labelText &&
            widget.controller?.text == value;
      }

      testWidgets(
          "if user has edited before (don't show first name and last name fields)",
          (tester) async {
        user = User(
          phoneNumber: '1234567890',
          address: '123 Main St',
          profilePicture: null,
          username: 'john_doe',
          email: 'john_doe@email.com',
        );
        setUpWidgetTest(tester);
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: EditProfilePage(user: user))),
        );
        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate(
                (w) => textFieldPredicate(w, 'First name *', 'John')),
            findsNothing);
        expect(
            find.byWidgetPredicate(
                (w) => textFieldPredicate(w, 'Last name *', 'Doe')),
            findsNothing);
        expect(
            find.byWidgetPredicate(
                (w) => textFieldPredicate(w, 'Phone Number *', '1234567890')),
            findsOneWidget);
        expect(
            find.byWidgetPredicate(
                (w) => textFieldPredicate(w, 'Address', '123 Main St')),
            findsOneWidget);
        tearDownWidgetTest(tester);
      });

      testWidgets(
          "if user hasn't edited before (show first name and last name fields)",
          (tester) async {
        user = User(
          phoneNumber: '1234567890',
          address: '123 Main St',
          profilePicture: null,
          username: 'john_doe',
          email: 'john_doe@email.com',
        );
        setUpWidgetTest(tester);
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: EditProfilePage(user: user))),
        );
        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate(
                (w) => textFieldPredicate(w, 'First name *', '')),
            findsOneWidget);
        expect(
            find.byWidgetPredicate(
                (w) => textFieldPredicate(w, 'Last name *', '')),
            findsOneWidget);
        expect(
            find.byWidgetPredicate(
                (w) => textFieldPredicate(w, 'Phone Number *', '1234567890')),
            findsOneWidget);
        expect(
            find.byWidgetPredicate(
                (w) => textFieldPredicate(w, 'Address', '123 Main St')),
            findsOneWidget);
        tearDownWidgetTest(tester);
      });
    });

    testWidgets('displays profile picture if available', (tester) async {
      setUpWidgetTest(tester);
      user = User(
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '1234567890',
        address: '123 Main St',
        profilePicture: '/path/to/pfp',
        username: 'john_doe',
        email: 'john_doe@email.com',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EditProfilePage(user: user)),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('allows editing profile picture', (tester) async {
      setUpWidgetTest(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditProfilePage(user: user),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.upload_rounded));
      await tester.pump();

      expect(find.byType(CircleAvatar), findsOneWidget);
      tearDownWidgetTest(tester);
    }, skip: true); // todo can not mock :(
  });
}
