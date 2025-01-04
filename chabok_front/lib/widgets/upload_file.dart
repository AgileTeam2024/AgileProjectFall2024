import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class UploadFileWidget extends StatelessWidget {
  Map<String, Uint8List> files;

  final void Function(Map<String, Uint8List> files) onFilesChange;

  final int minimumFiles;
  final int? maximumFiles;

  UploadFileWidget({
    super.key,
    required this.files,
    required this.onFilesChange,
    this.minimumFiles = 1,
    this.maximumFiles,
  });

  DropzoneViewController? controller;

  @override
  Widget build(BuildContext context) {
    final isBigScreen = MediaQuery.sizeOf(context).width > 1000;
    final textTheme = Theme.of(context).textTheme;
    return Flex(
      direction: isBigScreen ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: isBigScreen ? 1 : 2,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border.all(
                    color: Colors.black45,
                    width: 5,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, color: Colors.black45, size: 75),
                    SizedBox(height: 20),
                    Text(
                      'Upload your product images...',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.black45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      'You can drag and drop up to $maximumFiles files or '
                      'click to open file browse.',
                      style:
                          textTheme.bodyMedium?.copyWith(color: Colors.black45),
                    ),
                  ],
                ),
              ),
              DropzoneView(
                cursor: CursorType.grab,
                onCreated: (ctrl) => controller = ctrl,
                mime: ['image/jpeg', 'image/png', 'image/jpg'],
                operation: DragOperation.copy,
                onDropFiles: (files) async {
                  final newFiles = await Future.wait(
                    (files ?? []).map((f) async =>
                        MapEntry(f.name, await controller!.getFileData(f))),
                  );
                  _addFiles(Map.fromEntries(newFiles));
                },
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _openFileExplorer,
              ),
            ],
          ),
        ),
        if (files.isNotEmpty)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isBigScreen ? 10 : 20,
                vertical: isBigScreen ? 20 : 10,
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files.entries.toList()[index];
                  return Stack(
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.memory(file.value),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 15,
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeFile(file.key),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openFileExplorer() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true);
    if (result == null) return;
    _addFiles(result.files.asMap().map((_, e) => MapEntry(e.name, e.bytes!)));
  }

  void _addFiles(Map<String, Uint8List> newFiles) =>
      _setFiles({...files, ...newFiles});

  void _removeFile(String fileName) => _setFiles(files..remove(fileName));

  void _setFiles(Map<String, Uint8List> newFiles) {
    final newFilesTrunc = Map.fromEntries(
      newFiles.entries.take(maximumFiles ?? newFiles.length),
    );
    onFilesChange(newFilesTrunc);
    files = newFilesTrunc;
  }
}
