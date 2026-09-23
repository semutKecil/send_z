import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

@JS('streamSaver.createWriteStream')
external JSAny createWriteStream(JSString fileName);

Future<void> downloadStreamZeroMemory({
  required Stream<List<int>> byteStream,
  required String fileName,
}) async {
  final JSAny fileStream = createWriteStream(fileName.toJS);
  final jsWriter = (fileStream as dynamic).getWriter();

  try {
    await for (final List<int> chunk in byteStream) {
      final Uint8List uint8list = Uint8List.fromList(chunk);
      final jsUint8Array = uint8list.toJS;
      await (jsWriter.write(jsUint8Array) as JSPromise).toDart;
    }
  } finally {
    await (jsWriter.close() as JSPromise).toDart;
  }
}
