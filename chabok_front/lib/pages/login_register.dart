import 'package:chabok_front/view_models/text_field.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  String get title => throw UnimplementedError('Should be overridden!');

  List<TextFieldViewModel> get fields =>
      throw UnimplementedError('Should be overridden!');

  List<Widget> get navigateToOtherForm =>
      throw UnimplementedError('Should be overridden!');

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();

  void submit(GlobalKey<FormState> formKey) {
    throw UnimplementedError('Should be overridden!');
  }
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 500,
          child: CardWidget(
            child: Form(
              key: formKey,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.title, style: textTheme.headlineLarge),
                  SizedBox(height: 10),
                  Divider(height: 1),
                  SizedBox(height: 20),
                  ...widget.fields.map(
                    (vm) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7.5,
                        horizontal: 10,
                      ),
                      child: CustomTextField(vm),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Button.filled(
                      text: widget.title,
                      onPressed: () => widget.submit(formKey),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(child: widget.navigateToOtherForm[0]),
                      SizedBox(width: 5),
                      widget.navigateToOtherForm[1]
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
}

class LoginPage extends LoginRegisterPage {
  const LoginPage({super.key});

  @override
  String get title => 'Login';

  @override
  List<TextFieldViewModel> get fields => [
        TextFieldViewModel(
          label: 'Username',
          icon: Icons.abc,
          required: true,
        ),
        PasswordTextFieldViewModel(
          label: 'Password',
          icon: Icons.password,
          required: true,
        ),
      ];

  @override
  List<Widget> get navigateToOtherForm => [
        Text('Don\'t have an account?'),
        Button.text(
          text: 'Register',
          onPressed: () => Get.to(() => RegisterPage()),
        )
      ];

  @override
  void submit(GlobalKey<FormState> formKey) {
    if (formKey.currentState?.validate() ?? false) {
      // todo send to backend
    }
  }
}

class RegisterPage extends LoginRegisterPage {
  const RegisterPage({super.key});

  @override
  String get title => 'Register';

  @override
  List<TextFieldViewModel> get fields => [
        TextFieldViewModel(
          label: 'Username',
          icon: Icons.abc,
          required: true,
        ),
        PasswordTextFieldViewModel(
          label: 'Password',
          icon: Icons.password,
          required: true,
        ),
        PasswordTextFieldViewModel(
          label: 'Repeat Password',
          icon: Icons.password,
          required: true,
        ),
        EmailTextFieldViewModel(
          label: 'Email',
          icon: Icons.email,
          required: false,
        ),
      ];

  @override
  List<Widget> get navigateToOtherForm => [
        Text('Already have an account?'),
        Button.text(
          text: 'Login',
          onPressed: () => Get.back(),
        )
      ];

  @override
  void submit(GlobalKey<FormState> formKey) {
    if (formKey.currentState?.validate() ?? false) {
      // todo send to backend
    }
  }
}
