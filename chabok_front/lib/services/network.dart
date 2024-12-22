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
    const scheme = String.fromEnvironment('base_scheme', defaultValue: 'http');
    const url = String.fromEnvironment('base_url', defaultValue: '185.231.59.87');
    return Uri(
      scheme: scheme,
      host: url,
      port: const int.fromEnvironment('base_port', defaultValue: 8000),
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
