import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:send_z/features/send/bloc/send_bloc.dart';
import 'package:send_z/main.dart';

class QrDisplay extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendBloc, SendState>(
      buildWhen: (previous, current) {
        return current.type != previous.type &&
                (current.type == SendStateType.linkGenerated) ||
            previous.type == SendStateType.linkGenerated;
      },
      builder: (context, state) {
        String? appCode = state.code;
        final url = '$baseUrl/$appCode';
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Visibility(
            visible:
                state.type ==
                SendStateType.linkGenerated, // Dikontrol oleh State BLoC
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(16),
              width: double.infinity, // Lebar full di dalam Column
              // color: Colors.blue.shade100,
              child: Column(
                spacing: 10,
                children: [
                  Text("Scan QR or copy url bellow to receive files"),
                  Container(
                    constraints: BoxConstraints(maxWidth: 200, maxHeight: 200),
                    child: Card(
                      color: Colors.white,
                      child: PrettyQrView.data(
                        data: url,
                        decoration: const PrettyQrDecoration(
                          quietZone: PrettyQrQuietZone.pixels(10),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      readOnly: true,
                      initialValue: url,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: url));
                          },
                          icon: const Icon(Icons.copy),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
