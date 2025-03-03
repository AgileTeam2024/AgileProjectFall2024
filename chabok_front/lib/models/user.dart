import 'package:chabok_front/services/network.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final String username;
  final String? firstName, lastName, phoneNumber;
  final String email;
  final String? profilePicture;
  final String? address;
  final bool isAdmin;

  String? get profilePictureAbsolute =>
      NetworkService.instance.getAbsoluteFilePath(profilePicture);

  User({
    required this.username,
    this.firstName,
    this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
    this.address,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  static Map<String, dynamic> staticToJson(User user) => _$UserToJson(user);

  String get fullName {
    if ((firstName ?? lastName) == null) return 'Stranger';
    return '$firstName $lastName';
  }
}
