part of 'send_bloc.dart';

enum SendStateType {
  initialized,
  started,
  linkGenerated,
  connected,
  error,
  disconnected,
  done,
}

@freezed
sealed class SendState with _$SendState {
  const factory SendState({
    required SendStateType type,
    required List<FileMeta> files,
    String? code,
  }) = _SendState;
  // const factory SendState.initialize({required List<PlatformFile> files}) =
  //     SendStateInitialize;
  // const factory SendState.connecting({
  //   required List<PlatformFile> files,
  //   required String code,
  // }) = SendStateConnecting;
  // const factory SendState.sending({required List<PlatformFile> files}) =
  //     SendStateSending;
  // const factory SendState.error({required List<PlatformFile> files}) =
  //     SendStateError;
  // const factory SendState.disconnect({required List<PlatformFile> files}) =
  //     SendStateDisconnect;
  // const factory SendState.done({required List<PlatformFile> files}) =
  //     SendStateDone;
}
