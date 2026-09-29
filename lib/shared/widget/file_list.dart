import 'package:flutter/material.dart';
import 'package:send_z/core/model/file_meta.dart';
import 'package:send_z/features/transfer/presentation/widget/file_transfer.dart';

class FileList extends StatelessWidget {
  final List<FileMeta> files;
  final bool isSliver;
  const new({super.key, required this.files, this.isSliver = true});

  @override
  Widget build(BuildContext context) {
    return isSliver
        ? SliverList.builder(
            itemBuilder: (context, index) {
              final file = files[index];
              return FileTransfer(file: file);
            },
            itemCount: files.length,
          )
        : ListView.builder(
            itemBuilder: (context, index) {
              final file = files[index];
              return FileTransfer(file: file);
            },
            itemCount: files.length,
          );
  }
}
