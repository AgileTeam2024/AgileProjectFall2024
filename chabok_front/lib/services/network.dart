import 'dart:convert';
import 'dart:typed_data';

import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  static NetworkService? _instance;

  static NetworkService get instance {
    _instance ??= NetworkService();
    return _instance!;
  }

  @visibleForTesting
  static set instance(NetworkService value) {
    _instance = value;
  }

  static const scheme = 'https';
  static const host = 'pre-loved.ir';
  static const port = 443;

  Map<String, String>? get authHeaderAccess {
    final authService = AuthService.instance;
    if (authService.accessToken == null) return null;
    return {'Authorization': 'Bearer ${authService.accessToken}'};
  }

  Map<String, String>? get authHeaderRefresh {
    final authService = AuthService.instance;
    if (authService.refreshToken == null) return null;
    return {'Authorization': 'Bearer ${authService.refreshToken}'};
  }

  Uri _buildUrl(
    String path,
    Map<String, dynamic>? query, [
    String prefix = '/api',
  ]) {
    return Uri(
      scheme: scheme,
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
        ...?authHeaderAccess
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 &&
        path != '/user/refresh' &&
        authHeaderRefresh != null &&
        await refreshToken()) {
      return post(path, body, query: query);
    }

    return ServerResponse.visualize(response.body, response.statusCode);
  }

  Future<ServerResponse> postFormData<T>(
    String path,
    Map<String, dynamic> fields, {
    Map<String, dynamic>? query,
    Map<String, Map<String, Uint8List>>? files,
  }) =>
      _formData('POST', path, fields, files: files, query: query);

  Future<ServerResponse> putFormData<T>(
    String path,
    Map<String, dynamic> fields, {
    Map<String, dynamic>? query,
    Map<String, Map<String, Uint8List>>? files,
  }) =>
      _formData('PUT', path, fields, files: files, query: query);

  Future<ServerResponse> _formData(
    String method,
    String path,
    Map<String, dynamic> fields, {
    Map<String, dynamic>? query,
    Map<String, Map<String, Uint8List>>? files,
  }) async {
    final request = http.MultipartRequest(method, _buildUrl(path, query));
    fields.forEach((k, v) => request.fields.putIfAbsent(k, () => '$v'));
    files?.forEach(
      (key, values) => values.forEach(
        (path, bytes) => request.files.add(
          http.MultipartFile.fromBytes(key, bytes, filename: path),
        ),
      ),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/form-data',
      ...?authHeaderAccess
    });

    final response = await request.send();

    if (response.statusCode == 401 &&
        path != '/user/refresh' &&
        authHeaderRefresh != null &&
        await refreshToken()) {
      return _formData(method, path, fields, query: query, files: files);
    }

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
      headers: {
        'Accept': 'application/json',
        if (path == '/user/refresh')
          ...?authHeaderRefresh
        else
          ...?authHeaderAccess,
      },
    );
    if (response.statusCode == 401 &&
        path != '/user/refresh' &&
        authHeaderRefresh != null &&
        await refreshToken()) {
      return get(path, query: query);
    }
    return ServerResponse.visualize(response.body, response.statusCode);
  }

  Future<ServerResponse> delete<T>(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await http.delete(
      _buildUrl(path, query),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        ...?authHeaderAccess
      },
    );

    if (response.statusCode == 401 &&
        path != '/user/refresh' &&
        authHeaderRefresh != null &&
        await refreshToken()) {
      return delete(path, query: query);
    }

    return ServerResponse.visualize(response.body, response.statusCode);
  }

  String? getAbsoluteFilePath(String? relative) => relative == null
      ? relative
      : Uri(
              scheme: scheme,
              host: host,
              port: port,
              path: 'backend/uploads/$relative')
          .toString();

  String? getRelativeFilePath(String? absolute) => absolute == null
      ? absolute
      : Uri.parse(absolute).path.replaceAll('/backend/uploads/', '');

  Future<Uint8List> getImage(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'image/*', ...?authHeaderAccess},
    );
    return response.bodyBytes;
  }

  Future<bool> refreshToken() async {
    return (await get('/user/refresh')).isOk;
  }
}
