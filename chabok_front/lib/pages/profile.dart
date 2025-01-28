import 'package:chabok_front/dialogs/report.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/services/user.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/products_list.dart';
import 'package:chabok_front/widgets/toast.dart';
import 'package:chabok_front/widgets/user_info.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String? username;

  late final User user;

  UserProfilePage({super.key, this.username});

  final _authService = AuthService.instance;
  final _userService = UserService.instance;
  final _productService = ProductService.instance;

  bool get isOwnProfile => username == null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: CardWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<User?>(
                    future: username == null
                        ? Future.value(null)
                        : _userService.getProfile(username!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      try {
                        user = snapshot.data!;
                      } catch (LateInitializationError) {}
                      return UserInfoWidget(user: user);
                    },
                  ),
                ),
              ),
              if (isOwnProfile)
                FutureBuilder<List<Product>>(
                  future: _productService.ownProducts,
                  builder: (context, snapshot) {
                    return ProductsListWidget(
                      title: 'Your Products',
                      products: snapshot.data ?? [],
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
                    if (isOwnProfile) ...[
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
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete Account'),
                        onTap: () => _deleteAccount(context),
                      ),
                    ] else
                      ListTile(
                        leading: Icon(Icons.report, color: Colors.red),
                        title: Text('Report Account'),
                        onTap: () => _report(context),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final response = await _authService.deleteAccount();
    CustomToast.showToast(context, response);
    if (response.isOk) RouterService.go('/');
  }

  void _goToEditProfile() => RouterService.go('/edit-profile');

  Future<void> _logout(BuildContext context) async {
    final response = await _authService.logout();
    CustomToast.showToast(context, response);
    if (response.isOk) RouterService.go('/');
  }

  Future<void> _report(BuildContext context) async {
    final String? description = await showDialog(
      context: context,
      builder: (context) => ReportUserDialog(context, user: user),
    );
    if (description?.isEmpty ?? true) return;
    final response = await _userService.report(user.username, description!);
    CustomToast.showToast(context, response);
  }
}
