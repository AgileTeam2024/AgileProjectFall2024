import 'package:chabok_front/pages/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../finder_image.dart';

void main() {
  testWidgets('Displays error image based on errorCode', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ErrorPage(errorCode: 404)));
    expect(find.byAssetImagePath('assets/error/404.png'), findsOneWidget);
  });

  testWidgets('Displays general error image when errorCode is null',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: ErrorPage()));
    expect(find.byAssetImagePath('assets/error/general.png'), findsOneWidget);
  });

  testWidgets('Displays message when provided', (tester) async {
    await tester
        .pumpWidget(MaterialApp(home: ErrorPage(message: 'An error occurred')));
    expect(find.text('An error occurred'), findsOneWidget);
  });

  testWidgets('Does not display message when not provided', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ErrorPage()));
    expect(find.byType(Text), findsNothing);
  });
}
