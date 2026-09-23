import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

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

  void _goToReceive(String code) {
    String cleanCode = code;
    if (code.contains("/")) {
      cleanCode = code.split("/").last;
    }

    AutoRouter.of(context).replacePath("/$cleanCode");
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        SizedBox(
          height: 42,
          child: FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.all(0),
            ),
            child: Icon(Icons.qr_code_scanner),
          ),
        ),
        Expanded(
          child: TextField(
            controller: urlController,
            decoration: InputDecoration(
              hintText: "Insert Sendz Url or Scan QR",
            ),
            onSubmitted: _goToReceive,
          ),
        ),

        SizedBox(
          height: 42,
          child: FilledButton(
            onPressed: () {
              _goToReceive(urlController.text);
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
