part of 'receive_bloc.dart';

enum ReceiveStateType {
  initialized,
  connected,
  error,
  urlError,
  disconnected,
  done,
  rejected,
}

@freezed
sealed class ReceiveState with _$ReceiveState {
  const factory ReceiveState({
    required ReceiveStateType type,
    @Default([]) List<FileMeta> files,
  }) = _ReceiveState;
  // const factory ReceiveState.initialize() = ReceiveStateInitialize;
  // const factory ReceiveState.connecting() = ReceiveStateConnecting;
  // const factory ReceiveState.fileList({required List<FileMeta> files}) =
  //     ReceiveStateFileList;
  // const factory ReceiveState.error() = ReceiveStateError;
  // const factory ReceiveState.disconnect() = ReceiveStateDisconnect;
  // const factory ReceiveState.done() = ReceiveStateDone;
}
