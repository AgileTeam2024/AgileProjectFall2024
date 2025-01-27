import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/sort_type.dart';
import 'package:chabok_front/pages/search.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/view_models/search_filter.dart';
import 'package:chabok_front/widgets/products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import '../tests_setup_teardown.dart';
import 'search_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProductService>()])
void main() {
  late final SearchFilter filter;

  setUpAll(() {
    filter = SearchFilter(
      query: 'test',
      categories: [ProductCategory.digitalAndElectronics],
    );
    ProductService.instance = MockProductService();
  });

  testWidgets('displays ProductsWidget with results', (tester) async {
    setUpWidgetTest(tester, Size.square(2500));
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SearchPage(filter: filter))));
    await tester.pumpAndSettle();
    expect(find.byType(ProductsWidget), findsOneWidget);
    tearDownWidgetTest(tester);
  });

  testWidgets('displays FilterWidget with correct initial values',
      (tester) async {
    setUpWidgetTest(tester, Size.square(2500));
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SearchPage(filter: filter))));
    await tester.pumpAndSettle();
    expect(find.byType(FilterWidget), findsOneWidget);
    expect(find.text('Show Reserved products'), findsOneWidget);
    expect(find.text('Show Available products'), findsOneWidget);
    expect(find.text('Price Range'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    tearDownWidgetTest(tester);
  });

  testWidgets('updates filter when sort type button is pressed',
      (tester) async {
    setUpWidgetTest(tester, Size.square(2500));
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SearchPage(filter: filter))));
    await tester.pumpAndSettle();
    await tester.tap(find.text(SortType.priceDSC.toStringDisplay()));
    await tester.pumpAndSettle();
    expect(filter.sortType, SortType.priceDSC);
    tearDownWidgetTest(tester);
  });

  testWidgets('updates filter when price range is changed', (tester) async {
    setUpWidgetTest(tester, Size.square(2500));
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SearchPage(filter: filter))));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(RangeSlider), Offset(50, 0));
    await tester.pumpAndSettle();
    expect(filter.priceRange, isNotNull);
    tearDownWidgetTest(tester);
  }, skip: true); // todo cannot test range_slider :(

  testWidgets('updates filter when category is selected', (tester) async {
    setUpWidgetTest(tester, Size.square(2500));
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SearchPage(filter: filter))));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ProductCategory.kitchenware.toString()));
    await tester.pumpAndSettle();
    expect(filter.categories.contains(ProductCategory.kitchenware), isTrue);
    tearDownWidgetTest(tester);
  });

  testWidgets('updates filter when showReservedProducts is selected', (tester) async {
    setUpWidgetTest(tester, Size.square(2500));
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SearchPage(filter: filter))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show Reserved products'));
    await tester.pumpAndSettle();
    expect(filter.showReservedProducts, isFalse);
    await tester.tap(find.text('Show Reserved products'));
    await tester.pumpAndSettle();
    expect(filter.showReservedProducts, isTrue);
    tearDownWidgetTest(tester);
  });

  testWidgets('updates filter when showAvailableProducts is selected', (tester) async {
    setUpWidgetTest(tester, Size.square(2500));
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SearchPage(filter: filter))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show Available products'));
    await tester.pumpAndSettle();
    expect(filter.showAvailableProducts, isFalse);
    await tester.tap(find.text('Show Available products'));
    await tester.pumpAndSettle();
    expect(filter.showAvailableProducts, isTrue);
    tearDownWidgetTest(tester);
  });
}
