import 'package:json_annotation/json_annotation.dart';

enum ProductStatus {
  @JsonValue('for sale')
  available,
  @JsonValue('reserved')
  reserved,
  @JsonValue('sold')
  sold;

  String toJson() => toString();

  factory ProductStatus.fromJson(String json) =>
      values.where((v) => '$v' == json).first;

  @override
  String toString() => ['for sale', 'reserved', 'sold'][index];

  String toStringDisplay() => ['Available', 'Reserved', 'Sold'][index];
}
