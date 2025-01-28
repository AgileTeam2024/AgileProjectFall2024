import 'dart:convert';

import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/product_status.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/product_report.dart';
import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/models/user_report.dart';
import 'package:chabok_front/pages/admin_profile.dart';
import 'package:chabok_front/services/admin.dart';
import 'package:chabok_front/widgets/products_list.dart';
import 'package:chabok_front/widgets/users_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../tests_setup_teardown.dart';
import 'admin_profile_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AdminService>()])
void main() {
  late MockAdminService mockAdminService;

  final user1 =
      User(username: 'username1', email: 'email1', phoneNumber: 'phoneNumber1');
  final user2 =
      User(username: 'username2', email: 'email2', phoneNumber: 'phoneNumber2');
  final product1 = Product(
      id: 1,
      name: 'name',
      description: 'description',
      seller: user1,
      imageUrls: [],
      category: ProductCategory.others,
      price: 1000,
      status: ProductStatus.available);
  final product2 = Product(
      id: 2,
      name: 'name',
      description: 'description',
      seller: user1,
      imageUrls: [],
      category: ProductCategory.others,
      price: 1000,
      status: ProductStatus.available);
  final userReport1 = UserReport(
      id: 1,
      description: 'description',
      reporterUsername: user2.username,
      user: user1);
  final productReport1 = ProductReport(
      id: 1,
      description: 'description',
      reporterUsername: user2.username,
      product: product1);
  final success = ServerResponse(jsonEncode({'message': 'Success'}), 200);

  final banProductBtn = find.byKey(Key('banProductButton_${product1.id}'));
  final unbanProductBtn = find.byKey(Key('unbanProductButton_${product2.id}'));
  final banUserBtn = find.byKey(Key('banUserButton_${user1.username}'));
  final unbanUserBtn = find.byKey(Key('unbanUserButton_${user2.username}'));

  setUpAll(() {
    AdminService.instance = mockAdminService = MockAdminService();
  });

  Future<void> testerSetup(WidgetTester tester) async {
    setUpWidgetTest(tester, Size(2500, 2500));

    when(mockAdminService.reportedUsers).thenAnswer((_) async => [userReport1]);
    when(mockAdminService.reportedProducts)
        .thenAnswer((_) async => [productReport1]);
    when(mockAdminService.bannedUsers).thenAnswer((_) async => [user2]);
    when(mockAdminService.bannedProducts).thenAnswer((_) async => [product2]);
    when(mockAdminService.banProduct(any)).thenAnswer((_) async => success);
    when(mockAdminService.unbanProduct(any)).thenAnswer((_) async => success);
    when(mockAdminService.banUser(any)).thenAnswer((_) async => success);
    when(mockAdminService.unbanUser(any)).thenAnswer((_) async => success);

    await tester.pumpWidget(MaterialApp(home: AdminProfilePage()));

    await tester.pump(Duration(seconds: 15));
  }

  testWidgets('Displays lists correctly', (tester) async {
    await testerSetup(tester);
    expect(find.byType(UsersListWidget), findsExactly(2));
    expect(find.byType(ProductsListWidget), findsExactly(2));
    expect(banProductBtn, findsOneWidget);
    expect(unbanProductBtn, findsOneWidget);
    expect(banUserBtn, findsOneWidget);
    expect(unbanUserBtn, findsOneWidget);
  });

  testWidgets('Ban user button calls correct method', (tester) async {
    await testerSetup(tester);
    await tester.tap(banUserBtn);
    verify(mockAdminService.banUser(user1.username)).called(1);
  });

  testWidgets('Ban product button calls correct method', (tester) async {
    await testerSetup(tester);
    await tester.tap(banProductBtn);
    verify(mockAdminService.banProduct(product1.id)).called(1);
  });

  testWidgets('Unban user button calls correct method', (tester) async {
    await testerSetup(tester);
    await tester.tap(unbanUserBtn);
    verify(mockAdminService.unbanUser(user2.username)).called(1);
  });

  testWidgets('Unban product button calls correct method', (tester) async {
    await testerSetup(tester);
    await tester.tap(unbanProductBtn);
    verify(mockAdminService.unbanProduct(product2.id)).called(1);
  });
}
