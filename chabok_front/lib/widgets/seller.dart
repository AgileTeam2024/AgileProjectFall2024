import 'package:chabok_front/extensions/string.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:flutter/material.dart';

class SellerWidget extends StatelessWidget {
  final User seller;
  final bool showContactInfo;

  const SellerWidget(
    this.seller, {
    this.showContactInfo = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        _SellerPfpWidget(seller.profilePicture),
        Expanded(child: _SellerUsernameWidget(seller.username)),
        if (showContactInfo) ...[
          Spacer(),
          Button.icon(
            icon: Icons.phone,
            onPressed: seller.phoneNumber?.copy,
          ),
          Button.icon(
            icon: Icons.email,
            onPressed: seller.email?.copy,
          ),
        ],
      ],
    );
  }
}

class _SellerPfpWidget extends StatelessWidget {
  final String? pfp;

  const _SellerPfpWidget(this.pfp);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: pfp == null ? Container() : Image(image: AssetImage(pfp!)),
      ),
    );
  }
}

class _SellerUsernameWidget extends StatelessWidget {
  final String username;

  const _SellerUsernameWidget(this.username);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      username,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
