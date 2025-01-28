import 'dart:convert';

import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/product_status.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/admin.dart';
import 'package:chabok_front/services/network.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'admin_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NetworkService>()])
void main() {
  late AdminService adminService;
  late MockNetworkService mockNetworkService;

  final reportProduct = ServerResponse(
    jsonEncode({
      'reported_products': [
        {
          'id': 1,
          'reporter_username': 'username1',
          'reported_product': 1,
          'description': 'spam'
        }
      ]
    }),
    200,
  );
  final reportUser = ServerResponse(
    jsonEncode({
      'reported_users': [
        {
          'id': 1,
          'reporter_username': 'username1',
          'reported_user': 'username',
          'description': 'spam'
        }
      ]
    }),
    200,
  );
  final failed = ServerResponse('{}', 403);
  final emptySuccess = ServerResponse('{}', 200);
  final user =
      User(username: 'username', email: 'email', phoneNumber: 'phoneNumber');
  final product = Product(
      id: 1,
      name: 'name',
      description: 'description',
      seller: user,
      imageUrls: [],
      category: ProductCategory.others,
      price: 1000,
      status: ProductStatus.available);

  setUp(() {
    NetworkService.instance = mockNetworkService = MockNetworkService();
    adminService = AdminService.instance;
  });

  test('returns reported products when response is OK', () async {
    when(mockNetworkService
            .get('/product/get_product_by_id', query: {'product_id': '1'}))
        .thenAnswer((_) async =>
            ServerResponse(jsonEncode({'product': product.toJson()}), 200));
    when(mockNetworkService.get(
      '/admin/product-reports-list',
      query: null,
    )).thenAnswer((_) async => reportProduct);

    final products = await adminService.reportedProducts;

    expect(products, isNotEmpty);
  });

  test('returns empty list when reported products response is not OK',
      () async {
    when(
      mockNetworkService.get(
        '/admin/product-reports-list',
        query: anyNamed('query'),
      ),
    ).thenAnswer((_) async => failed);
    when(mockNetworkService
            .get('/product/get_product_by_id', query: {'product_id': 1}))
        .thenAnswer((_) async =>
            ServerResponse(jsonEncode({'product': product.toJson()}), 200));

    final products = await adminService.reportedProducts;

    expect(products, isEmpty);
  });

  test('returns reported users when response is OK', () async {
    when(
      mockNetworkService.get(
        '/user/get_profile_by_username/username',
        query: anyNamed('query'),
      ),
    ).thenAnswer((_) async =>
        ServerResponse(jsonEncode({'profile': user.toJson()}), 200));
    when(
      mockNetworkService.get(
        '/admin/user-reports-list',
        query: anyNamed('query'),
      ),
    ).thenAnswer((_) async => reportUser);

    final users = await adminService.reportedUsers;

    expect(users, isNotEmpty);
  });

  test('returns empty list when reported users response is not OK', () async {
    when(
      mockNetworkService.get(
        '/admin/user-reports-list',
        query: anyNamed('query'),
      ),
    ).thenAnswer((_) async => failed);

    final users = await adminService.reportedUsers;

    expect(users, isEmpty);
  });

  test('returns banned products when response is OK', () async {
    when(
      mockNetworkService.get(
        '/admin/banned-product-list',
        query: anyNamed('query'),
      ),
    ).thenAnswer(
      (_) async => ServerResponse(
        jsonEncode({
          'banned_products': [product.toJson()]
        }),
        200,
      ),
    );

    final products = await adminService.bannedProducts;

    expect(products, isNotEmpty);
  });

  test('returns empty list when banned products response is not OK', () async {
    when(
      mockNetworkService.get(
        '/admin/banned-product-list',
        query: anyNamed('query'),
      ),
    ).thenAnswer((_) async => failed);

    final products = await adminService.bannedProducts;

    expect(products, isEmpty);
  });

  test('returns banned users when response is OK', () async {
    when(
      mockNetworkService.get(
        '/admin/banned-user-list',
        query: anyNamed('query'),
      ),
    ).thenAnswer(
      (_) async => ServerResponse(
        jsonEncode({
          'banned_users': [user.toJson()]
        }),
        200,
      ),
    );

    final users = await adminService.bannedUsers;

    expect(users, isNotEmpty);
  });

  test('returns empty list when banned users response is not OK', () async {
    when(mockNetworkService.get('/admin/banned-user-list', query: null))
        .thenAnswer((_) async => failed);

    final users = await adminService.bannedUsers;

    expect(users, isEmpty);
  });

  test('bans user successfully', () async {
    when(mockNetworkService.postFormData(
      '/admin/ban_user',
      {'username': 'user1'},
      query: null,
      files: null,
    )).thenAnswer((_) async => emptySuccess);

    final response = await adminService.banUser('user1');

    expect(response.isOk, isTrue);
  });

  test('unbans user successfully', () async {
    when(
      mockNetworkService.postFormData(
        '/admin/unban_user',
        {'username': 'user1'},
        query: null,
        files: null,
      ),
    ).thenAnswer((_) async => emptySuccess);

    final response = await adminService.unbanUser('user1');

    expect(response.isOk, isTrue);
  });

  test('bans product successfully', () async {
    when(
      mockNetworkService.postFormData(
        '/admin/ban_product',
        {'product_id': 1},
        query: null,
        files: null,
      ),
    ).thenAnswer((_) async => emptySuccess);

    final response = await adminService.banProduct(1);

    expect(response.isOk, isTrue);
  });

  test('unbans product successfully', () async {
    when(mockNetworkService
            .postFormData('/admin/unban_product', {'product_id': 1}))
        .thenAnswer((_) async => emptySuccess);

    final response = await adminService.unbanProduct(1);

    expect(response.isOk, isTrue);
  });
}
