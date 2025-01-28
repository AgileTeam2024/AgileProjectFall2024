import 'package:chabok_front/models/product.dart';
import 'package:chabok_front/models/user.dart';
import 'package:chabok_front/view_models/text_field.dart';
import 'package:chabok_front/widgets/button.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _ReportDialog extends Dialog {
  final formKey = GlobalKey<FormState>();

  final BuildContext context;

  _ReportDialog(this.context);

  @override
  Color? get backgroundColor => Colors.transparent;

  @override
  EdgeInsets? get insetPadding => EdgeInsets.zero;

  List<TextFieldViewModel> fields = [
    TextFieldViewModel(
      icon: Icons.description,
      required: true,
      label: 'Reason',
    ),
  ];

  String get title => throw UnimplementedError('Should be overridden!');

  @override
  Widget? get child => CardWidget(
        child: SizedBox(
          width: 300,
          child: Form(
            key: formKey,
            child: Column(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ...fields.map((vm) => CustomTextField(vm)),
                Button.filled(
                  text: 'Submit Report',
                  icon: Icons.check,
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      context.pop(fields.last.text);
                    }
                  },
                ),
                Button.text(
                  text: 'Dismiss Report',
                  icon: Icons.cancel_outlined,
                  onPressed: () => context.pop(null),
                ),
              ],
            ),
          ),
        ),
      );
}

class ReportProductDialog extends _ReportDialog {
  final Product product;

  ReportProductDialog(super.context, {required this.product});

  @override
  String get title => 'Report Product';

  @override
  List<TextFieldViewModel> get fields => [
        TextFieldViewModel(
          icon: Icons.person_off,
          required: true,
          initialText: product.name,
          readOnly: true,
          label: 'Product Name',
        ),
        ...super.fields
      ];
}

class ReportUserDialog extends _ReportDialog {
  final User user;

  ReportUserDialog(super.context, {required this.user});

  @override
  String get title => 'Report User';

  @override
  List<TextFieldViewModel> get fields => [
        TextFieldViewModel(
          icon: Icons.production_quantity_limits,
          required: true,
          initialText: user.username,
          readOnly: true,
          label: 'Username',
        ),
        ...super.fields
      ];
}
