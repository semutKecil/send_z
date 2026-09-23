import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_meta.freezed.dart';
part 'file_meta.g.dart';

@freezed
sealed class FileMeta with _$FileMeta {
  const factory FileMeta({
    required String id,
    required String name,
    required int size,
    String? extension,
  }) = _FileMeta;

  factory FileMeta.fromJson(Map<String, dynamic> json) =>
      _$FileMetaFromJson(json);
}

extension PlatformFileExt on PlatformFile {
  Future<FileMeta> toFileMeta() async {
    return FileMeta(
      id: uri.path,
      name: name,
      size: (await length()) ?? 0,
      extension: extension,
    );
  }
}
