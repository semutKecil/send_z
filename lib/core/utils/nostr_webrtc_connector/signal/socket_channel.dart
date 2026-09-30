import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

class SocketChannel {
  final WebSocketChannel channel;
  final StreamSubscription sub;

  final StreamController<String> _messageSubs = StreamController();

  new({required this.channel, required this.sub}) {
    _processMessage();
  }

  Future<void> _processMessage() async {
    await for (var event in _messageSubs.stream) {
      channel.sink.add(event);
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  void send(String message) {
    _messageSubs.add(message);
  }

  void sendAll(List<String> messages) {
    for (var message in messages) {
      send(message);
    }
  }

  Future<void> close() async {
    await _messageSubs.close();
    channel.sink.close();
    sub.cancel();
  }
}
