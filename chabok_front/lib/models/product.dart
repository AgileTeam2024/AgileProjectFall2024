import 'package:chabok_front/enums/product_category.dart';
import 'package:chabok_front/enums/product_status.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/network.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  final String description;
  final User seller;
  @JsonKey(name: 'pictures')
  final List<String> imageUrls;
  @JsonKey(fromJson: ProductCategory.fromJson, toJson: ProductCategory.toJson)
  final ProductCategory category;
  final double price;
  @JsonKey(name: 'city_name')
  final String? location;
  @JsonKey(fromJson: ProductStatus.fromJson, toJson: ProductStatus.toJson)
  final ProductStatus status;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.seller,
    required List<String> imageUrls,
    required this.category,
    required this.price,
    this.location,
    required this.status,
  }) : imageUrls =
            imageUrls.map(NetworkService.instance.getAbsoluteFilePath).toList();

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
