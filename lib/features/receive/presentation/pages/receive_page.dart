import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_z/features/receive/bloc/receive_bloc.dart';
import 'package:send_z/shared/widget/default_body.dart';
import 'package:send_z/shared/widget/file_list.dart';

import '../../../../core/utils/strings_const.dart';

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
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _alerDialogSimple(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
            _alerDialogSimple(
              context,
              title: StringsConst.alertsReceiveConnectionErrorTitle,
              content: StringsConst.alertsReceiveConnectionErrorContent,
            );
            break;
          case ReceiveStateType.disconnected:
            _alerDialogSimple(
              context,
              title: StringsConst.alertsDisconnectedTitle,
              content: StringsConst.alertsDisconnectedContent,
            );
            break;
          case ReceiveStateType.done:
            _alerDialogSimple(
              context,
              title: StringsConst.alertsReceiveDoneTitle,
              content: StringsConst.alertsReceiveDoneContent,
            );
            break;
          case ReceiveStateType.rejected:
            _alerDialogSimple(
              context,
              title: StringsConst.alertsReceiveRejectedTitle,
              content: StringsConst.alertsReceiveRejectedContent,
            );
            break;
          case ReceiveStateType.urlError:
            _alerDialogSimple(
              context,
              title: StringsConst.alertsReceiveInvalidUrlTitle,
              content: StringsConst.alertsReceiveInvalidUrlContent,
            );
            break;
          case ReceiveStateType.pairFailed:
            _alerDialogSimple(
              context,
              title: StringsConst.alertsPairFailedTitle,
              content: StringsConst.alertsPairFailedContent,
            );
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Receive FIles")),
        body: DefaultBody(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
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
                      case ReceiveStateType.rejected:
                      case ReceiveStateType.pairFailed:
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
                    return previous.files != current.files;
                    // return previous.type != current.type &&
                    //     (previous.type == ReceiveStateType.connected ||
                    //         current.type == ReceiveStateType.connected);
                  },
                  builder: (context, state) {
                    return Expanded(
                      flex: 2,
                      child: FileList(files: state.files, isSliver: false),
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
