import 'dart:convert';
import 'dart:typed_data';

import 'package:chabok_front/models/pair.dart';
import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/services/network.dart';
import 'package:chabok_front/services/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NetworkService>()])
void main() {
  late UserService userService;
  late MockNetworkService mockNetworkService;

  setUp(() {
    NetworkService.instance = mockNetworkService = MockNetworkService();
    UserService.instance = userService = UserService();
  });

  test('returns User on successful ownProfile fetch', () async {
    final userJson = {
      'profile': {'username': 'test_user'}
    };
    when(mockNetworkService.get('/user/get_profile_by_username'))
        .thenAnswer((_) async => ServerResponse(jsonEncode(userJson), 200));

    final user = await userService.ownProfile;

    expect(user, isNotNull);
    expect(user!.username, 'test_user');
  });

  test('returns null on failed ownProfile fetch', () async {
    when(mockNetworkService.get('/user/get_profile_by_username'))
        .thenAnswer((_) async => ServerResponse(jsonEncode({}), 401));

    final user = await userService.ownProfile;

    expect(user, isNull);
  });

  test('returns ServerResponse on successful editProfile', () async {
    final fields = {'name': 'new_name'};
    final response = ServerResponse(jsonEncode({}), 200);
    when(mockNetworkService.postFormData(
      '/user/edit_profile',
      fields,
      files: anyNamed('files'),
    )).thenAnswer((_) async => response);

    final result = await userService.editProfile(fields, null);

    expect(result, response);
  });

  test('returns ServerResponse on failed editProfile', () async {
    final fields = {'name': 'new_name'};
    final response = ServerResponse(jsonEncode({}), 400);
    when(mockNetworkService.postFormData(
      '/user/edit_profile',
      fields,
      files: anyNamed('files'),
    )).thenAnswer((_) async => response);

    final result = await userService.editProfile(fields, null);

    expect(result, response);
  });

  test('sends profile picture in editProfile', () async {
    final fields = {'name': 'new_name'};
    final profilePicture = Pair('profile.jpg', Uint8List(0));
    final response = ServerResponse(jsonEncode({}), 200);
    when(mockNetworkService.postFormData(
      '/user/edit_profile',
      fields,
      files: {
        'profile_picture': {'profile.jpg': Uint8List(0)},
      },
    )).thenAnswer((_) async => response);

    final result = await userService.editProfile(fields, profilePicture);

    expect(result, response);
  });
}
