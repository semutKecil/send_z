import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:send_z/core/utils/logger.dart';

Future<void> downloadStreamZeroMemory({
  required Stream<List<int>> byteStream,
  required String fileName,
}) async {
  final directory = await getApplicationDocumentsDirectory();

  // 1. Resolve duplicate name safely
  final String extension = fileName.contains(".")
      ? ".${fileName.split(".").last}"
      : "";

  final String baseName = extension.isEmpty
      ? fileName
      : fileName.substring(0, fileName.length - extension.length);

  // String baseName = fileName.substring(0);
  // String extension = 'bin';
  String filePath = '${directory.path}/$baseName$extension';
  File file = File(filePath);

  int counter = 1;
  // Keep looping as long as a file with this name already exists
  while (await file.exists()) {
    filePath = '${directory.path}/$baseName ($counter)$extension';
    file = File(filePath);
    counter++;
  }

  // 2. Open an IOSink and write chunks sequentially
  final IOSink sink = file.openWrite();

  try {
    await sink.addStream(byteStream);
  } catch (e, s) {
    logger.e("Error writing stream to file", error: e, stackTrace: s);
  } finally {
    await sink.close();
    logger.d("File completely written to: $filePath");
  }
}
