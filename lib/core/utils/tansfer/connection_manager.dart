import 'package:get_it/get_it.dart';

abstract class ConnectionManager {
  final void Function() onConnected;
  final void Function() onDisconnected;
  final void Function() onDone;
  final void Function(String id, int size) onTransferFile;
  final void Function()? onPairing;

  new({
    required this.onConnected,
    required this.onDisconnected,
    required this.onDone,
    required this.onTransferFile,
    this.onPairing,
  });
  Future<void> closeWebRTC({bool disconnect = false, bool fromMessage = false});
  Future<void> connect();

  static Future<T> initConnection<T extends ConnectionManager>(
    T manager,
  ) async {
    // await close();
    try {
      await GetIt.I.unregister<ConnectionManager>();
    } catch (_) {}
    GetIt.I.registerSingleton<ConnectionManager>(manager);
    await manager.connect();
    return manager;
  }

  static T? current<T extends ConnectionManager>() {
    try {
      return GetIt.I<ConnectionManager>() as T;
    } catch (_) {
      return null;
    }
  }

  static Future<void> close() async {
    try {
      final manager = GetIt.I<ConnectionManager>();
      await manager.closeWebRTC(disconnect: true, fromMessage: false);
      await GetIt.I.unregister<ConnectionManager>();
    } catch (_) {}
  }
}
