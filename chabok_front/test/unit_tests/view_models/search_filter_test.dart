import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/sort_type.dart';
import 'package:chabok_front/view_models/search_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initializes with default values', () {
    final filter = SearchFilter();

    expect(filter.categories, isEmpty);
    expect(filter.priceRange, isNull);
    expect(filter.showAvailableProducts, isTrue);
    expect(filter.showReservedProducts, isTrue);
    expect(filter.query, isNull);
    expect(filter.sortType, SortType.createdASC);
  });

  test('initializes with provided values', () {
    final filter = SearchFilter(
      categories: [ProductCategory.digitalAndElectronics],
      priceRange: RangeValues(100, 500),
      showAvailableProducts: false,
      showReservedProducts: false,
      query: 'test',
      sortType: SortType.priceDSC,
    );

    expect(filter.categories, [ProductCategory.digitalAndElectronics]);
    expect(filter.priceRange, RangeValues(100, 500));
    expect(filter.showAvailableProducts, isFalse);
    expect(filter.showReservedProducts, isFalse);
    expect(filter.query, 'test');
    expect(filter.sortType, SortType.priceDSC);
  });

  test('addCategory adds a category', () {
    final filter = SearchFilter();
    filter.addCategory(ProductCategory.kitchenware);

    expect(filter.categories, [ProductCategory.kitchenware]);
  });

  test('deleteCategory removes a category', () {
    final filter = SearchFilter(categories: [ProductCategory.kitchenware]);
    filter.deleteCategory(ProductCategory.kitchenware);

    expect(filter.categories, isEmpty);
  });

  test('categories list is unmodifiable', () {
    final filter = SearchFilter(categories: [ProductCategory.kitchenware]);

    expect(() => filter.categories.add(ProductCategory.digitalAndElectronics),
        throwsUnsupportedError);
  });
}
