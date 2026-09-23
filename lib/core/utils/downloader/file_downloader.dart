// 1. Default to the safe stub file (for Android, iOS, Windows, Mac)
export 'downloader_stub.dart' // <-- The "else" (Default fallback)
    if (dart.library.js_interop) 'downloader_web.dart' // <-- If Web
    if (dart.library.io) 'downloader_io.dart';
