import 'package:chabok_front/models/server_response.dart';

class AuthService {
  static AuthService? _instance;

  static AuthService get instance {
    _instance ??= AuthService();
    return _instance!;
  }

  Future<bool> get isLoggedIn {
    // todo
    return Future.value(false);
  }

  Future<ServerResponse> login(Map<String, String> body) {
    // todo send to backend
    return Future.value(ServerResponse('{}', 200));
  }

  Future<ServerResponse> register(Map<String, String> body) {
    // todo send to backend
    return Future.value(ServerResponse('{}', 201));
  }
}
