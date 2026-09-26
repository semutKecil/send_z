part of 'receive_bloc.dart';

abstract class ReceiveEvent {}

class ReceiveEventStarted extends ReceiveEvent {
  final String code;
  new({required this.code});
}

// class ReceiveEventFileMeta extends ReceiveEvent {
//   final List<FileMeta> files;
//   new({required this.files});
// }

class ReceiveEventStoped extends ReceiveEvent {}

class ReceiveEventRejected extends ReceiveEvent {}

class ReceiveEventNotAnswered extends ReceiveEvent {}

class ReceiveEventDisconnected extends ReceiveEvent {}

class ReceiveEventDone extends ReceiveEvent {}

class ReceiveEventUrlError extends ReceiveEvent {}

class ReceiveEventConnected extends ReceiveEvent {
  final List<FileMeta> files;
  new({required this.files});
}
