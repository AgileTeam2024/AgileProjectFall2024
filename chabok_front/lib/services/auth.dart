import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/services/network.dart';

class AuthService {
  static AuthService? _instance;

  static AuthService get instance {
    _instance ??= AuthService();
    return _instance!;
  }

  final _networkService = NetworkService.instance;

  bool get isLoggedIn => true;

  Future<ServerResponse> login(Map<String, String> body) =>
      _networkService.post('/user/login', body);

  Future<ServerResponse> register(Map<String, String> body) =>
      _networkService.post('/user/register', body);
}
