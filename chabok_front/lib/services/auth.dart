import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/services/network.dart';

class AuthService {
  static AuthService? _instance;

  static AuthService get instance {
    _instance ??= AuthService();
    return _instance!;
  }

  final _networkService = NetworkService.instance;

  Future<bool> get isLoggedIn =>
      _networkService.get('/user/check_cookie').then((response) => response.isOk);

  Future<ServerResponse> login(Map<String, String> body) =>
      _networkService.post('/user/login', body);

  Future<ServerResponse> register(Map<String, String> body) =>
      _networkService.post('/user/register', body);
}
