import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tests_setup_teardown.dart';

void main() {
  testWidgets('Displays success toast with correct message and colors',
      (WidgetTester tester) async {
    setUpWidgetTest(tester);
    final response = ServerResponse('{"message": "Success"}', 200);
    final toast =
        CustomToast(text: response.message!, toastType: ToastType.success);

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: toast)));

    expect(find.text('Success'), findsOneWidget);
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.green.shade100);
    expect(decoration.border!.top.color, Colors.green.shade900);
    tearDownWidgetTest(tester);
  });

  testWidgets('Displays error toast with correct message and colors',
      (WidgetTester tester) async {
    setUpWidgetTest(tester);
    final response = ServerResponse('{"message": "Error"}', 400);
    final toast =
        CustomToast(text: response.message!, toastType: ToastType.error);

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: toast)));

    expect(find.text('Error'), findsOneWidget);
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.red.shade100);
    expect(decoration.border!.top.color, Colors.red.shade900);
    tearDownWidgetTest(tester);
  });

  testWidgets('Displays warning toast with correct message and colors',
      (WidgetTester tester) async {
    setUpWidgetTest(tester);
    final toast = CustomToast(text: 'Warning', toastType: ToastType.warning);

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: toast)));

    expect(find.text('Warning'), findsOneWidget);
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.yellow.shade100);
    expect(decoration.border!.top.color, Colors.yellow.shade900);
    tearDownWidgetTest(tester);
  });
}
