import 'dart:async';

import 'package:send_z/core/utils/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'socket_channel.dart';

class SocketPool {
  final List<String> relays;
  final void Function() onConnected;
  final void Function(dynamic message) onMessageReceived;
  final Map<String, SocketChannel> channelManager = {};

  new({
    required this.relays,
    required this.onConnected,
    required this.onMessageReceived,
  });

  Future<void> connect() async {
    for (var relay in relays) {
      _singleConnect(relay);
    }

    await connected.future;
    logger.d("relay connected");
    onConnected();
  }

  final Completer<bool> connected = Completer();

  final List<String> _sentHistory = [];

  Future<void> _singleConnect(String relay) async {
    try {
      logger.d("try to connect to $relay");
      final channel = WebSocketChannel.connect(Uri.parse(relays[0]));
      await channel.ready.timeout(Duration(seconds: 7));

      channelManager[relay] = SocketChannel(
        channel: channel,
        sub: channel.stream.listen((event) {
          onMessageReceived(event);
        }),
      )..sendAll(_sentHistory);

      if (connected.isCompleted == false) {
        connected.complete(true);
      }
    } catch (e, s) {
      logger.e("failed to connect to socket $relay", error: e, stackTrace: s);
      await Future.delayed(Duration(seconds: 3));
      _singleConnect(relay);
    }
  }

  Future<void> send(String event) async {
    _sentHistory.add(event);
    for (var mng in channelManager.values) {
      mng.send(event);
    }
  }

  Future<void> close() async {
    for (var mng in channelManager.values) {
      mng.close();
    }
  }
}
