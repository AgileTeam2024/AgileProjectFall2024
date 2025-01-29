import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/product_report.dart';
import 'package:chabok_front/models/server_response.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/models/user_report.dart';
import 'package:chabok_front/services/admin.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/products_list.dart';
import 'package:chabok_front/widgets/toast.dart';
import 'package:chabok_front/widgets/user_info.dart';
import 'package:chabok_front/widgets/users_list.dart';
import 'package:flutter/material.dart';

class AdminProfilePage extends StatefulWidget {
  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  AdminService get _adminService => AdminService.instance;

  AuthService get _authService => AuthService.instance;

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
            FutureBuilder<List<UserReport>>(
              future: _adminService.reportedUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final reportedUsers = snapshot.data ?? [];
                return UsersListWidget(
                  title: 'Reported Users',
                  users: reportedUsers,
                  onBan: (username) =>
                      runAction(_adminService.banUser(username)),
                );
              },
            ),
            FutureBuilder<List<ProductReport>>(
              future: _adminService.reportedProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final reportedProducts = snapshot.data ?? [];
                return ProductsListWidget(
                  title: 'Reported Products',
                  products: reportedProducts,
                  onBan: (id) => runAction(_adminService.banProduct(id)),
                );
              },
            ),
            FutureBuilder<List<User>>(
              future: _adminService.bannedUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final bannedUsers = snapshot.data ?? [];
                return UsersListWidget(
                  title: 'Banned Users',
                  users: bannedUsers,
                  onUnban: (username) =>
                      runAction(_adminService.unbanUser(username)),
                );
              },
            ),
            FutureBuilder<List<Product>>(
              future: _adminService.bannedProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final bannedProducts = snapshot.data ?? [];
                return ProductsListWidget(
                  title: 'Banned Products',
                  products: bannedProducts,
                  onUnban: (id) => runAction(_adminService.unbanProduct(id)),
                );
              },
            ),

            Text(
              'Account Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.blueAccent),
                    title: Text('Log Out'),
                    onTap: () => _logout(context),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.edit, color: Colors.orange),
                    title: Text('Edit Profile'),
                    onTap: _goToEditProfile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> runAction(Future<ServerResponse> request) async {
    final response = await request;
    if (response.isOk) {
      CustomToast.showToast(context, response);
    }
    setState(() {});
  }

  void _goToEditProfile() => RouterService.go('/edit-profile');

  Future<void> _logout(BuildContext context) async {
    final response = await _authService.logout();
    CustomToast.showToast(context, response);
    if (response.isOk) RouterService.go('/');
  }
}
