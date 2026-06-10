/// Shared JSON parsing helpers so DTO `fromJson` factories don't each re-declare
/// their own private int/double/date/enum coercion logic.
abstract final class JsonHelpers {
  /// Reads a value from dual-cased JSON keys (`camelCase` or `PascalCase`).
  static dynamic dualKey(Map<String, dynamic> json, String camel, String pascal) =>
      json[camel] ?? json[pascal];

  /// Reads an int from a loosely-typed [value], returning [fallback] when it
  /// cannot be parsed. Used for enum-index fields sent as int / num / string.
  static int enumInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  /// Reads an int from a dual-cased field (`camelCase` or `PascalCase`),
  /// defaulting to 0 when missing/unparseable.
  static int dualInt(Map<String, dynamic> json, String camel, String pascal) {
    final v = dualKey(json, camel, pascal);
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  /// Reads an int from [value], returning [fallback] when missing/unparseable.
  static int readInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  /// Reads a double from [value], returning [fallback] when missing/unparseable.
  static double readDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  /// Reads a bool from [value], accepting bool / 0|1 / "true"|"false".
  static bool readBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return fallback;
  }

  /// Reads a trimmed non-empty string from dual-cased keys, else null.
  static String? dualString(Map<String, dynamic> json, String camel, String pascal) {
    final v = dualKey(json, camel, pascal);
    if (v == null) return null;
    final normalized = v.toString().trim();
    if (normalized.isEmpty) return null;
    return normalized;
  }

  /// Parses a UTC [DateTime], returning null when missing/unparseable.
  static DateTime? utcDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();
    return DateTime.tryParse(value.toString())?.toUtc();
  }

  /// Reads a price/amount as a double, returning 0 when unparseable.
  static double price(dynamic value) => readDouble(value);
}
