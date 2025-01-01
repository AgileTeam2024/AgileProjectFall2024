import 'package:chabok_front/extensions/num.dart';
import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:flutter/material.dart';

class ProductsWidget extends StatelessWidget {
  final List<Product> products;

  const ProductsWidget(this.products, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25) +
          EdgeInsets.symmetric(horizontal: 250),
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
                _ProductImageWidget(displayImage),
                _ProductNameWidget(product.name),
                SizedBox(height: 7.5),
                _ProductPriceWidget(product.price),
                SizedBox(height: 2.5),
                _SellerWidget(seller),
              ],
            ),
          );
        },
      ),
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
        child: image == null ? Container() : Image(image: AssetImage(image!)),
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
  final double? price;

  const _ProductPriceWidget(this.price);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      price != null ? '${price!.compact} ᴵᴿᴿ' : 'Negotiated Price',
      style: textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      textAlign: TextAlign.end,
    );
  }
}

class _SellerWidget extends StatelessWidget {
  final User seller;

  const _SellerWidget(this.seller);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SellerPfpWidget(seller.profilePicture),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SellerUsernameWidget(seller.username),
              SizedBox(height: 1.5),
              _SellerRatingWidget(seller.averageRating)
            ],
          ),
        ),
      ],
    );
  }
}

class _SellerPfpWidget extends StatelessWidget {
  final String? pfp;

  const _SellerPfpWidget(this.pfp);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: pfp == null
            ? Container()
            : Image(
                image: AssetImage(pfp!),
              ),
      ),
    );
  }
}

class _SellerUsernameWidget extends StatelessWidget {
  final String username;

  const _SellerUsernameWidget(this.username);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      username,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _SellerRatingWidget extends StatelessWidget {
  final double? rating;

  const _SellerRatingWidget(this.rating);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      rating != null ? '$rating ⭐️' : '',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textTheme.labelSmall,
    );
  }
}
