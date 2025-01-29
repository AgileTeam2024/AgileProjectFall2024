import 'package:chabok_front/models/pair.dart';
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

  Future<User?> getProfile(String username) async {
    final response =
        await _networkService.get('/user/get_profile_by_username/$username');
    if (!response.isOk) return null;
    final user = response.bodyJson['profile'];
    print(user);
    return User.fromJson(user);
  }

  Future<ServerResponse> editProfile(
    Map<String, String> fields,
    Pair<String, Uint8List>? profilePicture,
  ) async {
    final response = await _networkService.putFormData(
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

  Future<ServerResponse> report(String username, String description) =>
      _networkService.postFormData(
        '/user/report_user',
        {'reported_username': username, 'description': description},
      );
}
