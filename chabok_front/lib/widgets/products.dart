import 'package:chabok_front/extensions/num.dart';
import 'package:chabok_front/models/product.dart';
import 'package:flutter/material.dart';

class ProductsWidget extends StatelessWidget {
  final List<Product> products;

  const ProductsWidget(this.products, {super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 50, right: 50),
      child: GridView.builder(
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
            onPressed: () {},
            color: Colors.white,
            hoverElevation: 2,
            focusElevation: 2,
            elevation: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: displayImage == null
                        ? Container()
                        : Image(image: AssetImage(displayImage)),
                  ),
                ),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Text(
                    product.price != null
                        ? '${product.price!.compact} ᴵᴿᴿ'
                        : 'Negotiated Price',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: seller.profilePicture == null
                            ? Container()
                            : Image(
                                image: AssetImage(seller.profilePicture!),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seller.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 1.5),
                          Text(
                            seller.averageRating != null
                                ? '${seller.averageRating} ⭐️'
                                : '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
