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

    if (viewModel is OptionsTextFieldViewModel) {
      return DropdownButtonFormField(
        onChanged: (selected) => viewModel.controller.text = selected ?? '',
        items: viewModel.options
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
            .toList(),
        decoration: InputDecoration(
          helperText: viewModel.helper,
          hintText: viewModel.hint,
          errorText: viewModel.error,
          icon: Icon(viewModel.icon),
          labelText:
              viewModel.required ? viewModel.label?.required : viewModel.label,
          border: OutlineInputBorder(),
        ),
      );
    }

    return TextFormField(
      controller: viewModel.controller,
      readOnly: viewModel.readOnly,
      keyboardType: viewModel.type,
      maxLines: viewModel.maxLines,
      validator: viewModel.validator,
      inputFormatters: viewModel.inputFormatters,
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
            : (viewModel is MoneyTextFieldViewModel ? Text('IRR') : null),
        border: OutlineInputBorder(),
      ),
    );
  }
}

extension _StringRequired on String {
  String? get required => '$this *';
}
