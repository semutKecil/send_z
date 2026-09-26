import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_z/features/receive/bloc/receive_bloc.dart';
import 'package:send_z/shared/widget/default_body.dart';
import 'package:send_z/shared/widget/file_list.dart';

@RoutePage()
class ReceivePage extends StatefulWidget {
  final String code;
  const new({super.key, @PathParam('code') required this.code});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  StreamSubscription? _sub;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ReceiveBloc>().add(ReceiveEventStarted(code: widget.code));
      // _sub = context.read<ReceiveBloc>().stream.listen((event) {
      //   if (event case ReceiveEventFileDownload(:final file, :final stream)) {
      //     if (mounted) {
      //       showDialog(
      //         context: context,
      //         builder: (context) {
      //           return AlertDialog(
      //             title: Text("Download ${file.name}"),
      //             actions: [
      //               TextButton(
      //                 onPressed: () async {
      //                   await FileSaver.instance.saveAsStream(
      //                     name: file.name,
      //                     stream: stream,
      //                     fileExtension: file.extension ?? "",
      //                     mimeType:
      //                         MimeType.values
      //                             .where((mime) => mime.name == file.extension)
      //                             .firstOrNull ??
      //                         MimeType.other,
      //                   );
      //                 },
      //                 child: Text("Download"),
      //               ),
      //             ],
      //           );
      //         },
      //       );
      //     }
      //   }
      // });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _onError(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Connection Error"),
          content: Text("Connectrion error please try again"),
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

  Future<void> _onNotAnswered(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("No Response"),
          content: Text("Sender not responding."),
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

  Future<void> _onDisconnected(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Disconnected"),
          content: Text("File transfer are disconnected"),
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

  Future<void> _onDone(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Files Received"),
          content: Text("All Files are saved"),
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

  Future<void> _onRejected(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Already connected"),
          content: Text("Already connected with other device"),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReceiveBloc, ReceiveState>(
      listener: (context, state) async {
        switch (state.type) {
          case ReceiveStateType.initialized:
          case ReceiveStateType.connected:
            break;
          case ReceiveStateType.error:
            _onError(context);
            break;
          case ReceiveStateType.disconnected:
            _onDisconnected(context);
            break;
          case ReceiveStateType.done:
            _onDone(context);
            break;
          case ReceiveStateType.rejected:
            _onRejected(context);
            break;
          case ReceiveStateType.urlError:
            _onUrlError(context);
            break;
          case ReceiveStateType.notAnswered:
            _onNotAnswered(context);
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Receive FIles")),
        body: DefaultBody(
          child: Column(
            spacing: 10,
            children: [
              BlocBuilder<ReceiveBloc, ReceiveState>(
                builder: (context, state) {
                  final Widget content;
                  switch (state.type) {
                    case ReceiveStateType.initialized:
                      content = Row(
                        mainAxisSize: MainAxisSize.min,
                        key: ValueKey("initializing"),
                        spacing: 10,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(),
                          ),
                          Text("Waiting for connection..."),
                        ],
                      );
                      break;

                    case ReceiveStateType.connected:
                    case ReceiveStateType.error:
                    case ReceiveStateType.disconnected:
                    case ReceiveStateType.done:
                    case ReceiveStateType.urlError:
                    case ReceiveStateType.notAnswered:
                    case ReceiveStateType.rejected:
                      content = SizedBox.shrink(key: ValueKey("none"));
                      break;
                  }
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: content,
                  );
                },
              ),

              SizedBox(height: 10),
              BlocBuilder<ReceiveBloc, ReceiveState>(
                buildWhen: (previous, current) {
                  return previous.type != current.type &&
                      (previous.type == ReceiveStateType.connected ||
                          current.type == ReceiveStateType.connected);
                },
                builder: (context, state) {
                  return Expanded(flex: 2, child: FileList(files: state.files));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
