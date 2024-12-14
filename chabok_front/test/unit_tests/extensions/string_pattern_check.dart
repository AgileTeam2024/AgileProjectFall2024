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

  group('Testing containsAlphabet', () {
    group('should return true', () {
      test('if single alphabet character',
          () => expect(true, 'a'.containsAlphabet));
      test('if multiple alphabet characters',
          () => expect(true, 'aaa'.containsAlphabet));
      test('if starts with alphabet character',
          () => expect(true, 'a11'.containsAlphabet));
      test('if ends with alphabet character',
          () => expect(true, '11a'.containsAlphabet));
      test('if starts and ends with alphabet character',
          () => expect(true, 'a11a'.containsAlphabet));
      test('if contains alphabet character in middle',
          () => expect(true, '1a1'.containsAlphabet));
    });

    group('should return false', () {
      test('for empty string', () => expect(false, ''.containsAlphabet));
      test('if doesn\'t contain numbers',
          () => expect(false, '123'.containsAlphabet));
    });
  });
}
