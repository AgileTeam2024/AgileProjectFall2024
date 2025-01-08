import 'dart:io';

import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/pages/product_view.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/services/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../tests_setup_teardown.dart';

class MockProductService extends Mock implements ProductService {
  @override
  Future<Product> getProductById(int id) async {
    if (id == 2) return Future.delayed(Duration(seconds: 2));
    if (id == 3) throw Exception('Sample Error');
    return Product(
      id: 1,
      name: 'Test Product',
      imageUrls:
          List.generate(3, (i) => 'https://placehold.co/${(i + 1) * 100}'),
      category: 'Test Category',
      price: 1000.0,
      status: 'Available',
      seller: User(
        username: 'imseller',
        email: 'imseller@gmail.com',
        phoneNumber: '09121234567',
      ),
      description: 'Test Description',
    );
  }
}

class MockUserService extends Mock implements UserService {
  final bool viewerIsSeller;

  MockUserService(this.viewerIsSeller);

  @override
  Future<User?> get ownProfile async => User(
        username: viewerIsSeller ? 'imseller' : 'imnotseller',
        email: 'imseller@gmail.com',
        phoneNumber: '09121234567',
      );
}

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
    ProductService.instance = MockProductService();
  });

  Widget createWidgetUnderTest(int id, bool viewerIsSeller) {
    UserService.instance = MockUserService(viewerIsSeller);
    return MaterialApp(
      home: ProductViewPage(id),
    );
  }

  testWidgets('displays product information correctly', (tester) async {
    setUpWidgetTest(tester);
    await tester.pumpWidget(createWidgetUnderTest(1, false));
    await tester.pumpAndSettle();

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('Test Category Category'), findsOneWidget);
    expect(find.text('1,000 ᴵᴿᴿ'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    // expect( todo fix test
    //   find.descendant(
    //     of: find.byKey(scrollableKey),
    //     matching: find.text('Test Description'),
    //   ),
    //   findsOneWidget,
    // );
  });

  testWidgets('displays edit and delete buttons for seller', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(1, true));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });

  testWidgets('displays report button for non-seller', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(1, false));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.report), findsOneWidget);
  });

  testWidgets('displays loading indicator while fetching product',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(2, false));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays error container on error', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(3, false));
    await tester.pumpAndSettle();
    expect(find.byType(Container), findsOneWidget);
  }, skip: true); // todo skip until ErrorWidget is added

  testWidgets('responsive layout changes based on screen size', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(1, false));
    setUpWidgetTest(tester, Size(1200, 800));
    await tester.pumpAndSettle();

    Flex flex;
    expect(find.byType(Flex), findsExactly(2));

    flex = find.byType(Flex).evaluate().first.widget as Flex;
    expect(flex.direction, Axis.horizontal);
    expect(find.byType(VerticalDivider), findsOneWidget);

    setUpWidgetTest(tester, Size(800, 1200));
    await tester.pumpAndSettle();

    expect(find.byType(Flex), findsExactly(2));

    flex = find.byType(Flex).evaluate().first.widget as Flex;
    expect(flex.direction, Axis.vertical);
    expect(find.byType(Divider), findsOneWidget);
  });
}
