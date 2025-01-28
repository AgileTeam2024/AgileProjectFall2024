import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/user.dart';
import 'package:chabok_front/widgets/user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../tests_setup_teardown.dart';
import 'user_info_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserService>()])
void main() {
  late final MockUserService mockUserService;

  final user = User(
      username: '_JohnDoe_',
      firstName: 'John',
      lastName: 'Doe',
      email: 'johndoe@email.com',
      phoneNumber: '09121234567',
      address: 'Tehran 1234');

  setUpAll(() {
    UserService.instance = mockUserService = MockUserService();
  });

  testWidgets('displays own user information correctly', (tester) async {
    setUpWidgetTest(tester, Size(2500, 2500));
    when(mockUserService.ownProfile).thenAnswer((_) async => user);

    await tester.pumpWidget(MaterialApp(home: UserInfoWidget()));
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Username: _JohnDoe_'), findsOneWidget);
    expect(find.text('Email: johndoe@email.com'), findsOneWidget);
    expect(find.text('Phone: 09121234567'), findsOneWidget);
    expect(find.text('Address: Tehran 1234'), findsOneWidget);
  });

  testWidgets('displays user information correctly', (tester) async {
    setUpWidgetTest(tester, Size(2500, 2500));
    when(mockUserService.ownProfile).thenThrow(Error());

    await tester.pumpWidget(MaterialApp(home: UserInfoWidget(user: user)));
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Username: _JohnDoe_'), findsOneWidget);
    expect(find.text('Email: johndoe@email.com'), findsOneWidget);
    expect(find.text('Phone: 09121234567'), findsOneWidget);
    expect(find.text('Address: Tehran 1234'), findsOneWidget);
  });
}
