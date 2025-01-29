import 'dart:convert';

import 'package:chabok_front/services/router.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServerResponse extends http.Response {
  @visibleForTesting
  ServerResponse(super.body, super.statusCode);

  ServerResponse.visualize(super.body, super.statusCode) {
    if (isOk || is401 || is400 || is403) return;
    RouterService.go('/error/${super.statusCode}');
  }

  bool get isOk => super.statusCode ~/ 100 == 2;

  bool get isServerError => super.statusCode ~/ 100 == 5;

  bool get isRequestError => super.statusCode ~/ 100 == 4;

  bool get is401 => super.statusCode == 401;

  bool get is400 => super.statusCode == 400;

  bool get is403 => super.statusCode == 403;

  Map<String, dynamic> get bodyJson => jsonDecode(super.body);

  String? get message => bodyJson['message'];
}
