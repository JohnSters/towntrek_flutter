import 'dart:io';

Future<bool> canConnect(
  String host,
  int port, {
  Duration timeout = const Duration(milliseconds: 750),
}) async {
  try {
    final socket = await Socket.connect(host, port, timeout: timeout);
    socket.destroy();
    return true;
  } catch (_) {
    return false;
  }
}

