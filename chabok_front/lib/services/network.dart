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
    return Uri(
      scheme: 'http',
      host: 'localhost',
      port: 80,
      path: '/api/${path.substring(1)}',
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
