import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/widgets/seller.dart';
import 'package:flutter/material.dart';

void main() {
  setUpAll(() => HttpOverrides.global = null);

  group('SellerWidget', () {
    testWidgets('displays seller username', (tester) async {
      final user = User(
          username: 'testuser',
          profilePicture: null,
          phoneNumber: '1234567890',
          email: 'test@example.com');
      await tester.pumpWidget(MaterialApp(home: SellerWidget(user)));

      expect(find.text('testuser'), findsOneWidget);
    });

    testWidgets('displays seller profile picture', (tester) async {
      final user = User(
          username: 'testuser',
          profilePicture: 'assets/sample_images/seller_pfp.jpg',
          phoneNumber: '1234567890',
          email: 'test@example.com');
      await tester.pumpWidget(MaterialApp(home: SellerWidget(user)));

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('displays contact info when showContactInfo is true',
        (tester) async {
      final user = User(
          username: 'testuser',
          profilePicture: null,
          phoneNumber: '1234567890',
          email: 'test@example.com');
      await tester.pumpWidget(
          MaterialApp(home: SellerWidget(user, showContactInfo: true)));

      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('does not display contact info when showContactInfo is false',
        (tester) async {
      final user = User(
          username: 'testuser',
          profilePicture: null,
          phoneNumber: '1234567890',
          email: 'test@example.com');
      await tester.pumpWidget(
          MaterialApp(home: SellerWidget(user, showContactInfo: false)));

      expect(find.byIcon(Icons.phone), findsNothing);
      expect(find.byIcon(Icons.email), findsNothing);
    });

    testWidgets('copies phone number to clipboard when phone icon is tapped',
        (tester) async {
      bool copiedToClipboard = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          switch (call.method) {
            case 'Clipboard.setData':
              copiedToClipboard = true;
            case 'Clipboard.getData':
              return {'text': '1234567890'};
          }
          return null;
        },
      );

      final user = User(
          username: 'testuser',
          profilePicture: null,
          phoneNumber: '1234567890',
          email: 'test@example.com');
      await tester.pumpWidget(
          MaterialApp(home: SellerWidget(user, showContactInfo: true)));

      await tester.tap(find.byIcon(Icons.phone));
      await tester.pumpAndSettle(Duration(seconds: 5));

      expect(copiedToClipboard, true);

      final clipboardData = await Clipboard.getData('text/plain');
      expect(clipboardData?.text, '1234567890');
    });

    testWidgets('copies email to clipboard when email icon is tapped',
        (tester) async {
      bool copiedToClipboard = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          switch (call.method) {
            case 'Clipboard.setData':
              copiedToClipboard = true;
            case 'Clipboard.getData':
              return {'text': 'test@example.com'};
          }
          return null;
        },
      );

      final user = User(
          username: 'testuser',
          profilePicture: null,
          phoneNumber: '1234567890',
          email: 'test@example.com');
      await tester.pumpWidget(
          MaterialApp(home: SellerWidget(user, showContactInfo: true)));

      await tester.tap(find.byIcon(Icons.email));
      await tester.pumpAndSettle(Duration(seconds: 5));

      expect(copiedToClipboard, true);

      final clipboardData = await Clipboard.getData('text/plain');
      expect(clipboardData?.text, 'test@example.com');
    });
  });
}
