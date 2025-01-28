import 'dart:convert';

import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension StringExt on String {
  void copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: this));
    CustomToast.showToast(
      context,
      ServerResponse.visualize(
        jsonEncode({'message': 'Copied to Clipboard'}),
        200,
      ),
    );
  }
}
