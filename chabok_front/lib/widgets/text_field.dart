import 'package:chabok_front/view_models/text_field.dart';
import 'package:chabok_front/widgets/show_hide_button.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextFieldViewModel viewModel;

  const CustomTextField(this.viewModel, {super.key});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return TextFormField(
      controller: viewModel.controller,
      readOnly: viewModel.readOnly,
      keyboardType: viewModel.type,
      validator: viewModel.validator,
      obscureText: viewModel.obscureText,
      decoration: InputDecoration(
        helperText: viewModel.helper,
        hintText: viewModel.hint,
        errorText: viewModel.error,
        icon: Icon(viewModel.icon),
        labelText:
            viewModel.required ? viewModel.label?.required : viewModel.label,
        suffix: viewModel is PasswordTextFieldViewModel
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShowHideButton(
                    isShown: !viewModel.obscureText,
                    toggleIsShown: () {
                      viewModel.obscureText = !viewModel.obscureText;
                      setState(() {});
                    },
                  ),
                ],
              )
            : null,
        border: OutlineInputBorder(),
      ),
    );
  }
}

extension _StringRequired on String {
  String? get required => '$this *';
}
