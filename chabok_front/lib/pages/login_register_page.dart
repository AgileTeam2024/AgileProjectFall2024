import 'package:chabok_front/view_models/text_field.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:chabok_front/widgets/card_widget.dart';
import 'package:chabok_front/widgets/main_app_bar.dart';
import 'package:chabok_front/widgets/text_field.dart';
import 'package:flutter/material.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  String get title => throw UnimplementedError('Should be overridden!');

  List<TextFieldViewModel> get fields =>
      throw UnimplementedError('Should be overridden!');

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();

  void submit(GlobalKey<FormState> _formKey) {
    throw new UnimplementedError('Should be overridden!');
  }
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 600,
          child: CardWidget(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.title, style: textTheme.headlineLarge),
                  SizedBox(height: 10),
                  Divider(height: 1),
                  SizedBox(height: 20),
                  ...widget.fields.map(
                    (vm) => Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: CustomTextField(vm),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Button.filled(
                      text: widget.title,
                      onPressed: () => widget.submit(_formKey),
                    ),
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
  void submit(GlobalKey<FormState> _formKey) {
    if (_formKey.currentState?.validate() ?? false) {
      // todo send to backend
    }
  }
}

class RegisterPage extends LoginRegisterPage {
  @override
  String get title => 'Register';
}
