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

    expect(product!.id, 1);
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
    when(mockNetworkService.putFormData(any, any,
            query: anyNamed('query'), files: anyNamed('files')))
        .thenAnswer(
      (_) async => ServerResponse(jsonEncode(responseJson), 200),
    );

    final response =
        await productService.editProduct(1, {'name': 'Updated Product'}, null);

    expect(response.bodyJson['success'], true);
  });

  test('deletes product successfully', () async {
    final responseJson = {'success': true};
    when(mockNetworkService.delete(any, query: anyNamed('query')))
        .thenAnswer((_) async => ServerResponse('', 204));

    final response = await productService.deleteProduct(1);

    expect(response.bodyJson['message'], 'Product deleted successfully');
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
        'user_username': 'user1',
      };
      return result;
    }).toList();
    when(mockNetworkService.get('/product/search', query: anyNamed('query')))
        .thenAnswer((_) async =>
            ServerResponse(jsonEncode({'products': productsJson}), 200));

    final products = await productService.searchProducts(name: 'Product');

    expect(products.length, 2);
    expect(products[0].name, 'Product 1');
    expect(products[1].name, 'Product 2');
  });

  test('returns null if product not found by id', () async {
    when(mockNetworkService.get(any, query: anyNamed('query'))).thenAnswer(
      (_) async => ServerResponse(
          jsonEncode({"message": "No product found with the provided ID."}),
          404),
    );

    final product = await productService.getProductById(999);

    expect(product, isNull);
  });

  test('fails to create product with invalid data', () async {
    final responseJson = {'success': false, 'error': 'Invalid data'};
    when(mockNetworkService.postFormData(any, any, files: anyNamed('files')))
        .thenAnswer(
      (_) async => ServerResponse(jsonEncode(responseJson), 400),
    );

    final response = await productService.createProduct({'name': ''}, null);

    expect(response.bodyJson['success'], false);
    expect(response.bodyJson['error'], 'Invalid data');
  });

  test('fails to edit non-existent product', () async {
    final responseJson = {'success': false, 'error': 'Product not found'};
    when(mockNetworkService.putFormData(any, any,
            query: anyNamed('query'), files: anyNamed('files')))
        .thenAnswer(
      (_) async => ServerResponse(jsonEncode(responseJson), 404),
    );

    final response = await productService.editProduct(
        999, {'name': 'Updated Product'}, null);

    expect(response.bodyJson['success'], false);
    expect(response.bodyJson['error'], 'Product not found');
  });

  test('fails to delete non-existent product', () async {
    final responseJson = {'success': false, 'error': 'Product not found'};
    when(mockNetworkService.delete(any, query: anyNamed('query'))).thenAnswer(
      (_) async => ServerResponse(jsonEncode(responseJson), 404),
    );

    final response = await productService.deleteProduct(999);

    expect(response.bodyJson['success'], false);
    expect(response.bodyJson['error'], 'Product not found');
  });

  test('searches products with no results', () async {
    when(mockNetworkService.get('/product/search', query: anyNamed('query')))
        .thenAnswer(
            (_) async => ServerResponse(jsonEncode({'products': []}), 200));

    final products = await productService.searchProducts(name: 'NonExistent');

    expect(products.length, 0);
  });
}
