import 'dart:convert';
import 'dart:io';

import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/pages/create_edit_product.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/widgets/text_field.dart';
import 'package:chabok_front/widgets/upload_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../tests_setup_teardown.dart';
import 'create_product_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ProductService>(),
  MockSpec<AuthService>(),
  MockSpec<FilePicker>()
])
void main() {
  late MockProductService mockProductService;
  late MockAuthService mockAuthService;
  late MockFilePicker mockFilePicker;

  setUp(() {
    HttpOverrides.global = null;
    ProductService.instance = mockProductService = MockProductService();
    AuthService.instance = mockAuthService = MockAuthService();
    mockFilePicker = MockFilePicker();
  });

  testWidgets('displays all text fields and upload widget', (tester) async {
    setUpWidgetTest(tester);
    await tester.pumpWidget(MaterialApp(home: CreateProductPage()));

    expect(find.byType(CustomTextField), findsNWidgets(6));
    expect(find.byType(UploadFileWidget), findsOneWidget);
  });

  testWidgets('displays MainFAB with check icon', (tester) async {
    setUpWidgetTest(tester);
    await tester.pumpWidget(MaterialApp(home: CreateProductPage()));
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('calls createProduct when MainFAB is pressed', (tester) async {
    when(mockAuthService.isLoggedIn).thenAnswer((_) => true);
    when(mockProductService.homePageProducts).thenAnswer((_) async => []);

    setUpWidgetTest(tester);
    await tester
        .pumpWidget(MaterialApp.router(routerConfig: RouterService.router));
    RouterService.go('/create-product');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CustomTextField).at(0), 'Product name');
    await tester.tap(find.byType(CustomTextField).at(1));
    await tester.pump();
    await tester.tap(find.text('Others'));
    await tester.pump();
    await tester.enterText(find.byType(CustomTextField).at(4), '1000');
    await tester.enterText(
        find.byType(CustomTextField).at(5), 'Product description');
    await tester.pump();

    final uploadWidget = find.byType(UploadFileWidget).evaluate().first.widget
        as UploadFileWidget;
    uploadWidget.filePicker = mockFilePicker;

    when(mockFilePicker.pickFiles(type: FileType.image, allowMultiple: true))
        .thenAnswer((_) async {
      final name = 'assets/sample_images/product_img0.jpg';
      final bytes = File(name).readAsBytesSync();
      return FilePickerResult([
        PlatformFile(
          name: name,
          size: bytes.lengthInBytes,
          bytes: bytes,
        )
      ]);
    });
    await tester.tap(find.byType(UploadFileWidget));
    await tester.pump();

    when(mockProductService.createProduct(any, any)).thenAnswer((_) async =>
        ServerResponse(jsonEncode({'message': 'product created'}), 201));

    await tester.tap(find.byIcon(Icons.check));
    await tester.pump(Duration(seconds: 5));

    verify(
      mockProductService.createProduct({
        'name': 'Product name',
        'category': 'Others',
        'status': 'for sale',
        'city_name': '',
        'price': '1000',
        'description': 'Product description'
      }, any),
    ).called(1);
  });

  testWidgets('displays vertical layout on small screens',
      (WidgetTester tester) async {
    setUpWidgetTest(tester, Size(999, 800));
    await tester.pumpWidget(MaterialApp(home: CreateProductPage()));

    expect(find.byType(Column), findsNWidgets(2));
  });

  testWidgets('displays horizontal layout on large screens',
      (WidgetTester tester) async {
    setUpWidgetTest(tester, Size(1200, 800));
    await tester.pumpWidget(MaterialApp(home: CreateProductPage()));

    expect(find.byType(Row), findsNWidgets(3));
  });
}
