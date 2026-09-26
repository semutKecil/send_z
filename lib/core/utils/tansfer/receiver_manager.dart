import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:send_z/core/model/connection_code.dart';
import 'package:send_z/core/model/file_meta.dart';
import 'package:send_z/core/model/message.dart';
import 'package:send_z/core/utils/logger.dart';
import 'package:send_z/core/utils/signal/nostr_signaling.dart';
import 'package:send_z/core/utils/utils.dart';

import '../downloader/file_downloader.dart';

import 'connection_manager.dart';

class ReceiverManager extends ConnectionManager {
  RTCPeerConnection? peerConnection;
  RTCDataChannel? controlChannel;
  RTCDataChannel? fileChannel;
  NostrSignaling? signaling;

  final String code;
  final void Function(List<FileMeta> files) onFileMetaReceived;
  final void Function() onRejected;
  final void Function() onUrlError;

  new({
    required this.code,
    required this.onFileMetaReceived,
    required this.onRejected,
    required this.onUrlError,
    required super.onConnected,
    required super.onDisconnected,
    required super.onDone,
    required super.onTransferFile,
  });

  @override
  Future<void> connect() async {
    try {
      final ConnectionCode cc = MessagePackager().decode(code);
      if (cc case CodeNostrWebRtc(:final relays, :final npub, :final rtcConf)) {
        signaling = NostrSignaling(
          role: Role.receiver,
          relays: relays,
          onConnected: () async {
            peerConnection = await createPeerConnection(rtcConf);

            _setupReceiverListeners();

            peerConnection?.onIceCandidate = (candidate) {
              signaling?.sendIceCandidate(candidate);
            };

            signaling?.onOfferReceived = (offer) async {
              await peerConnection?.setRemoteDescription(offer);

              RTCSessionDescription? answer = await peerConnection
                  ?.createAnswer();
              if (answer == null) return;
              await peerConnection?.setLocalDescription(answer);
              await signaling?.sendAnswer(answer);
            };

            signaling?.onIceCandidateReceived = (candidate) async {
              await peerConnection?.addCandidate(candidate);
            };
          },
          onRejected: () async {
            await closeWebRTC(disconnect: true, fromMessage: true);
            onRejected();
          },
        );
        await signaling?.connect();
        await signaling?.connectToSender(npub);
      } else {
        onUrlError();
        // throw Exception("Invalid url code");
      }
    } catch (e, s) {
      logger.e('Failed to connect!', error: e, stackTrace: s);
      onUrlError();
    }
    // 1. Inisialisasi Signaling
  }

  void _setupReceiverListeners() {
    peerConnection?.onDataChannel = (RTCDataChannel channel) {
      if (channel.label == 'sendz_control') {
        controlChannel = channel;
        _setupControlChannelListeners(controlChannel!);
      } else if (channel.label == 'sendz_file') {
        fileChannel = channel;
        _setupFileChannelListeners(fileChannel!);
      }
    };
  }

  List<FileMeta>? files;
  List<String> transfered = [];
  Map<String, StreamController<List<int>>> transferStream = {};

  Future<void> _prepareReceiveFiles(RTCDataChannel channel) async {
    FileMeta? file = files
        ?.where((element) => !transfered.any((tr) => tr == element.id))
        .firstOrNull;
    if (file == null) {
      //send finish
      await closeWebRTC(disconnect: false, fromMessage: false);
      return;
    }
    transfered.add(file.id);
    int sentSize = 0;

    final streamController = StreamController<List<int>>.broadcast();

    streamController.stream.listen((event) {
      sentSize += event.length;
      onTransferFile(file.id, sentSize);
    });

    transferStream.putIfAbsent(file.id, () => streamController);
    downloadStreamZeroMemory(
      byteStream: streamController.stream,
      fileName: file.name,
    );

    await channel.send(
      RTCDataChannelMessage(jsonEncode(Message.readyReceive(id: file.id))),
    );
  }

  void _setupControlChannelListeners(RTCDataChannel channel) {
    channel.onMessage = (RTCDataChannelMessage msg) async {
      if (!msg.isBinary) {
        final message = Message.fromJson(jsonDecode(msg.text));
        switch (message) {
          case MessageFilesMeta(:final files):
            this.files = files;
            onFileMetaReceived(files);
            _prepareReceiveFiles(channel);
            break;
          case MessageBye(:final disconnect):
            await closeWebRTC(disconnect: disconnect, fromMessage: true);
            if (disconnect) {
              onDisconnected();
            }
            break;
          case MessageReadyReceive():
            break;
        }
      }
    };
  }

  void _setupFileChannelListeners(RTCDataChannel channel) {
    channel.onDataChannelState = (state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        logger.d('DataChannel TERKONEKSI pada Receiver!');
        signaling?.dispose();
        onConnected.call();
        //Todo on connect
      }
    };

    channel.onMessage = (RTCDataChannelMessage msg) async {
      if (msg.isBinary) {
        transferStream[transfered.last]!.add(msg.binary.toList());
      } else {
        if (msg.text.startsWith("EOF")) {
          logger.d(msg.text);
          await transferStream[transfered.last]!.close();
          await _prepareReceiveFiles(controlChannel!);
        } else {}
      }
    };
  }

  @override
  Future<void> closeWebRTC({
    bool disconnect = false,
    bool fromMessage = false,
  }) async {
    logger.d('Closing WebRTC resources on Receiver...');
    if (!fromMessage) {
      await controlChannel?.send(
        RTCDataChannelMessage(jsonEncode(Message.bye(disconnect: disconnect))),
      );
    }
    for (var element in transferStream.values) {
      element.close();
    }
    signaling?.dispose();
    signaling = null;
    // 1. Tutup Data Channels
    await controlChannel?.close();
    await fileChannel?.close();
    controlChannel = null;
    fileChannel = null;

    // 2. Tutup PeerConnection
    await peerConnection?.close();
    await peerConnection?.dispose();
    peerConnection = null;

    logger.d('WebRTC Receiver Closed Completely.');
    if (!disconnect) {
      onDone();
    }
  }
}
