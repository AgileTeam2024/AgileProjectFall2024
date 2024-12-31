import 'package:chabok_front/models/product.dart';

class ProductService {
  static ProductService? _instance;

  static ProductService get instance {
    _instance ??= ProductService();
    return _instance!;
  }

  Future<List<Product>> get suggestions {
    // todo get from back
    return Future.value(List.generate(
        30,
        (i) => {
              "id": i,
              "name":
                  "Custom Wooden Guitar Picks Box,Personalized Guitar Pick Holder Storage,Wood Guitar Plectrum Organizer Case,Music Gift for Guitarist Musician\n",
              "seller": {
                "id": 2,
                "username": "CraftsByAden",
                "profilePicture": "assets/sample_images/seller_pfp.jpg",
                "email": "CraftsByAden@gmail.com",
                "phoneNumber": "09121234567",
              },
              "imageUrls": ["assets/sample_images/product_img1.jpg"],
              "category":
                  "Books, Movies & Music > Music > Picks & Slides > Picks",
              "location": "Manchester, United Kingdom",
              "status": "Available for sale",
              "description":
                  "【Product Details】Box Size: 40 x 40 x 29mm / 1.57 x 1.57 x 1.14 inch( L x W x H ), Material of box: walnut.\n\n【Unique Design】The color, texture, and wood grain of any natural wood product will vary from piece to piece, but this is what makes this guitar pick holder unique. Our pick case are crafted from high quality, sturdy wood. The edge treatment of the product is very meticulously smooth, and the box will keep your picks safe and protected.\n\n【Convenient Storage and Display】With this pick container, you can keep your guitar picks organized and easily accessible. The case is compact and lightweight, making it portable for gigs, rehearsals, or traveling. Additionally, the lid is held closed by a strong magnet lock, which protects the guitar picks from damage or from falling out.\n\n【Free Engraving】There are 18 fonts/patterns to be selected from, you can customize your the guitar box case with someone name, initials, letter combination, special date! It will be a unique Christmas/Birthday/Anniversary Gifts for Friends, lover, Husband, Boyfriends, Musicians and Guitarists to express your encouragement or love for them.\n\n【Please Note】Due to wood’s natural texture and color, the item may not be exactly as the pictures show. Some wood is a little bit dark and some wood may have some spots. If you are not satisfied or have any questions, please feel free to contact us to get a satisfied solution. We will be happy to assist you and reply within 24 hours.",
              "price": i % 5 * 1_000_000
            }).map(Product.fromJson).toList());
  }

  Future<Product> getProductById(int id) async {
    // todo send request to back
    final list = await suggestions;
    return list.where((p) => p.id == id).first;
  }
}
