import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:send_z/features/home/presentation/widget/scanner.dart';
import 'package:send_z/main.dart';
import 'package:url_launcher/url_launcher.dart';

class ReceiverInput extends StatefulWidget {
  const new({super.key});

  @override
  State<ReceiverInput> createState() => _ReceiverInputState();
}

class _ReceiverInputState extends State<ReceiverInput> {
  final TextEditingController urlController = TextEditingController();

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  void _goToReceive(BuildContext context, String code) async {
    String cleanCode = code;
    if (code.contains("/")) {
      cleanCode = code.split("/").last;
    }

    if (kIsWeb) {
      if (!await launchUrl(
        Uri.parse('$baseUrl#/$cleanCode'),
        // '_blank' untuk tab baru, '_self' untuk tab yang sama
        webOnlyWindowName: '_self',
      )) {
        throw Exception('Tidak dapat membuka $baseUrl#/$cleanCode');
      }
    } else {
      AutoRouter.of(context).replacePath("/$cleanCode");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        kIsWeb || Platform.isAndroid || Platform.isIOS
            ? Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  height: 42,
                  child: FilledButton(
                    onPressed: () async {
                      final qrData = await Navigator.of(context).push<String?>(
                        MaterialPageRoute(
                          builder: (context) {
                            return Scanner(
                              onDetect: (barcode) {
                                Navigator.of(context).pop(barcode);
                              },
                            );
                          },
                        ),
                      );
                      if (qrData != null && context.mounted) {
                        _goToReceive(context, qrData);
                      }
                    },
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.all(0),
                    ),
                    child: Icon(Icons.qr_code_scanner),
                  ),
                ),
              )
            : SizedBox.shrink(),
        Expanded(
          child: TextField(
            controller: urlController,
            decoration: InputDecoration(
              hintText: "Insert Sendz Url or Scan QR",
              // prefixIcon: FilledButton(
              //   onPressed: () {},
              //   child: Icon(Icons.qr_code_scanner),
              // ),
            ),
            onSubmitted: (value) {
              _goToReceive(context, value);
            },
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          height: 42,
          child: FilledButton(
            onPressed: () {
              _goToReceive(context, urlController.text);
            },
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.all(0),
            ),
            child: Icon(Icons.keyboard_return),
          ),
        ),
      ],
    );
  }
}
