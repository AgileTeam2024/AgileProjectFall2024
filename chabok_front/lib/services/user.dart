import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/product_status.dart';
import 'package:chabok_front/models/pair.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/network.dart';
import 'package:flutter/foundation.dart';

class UserService {
  static UserService? _instance;

  static UserService get instance {
    _instance ??= UserService();
    return _instance!;
  }

  @visibleForTesting
  static set instance(UserService value) {
    _instance = value;
  }

  final _networkService = NetworkService.instance;

  Future<User?> get ownProfile async {
    final response = await _networkService.get('/user/get_profile');
    if (!response.isOk) return null;
    final user = response.bodyJson['profile'];
    return User.fromJson(user);
  }

  Future<List<Product>> get ownProducts async {
    // todo backend
    return List.generate(
      5,
      (i) => Product(
        id: i,
        name: 'Product $i',
        seller: User(
          username: 'ckdks',
          phoneNumber: '09121234567',
          email: 'seller@gmail.com',
        ),
        imageUrls: ['assets/sample_images/product_img1.jpg'],
        category: ProductCategory.others,
        location: '',
        status: ProductStatus.reserved,
        price: 1000,
        description: 'Description on Product $i',
      ),
    );
  }

  Future<User?> getProfile(String username) async {
    final response =
        await _networkService.get('/user/get_profile_by_username/$username');
    if (!response.isOk) return null;
    final user = response.bodyJson['profile'];
    return User.fromJson(user);
  }

  Future<ServerResponse> editProfile(
    Map<String, String> fields,
    Pair<String, Uint8List>? profilePicture,
  ) async {
    final response = await _networkService.postFormData(
      '/user/edit_profile',
      fields,
      files: profilePicture == null
          ? null
          : {
              'profile_picture': Map.fromEntries(
                [MapEntry(profilePicture.first, profilePicture.second)],
              ),
            },
    );
    return response;
  }
}
