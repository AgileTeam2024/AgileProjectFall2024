import 'dart:typed_data';

import 'package:chabok_front/models/pair.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/services/network.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/services/user.dart';
import 'package:chabok_front/view_models/text_field.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/text_field.dart';
import 'package:chabok_front/widgets/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _networkService = NetworkService.instance;
  final _userService = UserService.instance;

  Pair<String, Uint8List>? profilePicture;
  late final List<TextFieldViewModel> fieldViewModels;
  final formKey = GlobalKey<FormState>();

  User get user => widget.user;

  @override
  void initState() {
    super.initState();
    fieldViewModels = [
      TextFieldViewModel(
        icon: Icons.abc,
        required: true,
        label: 'First name',
        initialText: user.firstName,
      ),
      TextFieldViewModel(
        icon: Icons.abc,
        required: true,
        label: 'Last name',
        initialText: user.lastName,
      ),
      TextFieldViewModel(
        icon: Icons.phone,
        required: true,
        label: 'Phone Number',
        initialText: user.phoneNumber,
      ),
      TextFieldViewModel(
        icon: Icons.pin_drop,
        required: false,
        label: 'Address',
        maxLines: 2,
        initialText: user.address,
      ),
    ];

    final imageAddress = user.profilePicture;
    if (imageAddress != null) {
      _networkService
          .getImage(imageAddress)
          .then((bytes) => profilePicture = Pair(imageAddress, bytes))
          .then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: CardWidget(
          child: SizedBox(
            width: 525,
            child: Form(
              key: formKey,
              child: Column(
                spacing: 15,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 75,
                        foregroundImage: profilePicture?.second == null
                            ? null
                            : MemoryImage(profilePicture!.second),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Button.icon(
                          icon: Icons.upload_rounded,
                          onPressed: _editProfilePicture,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  ...fieldViewModels.map(
                    (vm) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: CustomTextField(vm),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Button.text(
                          icon: Icons.cancel_outlined,
                          text: 'Discard changes',
                          onPressed: () => RouterService.go('/profile'),
                        ),
                      ),
                      Expanded(
                        child: Button.filled(
                          icon: Icons.check,
                          text: 'Save changes',
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editProfilePicture() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final file = result?.files.firstOrNull;
    if (file == null) return;
    profilePicture = Pair(file.name, file.bytes!);
    setState(() {});
  }

  Future<void> _submit() async {
    if (formKey.currentState?.validate() ?? false) {
      final fields = fieldViewModels.asMap().map(
            (_, e) => MapEntry(
              e.label!.replaceAll(' ', '_').toLowerCase(),
              e.text,
            ),
          );
      final response = await _userService.editProfile(
        fields,
        profilePicture,
      );
      if (response.isOk) RouterService.go('/profile');
      CustomToast.showToast(context, response);
    }
  }
}
