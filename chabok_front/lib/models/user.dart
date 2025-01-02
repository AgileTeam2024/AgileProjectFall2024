import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String username, email, phoneNumber;
  final String? firstName, lastName;
  final String? profilePicture;

  User({
    required this.username,
    this.firstName,
    this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
