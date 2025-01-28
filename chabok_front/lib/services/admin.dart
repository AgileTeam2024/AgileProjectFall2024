import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/product_report.dart';
import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/network.dart';
import 'package:chabok_front/services/product.dart';
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
  final _productService = ProductService.instance;

  Future<List<ProductReport>> get reportedProducts async {
    final response = await _networkService.get('/admin/product-reports-list');
    if (response.isOk) {
      final body = (response.bodyJson['reported_products'] as List)
          .cast<Map<String, dynamic>>()
          .toList();
      return Future.wait(
        body.map(
          (report) async {
            final product = await _productService
                .getProductById(report['reported_product']);
            return ProductReport.fromJson(
                {...report, 'product': product!.toJson()});
          },
        ),
      );
    }
    return [];
  }

  Future<List<User>> get reportedUsers async {
    final response = await _networkService.get('/admin/user-reports-list');
    if (response.isOk) {
      final body =
          response.bodyJson['reported_users'] as List<Map<String, dynamic>>;
      return body.map(User.fromJson).toList();
    }
    return [];
  }

  Future<List<Product>> get bannedProducts async {
    final response = await _networkService.get('/admin/banned-product-list');
    if (response.isOk) {
      final body = (response.bodyJson['banned_products'] as List)
          .cast<Map<String, dynamic>>();
      return await _productService.getProductsSellers(body);
    }
    return [];
  }

  Future<List<User>> get bannedUsers async {
    final response = await _networkService.get('/admin/banned-user-list');
    if (response.isOk) {
      final body =
          response.bodyJson['banned_users'] as List<Map<String, dynamic>>;
      return body.map(User.fromJson).toList();
    }
    return [];
  }

  Future<ServerResponse> banProduct(int id) =>
      _networkService.postFormData('/admin/ban_product', {'product_id': id});

  Future<ServerResponse> banUser(String username) =>
      _networkService.postFormData('/admin/ban_user', {'username': username});

  Future<ServerResponse> unbanProduct(int id) =>
      _networkService.postFormData('/admin/unban_product', {'product_id': id});

  Future<ServerResponse> unbanUser(String username) =>
      _networkService.postFormData('/admin/unban_user', {'username': username});
}
