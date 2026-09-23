import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_z/features/send/bloc/send_bloc.dart';

class LoadingMessage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendBloc, SendState>(
      buildWhen: (previous, current) {
        return previous.type != current.type;
      },
      builder: (context, state) {
        final Widget content;
        switch (state.type) {
          case SendStateType.started:
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
                Text("Generate link..."),
              ],
            );
            break;
          case SendStateType.linkGenerated:
            content = Row(
              mainAxisSize: MainAxisSize.min,
              key: ValueKey("connecting"),
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
          case SendStateType.connected:
          case SendStateType.initialized:
          case SendStateType.error:
          case SendStateType.disconnected:
          case SendStateType.done:
            content = SizedBox.shrink(key: ValueKey("none"));
            break;
        }

        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: content,
        );
      },
    );
  }
}
