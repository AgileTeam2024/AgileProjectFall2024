import 'package:chabok_front/extensions/string.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:flutter/material.dart';

class UsersListWidget extends StatelessWidget {
  final String title;
  final List<dynamic> users;

  final void Function(String username)? onBan, onUnban;

  const UsersListWidget({
    super.key,
    required this.title,
    required this.users,
    this.onBan,
    this.onUnban,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return Container();

    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final item = users[index];
            final user = item is User ? item : item.user;

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: user.profilePicture == null
                      ? null
                      : NetworkImage(user.profilePicture!),
                ),
                title: Text(
                  user.username,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  spacing: 10,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onBan != null)
                      Button.icon(
                        icon: Icons.block,
                        onPressed: () => onBan!(user.username),
                      ),
                    if (onUnban != null)
                      Button.icon(
                        icon: Icons.undo,
                        onPressed: () => onUnban!(user.username),
                      ),
                    Button.icon(
                      icon: Icons.email,
                      onPressed: ()=> user.email.copy(context),
                    ),
                    Button.icon(
                      icon: Icons.phone,
                      onPressed: ()=> user.phoneNumber?.copy(context),
                    ),
                  ],
                ),
                onTap: () => RouterService.go('/profile/${user.username}'),
              ),
            );
          },
        ),
      ],
    );
  }
}
