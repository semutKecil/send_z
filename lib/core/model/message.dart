// enum MessageType {
//   filesMeta,
//   readyReceive,
//   startSend,
//   receiving,
//   finishSend,
//   nextFiles,
//   finished,
// }
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:send_z/core/model/file_meta.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
sealed class RtcMessage with _$RtcMessage {
  const factory RtcMessage.filesMeta({required List<FileMeta> files}) =
      RtcMessageFilesMeta;
  const factory RtcMessage.readyReceive({required String id}) =
      RtcMessageReadyReceive;
  const factory RtcMessage.bye({@Default(false) bool disconnect}) =
      RtcMessageBye;

  factory RtcMessage.fromJson(Map<String, dynamic> json) =>
      _$RtcMessageFromJson(json);
}
