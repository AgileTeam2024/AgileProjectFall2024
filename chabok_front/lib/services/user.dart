import 'dart:typed_data';

import 'package:chabok_front/models/pair.dart';
import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/network.dart';

class UserService {
  static UserService? _instance;

  static UserService get instance {
    _instance ??= UserService();
    return _instance!;
  }

  final _networkService = NetworkService.instance;

  Future<User> get ownProfile async {
    final response = await _networkService.get('/user/get_profile_by_username');
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
