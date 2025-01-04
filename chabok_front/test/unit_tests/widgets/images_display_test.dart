import 'dart:io';

import 'package:chabok_front/widgets/images_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tests_setup_teardown.dart';

void main() {
  final imageUrls =
      List.generate(3, (i) => 'https://placehold.co/${(i + 1) * 100}');

  setUpAll(() => HttpOverrides.global = null);

  testWidgets('ImagesDisplayWidget displays images correctly', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ImagesDisplayWidget(imageUrls)));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsNWidgets(4)); // 1 selected + 3 in grid
  });

  testWidgets('ImagesDisplayWidget selects image on tap', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ImagesDisplayWidget(imageUrls)));

    await tester.tap(find.byType(SmallImageWidget).at(1));
    await tester.pump();

    expect(find.byType(SelectedImageDisplay), findsOneWidget);
    expect(find.byType(SmallImageWidget).at(1), findsOneWidget);
  });

  testWidgets('ImagesDisplayWidget navigates to next image', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ImagesDisplayWidget(imageUrls)));

    await tester.tap(find.byIcon(Icons.navigate_next));
    await tester.pump();

    expect(find.byType(SelectedImageDisplay), findsOneWidget);
    expect(find.byType(SmallImageWidget).at(1), findsOneWidget);
  });

  testWidgets('ImagesDisplayWidget navigates to previous image',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: ImagesDisplayWidget(imageUrls)));

    await tester.tap(find.byIcon(Icons.navigate_before));
    await tester.pump();

    expect(find.byType(SelectedImageDisplay), findsOneWidget);
    expect(find.byType(SmallImageWidget).at(2), findsOneWidget);
  });

  testWidgets('ImagesDisplayWidget is responsive to screen size',
      (tester) async {
    setUpWidgetTest(tester, Size(1200, 800));
    await tester.pumpWidget(MaterialApp(home: ImagesDisplayWidget(imageUrls)));

    expect(find.byType(Flex), findsOneWidget);
    expect((tester.widget(find.byType(Flex)) as Flex).direction, Axis.vertical);

    setUpWidgetTest(tester, Size(800, 1200));
    await tester.pumpWidget(MaterialApp(home: ImagesDisplayWidget(imageUrls)));

    expect(find.byType(Flex), findsOneWidget);
    expect(
        (tester.widget(find.byType(Flex)) as Flex).direction, Axis.horizontal);
  });
}
