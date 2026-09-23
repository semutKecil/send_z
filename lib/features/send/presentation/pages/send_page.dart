import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_z/features/send/bloc/send_bloc.dart';
import 'package:send_z/features/send/presentation/widget/loading_message.dart';
import 'package:send_z/features/send/presentation/widget/qr_display.dart';
import 'package:send_z/shared/widget/default_body.dart';
import 'package:send_z/shared/widget/file_list.dart';

class SendPage extends StatefulWidget {
  final List<PlatformFile> files;
  const new({super.key, required this.files});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<SendBloc>().add(SendEventStart(files: widget.files));
    });
  }

  void _exit(BuildContext context) {
    Navigator.of(context).pop("exit");
  }

  Future<void> _back(BuildContext context) async {
    final confirm = await showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Stop Sending file?"),
          content: Text("File sending wiil be stop. Are you sure?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
    if (confirm == true && context.mounted) {
      context.read<SendBloc>().add(SendEventStoped());
      _exit(context);
    }
  }

  Future<void> _onDisconnect(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Disconected"),
          content: Text("Connection disconnect by peer?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Ok"),
            ),
          ],
        );
      },
    );

    if (context.mounted) {
      context.read<SendBloc>().add(SendEventStoped());
      _exit(context);
    }
  }

  Future<void> _onError(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Transfer error"),
          content: Text("Transfer file error?"),
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
      _exit(context);
    }
  }

  Future<void> _onDone(BuildContext context) async {
    final resend = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("All Sent"),
          content: Text("All files are sent. Do you want to back or re send?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Back"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Re Send"),
            ),
          ],
        );
      },
    );

    if (resend == true && context.mounted) {
      context.read<SendBloc>().add(SendEventStart(files: widget.files));
    } else if (context.mounted) {
      _exit(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SendBloc, SendState>(
      listener: (BuildContext context, SendState state) async {
        switch (state.type) {
          case SendStateType.initialized:
          case SendStateType.started:
          case SendStateType.connected:
          case SendStateType.linkGenerated:
            break;
          case SendStateType.error:
            _onError(context);
            break;
          case SendStateType.disconnected:
            _onDisconnect(context);
            break;
          case SendStateType.done:
            await _onDone(context);
            break;
        }
      },
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (result != "exit") {
            _back(context);
          }
        },
        canPop: false,
        child: Scaffold(
          appBar: AppBar(title: Text("Send Files")),
          body: DefaultBody(
            child: Column(
              spacing: 10,
              children: [
                QrDisplay(),
                LoadingMessage(),
                SizedBox(height: 10),
                BlocBuilder<SendBloc, SendState>(
                  buildWhen: (previous, current) {
                    return (previous.type != current.type &&
                        (previous.type == SendStateType.started ||
                            current.type == SendStateType.started));
                  },
                  builder: (context, state) {
                    return Expanded(
                      flex: 2,
                      child: FileList(files: state.files),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
