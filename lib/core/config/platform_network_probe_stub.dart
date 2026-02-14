Future<bool> canConnect(
  String host,
  int port, {
  Duration timeout = const Duration(milliseconds: 750),
}) async {
  // Fallback for unexpected platforms; treat as unreachable.
  return false;
}

