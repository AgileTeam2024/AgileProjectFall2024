import 'package:chabok_front/extensions/num.dart';
import 'package:chabok_front/extensions/string_pattern_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldViewModel {
  final TextEditingController controller = TextEditingController();
  final IconData icon;
  final String? helper, hint, error, label;
  final bool required, readOnly;
  final int? maxLines;

  TextInputType type = TextInputType.text;
  List<TextInputFormatter>? inputFormatters;
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
    this.inputFormatters,
    this.maxLines,
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
    if (!this.required && this.text.isEmpty) return null;
    if (!text!.isEmail) return 'Incorrect email format.';
    return null;
  }
}

class MoneyTextFieldViewModel extends TextFieldViewModel {
  MoneyTextFieldViewModel({
    super.icon = Icons.money,
    super.helper,
    super.hint,
    super.error,
    super.label,
    required super.required,
    super.readOnly,
  }) {
    inputFormatters = [
      TextInputFormatter.withFunction((olderValue, oldValue) {
        if (oldValue.text.isEmpty) return oldValue;
        try {
          final newValue =
              int.parse(oldValue.text.replaceAll(',', '')).decimalFormat;
          return oldValue.copyWith(
            text: newValue,
            selection: TextSelection(
              baseOffset: newValue.length,
              extentOffset: newValue.length,
            ),
          );
        } on FormatException {
          return olderValue;
        }
      }),
    ];
    type = TextInputType.numberWithOptions();
  }
}

class OptionsTextFieldViewModel extends TextFieldViewModel {
  final List<String> options;

  OptionsTextFieldViewModel({
    required this.options,
    required super.icon,
    super.helper,
    super.hint,
    super.error,
    super.label,
    required super.required,
    super.readOnly,
  });
}
