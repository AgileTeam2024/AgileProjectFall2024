import 'dart:convert';

import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/services/network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:universal_html/html.dart' as html;

import 'auth_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NetworkService>()])
void main() {
  late AuthService authService;
  late MockNetworkService mockNetworkService;

  setUp(() {
    html.window.localStorage.removeWhere((k, v) => true);
    NetworkService.instance = mockNetworkService = MockNetworkService();
    authService = AuthService.instance;
  });

  test('login sets access and refresh tokens on success', () async {
    final response = ServerResponse(
      jsonEncode(
        {'access_token': 'access123', 'refresh_token': 'refresh123'},
      ),
      200,
    );
    when(mockNetworkService.post(any, any)).thenAnswer((_) async => response);

    final result =
        await authService.login({'username': 'test', 'password': 'test'});

    expect(result.isOk, true);
    expect(authService.accessToken, 'access123');
    expect(authService.refreshToken, 'refresh123');
  });

  test('login does not set tokens on failure', () async {
    final response = ServerResponse(jsonEncode({}), 401);
    when(mockNetworkService.post(any, any)).thenAnswer((_) async => response);

    final result =
        await authService.login({'username': 'test', 'password': 'test'});

    expect(result.isOk, false);
    expect(authService.accessToken, isNull);
    expect(authService.refreshToken, isNull);
  });

  test('logout clears access and refresh tokens on success', () async {
    authService.accessToken = 'access123';
    authService.refreshToken = 'refresh123';
    final response = ServerResponse(jsonEncode({}), 200);
    when(mockNetworkService.delete(any)).thenAnswer((_) async => response);

    final result = await authService.logout();

    expect(result.isOk, true);
    expect(authService.accessToken, isNull);
    expect(authService.refreshToken, isNull);
  });

  test('logout does not clear tokens on failure', () async {
    authService.accessToken = 'access123';
    authService.refreshToken = 'refresh123';
    final response = ServerResponse(jsonEncode({}), 401);
    when(mockNetworkService.delete(any)).thenAnswer((_) async => response);

    final result = await authService.logout();

    expect(result.isOk, false);
    expect(authService.accessToken, 'access123');
    expect(authService.refreshToken, 'refresh123');
  });

  test('isLoggedIn returns true when accessToken is set', () {
    authService.accessToken = 'access123';
    expect(authService.isLoggedIn, true);
  });

  test('isLoggedIn returns false when accessToken is not set', () {
    authService.accessToken = null;
    expect(authService.isLoggedIn, false);
  });

  test('deleteAccount clears access and refresh tokens on success', () async {
    authService.accessToken = 'access123';
    authService.refreshToken = 'refresh123';
    final response = ServerResponse(jsonEncode({}), 200);
    when(mockNetworkService.delete(any)).thenAnswer((_) async => response);

    final result = await authService.deleteAccount();

    expect(result.isOk, true);
    expect(authService.accessToken, isNull);
    expect(authService.refreshToken, isNull);
  });

  test('deleteAccount does not clear tokens on failure', () async {
    authService.accessToken = 'access123';
    authService.refreshToken = 'refresh123';
    final response = ServerResponse(jsonEncode({}), 401);
    when(mockNetworkService.delete(any)).thenAnswer((_) async => response);

    final result = await authService.deleteAccount();

    expect(result.isOk, false);
    expect(authService.accessToken, 'access123');
    expect(authService.refreshToken, 'refresh123');
  });
}
