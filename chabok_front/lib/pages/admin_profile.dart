import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/admin.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/products_list.dart';
import 'package:chabok_front/widgets/user_info.dart';
import 'package:chabok_front/widgets/users_list.dart';
import 'package:flutter/material.dart';

class AdminProfilePage extends StatefulWidget {
  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  AdminService get _adminService => AdminService.instance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: CardWidget(
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Info Section
            UserInfoWidget(),
            SizedBox(height: 10),
            FutureBuilder<List<User>>(
              future: _adminService.reportedUsers,
              builder: (context, snapshot) {
                final reportedUsers = snapshot.data ?? [];
                return UsersListWidget(
                  title: 'Reported Users',
                  users: reportedUsers,
                  onBan: _adminService.banUser,
                );
              },
            ),
            FutureBuilder<List<Product>>(
              future: _adminService.reportedProducts,
              builder: (context, snapshot) {
                final reportedProducts = snapshot.data ?? [];
                return ProductsListWidget(
                  title: 'Reported Products',
                  products: reportedProducts,
                  onBan: _adminService.banProduct,
                );
              },
            ),
            FutureBuilder<List<User>>(
              future: _adminService.bannedUsers,
              builder: (context, snapshot) {
                final bannedUsers = snapshot.data ?? [];
                return UsersListWidget(
                  title: 'Banned Users',
                  users: bannedUsers,
                  onBan: _adminService.unbanUser,
                );
              },
            ),
            FutureBuilder<List<Product>>(
              future: _adminService.bannedProducts,
              builder: (context, snapshot) {
                final bannedProducts = snapshot.data ?? [];
                return ProductsListWidget(
                  title: 'Banned Products',
                  products: bannedProducts,
                  onBan: _adminService.unbanProduct,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
