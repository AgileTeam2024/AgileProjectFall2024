import 'dart:io';

import 'package:chabok_front/widgets/upload_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<FilePicker>()])
void main() {
  group('UploadFileWidget', () {
    late Map<String, Uint8List> files;
    late void Function(Map<String, Uint8List>) onFilesChange;
    final filename = 'assets/sample_images/product_img1.jpg';
    final fileBytes = File(filename).readAsBytesSync();

    setUpAll(() {
      HttpOverrides.global = null;
      files = {};
      onFilesChange = (newFiles) => files = newFiles;
    });

    testWidgets('displays initial UI correctly', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UploadFileWidget(
          files: files,
          onFilesChange: onFilesChange,
        ),
      ));

      expect(find.text('Upload your product images...'), findsOneWidget);
      expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('adds files with file_picker', (tester) async {
      assert(false);
    });

    testWidgets('removes a file', (tester) async {
      files = {filename: fileBytes};
      await tester.pumpWidget(MaterialApp(
        home: UploadFileWidget(
          files: files,
          onFilesChange: onFilesChange,
        ),
      ));

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(files.length, 0);
    });
  });
}
