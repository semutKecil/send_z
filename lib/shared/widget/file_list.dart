import 'package:flutter/material.dart';
import 'package:send_z/core/model/file_meta.dart';
import 'package:send_z/features/transfer/presentation/widget/file_transfer.dart';

class FileList extends StatelessWidget {
  final List<FileMeta> files;
  const new({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListView.builder(
        itemBuilder: (context, index) {
          final file = files[index];
          return FileTransfer(file: file);
        },
        itemCount: files.length,
      ),
    );
  }
}
