import 'package:chabok_front/extensions/string_pattern_check.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Testing containsNumeric', () {
    group('should return true', () {
      test('if single numeric character',
          () => expect(true, '1'.containsNumeric));
      test('if multiple numeric characters',
          () => expect(true, '123'.containsNumeric));
      test('if starts with numeric character',
          () => expect(true, '1ab'.containsNumeric));
      test('if ends with numeric character',
          () => expect(true, 'ab1'.containsNumeric));
      test('if starts and ends with numeric character',
          () => expect(true, '1ab1'.containsNumeric));
      test('if contains numeric character in middle',
          () => expect(true, 'a1b'.containsNumeric));
    });
    group('should return false', () {
      test('for empty string', () => expect(false, ''.containsNumeric));
      test('if doesn\'t contain numbers',
          () => expect(false, 'abc'.containsNumeric));
    });
  });
}
