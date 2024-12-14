class AuthService {
  static AuthService? _instance;

  static AuthService get instance {
    _instance ??= AuthService();
    return _instance!;
  }

  Future<bool> get isLoggedIn {
    // todo
    return Future.value(true);
  }
}
