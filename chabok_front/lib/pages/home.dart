import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/widgets/products.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productService.homePageProducts,
      builder: (context, snapshot) {
        print(snapshot.error);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data ?? [];
        return ProductsWidget(data);
      },
    );
  }
}
