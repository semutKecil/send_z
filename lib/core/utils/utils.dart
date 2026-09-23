import 'dart:convert';
import 'dart:math';

import 'package:pro_mpack/pro_mpack.dart';
import 'package:send_z/core/model/connection_code.dart';
import 'package:send_z/core/model/file_meta.dart';
import 'package:send_z/core/model/message.dart';

extension IntExtension on int {
  String toByteSize({int decimals = 2}) {
    if (this <= 0) return " 0B";

    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB"];
    // Calculate the correct index in the suffixes array
    var i = (log(this) / log(1024)).floor();

    // Normalize the bytes value into the selected unit size
    var size = this / pow(1024, i);

    return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
  }
}

class MessagePackager {
  static final MessagePackager _instance = MessagePackager._internal();

  factory MessagePackager() {
    return _instance;
  }

  MessagePackager._internal();

  final mp = MessagePack(
    extensions: (config) {
      config.register<ConnectionCode>(
        extId: 1,
        polymorphic: true,
        encoder: (data, packer) => packer.packMap(data.toJson()),
        decoder: (unpacker, length) {
          final map = unpacker.unpackMapOf<String, dynamic>();
          final rtcConf = map['rtcConf'];
          if (rtcConf != null) {
            map['rtcConf'] = Map<String, dynamic>.from(rtcConf);
          }
          return ConnectionCode.fromJson(map);
        },
      );

      config.register<Message>(
        extId: 2,
        polymorphic: true,
        encoder: (data, packer) => packer.packMap(data.toJson()),
        decoder: (unpacker, length) {
          final map = unpacker.unpackMapOf<String, dynamic>();
          final List<dynamic>? files = map['files'];
          if (files != null) {
            map['files'] = files.map((e) {
              return e.toJson();
            }).toList();
          }

          return Message.fromJson(map);
        },
      );

      config.register<FileMeta>(
        extId: 3,
        polymorphic: true,
        encoder: (data, packer) => packer.packMap(data.toJson()),
        decoder: (unpacker, length) {
          return FileMeta.fromJson(unpacker.unpackMapOf<String, dynamic>());
        },
      );
    },
  );

  String encode(dynamic data) {
    final byte = mp.encode(data);
    return base64Url.encode(byte);
  }

  dynamic decode(String data) {
    return mp.decode(base64Url.decode(data));
  }
}
