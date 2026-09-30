import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:send_z/main.dart';

part 'connection_code.freezed.dart';
part 'connection_code.g.dart';

@freezed
sealed class ConnectionCode with _$ConnectionCode {
  const factory ConnectionCode({
    required String npub,
    List<String>? relays,
    Map<String, dynamic>? rtcConf,
  }) = _ConnectionCode;

  factory ConnectionCode.fromJson(Map<String, dynamic> json) =>
      _$ConnectionCodeFromJson(json);
}

extension ConnetionCodeExt on ConnectionCode {
  List<String> get usedRelays => relays ?? defaultRelay;
  Map<String, dynamic> get usedRtcConf => rtcConf ?? defaultRtcConfig;
}
