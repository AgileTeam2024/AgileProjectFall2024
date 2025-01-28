import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/product_status.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/network.dart';
import 'package:flutter/foundation.dart';

class AdminService {
  static AdminService? _instance;

  static AdminService get instance {
    _instance ??= AdminService();
    return _instance!;
  }

  @visibleForTesting
  static set instance(AdminService value) {
    _instance = value;
  }

  final _networkService = NetworkService.instance;

  Future<List<Product>> get reportedProducts async {
    return List.generate(
        5,
        (i) => Product(
            id: i,
            name: 'name',
            description: 'description',
            seller: User(
                username: 'username',
                email: 'email',
                phoneNumber: 'phoneNumber'),
            imageUrls: [],
            category: ProductCategory.values[i % ProductCategory.values.length],
            price: i * 1000,
            status: ProductStatus.values[i % ProductStatus.values.length]));
    final response = await _networkService.get('/admin/product-reports-list');
    if (response.isOk) {
      final body =
          response.bodyJson['reported_products'] as List<Map<String, dynamic>>;
      return body.map(Product.fromJson).toList();
    }
    return [];
  }

  Future<List<User>> get reportedUsers async {
    return List.generate(
        3,
        (i) => User(
            username: 'username', email: 'email', phoneNumber: 'phoneNumber'));
    final response = await _networkService.get('/admin/user-reports-list');
    if (response.isOk) {
      final body =
          response.bodyJson['reported_users'] as List<Map<String, dynamic>>;
      return body.map(User.fromJson).toList();
    }
    return [];
  }

  Future<List<Product>> get bannedProducts async {
    return List.generate(
        5,
        (i) => Product(
            id: i,
            name: 'name',
            description: 'description',
            seller: User(
                username: 'username',
                email: 'email',
                phoneNumber: 'phoneNumber'),
            imageUrls: [],
            category: ProductCategory.values[i % ProductCategory.values.length],
            price: i * 1000,
            status: ProductStatus.values[i % ProductStatus.values.length]));
    // todo send request to back
    return [];
  }

  Future<List<User>> get bannedUsers async {
    return List.generate(
        3,
        (i) => User(
            username: 'username', email: 'email', phoneNumber: 'phoneNumber'));
    // todo send request to back
    return [];
  }

  Future<bool> banProduct(int id) async {
    // todo send request to back
    return false;
  }

  Future<bool> banUser(String username) async {
    // todo send request to back
    return false;
  }

  Future<bool> unbanProduct(int id) async {
    // todo send request to back
    return false;
  }

  Future<bool> unbanUser(String username) async {
    // todo send request to back
    return false;
  }
}
