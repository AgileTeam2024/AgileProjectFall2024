class ApiService {
  static ApiService? _instance;

  static ApiService get instance {
    _instance ??= ApiService();
    return _instance!;
  }
}