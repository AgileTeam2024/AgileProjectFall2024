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

  // static const host = '127.0.0.1';
  // static const port = 8000;
  static const host = '185.231.59.87';
  static const port = 80;

  Map<String, String>? get authHeader {
    final authService = AuthService.instance;
    if (authService.accessToken == null) return null;
    return {'Authorization': 'Bearer ${authService.accessToken}'};
  }

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
    Map<String, dynamic>? query,
  }) async {
    final response = await http.post(
      _buildUrl(path, query),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        ...?authHeader
      },
      body: jsonEncode(body),
    );
    return ServerResponse.visualize(response.body, response.statusCode);
  }

  Future<ServerResponse> postFormData<T>(
    String path,
    Map<String, dynamic> fields, {
    Map<String, dynamic>? query,
    Map<String, Map<String, Uint8List>>? files,
  }) async {
    final request = http.MultipartRequest('POST', _buildUrl(path, query));
    fields.forEach((k, v) => request.fields.putIfAbsent(k, () => v));
    files?.forEach(
      (key, values) => values.forEach(
        (path, bytes) => request.files.add(
          http.MultipartFile.fromBytes(key, bytes),
        ),
      ),
    );

    request.headers.putIfAbsent(
      'Accept',
      () => 'application/json',
    );
    request.headers.putIfAbsent(
      'Content-Type',
      () => 'application/form-data',
    );
    if (authHeader != null) request.headers.addAll(authHeader!);

    final response = await request.send();
    return ServerResponse.visualize(
      await response.stream.bytesToString(),
      response.statusCode,
    );
  }

  Future<ServerResponse> get<T>(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await http.get(
      _buildUrl(path, query),
      headers: {'Accept': 'application/json', ...?authHeader},
    );
    return ServerResponse.visualize(response.body, response.statusCode);
  }

  Future<Uint8List> getImage(String path, {bool useOurServer = true}) async {
    final url = useOurServer ? _buildUrl(path, {}, '') : Uri.parse(path);
    final response = await http.get(
      url,
      headers: {'Accept': 'image/*', ...?authHeader},
    );
    return response.bodyBytes;
  }
}
