import 'package:chabok_front/extensions/string_pattern_check.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextFieldViewModel {
  final TextEditingController controller = TextEditingController();
  final IconData icon;
  final String? helper, hint, error, label;
  TextInputType type = TextInputType.text;
  final bool required, readOnly;
  bool obscureText;

  String get text => controller.text;

  TextSelection get selection => controller.selection;

  TextFieldViewModel({
    required this.icon,
    this.helper,
    this.hint,
    this.error,
    this.label,
    required this.required,
    this.readOnly = false,
    this.obscureText = false,
  });

  String? validator(String? text) {
    if (required && (text?.isEmpty ?? false)) return 'This field is Required!';
    return null;
  }
}

class PasswordTextFieldViewModel extends TextFieldViewModel {
  PasswordTextFieldViewModel({
    required super.icon,
    super.helper,
    super.hint,
    super.error,
    super.label,
    required super.required,
    super.readOnly,
    super.obscureText = true,
  }) {
    type = TextInputType.visiblePassword;
  }

  @override
  String? validator(String? text) {
    final message = super.validator(text);
    if (message != null) return message;
    if (!text!.containsNumeric) return 'Password must contain numbers too.';
    if (!text.containsAlphabet) return 'Password must contain alphabet too.';

    return null;
  }
}

class EmailTextFieldViewModel extends TextFieldViewModel {
  EmailTextFieldViewModel({
    required super.icon,
    super.helper,
    super.hint,
    super.error,
    super.label,
    required super.required,
    super.readOnly,
  }) {
    type = TextInputType.emailAddress;
  }

  @override
  String? validator(String? text) {
    final message = super.validator(text);
    if (message != null) return message;
    if (!text!.isEmail) return 'Incorrect email format.';
    return null;
  }
}
