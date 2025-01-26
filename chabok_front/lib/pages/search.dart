import 'package:chabok_front/models/num_range.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/search_filter.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final String query;

  const SearchPage({super.key, required this.query});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _productService = ProductService.instance;
  late SearchFilter filter;

  @override
  void initState() {
    super.initState();
    filter = SearchFilter(query: widget.query);
  }

  Future<List<Product>> get searchResults async {
    final available = filter.showAvailableProducts
        ? _productService.searchProducts(
            name: filter.query,
            minPrice: filter.priceRange?.minValue?.toDouble(),
            maxPrice: filter.priceRange?.maxValue?.toDouble(),
            status: 'for sale',
            sortCreatedAt: filter.sortType.createdSort,
            sortPrice: filter.sortType.priceSort,
          )
        : Future.value([]);
    final reserved = filter.showReservedProducts
        ? _productService.searchProducts(
            name: filter.query,
            minPrice: filter.priceRange?.minValue?.toDouble(),
            maxPrice: filter.priceRange?.maxValue?.toDouble(),
            status: 'reserved',
            sortCreatedAt: filter.sortType.createdSort,
            sortPrice: filter.sortType.priceSort,
          )
        : Future.value([]);
    final resultsFuture = await Future.wait([available, reserved]);
    return [...resultsFuture[0], ...resultsFuture[1]];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(
        spacing: 20,
        children: [
          Expanded(
            child: CardWidget(
              margin: EdgeInsets.zero,
              child: FutureBuilder(
                future: searchResults,
                builder: (context, snapshot) => Container(),
              ),
            ),
          ),
          SizedBox(
            width: 300,
            child: CardWidget(
              margin: EdgeInsets.symmetric(vertical: 30),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: FilterWidget(
                filter: filter,
                setFilter: (newFilter) => setState(() => filter = newFilter),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterWidget extends StatefulWidget {
  final SearchFilter filter;
  final void Function(SearchFilter filter) setFilter;

  const FilterWidget({
    super.key,
    required this.filter,
    required this.setFilter,
  });

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  SearchFilter get filter => widget.filter;

  void Function(SearchFilter filter) get setFilter => widget.setFilter;

  String get query => widget.filter.query ?? '';

  List<String> get categories => widget.filter.categories;

  bool get showReserved => widget.filter.showReservedProducts;

  bool get showAvailable => widget.filter.showAvailableProducts;

  num? get minPrice => widget.filter.priceRange?.minValue;

  num? get maxPrice => widget.filter.priceRange?.maxValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FiltersPreview(),

      ],
    );
  }

  Widget FiltersPreview() {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        if (query.isNotEmpty)
          Chip(
            avatar: Icon(Icons.abc),
            label: Text(query),
            onDeleted: () => setFilter(filter..query = ''),
          ),
        if (showReserved)
          Chip(
            avatar: Icon(Icons.category),
            label: Text('Reserved'),
            onDeleted: () => setFilter(filter..showReservedProducts = false),
          ),
        if (showAvailable)
          Chip(
            avatar: Icon(Icons.category),
            label: Text('Available'),
            onDeleted: () => setFilter(filter..showAvailableProducts = false),
          ),
        ...categories.map(
          (category) => Chip(
            avatar: Icon(Icons.category),
            label: Text(category),
            onDeleted: () => setFilter(filter..deleteCategory(category)),
          ),
        ),
        if (minPrice != null)
          Chip(
            avatar: Icon(Icons.money),
            label: Text('> $minPrice'),
            onDeleted: () => setFilter(
              filter..priceRange = NumRange(maxValue: maxPrice),
            ),
          ),
        if (maxPrice != null)
          Chip(
            avatar: Icon(Icons.money),
            label: Text('< $maxPrice'),
            onDeleted: () => setFilter(
              filter..priceRange = NumRange(minValue: minPrice),
            ),
          ),
      ],
    );
  }
}
