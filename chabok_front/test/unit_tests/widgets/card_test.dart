import 'package:chabok_front/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardWidget Tests', () {
    testWidgets('should render child with correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardWidget(
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      final cardWidget = find.byType(CardWidget);
      expect(cardWidget, findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding,
          EdgeInsets.symmetric(vertical: 50, horizontal: 25));
      expect(
          container.margin, EdgeInsets.symmetric(vertical: 50, horizontal: 25));
      expect(container.decoration, isNotNull);
    });
  });
}
