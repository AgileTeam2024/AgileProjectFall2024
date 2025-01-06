import 'package:flutter/material.dart';

class AdminProfilePage extends StatefulWidget {
  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  // Sample lists for reported and banned users/products
  List<Map<String, String>> reportedUsers = [
    {'id': '1', 'name': 'Reported User 1'},
    {'id': '2', 'name': 'Reported User 2'},
  ];

  List<Map<String, String>> reportedProducts = [
    {'id': '101', 'name': 'Reported Product 1'},
    {'id': '102', 'name': 'Reported Product 2'},
  ];

  List<Map<String, String>> bannedUsers = [
    {'id': '3', 'name': 'Banned User 1'},
    {'id': '4', 'name': 'Banned User 2'},
  ];

  List<Map<String, String>> bannedProducts = [
    {'id': '201', 'name': 'Banned Product 1'},
    {'id': '202', 'name': 'Banned Product 2'},
  ];

  // Functions to handle banning and unbanning
  void banUser(Map<String, String> user) {
    setState(() {
      reportedUsers.remove(user);
      bannedUsers.add(user);
    });
  }

  void unbanUser(Map<String, String> user) {
    setState(() {
      bannedUsers.remove(user);
      reportedUsers.add(user);
    });
  }

  void banProduct(Map<String, String> product) {
    setState(() {
      reportedProducts.remove(product);
      bannedProducts.add(product);
    });
  }

  void unbanProduct(Map<String, String> product) {
    setState(() {
      bannedProducts.remove(product);
      reportedProducts.add(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Profile'),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Info Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, size: 40, color: Colors.blue),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Name',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Email: admin@example.com',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Phone: +1 234 567 890',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Address: 123 Admin St., Admin City, XYZ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Reported Users Section
              Text(
                'Reported Users',
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
                itemCount: reportedUsers.length,
                itemBuilder: (context, index) {
                  final user = reportedUsers[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.person, size: 30, color: Colors.red),
                      title: Text(user['name']!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility, color: Colors.blue),
                            onPressed: () {
                              // TODO: Navigate to user profile view
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.block, color: Colors.red),
                            onPressed: () {
                              banUser(user);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),

              // Reported Products Section
              Text(
                'Reported Products',
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
                itemCount: reportedProducts.length,
                itemBuilder: (context, index) {
                  final product = reportedProducts[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.shopping_cart,
                          size: 30, color: Colors.red),
                      title: Text(product['name']!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility, color: Colors.blue),
                            onPressed: () {
                              // TODO: Navigate to product profile view
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.block, color: Colors.red),
                            onPressed: () {
                              banProduct(product);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),

              // Banned Users Section
              Text(
                'Banned Users',
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
                itemCount: bannedUsers.length,
                itemBuilder: (context, index) {
                  final user = bannedUsers[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading:
                          Icon(Icons.person_off, size: 30, color: Colors.grey),
                      title: Text(user['name']!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility, color: Colors.blue),
                            onPressed: () {
                              // TODO: Navigate to banned user profile view
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.undo, color: Colors.green),
                            onPressed: () {
                              unbanUser(user);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),

              // Banned Products Section
              Text(
                'Banned Products',
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
                itemCount: bannedProducts.length,
                itemBuilder: (context, index) {
                  final product = bannedProducts[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.shopping_cart,
                          size: 30, color: Colors.grey),
                      title: Text(product['name']!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility, color: Colors.blue),
                            onPressed: () {
                              // TODO: Navigate to banned product profile view
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.undo, color: Colors.green),
                            onPressed: () {
                              unbanProduct(product);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdminProfilePage(),
  ));
}
