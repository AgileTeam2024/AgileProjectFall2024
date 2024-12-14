import 'package:get/get.dart';

extension StringPatternCheck on String {
  bool get containsNumeric => RegExp(r'[0-9]').hasMatch(this);

  bool get containsAlphabet => RegExp(r'[a-zA-Z]').hasMatch(this);
}
