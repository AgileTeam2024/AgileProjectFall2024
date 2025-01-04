import 'package:chabok_front/extensions/list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ListExt', () {
    test('returns empty list when input list is empty', () {
      final list = <int>[];
      final result = list.fixedGrouped(groupSize: 2);
      expect(result, []);
    });

    test('groups list elements correctly when group size is 1', () {
      final list = [1, 2, 3];
      final result = list.fixedGrouped(groupSize: 1);
      expect(result, [
        [1],
        [2],
        [3]
      ]);
    });

    test('groups list elements correctly when group size is greater than 1',
        () {
      final list = [1, 2, 3, 4, 5];
      final result = list.fixedGrouped(groupSize: 2);
      expect(result, [
        [1, 2],
        [3, 4],
        [5]
      ]);
    });

    test('handles list length not being a multiple of group size', () {
      final list = [1, 2, 3, 4, 5, 6, 7];
      final result = list.fixedGrouped(groupSize: 3);
      expect(result, [
        [1, 2, 3],
        [4, 5, 6],
        [7]
      ]);
    });

    test('handles list length being a multiple of group size', () {
      final list = [1, 2, 3, 4, 5, 6];
      final result = list.fixedGrouped(groupSize: 3);
      expect(result, [
        [1, 2, 3],
        [4, 5, 6]
      ]);
    });
  });
}
