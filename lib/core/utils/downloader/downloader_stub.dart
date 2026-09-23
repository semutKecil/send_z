import 'dart:async';

Future<void> downloadStreamZeroMemory({
  required Stream<List<int>> byteStream,
  required String fileName,
}) async {
  throw UnsupportedError('This platform does not support web streaming.');
}
