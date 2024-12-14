import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chabok_front/view_models/text_field.dart';

void main() {
  group('TextFieldViewModel Tests', () {
    test('Required field should return error if empty', () {
      final viewModel = TextFieldViewModel(icon: Icons.abc, required: true);
      expect(viewModel.validator(''), 'This field is Required!');
    });

    test('Non-required field should not return error if empty', () {
      final viewModel = TextFieldViewModel(icon: Icons.abc, required: false);
      expect(viewModel.validator(''), null);
    });
  });

  group('PasswordTextFieldViewModel Tests', () {
    test('Password should contain numbers and alphabets', () {
      final viewModel = PasswordTextFieldViewModel(icon: Icons.password, required: true);
      expect(viewModel.validator('password'), 'Password must contain numbers too.');
      expect(viewModel.validator('123456'), 'Password must contain alphabet too.');
      expect(viewModel.validator('Password123'), null);
    });
  });

  group('EmailTextFieldViewModel Tests', () {
    test('Email should be in correct format', () {
      final viewModel = EmailTextFieldViewModel(icon: Icons.email, required: true);
      expect(viewModel.validator('invalidemail'), 'Incorrect email format.');
      expect(viewModel.validator('valid@email.com'), null);
    });
  });
}
