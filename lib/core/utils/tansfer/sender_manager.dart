import 'dart:convert';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:send_z/core/model/connection_code.dart';
import 'package:send_z/core/model/file_meta.dart';
import 'package:send_z/core/model/message.dart';
import 'package:send_z/core/utils/logger.dart';
import 'package:send_z/core/utils/tansfer/connection_manager.dart';
import 'package:send_z/core/utils/signal/nostr_signaling.dart';
import 'package:send_z/core/utils/utils.dart';
import 'package:send_z/main.dart';

class SenderManager extends ConnectionManager {
  RTCPeerConnection? peerConnection;
  // RTCDataChannel? dataChannel;
  RTCDataChannel? controlChannel;
  RTCDataChannel? fileChannel;
  NostrSignaling? _signaling;
  final List<String> relays;
  final Map<String, dynamic> webRtcConfig;
  final List<PlatformFile> files;

  final Function(String code) codeGenerated;

  new({
    required this.files,
    required super.onConnected,
    required super.onDisconnected,
    required super.onDone,
    required super.onTransferFile,
    required this.codeGenerated,
    this.relays = defaultRelay,
    this.webRtcConfig = defaultRtcConfig,
  });

  @override
  Future<void> connect() async {
    // 1. Inisialisasi Signaling
    _signaling = NostrSignaling(
      role: Role.sender,
      relays: relays,
      onConnected: () async {
        // 2. Buat WebRTC PeerConnection
        peerConnection = await createPeerConnection(webRtcConfig);

        await _setupDataChannels();
        // 4. Handle ICE Candidates lokal -> Kirim ke Nostr
        peerConnection?.onIceCandidate = (candidate) {
          _signaling?.sendIceCandidate(candidate);
        };

        // 5. Handle ketika Receiver terhubung
        _signaling?.onPeerConnected = (receiverPubKey) async {
          // Buat Offer
          final RTCSessionDescription? offer = await peerConnection
              ?.createOffer();
          if (offer == null) return;
          await peerConnection?.setLocalDescription(offer);
          await _signaling?.sendOffer(offer);
        };

        // 6. Receive Answer dari Receiver
        _signaling?.onAnswerReceived = (answer) async {
          await peerConnection?.setRemoteDescription(answer);
        };

        // 7. Receive ICE Candidates dari Receiver
        _signaling?.onIceCandidateReceived = (candidate) async {
          await peerConnection?.addCandidate(candidate);
        };
      },
      onRejected: () {},
      onNoAnswer: () {},
    );
    await _signaling?.connect();
    codeGenerated(
      MessagePackager().encode(
        ConnectionCode.nostrWebRtc(
          relays: relays,
          npub: _signaling!.shareableNpub,
          rtcConf: webRtcConfig,
        ),
      ),
    );
  }

  // Method untuk mengirim chunk file
  void sendFileChunk(Uint8List chunk) {
    if (fileChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      fileChannel?.send(RTCDataChannelMessage.fromBinary(chunk));
    }
  }

  Future<void> _setupDataChannels() async {
    // 1. Channel untuk Pesan JSON / Kontrol
    RTCDataChannelInit controlConfig = RTCDataChannelInit()..ordered = true;
    controlChannel = await peerConnection?.createDataChannel(
      'sendz_control',
      controlConfig,
    );
    _setupControlChannelListeners(controlChannel!);

    // 2. Channel untuk Binary Transfer File
    RTCDataChannelInit fileConfig = RTCDataChannelInit()
      ..ordered = true
      ..maxRetransmits = 30; // Opsional: atur kebijakan retransmisi jika perlu

    fileChannel = await peerConnection?.createDataChannel(
      'sendz_file',
      fileConfig,
    );
    _setupFileChannelListeners(fileChannel!);

    // 3. Setelah channel dibuat, baru buat SDP Offer
    final RTCSessionDescription? offer = await peerConnection?.createOffer();
    if (offer == null) return;
    await peerConnection?.setLocalDescription(offer);
    await _signaling?.sendOffer(offer);
  }

  void _setupControlChannelListeners(RTCDataChannel channel) {
    channel.onMessage = (RTCDataChannelMessage msg) async {
      if (!msg.isBinary) {
        final message = Message.fromJson(jsonDecode(msg.text));
        switch (message) {
          case MessageFilesMeta():
            break;
          case MessageReadyReceive(:final id):
            final file = files.where((file) => file.uri.path == id).firstOrNull;
            if (file == null) return;
            _streamLocalFile(platformFile: file, dataChannel: fileChannel!);
            break;
          case MessageBye(:final disconnect):
            await closeWebRTC(disconnect: disconnect, fromMessage: true);
            if (disconnect) {
              onDisconnected();
            }
            break;
        }
      }
    };
  }

  void _setupFileChannelListeners(RTCDataChannel channel) {
    channel.onDataChannelState = (state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        logger.d('DataChannel TERKONEKSI! Siap kirim file.');
        _signaling?.dispose();
        onConnected.call();
        _sendFilesMetadata(); // Tutup signaling socket karena P2P sudah aktif
      }
    };
    // Handling log/state khusus file channel
    channel.onMessage = (RTCDataChannelMessage msg) {};
  }

  Future<void> _sendFilesMetadata() async {
    await controlChannel?.send(
      RTCDataChannelMessage(
        jsonEncode(
          Message.filesMeta(
            files: await Future.wait(files.map((e) => e.toFileMeta())),
          ),
        ),
      ),
    );
    // for (var file in files) {
    //   currentTransfer = file.uri.path;
    //   _streamLocalFile(dataChannel: fileChannel!, platformFile: file);
    // }
  }

  Future<void> _streamLocalFile({
    required PlatformFile platformFile, // The local path, e.g., '/storage/emulated/0/Download/video.mp4'
    required RTCDataChannel dataChannel,
  }) async {
    // 1. Point to the local file asset
    // final file = File.fromUri(platformFile.uri);

    final uriPath = platformFile.uri.path;
    // if (!await file.exists()) {
    // throw Exception('Local file does not exist at path: $uriPath');
    // }

    final int totalSize = (await platformFile.length()) ?? 0;

    dataChannel.send(RTCDataChannelMessage("START|$uriPath"));
    const int bufferThreshold = 1024 * 1024; // 1 MB ceiling
    onTransferFile(uriPath, 0);

    try {
      // final RandomAccessFile raf = await file.open(mode: FileMode.read);
      const int targetChunkSize = 16 * 1024;
      int bytesRead = 0;

      final byteStream = platformFile.readAsByteStream();
      final reader = ChunkedStreamReader<int>(byteStream);

      try {
        while (bytesRead < totalSize && !isCLosed) {
          while ((dataChannel.bufferedAmount ?? 0) > bufferThreshold) {
            await Future.delayed(const Duration(milliseconds: 30));
          }
          final chunk = await reader.readChunk(targetChunkSize);
          if (chunk.isEmpty) break;

          await dataChannel.send(
            RTCDataChannelMessage.fromBinary(Uint8List.fromList(chunk)),
          );

          bytesRead += chunk.length;
          onTransferFile(uriPath, bytesRead);
        }

        if (isCLosed) return;

        // 4. Notify completion
        await dataChannel.send(RTCDataChannelMessage("EOF|$uriPath"));
        logger.d('Local file transfer complete. EOF sent successfully.');
      } catch (_) {}
    } catch (e) {
      await dataChannel.send(RTCDataChannelMessage("ERROR|$e"));
    }
  }

  bool isCLosed = false;

  @override
  Future<void> closeWebRTC({
    bool disconnect = false,
    bool fromMessage = false,
  }) async {
    logger.d('Closing WebRTC resources...');
    isCLosed = true;
    if (!fromMessage) {
      await controlChannel?.send(
        RTCDataChannelMessage(jsonEncode(Message.bye(disconnect: disconnect))),
      );
    }
    _signaling?.dispose();
    _signaling = null;
    // 2. Tutup Data Channels
    await controlChannel?.close();
    await fileChannel?.close();
    controlChannel = null;
    fileChannel = null;

    // 3. Tutup PeerConnection
    await peerConnection?.close();
    await peerConnection?.dispose();
    peerConnection = null;

    logger.d('WebRTC Sender Closed Completely.');
    if (!disconnect) {
      onDone();
    }
  }
}
