import 'dart:io';
import 'dart:typed_data';

import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/product_status.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/pages/error.dart';
import 'package:chabok_front/services/network.dart';
import 'package:chabok_front/widgets/products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNetworkService extends Mock implements NetworkService {
  @override
  String getAbsoluteFilePath(String? relative) => relative!;

@override
Future<Uint8List> getImage(String path, {bool useOurServer = true}) =>
    File(path).readAsBytes();
}

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
    NetworkService.instance = MockNetworkService();
  });

  testWidgets('displays error page when products list is empty',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: ProductsWidget([])));

    expect(find.byType(ErrorPage), findsOneWidget);
    expect(find.text('No products found :('), findsOneWidget);
  });

  testWidgets('displays products in a grid when products list is not empty',
      (tester) async {
    final products = List.generate(
      2,
      (i) => Product(
        id: i,
        name: 'Product ${i + 1}',
        price: (i + 1) * 1000,
        imageUrls: [],
        seller: User(
            username: 'Seller ${i + 1}',
            email: 'seller${i + 1}@email.com',
            phoneNumber: ''),
        description: '',
        category: ProductCategory.others,
        status: ProductStatus.available,
      ),
    );

    await tester.pumpWidget(MaterialApp(home: ProductsWidget(products)));

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(MaterialButton), findsNWidgets(2));
  });
}
