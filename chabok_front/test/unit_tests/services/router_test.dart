import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/product_status.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/pages/create_edit_product.dart';
import 'package:chabok_front/pages/edit_profile.dart';
import 'package:chabok_front/pages/error.dart';
import 'package:chabok_front/pages/home.dart';
import 'package:chabok_front/pages/login_register.dart';
import 'package:chabok_front/pages/product_view.dart';
import 'package:chabok_front/pages/profile.dart';
import 'package:chabok_front/pages/search.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/services/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../tests_setup_teardown.dart';

class MockUserService extends Mock implements UserService {
  @override
  Future<User?> get ownProfile async =>
      User(username: 'username', email: 'email', phoneNumber: 'phoneNumber');
}

class MockProductService extends Mock implements ProductService {
  @override
  Future<List<Product>> searchProducts(
          {String? name,
          double? minPrice,
          double? maxPrice,
          String? status,
          List<String>? categories,
          String? sortCreatedAt,
          String? sortPrice}) async =>
      [];

  @override
  Future<List<Product>> get homePageProducts =>
      searchProducts(sortCreatedAt: 'asc');

  @override
  Future<Product> getProductById(int id) async => Product(
        id: 1,
        name: 'name',
        description: 'description',
        seller: User(
          username: 'username',
          email: 'email',
          phoneNumber: 'phoneNumber',
        ),
        imageUrls: [],
        category: ProductCategory.others,
        price: 10000,
        status: ProductStatus.available,
      );
}

void main() {
  setUpAll(() => ProductService.instance = MockProductService());

  testWidgets('Navigates to home page', (tester) async {
    setUpWidgetTest(tester);
    final router = RouterService.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.byType(HomePage), findsOneWidget);
    tearDownWidgetTest(tester);
  });

  group('If user is not logged in', () {
    setUp(() => AuthService.instance = MockAuthService(false));

    testWidgets('Navigates to login page', (tester) async {
      setUpWidgetTest(tester);
      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/login');
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Navigates to register page', (tester) async {
      setUpWidgetTest(tester);
      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/register');
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Redirects to home going to profile page', (tester) async {
      setUpWidgetTest(tester);
      await tester.pumpAndSettle();

      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/profile');
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Redirects to product view page when trying to edit product',
        (tester) async {
      setUpWidgetTest(tester);
      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/product/1/edit');
      await tester.pumpAndSettle();

      expect(find.byType(ProductViewPage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Redirects to home page when trying to edit profile',
        (tester) async {
      setUpWidgetTest(tester);
      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/edit-profile');
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Redirects to login page when trying to create product',
        (tester) async {
      setUpWidgetTest(tester);
      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/create-product');
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      tearDownWidgetTest(tester);
    });
  });

  group('If user is logged in', () {
    setUp(() {
      AuthService.instance = MockAuthService(true);
      UserService.instance = MockUserService();
    });

    testWidgets('Redirects to home going to login page', (tester) async {
      setUpWidgetTest(tester);
      await tester.pumpAndSettle();

      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/login');
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Redirects to home going to register page', (tester) async {
      setUpWidgetTest(tester);
      await tester.pumpAndSettle();

      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/register');
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Navigates to profile page', (tester) async {
      setUpWidgetTest(tester);
      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/profile');
      await tester.pumpAndSettle();

      expect(find.byType(UserProfilePage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Navigates to edit product page', (tester) async {
      setUpWidgetTest(tester);
      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/product/1/edit');
      await tester.pumpAndSettle();

      expect(find.byType(EditProductPage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Navigates to edit profile page', (tester) async {
      setUpWidgetTest(tester);
      UserService.instance = MockUserService();
      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/edit-profile');
      await tester.pumpAndSettle();

      expect(find.byType(EditProfilePage), findsOneWidget);
      tearDownWidgetTest(tester);
    });

    testWidgets('Navigates to create product page', (tester) async {
      setUpWidgetTest(tester);
      final router = RouterService.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      RouterService.go('/create-product');
      await tester.pumpAndSettle();

      expect(find.byType(CreateProductPage), findsOneWidget);
      tearDownWidgetTest(tester);
    });
  });

  testWidgets('Navigates to error page with correct code and message',
      (tester) async {
    setUpWidgetTest(tester);
    final router = RouterService.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    RouterService.go('/error/404', extra: 'Page not found :(');
    await tester.pumpAndSettle();

    expect(find.byType(ErrorPage), findsOneWidget);
    tearDownWidgetTest(tester);
  });

  testWidgets("Navigates to error page if page doesn't exist", (tester) async {
    setUpWidgetTest(tester);
    final router = RouterService.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    RouterService.go('/abc');
    await tester.pumpAndSettle();

    expect(find.byType(ErrorPage), findsOneWidget);
    expect(find.text('Page not found :('), findsOneWidget);
    tearDownWidgetTest(tester);
  });

  testWidgets('Navigates to search page with query parameters', (tester) async {
    setUpWidgetTest(tester, Size(2500, 2500));
    final router = RouterService.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    RouterService.goNamed('search', queryParameters: {'q': 'test', 'cat': '1'});
    await tester.pumpAndSettle();

    expect(find.byType(SearchPage), findsOneWidget);
    tearDownWidgetTest(tester);
  });

  testWidgets('Navigates to search page with invalid category index',
      (tester) async {
    setUpWidgetTest(tester, Size(2500, 2500));
    final router = RouterService.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    RouterService.goNamed('search',
        queryParameters: {'q': 'test', 'cat': 'invalid'});
    await tester.pumpAndSettle();

    expect(find.byType(SearchPage), findsOneWidget);
    tearDownWidgetTest(tester);
  });
}

class MockAuthService extends Mock implements AuthService {
  final bool _isLoggedIn;

  MockAuthService(this._isLoggedIn);

  @override
  bool get isLoggedIn => _isLoggedIn;
}
