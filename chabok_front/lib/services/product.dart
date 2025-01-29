import 'dart:convert';

import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/services/network.dart';
import 'package:chabok_front/services/user.dart';
import 'package:flutter/foundation.dart';

class ProductService {
  static ProductService? _instance;

  static ProductService get instance {
    _instance ??= ProductService();
    return _instance!;
  }

  @visibleForTesting
  static set instance(ProductService value) {
    _instance = value;
  }

  NetworkService get _networkService => NetworkService.instance;

  UserService get _userService => UserService.instance;

  Future<List<Product>> get homePageProducts =>
      searchProducts(sortCreatedAt: 'asc');

  Future<List<Product>> get ownProducts async {
    final response = await _networkService.get('/product/product_list');
    if (!response.isOk) return [];
    final products =
        (response.bodyJson['products'] as List).cast<Map<String, dynamic>>();
    return getProductsSellers(products);
  }

  Future<Product?> getProductById(int id) async {
    final response = await _networkService
        .get('/product/get_product_by_id', query: {'product_id': '$id'});
    if (!response.isOk) return null;
    final product = response.bodyJson['product'];
    return Product.fromJson(product);
  }

  Future<ServerResponse> createProduct(
    Map<String, dynamic> fields,
    Map<String, Uint8List?>? images,
  ) {
    images?.removeWhere((path, bytes) => bytes == null);
    return _networkService.postFormData(
      '/product/create',
      fields,
      files: {
        'pictures': images?.map((k, v) => MapEntry(k, v!)) ?? {},
      },
    );
  }

  Future<ServerResponse> editProduct(
    int productId,
    Map<String, dynamic> fields,
    Map<String, Uint8List?>? images,
  ) {
    images?.removeWhere((path, bytes) => bytes == null);
    return _networkService.putFormData(
      '/product/edit_product',
      query: {'product_id': ['$productId']},
      fields,
      files: {
        'pictures': images?.map((k, v) => MapEntry(k, v!)) ?? {},
      },
    );
  }

  Future<ServerResponse> deleteProduct(int id) async {
    final response = await _networkService.delete(
      '/product/delete',
      query: {
        'product_id': ['$id']
      },
    );
    if (response.isOk) {
      return ServerResponse.visualize(
          jsonEncode({'message': 'Product deleted successfully'}), 200);
    }
    return response;
  }

  Future<List<Product>> searchProducts({
    String? name,
    double? minPrice,
    double? maxPrice,
    String? status,
    List<String>? categories,
    String? sortCreatedAt,
    String? sortPrice,
  }) async {
    final response = await _networkService.get(
      '/product/search',
      query: {
        if (name != null) 'name': name,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (status != null) 'status': status,
        if (sortCreatedAt != null) 'sort_created_at': sortCreatedAt,
        if (sortPrice != null) 'sort_price': sortPrice,
        if (categories != null) 'categories': categories,
      },
    );
    if (!response.isOk) return [];
    final productsJson =
        (response.bodyJson['products'] as List).cast<Map<String, dynamic>>();
    return await getProductsSellers(productsJson);
  }

  Future<List<Product>> getProductsSellers(
      List<Map<String, dynamic>> products) {
    final users = {};
    return Future.wait(
      products.map((product) async {
        final sellerUsername = product['user_username'];
        if (product.containsKey('seller')) return Product.fromJson(product);
        if (!users.containsKey(sellerUsername)) {
          users[sellerUsername] = await _userService.getProfile(sellerUsername);
        }
        final product2 = {
          ...product,
          'seller': users[sellerUsername]?.toJson()
        };
        return Product.fromJson(product2);
      }),
    );
  }

  Future<ServerResponse> report(int productId, String description) =>
      _networkService.postFormData(
        '/product/report_product',
        {'reported_product': productId, 'description': description},
      );
}
