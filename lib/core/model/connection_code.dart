import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_code.freezed.dart';
part 'connection_code.g.dart';

@freezed
sealed class ConnectionCode with _$ConnectionCode {
  const factory ConnectionCode.nostrWebRtc({
    required String npub,
    required List<String> relays,
    required Map<String, dynamic> rtcConf,
  }) = CodeNostrWebRtc;

  const factory ConnectionCode.localWebRtc({required String signalingUrl}) =
      CodeLocalWebRtc;

  factory ConnectionCode.fromJson(Map<String, dynamic> json) =>
      _$ConnectionCodeFromJson(json);
}
