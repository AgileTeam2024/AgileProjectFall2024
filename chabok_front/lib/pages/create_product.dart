import 'dart:typed_data';

import 'package:chabok_front/widgets/card.dart';
import 'package:chabok_front/widgets/upload_file.dart';
import 'package:flutter/material.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  Map<String, Uint8List> images = {};

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CardWidget(
        child: UploadFileWidget(
          files: images,
          onFilesChange: (newFiles) => setState(() => images = newFiles),
          minimumFiles: 1,
          maximumFiles: 10,
        ),
      ),
    );
  }
}
