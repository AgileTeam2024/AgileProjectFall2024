import 'dart:math';

import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/product_status.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/models/user.dart';
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

  final _networkService = NetworkService.instance;
  final _userService = UserService.instance;

  Future<List<Product>> get homePageProducts =>
      searchProducts(sortCreatedAt: 'asc');

  Future<Product> getProductById(int id) async {
    final response = await _networkService
        .get('/product/get_product_by_id', query: {'product_id': '$id'});
    final product = response.bodyJson['product'];
    return Product.fromJson(product);
  }

  Future<ServerResponse> createProduct(Map<String, dynamic> fields,
      Map<String, Uint8List?>? images,) {
    images?.removeWhere((path, bytes) => bytes == null);
    return _networkService.postFormData(
      '/product/create',
      fields,
      files: {
        'picture': images?.map((k, v) => MapEntry(k, v!)) ?? {},
      },
    );
  }

  Future<ServerResponse> editProduct(int productId,
      Map<String, dynamic> fields,
      Map<String, Uint8List?>? images,) {
    images?.removeWhere((path, bytes) => bytes == null);
    return _networkService.postFormData(
      '/product/edit_product',
      fields..putIfAbsent('id', () => productId),
      files: {
        'picture': images?.map((k, v) => MapEntry(k, v!)) ?? {},
      },
    );
  }

  Future<ServerResponse> deleteProduct(int id) =>
      _networkService.delete('/product/delete', query: {'id': id});

  Future<List<Product>> searchProducts({
    String? name,
    double? minPrice,
    double? maxPrice,
    String? status,
    String? sortCreatedAt,
    String? sortPrice,
  }) async {
    return Future.value(List.generate(15, (i) => // todo
        Product(id: i,
            name: 'name',
            description: 'description',
            seller: User(username: 'username',
                email: 'email',
                phoneNumber: 'phoneNumber'),
            imageUrls: ['assets/sample_images/product_img0.jpg'],
            category: ProductCategory.others,
            price: Random().nextInt(100000000).toDouble(),
            status: ProductStatus.reserved)));
    final response = await _networkService.get(
      '/product/search',
      query: {
        if (name != null) 'name': name,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (status != null) 'status': status,
        if (sortCreatedAt != null) 'sort_created_at': sortCreatedAt,
        if (sortPrice != null) 'sort_price': sortPrice,
      },
    );
    if (!response.isOk) return [];
    final products = await getProductsSellers(
      response.bodyJson['products'].cast<Map<String, dynamic>>(),
    );
    return products;
  }

  Future<List<Product>> getProductsSellers(
      List<Map<String, dynamic>> products,) {
    return Future.wait(
      products.map(
            (product) async {
          return (await getProductById(product['id'] as int));
          // todo
          // if (!product.containsKey('seller')) {
          //   // _userService
          // }
          // return product;
        },
      ),
    );
  }
}
