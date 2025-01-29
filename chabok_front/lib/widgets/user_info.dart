import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/user.dart';
import 'package:flutter/material.dart';

class UserInfoWidget extends StatelessWidget {
  final User? user;

  final _userService = UserService.instance;

  UserInfoWidget({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future(() async => user ?? await _userService.ownProfile),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (!snapshot.hasData || profile == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: profile.profilePictureAbsolute == null
                  ? null
                  : NetworkImage(profile.profilePictureAbsolute!),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Username: ${profile.username}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  'Email: ${profile.email ?? "-"}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  'Address: ${profile.address ?? "-"}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  'Phone: ${profile.phoneNumber ?? "-"}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
