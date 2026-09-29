import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Scanner extends StatelessWidget {
  final Function(String barcode) onDetect;
  const new({super.key, required this.onDetect});

  @override
  Widget build(BuildContext context) {
    String? qrScanned;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan SendZ QR')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (barcodes) {
              final barcodeString = barcodes.barcodes.firstOrNull?.rawValue;
              if (barcodeString == null || qrScanned != null) return;
              qrScanned = barcodeString;
              onDetect(barcodeString);
            },
          ),
        ],
      ),
    );
  }
}
