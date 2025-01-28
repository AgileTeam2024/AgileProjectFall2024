import 'package:chabok_front/dialogs/report.dart';
import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/product_status.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/services/user.dart';
import 'package:chabok_front/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'report_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ProductService>(),
  MockSpec<AuthService>(),
  MockSpec<UserService>()
])
void main() {
  final loggedInUser =
      User(username: 'LoggedIn', email: 'email', phoneNumber: 'phoneNumber');
  final user =
      User(username: 'Seller', email: 'email', phoneNumber: 'phoneNumber');
  final product = Product(
    id: 1,
    name: 'Test Product',
    description: 'description',
    seller: user,
    imageUrls: [],
    category: ProductCategory.others,
    price: 1000,
    status: ProductStatus.available,
  );
  late final MockProductService mockProductService;
  late final MockAuthService mockAuthService;
  late final MockUserService mockUserService;

  setUpAll(() {
    AuthService.instance = mockAuthService = MockAuthService();
    ProductService.instance = mockProductService = MockProductService();
    UserService.instance = mockUserService = MockUserService();
  });

  group('ReportProductDialog', () {
    Future<void> showProductDialog(WidgetTester tester) async {
      when(mockProductService.getProductById(1))
          .thenAnswer((_) async => product);
      when(mockAuthService.isLoggedIn).thenAnswer((_) => true);
      when(mockUserService.ownProfile).thenAnswer((_) async => loggedInUser);
      await tester
          .pumpWidget(MaterialApp.router(routerConfig: RouterService.router));
      RouterService.go('/product/1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.report));
      await tester.pumpAndSettle();
    }

    testWidgets('displays product name and reason fields', (tester) async {
      await showProductDialog(tester);

      expect(find.text('Report Product'), findsOneWidget);
      expect(find.byType(TextFormField), findsExactly(2));
      // expect(find.text('Product Name'), findsOneWidget);
      // expect(find.text('Reason'), findsOneWidget);
      expect(find.text(product.name), findsOneWidget);
    });

    testWidgets('validates and submits the form', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReportProductDialog(
            tester.element(find.byType(Scaffold)),
            product: product,
          ),
        ),
      ));

      await tester.enterText(find.byType(CustomTextField).last, 'Test Reason');
      await tester.tap(find.text('Submit Report'));
      await tester.pump();

      expect(find.text('Test Reason'), findsOneWidget);
    });

    testWidgets('dismisses the dialog', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReportProductDialog(
            tester.element(find.byType(Scaffold)),
            product: product,
          ),
        ),
      ));

      await tester.tap(find.text('Dismiss Report'));
      await tester.pump();

      expect(find.byType(ReportProductDialog), findsNothing);
    });
  }, skip: true);

  group('ReportUserDialog', () {
    testWidgets('displays username and reason fields', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReportUserDialog(
            tester.element(find.byType(Scaffold)),
            user: user,
          ),
        ),
      ));

      expect(find.text('Report User'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Reason'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('validates and submits the form', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReportUserDialog(
            tester.element(find.byType(Scaffold)),
            user: user,
          ),
        ),
      ));

      await tester.enterText(find.byType(CustomTextField).last, 'Test Reason');
      await tester.tap(find.text('Submit Report'));
      await tester.pump();

      expect(find.text('Test Reason'), findsOneWidget);
    });

    testWidgets('dismisses the dialog', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReportUserDialog(
            tester.element(find.byType(Scaffold)),
            user: user,
          ),
        ),
      ));

      await tester.tap(find.text('Dismiss Report'));
      await tester.pump();

      expect(find.byType(ReportUserDialog), findsNothing);
    });
  }, skip: true);
}
