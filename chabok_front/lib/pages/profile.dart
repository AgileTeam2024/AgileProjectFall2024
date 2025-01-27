import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/product_status.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/services/user.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/toast.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  UserProfilePage({super.key});

  final _authService = AuthService.instance;
  final _userService = UserService.instance;

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
                  child: UserInfoWidget(),
                ),
              ),
              ProductsListWidget(
                title: 'Your Products',
                products: List.generate(
                  5,
                  // todo get user Products from backend
                  (i) => Product(
                    id: i,
                    name: 'Product $i',
                    seller: User(
                        username: 'ckdks',
                        phoneNumber: '09121234567',
                        email: 'seller@gmail.com'),
                    imageUrls: ['assets/sample_images/product_img1.jpg'],
                    category: ProductCategory.others,
                    location: '',
                    status: ProductStatus.reserved,
                    price: 1000,
                    description: 'Description on Product $i',
                  ),
                ),
              ),
              ProductsListWidget(
                title: 'Previous Purchases',
                products: List.generate(
                  5,
                  // todo get user Previous Purchases from backend
                  (i) => Product(
                    id: i,
                    name: 'Product $i',
                    seller: User(
                        username: 'ckdks',
                        phoneNumber: '09121234567',
                        email: 'seller@gmail.com'),
                    imageUrls: ['assets/sample_images/product_img1.jpg'],
                    category: ProductCategory.others,
                    location: '',
                    status: ProductStatus.reserved,
                    price: 1000,
                    description: 'Description on Product $i',
                  ),
                ),
              ),
              // Actions Section
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
                      leading: Icon(Icons.person_remove, color: Colors.orange),
                      title: Text('Edit Profile'),
                      onTap: _goToEditProfile,
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete Account'),
                      onTap: () => _deleteAccount(context),
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
}

@visibleForTesting
class UserInfoWidget extends StatelessWidget {
  UserInfoWidget({super.key});

  final _userService = UserService.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
        future: _userService.ownProfile,
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
                backgroundImage: profile.profilePicture == null
                    ? null
                    : NetworkImage(profile.profilePicture!),
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
                    'Email: ${profile.email}',
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
        });
  }
}

@visibleForTesting
class ProductsListWidget extends StatelessWidget {
  final String title;
  final List<Product> products;

  const ProductsListWidget({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(product.imageUrls[0]),
                ),
                title: Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  product.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () => RouterService.go('/product/${product.id}'),
              ),
            );
          },
        ),
      ],
    );
  }
}
