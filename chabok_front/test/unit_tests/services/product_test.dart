import 'dart:convert';

import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/services/network.dart';
import 'package:chabok_front/services/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'product_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NetworkService>()])
void main() {
  late ProductService productService;
  late MockNetworkService mockNetworkService;

  setUp(() {
    NetworkService.instance = mockNetworkService = MockNetworkService();
    ProductService.instance = productService = ProductService();
  });

  test('returns product by id', () async {
    final productJson = {
      'id': 1,
      'name': 'Test Product',
      'description': 'Test Product Description',
      'seller': {'username': 'user1', 'email': 'user1@gmail.com'},
      'pictures': [],
      'category': 'Others',
      'price': 1000,
      'status': 'for sale',
    };
    when(mockNetworkService.get(any, query: anyNamed('query'))).thenAnswer(
      (_) async => ServerResponse(jsonEncode({'product': productJson}), 200),
    );

    final product = await productService.getProductById(1);

    expect(product.id, 1);
    expect(product.name, 'Test Product');
  });

  test('creates product successfully', () async {
    final responseJson = {'success': true};
    when(mockNetworkService.postFormData(any, any, files: anyNamed('files')))
        .thenAnswer(
      (_) async => ServerResponse(jsonEncode(responseJson), 201),
    );

    final response =
        await productService.createProduct({'name': 'New Product'}, null);

    expect(response.bodyJson['success'], true);
  });

  test('edits product successfully', () async {
    final responseJson = {'success': true};
    when(mockNetworkService.postFormData(any, any, files: anyNamed('files')))
        .thenAnswer(
      (_) async => ServerResponse(jsonEncode(responseJson), 200),
    );

    final response =
        await productService.editProduct(1, {'name': 'Updated Product'}, null);

    expect(response.bodyJson['success'], true);
  });

  test('deletes product successfully', () async {
    final responseJson = {'success': true};
    when(mockNetworkService.delete(any, query: anyNamed('query'))).thenAnswer(
      (_) async => ServerResponse(jsonEncode(responseJson), 204),
    );

    final response = await productService.deleteProduct(1);

    expect(response.bodyJson['success'], true);
  });

  test('searches products with filters', () async {
    final productsJson = [
      {'id': 1, 'name': 'Product 1'},
      {'id': 2, 'name': 'Product 2'}
    ].map((e) {
      final result = {
        ...e,
        'description': 'Test Product Description',
        'seller': {'username': 'user1', 'email': 'user1@gmail.com'},
        'pictures': [],
        'category': 'Others',
        'price': 1000,
        'status': 'for sale',
      };
      return result;
    }).toList();
    when(mockNetworkService.get('/product/search', query: anyNamed('query')))
        .thenAnswer((_) async =>
            ServerResponse(jsonEncode({'products': productsJson}), 200));
    when(mockNetworkService.get('/product/get_product_by_id',
            query: anyNamed('query')))
        .thenAnswer((inv) async {
      final id = int.parse(inv.namedArguments.values.toList()[0]['product_id']);
      return ServerResponse(jsonEncode({'product': productsJson[id - 1]}), 200);
    });

    final products = await productService.searchProducts(name: 'Product');

    expect(products.length, 2);
    expect(products[0].name, 'Product 1');
    expect(products[1].name, 'Product 2');
  });
}
