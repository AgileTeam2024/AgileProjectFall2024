import 'package:chabok_front/extensions/num.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/pages/error.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/widgets/seller.dart';
import 'package:flutter/material.dart';

class ProductsWidget extends StatelessWidget {
  final List<Product> products;

  const ProductsWidget(this.products, {super.key});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return ErrorPage(errorCode: 404, message: 'No products found :(');
    }
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 225,
        childAspectRatio: .75,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final seller = product.seller;

        final displayImage = product.imageUrls.firstOrNull;

        return MaterialButton(
          onPressed: () => RouterService.go('/product/${product.id}'),
          color: Colors.white,
          hoverElevation: 2,
          focusElevation: 2,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                _ProductImageWidget(displayImage),
                _ProductNameWidget(product.name),
                SizedBox(height: 7.5),
                _ProductPriceWidget(product.price),
                SizedBox(height: 2.5),
                SellerWidget(seller),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductImageWidget extends StatelessWidget {
  final String? image;

  const _ProductImageWidget(this.image);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: image == null ? Container() : Image.network(image!),
      ),
    );
  }
}

class _ProductNameWidget extends StatelessWidget {
  final String name;

  const _ProductNameWidget(this.name);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _ProductPriceWidget extends StatelessWidget {
  final double price;

  const _ProductPriceWidget(this.price);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      '${price.compact} ᴵᴿᴿ',
      style: textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      textAlign: TextAlign.end,
    );
  }
}
