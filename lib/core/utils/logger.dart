import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // Menampilkan berapa baris stacktrace
    errorMethodCount: 8,
    lineLength: 120,
    colors: true, // Mengaktifkan warna di terminal
    printEmojis: true,
  ),
);
