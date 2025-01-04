import 'package:flutter/services.dart';

extension StringExt on String {
  void copy() => Clipboard.setData(ClipboardData(text: this));
}
