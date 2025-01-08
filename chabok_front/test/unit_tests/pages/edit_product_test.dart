import 'dart:convert';
import 'dart:io';

import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/pages/create_edit_product.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/services/network.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/widgets/main_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../tests_setup_teardown.dart';
import 'edit_product_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ProductService>(),
  MockSpec<NetworkService>(),
  MockSpec<AuthService>()
])
void main() {
  late MockProductService mockProductService;
  late MockNetworkService mockNetworkService;
  late MockAuthService mockAuthService;

  setUp(() {
    HttpOverrides.global = null;
    ProductService.instance = mockProductService = MockProductService();
    NetworkService.instance = mockNetworkService = MockNetworkService();
    AuthService.instance = mockAuthService = MockAuthService();
  });

  testWidgets('displays initial values correctly', (tester) async {
    setUpWidgetTest(tester);
    final product = Product.fromJson({
      'id': 1,
      'name': 'Test Product',
      'category': 'Others',
      'city_name': 'Test Location',
      'price': 1000,
      'seller': {'username': 'seller'},
      'description': 'Test Description',
      'status': 'for sale',
      'pictures': ['assets/sample_images/product_img0.jpg'],
    });
    when(mockNetworkService.getImage(any)).thenAnswer((_) async =>
        File('assets/sample_images/product_img0.jpg').readAsBytes());

    await tester.pumpWidget(MaterialApp(home: EditProductPage(product)));
    await tester.pumpAndSettle();

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('Others'), findsOneWidget);
    expect(find.text('Test Location'), findsOneWidget);
    expect(find.text('1000.0'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
    expect(find.text('for sale'), findsOneWidget);
  });

  testWidgets('submits edited product successfully', (tester) async {
    setUpWidgetTest(tester);
    final product = Product.fromJson({
      'id': 1,
      'name': 'Test Product',
      'category': 'Others',
      'city_name': 'Test Location',
      'price': 1000,
      'seller': {'username': 'seller'},
      'description': 'Test Description',
      'status': 'for sale',
      'pictures': ['assets/sample_images/product_img0.jpg'],
    });

    when(mockProductService.getProductById(1)).thenAnswer((_) async => product);
    when(mockProductService.editProduct(any, any, any)).thenAnswer((_) async =>
        ServerResponse(jsonEncode({'message': 'product edited'}), 200));
    when(mockNetworkService.getImage(any)).thenAnswer((_) async =>
        File('assets/sample_images/product_img0.jpg').readAsBytesSync());
    when(mockAuthService.isLoggedIn).thenAnswer((_) => true);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: RouterService.router),
    );
    RouterService.go('/product/1/edit');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Updated Product');
    await tester.pump(Duration(seconds: 10));
    await tester.tap(find.byType(MainFAB));
    await tester.pump(Duration(seconds: 10));

    verify(mockProductService.editProduct(
      1,
      {
        'name': 'Updated Product',
        'category': 'Others',
        'status': 'for sale',
        'city_name': 'Test Location',
        'price': '1000.0',
        'description': 'Test Description',
      },
      any,
    )).called(1);
  });

  testWidgets('shows error when no image is uploaded', (tester) async {
    final product = Product.fromJson({
      'id': 1,
      'name': 'Test Product',
      'category': 'Others',
      'city_name': 'Test Location',
      'price': 1000,
      'seller': {'username': 'seller'},
      'description': 'Test Description',
      'status': 'for sale',
      'pictures': [],
    });
    when(mockNetworkService.getImage(any)).thenAnswer((_) async =>
        File('assets/sample_images/product_img0.jpg').readAsBytes());

    await tester.pumpWidget(MaterialApp(home: EditProductPage(product)));

    await tester.tap(find.byType(MainFAB));
    await tester.pump(Duration(seconds: 10));

    verifyNever(mockProductService.editProduct(any, any, any));
  });
}
