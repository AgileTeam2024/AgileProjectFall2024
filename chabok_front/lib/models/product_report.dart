import 'package:chabok_front/models/product.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_report.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProductReport {
  final int id;
  final String description, reporterUsername;
  final Product product;

  ProductReport({
    required this.id,
    required this.description,
    required this.reporterUsername,
    required this.product,
  });

  factory ProductReport.fromJson(Map<String, dynamic> json) =>
      _$ProductReportFromJson(json);

  Map<String, dynamic> toJson() => _$ProductReportToJson(this);
}
