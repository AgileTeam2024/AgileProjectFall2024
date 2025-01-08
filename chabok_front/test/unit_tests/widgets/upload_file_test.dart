import 'dart:io';

import 'package:chabok_front/widgets/upload_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'upload_file_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FilePicker>()])
void main() {
  group('UploadFileWidget', () {
    late MockFilePicker mockFilePicker;

    late Map<String, Uint8List> files;
    late void Function(Map<String, Uint8List>) onFilesChange;
    final filename = 'assets/sample_images/product_img1.jpg';
    final fileBytes = File(filename).readAsBytesSync();

    setUpAll(() {
      HttpOverrides.global = null;
      files = {};
      onFilesChange = (newFiles) => files = newFiles;
      mockFilePicker = MockFilePicker();
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
      await tester.pumpWidget(MaterialApp(
        home: UploadFileWidget(
          files: files,
          onFilesChange: onFilesChange,
        ),
      ));

      final uploadWidget = find.byType(UploadFileWidget).evaluate().first.widget
          as UploadFileWidget;
      uploadWidget.filePicker = mockFilePicker;

      when(mockFilePicker.pickFiles(type: FileType.image, allowMultiple: true))
          .thenAnswer((_) async {
        return FilePickerResult([
          PlatformFile(
            name: filename,
            size: fileBytes.lengthInBytes,
            bytes: fileBytes,
          )
        ]);
      });

      await tester.tap(find.byType(UploadFileWidget));
      await tester.pump();

      expect(files.length, 1);
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
