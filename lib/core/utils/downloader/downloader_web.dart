import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

@JS('streamSaver.createWriteStream')
external JSWritableStream createWriteStream(JSString fileName);

// 1. Define the explicit JS structure for the WritableStream object
@JS()
extension type JSWritableStream(JSObject _) implements JSObject {
  external JSStreamWriter getWriter();
}

// 2. Define the explicit JS structure for the Writer object
@JS()
extension type JSStreamWriter(JSObject _) implements JSObject {
  external JSPromise write(JSAny chunk);
  external JSPromise close();
}

Future<void> downloadStreamZeroMemory({
  required Stream<List<int>> byteStream,
  required String fileName,
}) async {
  // Call the interop function returning our defined extension type
  final JSWritableStream fileStream = createWriteStream(fileName.toJS);

  // Call getWriter() safely without using 'dynamic'
  final JSStreamWriter jsWriter = fileStream.getWriter();

  try {
    await for (final List<int> chunk in byteStream) {
      final Uint8List uint8list = Uint8List.fromList(chunk);
      final JSAny jsUint8Array = uint8list.toJS;

      // Await the write promise safely
      await jsWriter.write(jsUint8Array).toDart;
    }
  } finally {
    // Await the close promise safely
    await jsWriter.close().toDart;
  }
}
