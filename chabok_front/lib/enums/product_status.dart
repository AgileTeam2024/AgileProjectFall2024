import 'package:json_annotation/json_annotation.dart';

enum ProductStatus {
  @JsonValue('for sale')
  available,
  @JsonValue('reserved')
  reserved,
  @JsonValue('sold')
  sold;

  static fromJson(String json) => values.firstWhere((e) => '$e' == json);

  static String toJson(ProductStatus status) => status.toString();

  @override
  String toString() => ['for sale', 'reserved', 'sold'][index];

  String toStringDisplay() => ['Available', 'Reserved', 'Sold'][index];
}
