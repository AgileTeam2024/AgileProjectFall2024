import 'package:chabok_front/services/auth.dart';
import 'package:chabok_front/services/router.dart';
import 'package:chabok_front/view_models/text_field.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/text_field.dart';
import 'package:chabok_front/widgets/toast.dart';
import 'package:flutter/material.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key, required this.fields});

  String get title => throw UnimplementedError('Should be overridden!');

  final Map<String, TextFieldViewModel> fields;

  Map<String, String> get fieldValues =>
      fields.map((k, vm) => MapEntry(k, vm.controller.text));

  List<Widget> get navigateToOtherForm =>
      throw UnimplementedError('Should be overridden!');

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();

  void submit(BuildContext context, GlobalKey<FormState> formKey) {
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
                  ...widget.fields.values.map(
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
                      onPressed: () => widget.submit(context, formKey),
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
  LoginPage({super.key})
      : super(fields: {
          'username': TextFieldViewModel(
            label: 'Username',
            icon: Icons.abc,
            required: true,
          ),
          'password': PasswordTextFieldViewModel(
            label: 'Password',
            icon: Icons.password,
            required: true,
          ),
        });

  @override
  String get title => 'Login';

  @override
  List<Widget> get navigateToOtherForm => [
        Text('Don\'t have an account?'),
        Button.text(
          text: 'Register',
          onPressed: () => RouterService.go('/register'),
        )
      ];

  @override
  Future<void> submit(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    AuthService authService = AuthService.instance;
    if (formKey.currentState?.validate() ?? false) {
      final response = await authService.login(fieldValues);
      if (response.isOk) {
        RouterService.go('/');
      } else if (context.mounted) {
        CustomToast.showToast(context, response);
      }
    }
  }
}

class RegisterPage extends LoginRegisterPage {
  RegisterPage({super.key})
      : super(fields: {
          'username': TextFieldViewModel(
            label: 'Username',
            icon: Icons.abc,
            required: true,
          ),
          'password': PasswordTextFieldViewModel(
            label: 'Password',
            icon: Icons.password,
            required: true,
          ),
          'repeat_password': PasswordTextFieldViewModel(
            label: 'Repeat Password',
            icon: Icons.password,
            required: true,
          ),
          'email': EmailTextFieldViewModel(
            label: 'Email',
            icon: Icons.email,
            required: false,
          ),
        });

  @override
  String get title => 'Register';

  @override
  List<Widget> get navigateToOtherForm => [
        Text('Already have an account?'),
        Button.text(
          text: 'Login',
          onPressed: () => RouterService.go('/login'),
        )
      ];

  @override
  Future<void> submit(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    AuthService authService = AuthService.instance;
    if (formKey.currentState?.validate() ?? false) {
      final response = await authService.register(fieldValues);
      if (response.isOk) {
        RouterService.go('/login');
      } else if (context.mounted) {
        CustomToast.showToast(context, response);
      }
    }
  }
}
