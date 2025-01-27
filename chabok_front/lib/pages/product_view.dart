import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/models/pair.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/product.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/services/user.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/images_display.dart';
import 'package:chabok_front/widgets/seller.dart';
import 'package:chabok_front/widgets/toast.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';

@visibleForTesting
final scrollableKey = GlobalKey();

class ProductViewPage extends StatefulWidget {
  final int id;

  const ProductViewPage(this.id, {super.key});

  @override
  State<ProductViewPage> createState() => _ProductViewPageState();
}

class _ProductViewPageState extends State<ProductViewPage> {
  final _productService = ProductService.instance;
  final _userService = UserService.instance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textStyle = textTheme.bodyMedium;
    final textStyleBold = textStyle?.copyWith(fontWeight: FontWeight.bold);
    final isBigScreen = MediaQuery.sizeOf(context).width > 1000;

    return CardWidget(
      child: FutureBuilder<Pair<Product, User?>>(
          future: Future.wait([
            _productService.getProductById(widget.id),
            _userService.ownProfile,
          ]).then((list) => Pair(list[0] as Product, list[1] as User?)),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // todo error page
              return Container();
            }
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final pair = snapshot.data!;
            final product = pair.first;
            final ownUsername = pair.second?.username;
            final viewerIsSeller = product.seller.username == ownUsername;

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
                    key: scrollableKey,
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
                          spacing: 5,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (viewerIsSeller) ...[
                              Button.icon(
                                onPressed: onEditProduct,
                                icon: Icons.edit,
                              ),
                              Button.icon(
                                onPressed: onDeleteProduct,
                                icon: Icons.delete,
                              ),
                            ] else if (ownUsername != null)
                              Button.icon(
                                onPressed: onReport,
                                icon: Icons.report,
                              ),
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
                              product.status.toStringDisplay(),
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
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  void onReport() {
    // todo send request to backend
  }

  Future<void> onEditProduct() async =>
      RouterService.go('/product/${widget.id}/edit');

  Future<void> onDeleteProduct() async {
    final response = await _productService.deleteProduct(widget.id);
    CustomToast.showToast(context, response);
    if (response.isOk) RouterService.go('/');
  }

  String formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (Match m) => ",",
        );
  }

  void _goToCategorySearchPage(ProductCategory category) =>
      RouterService.goNamed('search', queryParameters: {'cat': category.index});
}
