import 'dart:convert';
import 'dart:typed_data';

import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  static NetworkService? _instance;

  static NetworkService get instance {
    _instance ??= NetworkService();
    return _instance!;
  }

  static const host = '127.0.0.1';
  static const port = 8000;

  Uri _buildUrl(
    String path,
    Map<String, dynamic>? query, [
    String prefix = '/api',
  ]) {
    return Uri(
      scheme: 'http',
      host: host,
      port: port,
      path: '$prefix/${path.substring(1)}',
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
        'Authorization': 'Bearer ${AuthService.instance.accessToken}'
      },
      body: jsonEncode(body),
    );
    return ServerResponse.visualize(response.body, response.statusCode);
  }

  Future<ServerResponse> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
  }) async {
    final response = await http.get(
      _buildUrl(path, query),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${AuthService.instance.accessToken}'
      },
    );
    return ServerResponse.visualize(response.body, response.statusCode);
  }

  Future<Uint8List> getImage(String path, {bool useOurServer = true}) async {
    final url = useOurServer ? _buildUrl(path, {}, '') : Uri.parse(path);
    final response = await http.get(
      url,
      headers: {
        'Accept': 'image/*',
        'Authorization': 'Bearer ${AuthService.instance.accessToken}'
      },
    );
    return response.bodyBytes;
  }
}
