import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String username, email, phoneNumber;
  final String? firstName, lastName;
  final String? profilePicture;
  final String? address;

  User({
    required this.username,
    this.firstName,
    this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get hasBeenEditedBefore => ![firstName, lastName].contains(null);
}
