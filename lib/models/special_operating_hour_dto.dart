/// Date-based special operating hours override for a business (e.g. holiday closures)
class SpecialOperatingHourDto {
  final DateTime date;
  final String? openTime; // "HH:mm"
  final String? closeTime; // "HH:mm"
  final bool isClosed;
  final String? reason;
  final String? notes;

  const SpecialOperatingHourDto({
    required this.date,
    this.openTime,
    this.closeTime,
    required this.isClosed,
    this.reason,
    this.notes,
  });

  factory SpecialOperatingHourDto.fromJson(Map<String, dynamic> json) {
    final parsedDate = _readSpecialDate(json['date'] ?? json['Date']);
    if (parsedDate == null) {
      throw FormatException('SpecialOperatingHourDto: missing or invalid date');
    }

    return SpecialOperatingHourDto(
      date: parsedDate,
      openTime: (json['openTime'] ?? json['OpenTime']) as String?,
      closeTime: (json['closeTime'] ?? json['CloseTime']) as String?,
      // APIs / DB drivers sometimes send 0/1; a strict `as bool?` throws and drops the whole list.
      isClosed: _readJsonBool(json['isClosed'] ?? json['IsClosed']),
      reason: (json['reason'] ?? json['Reason']) as String?,
      notes: (json['notes'] ?? json['Notes']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
      'reason': reason,
      'notes': notes,
    };
  }
}

bool _readJsonBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }
  return false;
}

DateTime? _readSpecialDate(dynamic v) {
  if (v == null) return null;
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    final full = DateTime.tryParse(s);
    if (full != null) return full;
    if (s.length >= 10) {
      return DateTime.tryParse(s.substring(0, 10));
    }
    return null;
  }
  return null;
}

Map<String, dynamic> _jsonObject(dynamic e) {
  if (e is Map<String, dynamic>) return e;
  if (e is Map) return Map<String, dynamic>.from(e);
  throw const FormatException('expected JSON object');
}

/// [raw] null => null (JSON key absent). Otherwise parses each element; skips invalid rows.
List<SpecialOperatingHourDto>? specialOperatingHoursListFromJson(dynamic raw) {
  if (raw == null) return null;
  if (raw is! List) return const [];
  final out = <SpecialOperatingHourDto>[];
  for (final e in raw) {
    try {
      out.add(SpecialOperatingHourDto.fromJson(_jsonObject(e)));
    } catch (_) {}
  }
  return out;
}

