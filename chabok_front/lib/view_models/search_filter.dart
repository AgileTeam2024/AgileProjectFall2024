import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/sort_type.dart';
import 'package:flutter/material.dart';

class SearchFilter {
  final List<ProductCategory> _categories;
  RangeValues? priceRange;
  bool showAvailableProducts;
  bool showReservedProducts;
  String? query;
  SortType sortType;

  List<ProductCategory> get categories => List.unmodifiable(_categories);

  SearchFilter({
    List<ProductCategory>? categories,
    this.priceRange,
    this.showAvailableProducts = true,
    this.showReservedProducts = true,
    this.query,
    this.sortType = SortType.createdASC,
  }) : _categories = List.of(categories ?? []);

  void deleteCategory(ProductCategory category) => _categories.remove(category);

  void addCategory(ProductCategory category) => _categories.add(category);
}
