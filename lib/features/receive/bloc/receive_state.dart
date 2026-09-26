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
}
