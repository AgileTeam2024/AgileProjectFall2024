import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
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
                    category: '',
                    location: '',
                    status: '',
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
                    category: '',
                    location: '',
                    status: '',
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
                      onTap: _logout,
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
                      onTap: _deleteAccount,
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

  void _deleteAccount() {
    // todo connect to back
  }

  void _goToEditProfile() {
    // todo
  }

  void _logout() {
    // todo connect to back
    RouterService.go('/');
  }
}

@visibleForTesting
class UserInfoWidget extends StatelessWidget {
  const UserInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // todo get user profile from backend
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage(
            'assets/sample_images/seller_pfp.jpg',
          ),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'fff aaa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Username: fffaaa',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text(
              'Email: fa@example.com',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text(
              'Address: 123 Street',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text(
              'Phone: +1234567890',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ],
    );
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
                  product.description!,
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
