import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_z/core/model/file_meta.dart';
import 'package:send_z/core/utils/utils.dart';
import 'package:send_z/features/transfer/bloc/transfer_bloc.dart';

class FileTransfer extends StatefulWidget {
  final FileMeta file;
  const new({super.key, required this.file});

  @override
  State<FileTransfer> createState() => _FileTransferState();
}

class _FileTransferState extends State<FileTransfer> {
  final ExpansibleController controller = ExpansibleController()..collapse();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
      child: BlocListener<TransferBloc, TransferState>(
        listenWhen: (previous, current) {
          return current.id == "" || current.id == widget.file.id;
        },
        listener: (context, state) {
          if (state.size > 0) {
            controller.expand();
          } else {
            controller.collapse();
          }
        },
        child: IgnorePointer(
          ignoring: true,
          child: ExpansionTile(
            controller: controller,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            collapsedBackgroundColor: Theme.of(context)
                .colorScheme
                .primaryContainer,
            title: Text(widget.file.name),
            trailing: Text(widget.file.size.toByteSize()),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),

            children: [
              BlocBuilder<TransferBloc, TransferState>(
                buildWhen: (previous, current) {
                  return current.id == "" || current.id == widget.file.id;
                },
                builder: (context, state) {
                  return LinearProgressIndicator(
                    minHeight: 5,
                    color: Theme.of(context).colorScheme.primary,
                    value: state.size.toDouble() / widget.file.size.toDouble(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
