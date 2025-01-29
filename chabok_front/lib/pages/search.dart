import 'dart:math';

import 'package:chabok_front/enums/button_type.dart';
import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/sort_type.dart';
import 'package:chabok_front/extensions/num.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/view_models/search_filter.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/products.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final SearchFilter filter;

  const SearchPage({super.key, required this.filter});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _productService = ProductService.instance;

  late SearchFilter filter;

  RangeValues? priceRangeMinMax;

  @override
  void initState() {
    super.initState();
    filter = widget.filter;
    searchResults.then((results) {
      final prices = results.map((p) => p.price);
      if (prices.isNotEmpty) {
        priceRangeMinMax = RangeValues(prices.reduce(min), prices.reduce(max));
        setState(() {});
      }
    });
  }

  Future<List<Product>> get searchResults async {
    return _productService.searchProducts(
      name: filter.query,
      minPrice: filter.priceRange?.start,
      maxPrice: filter.priceRange?.end,
      statuses: [
        if (filter.showAvailableProducts) 'for sale',
        if (filter.showReservedProducts) 'reserved',
      ],
      categories: filter.categories.map((cat) => '$cat').toList(),
      sortCreatedAt: filter.sortType.createdSort,
      sortPrice: filter.sortType.priceSort,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Expanded(
            child: Column(
              spacing: 15,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      'Sort by: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...SortType.values.map((sort) {
                      return Button(
                        type: filter.sortType == sort
                            ? ButtonType.outlined
                            : ButtonType.text,
                        text: sort.toStringDisplay(),
                        onPressed: () => setState(() => filter.sortType = sort),
                      );
                    })
                  ],
                ),
                Expanded(
                  child: FutureBuilder(
                    future: searchResults,
                    builder: (context, snapshot) {
                      print(snapshot.error);
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ProductsWidget(snapshot.data!);
                    },
                  ),
                ),
              ],
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
                priceRangeMinMax: priceRangeMinMax,
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
  final RangeValues? priceRangeMinMax;

  const FilterWidget({
    super.key,
    required this.filter,
    required this.setFilter,
    this.priceRangeMinMax,
  });

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  SearchFilter get filter => widget.filter;

  void Function(SearchFilter filter) get setFilter => widget.setFilter;

  String get query => widget.filter.query ?? '';

  List<ProductCategory> get categories => widget.filter.categories;

  bool get showReserved => widget.filter.showReservedProducts;

  set showReserved(bool newValue) =>
      setFilter(filter..showReservedProducts = newValue);

  bool get showAvailable => widget.filter.showAvailableProducts;

  set showAvailable(bool newValue) =>
      setFilter(filter..showAvailableProducts = newValue);

  RangeValues get priceRange =>
      widget.filter.priceRange ?? widget.priceRangeMinMax ?? RangeValues(0, 1);

  set priceRange(RangeValues newValue) =>
      setFilter(filter..priceRange = newValue);

  RangeValues get priceRangeMinMax =>
      widget.priceRangeMinMax ?? RangeValues(0, 1);

  double get minPrice => priceRange.start;

  double get maxPrice => priceRange.end;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      shrinkWrap: true,
      children: [
        CheckboxListTile(
          title: Text(
            'Show Reserved products',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          value: showReserved,
          onChanged: (newValue) => showReserved = newValue!,
        ),
        CheckboxListTile(
          title: Text(
            'Show Available products',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          value: showAvailable,
          onChanged: (newValue) => showAvailable = newValue!,
        ),
        ListTile(
          title: Text(
            'Price Range',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: '  Minimum Price: ',
                    style: textTheme.labelSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: minPrice.priceFormat,
                    style: textTheme.labelSmall,
                  ),
                  TextSpan(
                    text: '\n  Maximum Price: ',
                    style: textTheme.labelSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: maxPrice.priceFormat,
                    style: textTheme.labelSmall,
                  ),
                ]),
              ),
              RangeSlider(
                min: priceRangeMinMax.start,
                max: priceRangeMinMax.end,
                values: priceRange,
                labels: RangeLabels(
                  priceRange.start.priceFormat,
                  priceRange.end.priceFormat,
                ),
                onChanged: (newRange) => priceRange = newRange,
              ),
            ],
          ),
        ),
        ListTile(
          title: Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: ListBody(
            children: ProductCategory.values.map(
              (cat) {
                final selected = filter.categories.contains(cat);
                return CheckboxListTile(
                  title: Text('$cat'),
                  value: selected,
                  onChanged: (newValue) {
                    (newValue!
                        ? filter.addCategory
                        : filter.deleteCategory)(cat);
                    setFilter(filter);
                  },
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }
}
