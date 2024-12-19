import 'package:chabok_front/extensions/num.dart';
import 'package:chabok_front/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  final String? description;
  final User seller;
  final List<String> imageUrls;
  final String category;
  final double? price;
  final String location;
  final String status;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.seller,
    required this.imageUrls,
    required this.category,
    this.price,
    required this.location,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
