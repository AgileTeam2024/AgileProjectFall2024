import 'package:flutter_test/flutter_test.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:flutter/material.dart';

void main() {
  group('Button Tests', () {
    testWidgets('should render TextButton for text type',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button.text(
              text: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      final textButton = find.byType(TextButton);
      expect(textButton, findsOneWidget);

      final buttonText = find.text('Click Me');
      expect(buttonText, findsOneWidget);
    });

    testWidgets('should render OutlinedButton for outlined type',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button.outlined(
              text: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      final outlinedButton = find.byType(OutlinedButton);
      expect(outlinedButton, findsOneWidget);

      final buttonText = find.text('Click Me');
      expect(buttonText, findsOneWidget);
    });

    testWidgets('should render ElevatedButton for filled type',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button.filled(
              text: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      final elevatedButton = find.byType(ElevatedButton);
      expect(elevatedButton, findsOneWidget);

      final buttonText = find.text('Click Me');
      expect(buttonText, findsOneWidget);
    });
  });
}
