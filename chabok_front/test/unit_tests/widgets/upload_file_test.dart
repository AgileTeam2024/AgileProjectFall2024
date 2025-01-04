import 'dart:io';

import 'package:chabok_front/widgets/upload_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFile extends Mock implements DropzoneFileInterface {
  final Uint8List bytes;

  @override
  String get name => 'assets/sample_images/product_img1.jpg';

  @override
  int get size => bytes.length;

  MockFile({required this.bytes});
}

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

    testWidgets('adds files by drag and drop', (tester) async {
      final widget = UploadFileWidget(
        files: files,
        onFilesChange: onFilesChange,
      );
      await tester.pumpWidget(MaterialApp(home: widget));
      await tester.pumpAndSettle(Duration(seconds: 5));

      widget.controller!.widget.onDropFiles
          ?.call([MockFile(bytes: fileBytes), MockFile(bytes: fileBytes)]);
      await tester.pumpAndSettle();

      expect(files.length, 1);
    }, skip: true); // todo can not mock :(

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
