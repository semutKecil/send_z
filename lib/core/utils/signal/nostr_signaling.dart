import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:nostr/nostr.dart';
import 'package:send_z/core/utils/debouncer.dart';
import 'package:send_z/core/utils/logger.dart';

import 'socket_pool.dart';

enum Role { sender, receiver }

class NostrSignaling {
  final List<String> relays;
  final Role role;
  final void Function() onConnected;
  final void Function() onRejected;

  late Keys _myKeychain;
  String? peerHexPubKey;

  late final SocketPool _socketPool;

  bool _dispose = false;
  final Set<String> _eventReceived = {};

  final List<Map<String, dynamic>> _messageBuffer = [];
  final Debouncer _messageDebouncer = Debouncer(milliseconds: 500);

  // WebRTC Callbacks
  Function(RTCSessionDescription offer)? onOfferReceived;
  Function(RTCSessionDescription answer)? onAnswerReceived;
  Function(RTCIceCandidate candidate)? onIceCandidateReceived;
  Function(String peerPubKey)? onPeerConnected;

  NostrSignaling({
    required this.role,
    required this.onConnected,
    required this.onRejected,
    required this.relays,
  }) {
    _myKeychain = Keys.generate();
    logger.d('nsec generated ${_myKeychain.nsec}');
  }

  /// Mendapatkan Shareable Npub untuk ditaruh di URL (Khusus Sender)
  String get shareableNpub => _myKeychain.npub;

  Future<void> connect() async {
    if (_dispose) return;
    _socketPool = SocketPool(
      relays: relays,
      onConnected: () {
        _subscribeToMyEvents();
      },
      onMessageReceived: (message) {
        _handleIncomingMessage(message);
      },
    );
    await _socketPool.connect();
  }

  Completer<bool>? _receiverComplete;
  Timer? _receiverTimer;

  /// 2. Receiver Inisialisasi Handshake ke Sender via Npub dari URL
  Future<void> connectToSender(String senderNpub) async {
    if (role != Role.receiver) return;
    logger.d("get pubhex $senderNpub");
    peerHexPubKey = Nip19.decode(payload: senderNpub).data;
    _receiverComplete = Completer();
    _sendNostrMessage({'type': 'init_handshake', 'message': 'Receiver ready'});
    _receiverTimer = Timer(Duration(seconds: 10), () {
      if (_receiverComplete?.isCompleted == false) {
        _receiverComplete?.complete(false);
      }
    });

    if ((await _receiverComplete?.future) == true) {
      await _sendNostrMessage({'type': 'start', 'sdp': 'start-send'});
      onConnected();
    } else {
      onRejected();
    }

    // onConnected();
  }

  /// 3. Mengirim SDP Offer (Sender -> Receiver)
  Future<void> sendOffer(RTCSessionDescription offer) async {
    if (peerHexPubKey == null) throw Exception('Peer PubKey belum diketahui!');

    await _sendNostrMessage({'type': 'offer', 'sdp': offer.toMap()});
  }

  /// 4. Mengirim SDP Answer (Receiver -> Sender)
  Future<void> sendAnswer(RTCSessionDescription answer) async {
    if (peerHexPubKey == null) throw Exception('Peer PubKey belum diketahui!');

    await _sendNostrMessage({'type': 'answer', 'sdp': answer.toMap()});
  }

  /// 5. Mengirim ICE Candidate
  Future<void> sendIceCandidate(RTCIceCandidate candidate) async {
    if (peerHexPubKey == null) return;

    await _sendNostrMessage({
      'type': 'candidate',
      'candidate': candidate.toMap(),
    });
  }

  /// Subscribe Filter REQ ke Nostr Relay
  void _subscribeToMyEvents() {
    final filter = {
      "kinds": [44],
      "#p": [_myKeychain.public],
    };
    final request = jsonEncode(["REQ", "sendz_signaling", filter]);
    logger.d('send init $request');
    _socketPool.send(request);
  }

  /// Handle pesan WebSocket yang masuk dari Nostr Relay
  void _handleIncomingMessage(dynamic rawMessage) async {
    final List<dynamic> decoded = jsonDecode(rawMessage);

    final String messageType = decoded[0];

    if (messageType == 'EVENT') {
      final Map<String, dynamic> eventMap = decoded[2];
      final String eventId = eventMap['id'];

      if (_eventReceived.contains(eventId)) return;
      _eventReceived.add(eventId);
      final String senderPubKey = eventMap['pubkey'];
      final String encryptedContent = eventMap['content'];

      try {
        final String decryptedJson = await Nip44.decrypt(
          payload: encryptedContent,
          senderPubkey: senderPubKey,
          recipientSecretKey: _myKeychain.secret,
        );

        final List<dynamic> payloads = jsonDecode(decryptedJson);
        for (var payload in payloads) {
          logger.d('rececived message $payload');
          final String payloadType = payload['type'];
          switch (payloadType) {
            case 'init_handshake':
              if (role == Role.sender) {
                if (peerHexPubKey != null) {
                  await _sendNostrMessage({
                    'type': 'reject',
                    'sdp': 'rejected',
                  }, pubKey: senderPubKey);
                } else {
                  peerHexPubKey = senderPubKey;

                  await _sendNostrMessage({
                    'type': 'confirm',
                    'sdp': 'confirmed',
                  });
                }
              }
              break;
            case 'start':
              if (role == Role.sender) {
                logger.d("start connection");
                onConnected();
                onPeerConnected?.call(senderPubKey);
              }
              break;
            case 'confirm':
              if (role == Role.receiver) {
                logger.d("confirmed connection");
                _receiverTimer?.cancel();
                _receiverComplete?.complete(true);
              }
              break;
            case 'reject':
              onRejected();
              break;
            case 'offer':
              final sdpMap = Map<String, dynamic>.from(payload['sdp']);
              onOfferReceived?.call(
                RTCSessionDescription(sdpMap['sdp'], sdpMap['type']),
              );
              break;

            case 'answer':
              final sdpMap = Map<String, dynamic>.from(payload['sdp']);
              onAnswerReceived?.call(
                RTCSessionDescription(sdpMap['sdp'], sdpMap['type']),
              );
              break;

            case 'candidate':
              final candMap = Map<String, dynamic>.from(payload['candidate']);
              onIceCandidateReceived?.call(
                RTCIceCandidate(
                  candMap['candidate'],
                  candMap['sdpMid'],
                  candMap['sdpMLineIndex'],
                ),
              );
              break;
          }
        }
      } catch (e) {
        logger.d("Gagal mendekripsi pesan NIP-44: $e");
      }
    }
  }

  /// Encrypt & Publish Event ke Nostr Relay menggunakan NIP-44
  Future<void> _sendNostrMessage(
    Map<String, dynamic> data, {
    String? pubKey,
  }) async {
    _messageBuffer.add(data);
    _messageDebouncer.run(() async {
      final String encodedMessage = jsonEncode(_messageBuffer);

      final String encryptedContent = await Nip44.encrypt(
        plaintext: encodedMessage,
        senderSecretKey: _myKeychain.secret,
        recipientPubkey: pubKey ?? peerHexPubKey!,
      );

      // Construct Nostr Event Kind 44
      final Event event = Event.from(
        secretKey: _myKeychain.secret,
        kind: 44,
        content: encryptedContent,
        pubkey: _myKeychain.public,
        tags: [
          ['p', pubKey ?? peerHexPubKey!],
        ],
      );

      final String request = jsonEncode(["EVENT", event.toMap()]);
      logger.d("send message $encodedMessage");
      _socketPool.send(request);
      // _channel?.sink.add(request);
      _messageBuffer.clear();
    });
  }

  /// Clean Up Socket Connections
  void dispose() {
    _dispose = true;
    _socketPool.close();
  }
}
