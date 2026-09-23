import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:send_z/core/model/file_meta.dart';
import 'package:send_z/core/utils/tansfer/connection_manager.dart';
import 'package:send_z/core/utils/tansfer/receiver_manager.dart';
import 'package:send_z/features/transfer/bloc/transfer_bloc.dart';

part 'receive_state.dart';
part 'receive_event.dart';
part 'receive_bloc.freezed.dart';

class ReceiveBloc extends Bloc<ReceiveEvent, ReceiveState> {
  final TransferBloc transferBloc;

  List<FileMeta> files = [];

  new({required this.transferBloc})
    : super(ReceiveState(type: ReceiveStateType.initialized)) {
    on<ReceiveEventStarted>((event, emit) async {
      transferBloc.add(TransferEventReset());
      emit(state.copyWith(type: ReceiveStateType.initialized, files: []));
      await ConnectionManager.initConnection(
        ReceiverManager(
          code: event.code,
          onConnected: () {},
          onFileMetaReceived: (files) {
            add(ReceiveEventConnected(files: files));
          },
          onDisconnected: () {
            add(ReceiveEventDisconnected());
          },
          onDone: () {
            add(ReceiveEventDone());
          },
          onTransferFile: (String id, int size) {
            transferBloc.add(TransferEventProcessed(id: id, size: size));
          },
          onRejected: () {
            add(ReceiveEventRejected());
          },
        ),
      );
    });

    on<ReceiveEventConnected>((event, emit) {
      files = event.files;
      emit(
        state.copyWith(type: ReceiveStateType.connected, files: event.files),
      );
    });

    on<ReceiveEventRejected>((event, emit) {
      emit(state.copyWith(type: ReceiveStateType.rejected));
    });

    on<ReceiveEventStoped>((event, emit) {
      ConnectionManager.close();
    });

    on<ReceiveEventDisconnected>((event, emit) {
      ConnectionManager.close();
      emit(state.copyWith(type: ReceiveStateType.disconnected));
    });

    on<ReceiveEventDone>((event, emit) {
      ConnectionManager.close();
      emit(state.copyWith(type: ReceiveStateType.done));
    });
  }
}
