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
}
