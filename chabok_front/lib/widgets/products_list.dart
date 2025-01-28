import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:flutter/material.dart';

class ProductsListWidget extends StatelessWidget {
  final String title;
  final List<dynamic> products;
  final void Function(int id)? onBan, onUnban;

  const ProductsListWidget({
    super.key,
    required this.title,
    required this.products,
    this.onBan,
    this.onUnban,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return Container();

    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final item = products[index];
            final product = item is Product ? item : item.product;

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: product.imageUrls.isEmpty
                      ? null
                      : NetworkImage(product.imageUrls[0]),
                ),
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${product.name}        ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '@${product.seller.username}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  spacing: 10,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onBan != null)
                      Button.icon(
                        key: Key('banProductButton_${product.id}'),
                        icon: Icons.block,
                        onPressed: () => onBan!(product.id),
                      ),
                    if (onUnban != null)
                      Button.icon(
                        key: Key('unbanProductButton_${product.id}'),
                        icon: Icons.undo,
                        onPressed: () => onUnban!(product.id),
                      ),
                  ],
                ),
                onTap: () => RouterService.go('/product/${product.id}'),
              ),
            );
          },
        ),
      ],
    );
  }
}
