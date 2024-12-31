import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:flutter/material.dart';

class ProductViewPage extends StatefulWidget {
  final int id;

  const ProductViewPage(this.id, {super.key});

  @override
  State<ProductViewPage> createState() => _ProductViewPageState();
}

class _ProductViewPageState extends State<ProductViewPage> {
  final _productService = ProductService.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product>(
        future: _productService.getProductById(widget.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // todo error page
            return Container();
          }
          if (!snapshot.hasData) return CircularProgressIndicator();

          final product = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display product images
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: product.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          product.imageUrls[index],
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description: ${product.description}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Category: ${product.category}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Price: ${formatPrice(product.price)} ᴵᴿᴿ',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location: ${product.location}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${product.status}',
                        style: const TextStyle(fontSize: 16),
                      ),

                      const Divider(height: 32),

                      // Display seller info
                      const SizedBox(height: 16),
                      Button.filled(
                        onPressed: () =>
                            goToSellerPage(product.seller.username),
                        text: 'View Seller Info',
                      ),

                      const Divider(height: 32),

                      if (isSeller) ...[
                        Button.filled(
                          onPressed: onEditProduct,
                          text: 'Edit Product',
                        ),
                      ] else ...[
                        if (isFavorite)
                          Button.filled(
                            onPressed: removeFromFavorite,
                            text: 'Remove from Favourite',
                          )
                        else
                          Button.filled(
                            onPressed: addToFavorite,
                            text: 'Add to Favourite',
                          ),
                        Button.filled(
                          onPressed: onReport,
                          text: 'Report Product',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  bool get isFavorite => false;

  bool get isSeller => false;

  void addToFavorite() {
    // todo send request to backend
  }

  void removeFromFavorite() {
    // todo send request to backend
  }

  void onReport() {
    // todo send request to backend
  }

  void onEditProduct() {
    // todo send request to backend
  }

  void goToSellerPage(String username) => RouterService.go('/user/$username');

  String formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (Match m) => ",",
        );
  }

  String formatPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAllMapped(
      RegExp(r'^(\d{3})(\d{3})(\d{4})\$'),
      (Match m) => "${m[1]}-${m[2]}-${m[3]}",
    );
  }
}

class SellerPage extends StatelessWidget {
  final User seller;

  const SellerPage({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seller Name: ${seller.username}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Phone: ${seller.phoneNumber}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
