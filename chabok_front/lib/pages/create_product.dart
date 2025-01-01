import 'dart:typed_data';

import 'package:chabok_front/extensions/list.dart';
import 'package:chabok_front/view_models/text_field.dart';
import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/text_field.dart';
import 'package:chabok_front/widgets/upload_file.dart';
import 'package:flutter/material.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  Map<String, Uint8List> images = {};
  final fieldViewModels = [
    TextFieldViewModel(
      icon: Icons.abc,
      required: true,
      label: 'Product Name',
    ),
    TextFieldViewModel(
      icon: Icons.category,
      required: true,
      label: 'Category',
    ),
    TextFieldViewModel(
      icon: Icons.pin_drop,
      required: false,
      label: 'Location',
    ),
    MoneyTextFieldViewModel(
      required: true,
      label: 'Price',
    ),
    TextFieldViewModel(
      icon: Icons.description,
      required: true,
      label: 'Description',
      maxLines: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isBigScreen = MediaQuery.sizeOf(context).width > 1000;

    return Center(
      child: CardWidget(
        child: Flex(
          direction: isBigScreen ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: UploadFileWidget(
                files: images,
                onFilesChange: (newFiles) => setState(() => images = newFiles),
                minimumFiles: 1,
                maximumFiles: 10,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: isBigScreen ? VerticalDivider() : Divider(),
            ),
            Expanded(
              child: isBigScreen
                  ? Column(
                      children: fieldViewModels
                          .map(
                            (vm) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 7.5,
                                horizontal: 10,
                              ),
                              child: CustomTextField(vm),
                            ),
                          )
                          .toList(),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 15,
                      children: fieldViewModels
                          .fixedGrouped(groupSize: 2)
                          .map(
                            (vmList) => Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 20,
                              children: vmList
                                  .map(
                                    (vm) => Expanded(
                                      child: CustomTextField(vm),
                                    ),
                                  )
                                  .toList(),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
