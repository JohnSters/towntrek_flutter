Future<bool> canConnect(
  String host,
  int port, {
  Duration timeout = const Duration(milliseconds: 750),
}) async {
  // Flutter Web can't use `dart:io` sockets, and doing a fetch probe is unreliable due to CORS.
  // Returning false keeps base URL selection deterministic for web builds.
  return false;
}

