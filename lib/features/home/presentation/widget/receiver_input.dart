import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:send_z/core/utils/logger.dart';
import 'package:send_z/core/utils/utils.dart';
import 'package:send_z/features/home/presentation/widget/scanner.dart';

class ReceiverInput extends StatefulWidget {
  const new({super.key});

  @override
  State<ReceiverInput> createState() => _ReceiverInputState();
}

class _ReceiverInputState extends State<ReceiverInput> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _onUrlError(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Invalid Url"),
          content: Text("Url you used are invalid"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
    if (context.mounted) {
      AutoRouter.of(context).replacePath("/");
    }
  }

  void _goToReceive(BuildContext context, String url) async {
    if (url.isEmpty) return;
    String cleanCode = url;
    if (cleanCode.contains("/")) {
      cleanCode = cleanCode.split("/").last;
    }

    try {
      MessagePackager().decode(cleanCode);
      AutoRouter.of(context).replacePath("/$cleanCode");
    } catch (e) {
      _onUrlError(context);
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
                        // _urlController.text = qrData;
                        logger.d("qr data $qrData");
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
            controller: _urlController,
            decoration: InputDecoration(
              hintText: "Insert Sendz Url or Scan QR",
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
              _goToReceive(context, _urlController.text);
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
