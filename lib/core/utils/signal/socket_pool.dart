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

    if (await _connected.future) {
      logger.d("relay connected");
      onConnected();
    }
  }

  final Completer<bool> _connected = Completer();

  final List<String> _sentHistory = [];
  bool _closeReq = false;

  Future<void> _singleConnect(String relay) async {
    WebSocketChannel? channel;
    try {
      if (_closeReq) {
        if (!_connected.isCompleted) {
          _connected.complete(false);
        }
        return;
      }
      logger.d("try to connect to $relay");
      channel = WebSocketChannel.connect(Uri.parse(relay));
      await channel.ready.timeout(Duration(seconds: 10));

      channelManager[relay] = SocketChannel(
        channel: channel,
        sub: channel.stream.listen((event) {
          onMessageReceived(event);
        }),
      )..sendAll(_sentHistory);

      if (_connected.isCompleted == false) {
        _connected.complete(true);
      }
    } catch (e, s) {
      channel?.sink.close();
      if (_closeReq) {
        if (!_connected.isCompleted) {
          _connected.complete(false);
        }
        return;
      }
      logger.e("failed to connect to socket $relay", error: e, stackTrace: s);
      await Future.delayed(Duration(seconds: 3));
      if (_closeReq) {
        if (!_connected.isCompleted) {
          _connected.complete(false);
        }
        return;
      }
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
    _closeReq = true;
    for (var mng in channelManager.values) {
      mng.close();
    }
  }
}
