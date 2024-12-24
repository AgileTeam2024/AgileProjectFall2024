import 'dart:convert';

import 'package:chabok_front/models/server_response.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  static NetworkService? _instance;

  static NetworkService get instance {
    _instance ??= NetworkService();
    return _instance!;
  }

  Uri _buildUrl(String path, Map<String, dynamic>? query) {
    const host = String.fromEnvironment('FLASK_HOST');
    const port = int.fromEnvironment('FLASK_PORT');
    return Uri(
      scheme: 'http',
      host: host,
      port: port,
      path: path.substring(1),
      queryParameters: query,
    );
  }

  Future<ServerResponse> post<T>(
    String path,
    dynamic body, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
  }) async {
    print(_buildUrl(path, query));
    final response = await http.post(
      _buildUrl(path, query),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    return ServerResponse(response.body, response.statusCode);
  }
}
