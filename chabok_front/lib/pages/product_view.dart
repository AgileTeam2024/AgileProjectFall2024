import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/images_display.dart';
import 'package:chabok_front/widgets/seller.dart';
import 'package:expandable_text/expandable_text.dart';
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
    final textTheme = Theme.of(context).textTheme;
    final textStyle = textTheme.bodyMedium;
    final textStyleBold = textStyle?.copyWith(fontWeight: FontWeight.bold);
    final isBigScreen = MediaQuery.sizeOf(context).width > 1000;

    return CardWidget(
      child: FutureBuilder<Product>(
          future: _productService.getProductById(widget.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // todo error page
              return Container();
            }
            if (!snapshot.hasData) return CircularProgressIndicator();

            final product = snapshot.data!;
            return Flex(
              crossAxisAlignment: isBigScreen
                  ? CrossAxisAlignment.stretch
                  : CrossAxisAlignment.center,
              direction: isBigScreen ? Axis.horizontal : Axis.vertical,
              children: [
                Expanded(
                  child: ImagesDisplayWidget(product.imageUrls),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: isBigScreen ? VerticalDivider() : Divider(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Button.text(
                              text: '${product.category} Category',
                              onPressed: () =>
                                  _goToCategorySearchPage(product.category),
                            ),
                          ],
                        ),
                        SellerWidget(
                          product.seller,
                          showContactInfo: true,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${formatPrice(product.price)} ᴵᴿᴿ',
                              style: textStyleBold?.copyWith(
                                  fontSize: textStyleBold.fontSize! * 2),
                            ),
                            Text(
                              product.status,
                              style: textStyle?.copyWith(
                                  // todo set color for status
                                  ),
                            ),
                          ],
                        ),
                        if (product.location != null)
                          Row(
                            children: [
                              Icon(Icons.pin_drop),
                              Text(product.location!, style: textStyle),
                            ],
                          ),
                        Text('Description', style: textStyleBold),
                        ExpandableText(
                          product.description,
                          maxLines: 5,
                          expandText: 'Show more...',
                          collapseText: 'Show less...',
                          linkColor: Colors.blue,
                          linkEllipsis: false,
                          style: textStyle,
                        ),
                        Button.filled(
                          onPressed: () =>
                              goToSellerPage(product.seller.username),
                          text: 'View Seller Info',
                        ),
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
                ),
              ],
            );
          }),
    );
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

  void _goToCategorySearchPage(String category) {
    // todo
  }
}
