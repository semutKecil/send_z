import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                spacing: 10,
                children: [
                  Spacer(flex: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 150.0,
                      height: 150.0,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SvgPicture.asset(
                          'assets/images/sendz-transparent.svg',
                          semanticsLabel:
                              'A descriptive label for screen readers',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: FilledButton(
                      onPressed: () async {
                        List<PlatformFile> files = await FilePicker.pickFiles();
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
                  Spacer(flex: 7),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
