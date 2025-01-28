import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_report.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserReport {
  final int id;
  final String description, reporterUsername;
  @JsonKey(toJson: User.staticToJson)
  final User user;

  UserReport({
    required this.id,
    required this.description,
    required this.reporterUsername,
    required this.user,
  });

  factory UserReport.fromJson(Map<String, dynamic> json) =>
      _$UserReportFromJson(json);

  Map<String, dynamic> toJson() => _$UserReportToJson(this);
}
