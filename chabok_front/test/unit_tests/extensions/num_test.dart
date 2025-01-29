import 'package:chabok_front/extensions/num.dart';
import 'package:test/test.dart';

void main() {
  group('NumExtension', () {
    test(
      'priceFormat returns correct format for numbers less than 1000',
      () => expect(999.priceFormat, '999 ᴵᴿᴿ'),
    );

    test(
      'priceFormat returns correct format for numbers in thousands',
      () => expect(1500.priceFormat, '1,500 ᴵᴿᴿ'),
    );

    test(
      'priceFormat returns correct format for numbers in millions',
      () => expect(2500000.priceFormat, '2,500,000 ᴵᴿᴿ'),
    );

    test(
      'priceFormat returns correct format for numbers in billions',
      () => expect(3500000000.priceFormat, '3,500,000,000 ᴵᴿᴿ'),
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
      () => expect(1234567.89.decimalFormat, '1,234,568'),
    );
  });
}
