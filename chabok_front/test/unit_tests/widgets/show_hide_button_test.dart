import 'package:chabok_front/widgets/show_hide_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShowHideButton Tests', () {
    testWidgets('should render "SHOW" when isShown is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShowHideButton(
              isShown: false,
              toggleIsShown: () {},
            ),
          ),
        ),
      );

      final buttonText = find.text('SHOW');
      expect(buttonText, findsOneWidget);
    });

    testWidgets('should render "HIDE" when isShown is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShowHideButton(
              isShown: true,
              toggleIsShown: () {},
            ),
          ),
        ),
      );

      final buttonText = find.text('HIDE');
      expect(buttonText, findsOneWidget);
    });
  });
}
