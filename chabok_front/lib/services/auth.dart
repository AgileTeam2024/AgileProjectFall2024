import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/services/network.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class AuthService {
  static AuthService? _instance;

  static AuthService get instance {
    _instance ??= AuthService();
    return _instance!;
  }

  set accessToken(String? newToken) {
    html.window.localStorage.remove('access_token');
    if (newToken != null) {
      html.window.localStorage.putIfAbsent('access_token', () => newToken);
    }
  }

  String? get accessToken => html.window.localStorage['access_token'];

  set refreshToken(String? newToken) {
    html.window.localStorage.remove('refresh_token');
    if (newToken != null) {
      html.window.localStorage.putIfAbsent('refresh_token', () => newToken);
    }
  }

  String? get refreshToken => html.window.localStorage['refresh_token'];

  @visibleForTesting
  static set instance(AuthService value) => _instance = value;

  NetworkService get _networkService => NetworkService.instance;

  bool get isLoggedIn => accessToken != null;

  Future<ServerResponse> login(Map<String, String> body) =>
      _networkService.post('/user/login', body).then((response) {
        if (response.isOk) {
          accessToken = response.bodyJson['access_token'];
          refreshToken = response.bodyJson['refresh_token'];
        }
        return response;
      });

  Future<ServerResponse> register(Map<String, String> body) =>
      _networkService.post('/user/register', body);

  Future<ServerResponse> logout() =>
      _networkService.get('/user/logout').then((response) {
        if (response.isOk) {
          accessToken = null;
          refreshToken = null;
        }
        return response;
      });

  Future<ServerResponse> deleteAccount() =>
      _networkService.get('/user/delete').then((response) {
        if (response.isOk) {
          accessToken = null;
          refreshToken = null;
        }
        return response;
      });

  Future<ServerResponse> refreshAccount() =>
      _networkService.get('/user/refresh', ).then((response) {
        if (response.isOk) {
          accessToken = null;
          refreshToken = null;
        }
        return response;
      });
}
