/// Display-only formatting for operating-hours time strings from the API.
/// Accepts values like `09:00`, `09:00:00`, `09:00:00.0000000` and returns
/// `HH:mm` (24-hour, zero-padded). Does not change parsing used for open/closed logic.
String formatOperatingHoursTimeForDisplay(String raw) {
  final main = raw.trim().split('.').first;
  final parts = main.split(':');
  if (parts.length < 2) return raw.trim();
  final hh = (int.tryParse(parts[0].trim()) ?? 0).toString().padLeft(2, '0');
  final mm = (int.tryParse(parts[1].trim()) ?? 0).toString().padLeft(2, '0');
  return '$hh:$mm';
}
