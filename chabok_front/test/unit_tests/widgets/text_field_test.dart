import 'package:chabok_front/view_models/text_field.dart';
import 'package:chabok_front/widgets/show_hide_button.dart';
import 'package:chabok_front/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final formKey = GlobalKey<FormState>();
  MaterialApp generateWidget(TextFieldViewModel viewModel) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: CustomTextField(viewModel),
        ),
      ),
    );
  }

  group('CustomTextField', () {
    testWidgets('Displays error message when required field is empty',
        (tester) async {
      final viewModel = TextFieldViewModel(icon: Icons.abc, required: true);
      await tester.pumpWidget(generateWidget(viewModel));
      await tester.enterText(find.byType(TextFormField), '');
      expect(formKey.currentState?.validate(), false);
      await tester.pumpAndSettle();
      expect(find.text('This field is Required!'), findsOneWidget);
    });

    testWidgets(
        'Does not display error message when non-required field is empty',
        (tester) async {
      final viewModel = TextFieldViewModel(icon: Icons.abc, required: false);
      await tester.pumpWidget(generateWidget(viewModel));
      await tester.enterText(find.byType(TextFormField), '');
      expect(formKey.currentState?.validate(), true);
      await tester.pumpAndSettle();
      expect(find.text('This field is Required!'), findsNothing);
    });
  });

  group('EmailTextFormField', () {
    testWidgets('Displays error message for invalid email format',
        (tester) async {
      final viewModel = EmailTextFieldViewModel(
        icon: Icons.email,
        required: true,
      );
      await tester.pumpWidget(generateWidget(viewModel));
      await tester.enterText(find.byType(TextFormField), 'invalidemail');
      expect(formKey.currentState?.validate(), false);
      await tester.pumpAndSettle();
      expect(find.text('Incorrect email format.'), findsOneWidget);
    });

    testWidgets('Does not display error message for valid email format',
        (tester) async {
      final viewModel = EmailTextFieldViewModel(
        icon: Icons.email,
        required: true,
      );
      await tester.pumpWidget(generateWidget(viewModel));
      await tester.enterText(find.byType(TextFormField), 'valid@email.com');
      expect(formKey.currentState?.validate(), true);
      await tester.pumpAndSettle();
      expect(find.text('Incorrect email format.'), findsNothing);
    });
  });

  group('PasswordTextFormField', () {
    testWidgets('Displays error message for password without numbers',
        (tester) async {
      final viewModel = PasswordTextFieldViewModel(
        icon: Icons.password,
        required: true,
      );
      await tester.pumpWidget(generateWidget(viewModel));
      await tester.enterText(find.byType(TextFormField), 'password');
      expect(formKey.currentState?.validate(), false);
      await tester.pumpAndSettle();
      expect(find.text('Password must contain numbers too.'), findsOneWidget);
    });

    testWidgets('Displays error message for password without alphabets',
        (tester) async {
      final viewModel = PasswordTextFieldViewModel(
        icon: Icons.password,
        required: true,
      );
      await tester.pumpWidget(generateWidget(viewModel));
      await tester.enterText(find.byType(TextFormField), '123456');
      expect(formKey.currentState?.validate(), false);
      await tester.pumpAndSettle();
      expect(find.text('Password must contain alphabet too.'), findsOneWidget);
    });

    testWidgets('Does not display error message for valid password',
        (tester) async {
      final viewModel = PasswordTextFieldViewModel(
        icon: Icons.password,
        required: true,
      );
      await tester.pumpWidget(generateWidget(viewModel));
      await tester.enterText(find.byType(TextFormField), 'Password123');
      expect(formKey.currentState?.validate(), true);
      await tester.pumpAndSettle();
      expect(find.text('Password must contain numbers too.'), findsNothing);
      expect(find.text('Password must contain alphabet too.'), findsNothing);
    });

    testWidgets('Toggles password visibility when ShowHideButton is pressed',
        (tester) async {
      final viewModel =
          PasswordTextFieldViewModel(icon: Icons.password, required: true);
      await tester.pumpWidget(generateWidget(viewModel));
      await tester.enterText(find.byType(TextFormField), 'Password123');

      TextField textField;

      await tester.pumpAndSettle();
      textField = find.byType(TextField).evaluate().first.widget as TextField;
      expect(viewModel.obscureText, true);
      expect(textField.obscureText, true);

      await tester.tap(find.byType(ShowHideButton));
      await tester.pumpAndSettle();
      textField = find.byType(TextField).evaluate().first.widget as TextField;
      expect(viewModel.obscureText, false);
      expect(textField.obscureText, false);

      await tester.tap(find.byType(ShowHideButton));
      await tester.pumpAndSettle();
      textField = find.byType(TextField).evaluate().first.widget as TextField;
      expect(viewModel.obscureText, true);
      expect(textField.obscureText, true);
    });
  });

  group('OptionsTextFormField', () {
    testWidgets('Displays options in dropdown', (tester) async {
      final viewModel = OptionsTextFieldViewModel(
        icon: Icons.list,
        required: true,
        options: ['Option1', 'Option2'],
      );
      await tester.pumpWidget(generateWidget(viewModel));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CustomTextField));
      await tester.pumpAndSettle();
      expect(find.text('Option1'), findsOneWidget);
      expect(find.text('Option2'), findsOneWidget);
    });

    testWidgets('Updates controller text when an option is selected',
        (tester) async {
      final viewModel = OptionsTextFieldViewModel(
        icon: Icons.list,
        required: true,
        options: ['Option1', 'Option2'],
      );
      await tester.pumpWidget(generateWidget(viewModel));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CustomTextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Option1').last);
      await tester.pumpAndSettle();
      expect(viewModel.controller.text, 'Option1');
    });
  });

  group('MoneyTextFormField', () {
    testWidgets('Formats input correctly with commas', (tester) async {
      final viewModel = MoneyTextFieldViewModel(required: true);
      await tester.pumpWidget(generateWidget(viewModel));
      await tester.enterText(find.byType(TextFormField), '1000');
      await tester.pumpAndSettle();
      expect(viewModel.controller.text, '1,000');
    });

    testWidgets('Retains correct cursor position after formatting',
        (tester) async {
      final viewModel = MoneyTextFieldViewModel(required: true);
      await tester.pumpWidget(generateWidget(viewModel));
      await tester.enterText(find.byType(TextFormField), '1000');
      await tester.pumpAndSettle();
      expect(viewModel.controller.selection.baseOffset, 5);
    });

    testWidgets('Ignores non-numeric input', (tester) async {
      final viewModel = MoneyTextFieldViewModel(required: true);
      await tester.pumpWidget(generateWidget(viewModel));
      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pumpAndSettle();
      expect(viewModel.controller.text, '');
    });
  });
}
