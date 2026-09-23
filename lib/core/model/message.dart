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
sealed class Message with _$Message {
  const factory Message.filesMeta({required List<FileMeta> files}) =
      MessageFilesMeta;
  const factory Message.readyReceive({required String id}) =
      MessageReadyReceive;
  const factory Message.bye({@Default(false) bool disconnect}) = MessageBye;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
