import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: CardWidget(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
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
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Product Section
                Text(
                  'Your Products',
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
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(
                            'assets/sample_images/product_img1.jpg',
                          ),
                        ),
                        title: Text(
                          'Product ${index + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Description of Product ${index + 1}'),
                        trailing: Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () => RouterService.go(
                            '/product/$index'), // todo replace with id
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                // Purchase Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Previous Purchases',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 3, // Replace with dynamic purchase count
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(
                            'assets/sample_images/product_img1.jpg',
                          ),
                        ),
                        title: Text(
                          'Purchase ${index + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Details of Purchase ${index + 1}'),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),

                // Actions Section
                Text(
                  'Account Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(height: 10),
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
                        leading:
                            Icon(Icons.person_remove, color: Colors.orange),
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
