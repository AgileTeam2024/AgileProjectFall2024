import 'package:chabok_front/extensions/num.dart';
import 'package:test/test.dart';

void main() {
  group('NumExtension', () {
    test(
      'compact returns correct format for numbers less than 1000',
      () => expect(999.compact, '999'),
    );

    test(
      'compact returns correct format for numbers in thousands',
      () => expect(1500.compact, '1.5K'),
    );

    test(
      'compact returns correct format for numbers in millions',
      () => expect(2500000.compact, '2.5M'),
    );

    test(
      'compact returns correct format for numbers in billions',
      () => expect(3500000000.compact, '3.5B'),
    );

    test(
      'decimalFormat returns correct format for small numbers',
      () => expect(123.decimalFormat, '123'),
    );

    test(
      'decimalFormat returns correct format for large numbers',
      () => expect(1234567890.decimalFormat, '1,234,567,890'),
    );

    test(
      'decimalFormat returns correct format for numbers with decimals',
      () => expect(1234567.89.decimalFormat, '1,234,567.89'),
    );
  });
}
