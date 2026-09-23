import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:send_z/features/home/presentation/widget/receiver_input.dart';
import 'package:send_z/features/send/presentation/pages/send_page.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: FilledButton(
                        onPressed: () async {
                          List<PlatformFile> files =
                              await FilePicker.pickFiles();
                          if (files.isNotEmpty && context.mounted) {
                            // context.read<SendBloc>().add(
                            //   SendEventStart(files: files),
                            // );
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return SendPage(files: files);
                                },
                              ),
                            );
                          } else {
                            return;
                          }
                        },
                        child: Row(
                          spacing: 15,
                          children: [Icon(Icons.upload), Text("Send Files")],
                        ),
                      ),
                    ),
                    const Divider(),
                    const ReceiverInput(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
