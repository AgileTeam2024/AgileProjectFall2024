import 'dart:convert';

import 'package:http/http.dart' as http;

class ServerResponse extends http.Response {
  ServerResponse(super.body, super.statusCode);

  bool get isOk => (super.statusCode / 100).floor() == 2;

  Map<String, dynamic> get bodyJson => jsonDecode(super.body);

  String? get message => isOk ? null : bodyJson['message'];
}
