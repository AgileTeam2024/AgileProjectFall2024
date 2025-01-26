import 'package:chabok_front/models/num_range.dart';

class SearchFilter {
  final List<String> _categories;
  NumRange? priceRange;
  bool showAvailableProducts;
  bool showReservedProducts;
  String? query;
  SortType sortType;

  List<String> get categories => List.unmodifiable(_categories);

  SearchFilter({
    List<String>? categories,
    this.priceRange,
    this.showAvailableProducts = true,
    this.showReservedProducts = true,
    this.query,
    this.sortType = SortType.createdASC,
  }) : _categories = categories ?? [];

  void deleteCategory(String category) => _categories.remove(category);

  void addCategory(String category) => _categories.add(category);
}

enum SortType {
  priceASC,
  priceDSC,
  createdASC,
  createdDSC;

  String? get priceSort =>
      ![priceASC, priceDSC].contains(this) ? null : '$this'.substring(4);

  String? get createdSort =>
      ![createdASC, createdDSC].contains(this) ? null : '$this'.substring(6);

  @override
  String toString() => super.toString().split('.')[1];
}
