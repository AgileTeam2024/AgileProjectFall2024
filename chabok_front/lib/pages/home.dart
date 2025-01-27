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
  ProductService get _productService => ProductService.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productService.homePageProducts,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.only(top: 25) +
              EdgeInsets.symmetric(horizontal: 250),
          child: ProductsWidget(data),
        );
      },
    );
  }
}
