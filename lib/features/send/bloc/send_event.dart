part of 'send_bloc.dart';

abstract class SendEvent {}

class SendEventStart extends SendEvent {
  final List<PlatformFile> files;

  new({required this.files});
}

class SendEventStoped extends SendEvent {}

class SendEventConnected extends SendEvent {}

class SendEventLinkGenerated extends SendEvent {
  final String code;

  new({required this.code});
}

class SendEventDisconnected extends SendEvent {}

class SendEventDone extends SendEvent {}

class SendEventError extends SendEvent {}
