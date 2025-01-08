import 'package:chabok_front/pages/create_edit_product.dart';
import 'package:chabok_front/widgets/text_field.dart';
import 'package:chabok_front/widgets/upload_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tests_setup_teardown.dart';

void main() {
  group('CreateProductPage', () {
    testWidgets('displays all text fields and upload widget', (tester) async {
      setUpWidgetTest(tester);
      await tester.pumpWidget(MaterialApp(home: CreateProductPage()));

      expect(find.byType(CustomTextField), findsNWidgets(6));
      expect(find.byType(UploadFileWidget), findsOneWidget);
    });

    testWidgets('displays MainFAB with check icon', (tester) async {
      setUpWidgetTest(tester);
      await tester.pumpWidget(MaterialApp(home: CreateProductPage()));
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('calls _createProduct when MainFAB is pressed', (tester) async {
      setUpWidgetTest(tester);
      await tester.pumpWidget(MaterialApp(home: CreateProductPage()));

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      // Verify the print statement or any other side effect
    }, skip: true); // todo check after api is connected

    testWidgets('displays vertical layout on small screens', (WidgetTester tester) async {
      setUpWidgetTest(tester, Size(999, 800));
      await tester.pumpWidget(MaterialApp(home: CreateProductPage()));

      expect(find.byType(Column), findsNWidgets(2));
    });

    testWidgets('displays horizontal layout on large screens', (WidgetTester tester) async {
      setUpWidgetTest(tester, Size(1200, 800));
      await tester.pumpWidget(MaterialApp(home: CreateProductPage()));

      expect(find.byType(Row), findsNWidgets(3));
    });
  });
}
