import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:send_z/core/model/file_meta.dart';
import 'package:send_z/core/utils/tansfer/connection_manager.dart';
import 'package:send_z/core/utils/tansfer/sender_manager.dart';
import 'package:send_z/features/transfer/bloc/transfer_bloc.dart';

part 'send_state.dart';
part 'send_event.dart';
part 'send_bloc.freezed.dart';

class SendBloc extends Bloc<SendEvent, SendState> {
  final TransferBloc transferBloc;
  List<FileMeta> files = [];

  new({required this.transferBloc})
    : super(SendState(type: SendStateType.initialized, files: [])) {
    on<SendEventStart>((event, emit) async {
      files = await Future.wait(event.files.map((e) => e.toFileMeta()));
      transferBloc.add(TransferEventReset());
      emit(
        state.copyWith(type: SendStateType.started, files: files, code: null),
      );
      await ConnectionManager.initConnection(
        SenderManager(
          files: event.files,
          onConnected: () {
            add(SendEventConnected());
          },
          onDisconnected: () {
            add(SendEventDisconnected());
          },
          onDone: () {
            add(SendEventDone());
          },
          onTransferFile: (String id, int size) {
            transferBloc.add(TransferEventProcessed(id: id, size: size));
          },
          codeGenerated: (String code) {
            add(SendEventLinkGenerated(code: code));
          },
        ),
      );
      // .then((value) {
      //   add(SendEventLinkGenerated(code: value.signaling!.shareableNpub));
      // });
    });

    on<SendEventError>((event, emit) {});

    on<SendEventStoped>((event, emit) {
      ConnectionManager.close();
    });

    on<SendEventLinkGenerated>((event, emit) {
      emit(state.copyWith(type: SendStateType.linkGenerated, code: event.code));
    });

    on<SendEventConnected>((event, emit) {
      emit(state.copyWith(type: SendStateType.connected));
    });

    on<SendEventDone>((event, emit) {
      emit(state.copyWith(type: SendStateType.done));
    });

    on<SendEventDisconnected>((event, emit) {
      emit(state.copyWith(type: SendStateType.disconnected));
    });
  }
}

class SendManager {}
