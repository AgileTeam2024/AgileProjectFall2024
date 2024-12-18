import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username, firstName, lastName;
  final String? email;
  final double averageRating;
  final String? profilePicture;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.email,
    this.averageRating = 0,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
