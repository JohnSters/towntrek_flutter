import '../../models/models.dart';

// Open-status audit (mobile):
// - **Business**: weekly hours + `specialOperatingHours` (matches `BusinessHoursCalculator` + SAST).
//   List payloads include hours; cards use [BusinessUtils.isBusinessOpenForListingCard] when hours are present.
// - **Service**: weekly slots only; no special-hours model — `ServiceHoursOpenCalculator` on API.
// - **Creative space**: weekly hours only; API `isOpenNow` from `CreativeSpaceOpenStatusHelper` — use that on cards/detail, not a divergent client path.

/// South Africa standard time (SAST = UTC+2, no DST) — matches server
/// [BusinessHoursCalculator] / [CreativeSpaceOpenStatusHelper] defaults.
///
/// Returns a **UTC-flagged** [DateTime] whose **components** (y, m, d, h, min, …)
/// are the civil wall clock in South Africa for the current instant.
///
/// Important: `DateTime.now().toUtc().add(Duration(hours: 2))` is **wrong** — it
/// moves the instant forward by two hours instead of shifting UTC clock fields
/// by +2 for the same moment.
DateTime operatingHoursSouthAfricaLocalNow() {
  final u = DateTime.now().toUtc();
  return DateTime.utc(
    u.year,
    u.month,
    u.day,
    u.hour,
    u.minute,
    u.second,
    u.millisecond,
    u.microsecond,
  ).add(const Duration(hours: 2));
}

/// Calendar y/m/d for a special-hours row from the API, aligned with server
/// [BusinessHoursCalculator] (`s.Date.Date` vs SA `localNow.Date`).
///
/// When the API sends a [DateTime.isUtc] instant (e.g. `…T22:00:00Z` = midnight
/// SAST on the next calendar day), using raw `.year`/`.month`/`.day` misses the
/// override and listing cards show "Open" while details show "Closed".
(int, int, int) businessSpecialCalendarYmd(DateTime apiDate) {
  if (apiDate.isUtc) {
    final x = apiDate.add(const Duration(hours: 2));
    return (x.year, x.month, x.day);
  }
  return (apiDate.year, apiDate.month, apiDate.day);
}

/// C# [System.DayOfWeek]: 0 = Sunday … 6 = Saturday.
///
/// Dart [DateTime.weekday]: 1 = Monday … 7 = Sunday — so only Sunday must be
/// remapped (7 → 0). Monday–Saturday already match C# (1–6). Do not map Sunday
/// to 6; that would be wrong for this codebase.
int csharpDayOfWeekFromDartWeekday(int dartWeekday) {
  return dartWeekday == DateTime.sunday ? 0 : dartWeekday;
}

int? parseTimeStringToMinutesSinceMidnight(String? raw) {
  if (raw == null) return null;
  final main = raw.trim().split('.').first;
  final parts = main.split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0].trim());
  final m = int.tryParse(parts[1].trim());
  if (h == null || m == null) return null;
  return h * 60 + m;
}

/// Normalises business/creative API `dayOfWeek` (int as string, full name, or 3-letter) to C# day index 0–6.
int? csharpDayOfWeekFromApiDayField(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final n = int.tryParse(s);
  if (n != null) {
    if (n == 0) return 0;
    if (n >= 1 && n <= 6) return n;
    if (n == 7) return 0;
  }
  final lower = s.toLowerCase();
  const full = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];
  const short = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
  for (var i = 0; i < full.length; i++) {
    if (lower == full[i]) return i;
  }
  for (var i = 0; i < short.length; i++) {
    if (lower == short[i]) return i;
  }
  return null;
}

/// Canonical calendar name for grids: Monday … Sunday (matches [detail_hours_mappers]).
String canonicalEnglishDayNameFromApiDayField(String raw) {
  final idx = csharpDayOfWeekFromApiDayField(raw);
  if (idx == null) return raw;
  const names = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  return names[idx];
}

class _WeeklyRow {
  final int csharpDayOfWeek;
  final bool active;
  final int? openMinutes;
  final int? closeMinutes;

  const _WeeklyRow({
    required this.csharpDayOfWeek,
    required this.active,
    this.openMinutes,
    this.closeMinutes,
  });
}

class _SpecialDay {
  final DateTime dateLocal;
  final bool isClosed;
  final int? openMinutes;
  final int? closeMinutes;

  const _SpecialDay({
    required this.dateLocal,
    required this.isClosed,
    this.openMinutes,
    this.closeMinutes,
  });
}

bool _isOpenInRange({
  required DateTime localWallClock,
  required DateTime baseDateLocal,
  required int openMinutes,
  required int closeMinutes,
}) {
  final openDt = baseDateLocal.add(Duration(minutes: openMinutes));
  var closeDt = baseDateLocal.add(Duration(minutes: closeMinutes));
  if (!closeDt.isAfter(openDt)) {
    closeDt = closeDt.add(const Duration(days: 1));
  }
  return !localWallClock.isBefore(openDt) && localWallClock.isBefore(closeDt);
}

/// Single implementation of “open now” for weekly + optional special overrides.
/// Mirrors server [BusinessHoursCalculator] (SA local time, special precedence,
/// overnight spill from previous day, half-open interval at close).
class OperatingHoursOpenCalc {
  OperatingHoursOpenCalc._();

  static List<_WeeklyRow> _weeklyRowsFromBusiness(List<OperatingHourDto> hours) {
    final out = <_WeeklyRow>[];
    for (final h in hours) {
      if (h.isSpecialHours) continue;
      final dow = csharpDayOfWeekFromApiDayField(h.dayOfWeek);
      if (dow == null) continue;
      final o = parseTimeStringToMinutesSinceMidnight(h.openTime);
      final c = parseTimeStringToMinutesSinceMidnight(h.closeTime);
      out.add(
        _WeeklyRow(
          csharpDayOfWeek: dow,
          active: h.isOpen,
          openMinutes: o,
          closeMinutes: c,
        ),
      );
    }
    return out;
  }

  static List<_WeeklyRow> _weeklyRowsFromService(List<ServiceOperatingHourDto> hours) {
    final out = <_WeeklyRow>[];
    for (final h in hours) {
      final dow = _normalizeServiceCSharpDay(h.dayOfWeek);
      final o = parseTimeStringToMinutesSinceMidnight(h.startTime);
      final c = parseTimeStringToMinutesSinceMidnight(h.endTime);
      out.add(
        _WeeklyRow(
          csharpDayOfWeek: dow,
          active: h.isAvailable,
          openMinutes: o,
          closeMinutes: c,
        ),
      );
    }
    return out;
  }

  /// Service API uses the same 0 = Sunday … 6 = Saturday convention as businesses.
  static int _normalizeServiceCSharpDay(int dayOfWeek) {
    if (dayOfWeek >= 0 && dayOfWeek <= 6) return dayOfWeek;
    return dayOfWeek;
  }

  static List<_WeeklyRow> _weeklyRowsFromCreativeSpace(
    List<CreativeSpaceOperatingHourDto> hours,
  ) {
    final out = <_WeeklyRow>[];
    for (final h in hours) {
      if (h.isSpecialHours) continue;
      final dow = csharpDayOfWeekFromApiDayField(h.dayOfWeek);
      if (dow == null) continue;
      final o = parseTimeStringToMinutesSinceMidnight(h.openTime);
      final c = parseTimeStringToMinutesSinceMidnight(h.closeTime);
      out.add(
        _WeeklyRow(
          csharpDayOfWeek: dow,
          active: h.isOpen,
          openMinutes: o,
          closeMinutes: c,
        ),
      );
    }
    return out;
  }

  static List<_SpecialDay> _specialDaysFromBusiness(
    List<SpecialOperatingHourDto> specials,
  ) {
    final out = <_SpecialDay>[];
    for (final s in specials) {
      final ymd = businessSpecialCalendarYmd(s.date);
      final d = DateTime.utc(ymd.$1, ymd.$2, ymd.$3);
      if (s.isClosed) {
        out.add(_SpecialDay(dateLocal: d, isClosed: true));
        continue;
      }
      final o = parseTimeStringToMinutesSinceMidnight(s.openTime);
      final c = parseTimeStringToMinutesSinceMidnight(s.closeTime);
      out.add(
        _SpecialDay(
          dateLocal: d,
          isClosed: false,
          openMinutes: o,
          closeMinutes: c,
        ),
      );
    }
    return out;
  }

  static _WeeklyRow? _rowForCSharpDay(List<_WeeklyRow> rows, int csharpDow) {
    for (final r in rows) {
      if (r.csharpDayOfWeek == csharpDow) return r;
    }
    return null;
  }

  /// Special hours for [localDate] only: last matching entry wins (approximates server order by id).
  static _SpecialDay? _specialForDate(List<_SpecialDay> specials, DateTime localDate) {
    final key = DateTime(localDate.year, localDate.month, localDate.day);
    _SpecialDay? last;
    for (final s in specials) {
      if (s.dateLocal.year == key.year &&
          s.dateLocal.month == key.month &&
          s.dateLocal.day == key.day) {
        last = s;
      }
    }
    return last;
  }

  static bool _isOpenNowCore({
    required List<_WeeklyRow> weekly,
    List<_SpecialDay> special = const [],
    DateTime? saLocalNow,
  }) {
    final now = saLocalNow ?? operatingHoursSouthAfricaLocalNow();
    // Same frame as [now]: SA calendar date as UTC-marked midnight (not device-local midnight).
    final localDate = DateTime.utc(now.year, now.month, now.day);
    final todaySpecial = _specialForDate(special, localDate);

    if (todaySpecial != null) {
      if (todaySpecial.isClosed) return false;
      final o = todaySpecial.openMinutes;
      final c = todaySpecial.closeMinutes;
      if (o == null || c == null) return false;
      return _isOpenInRange(
        localWallClock: now,
        baseDateLocal: localDate,
        openMinutes: o,
        closeMinutes: c,
      );
    }

    final todayCsharp = csharpDayOfWeekFromDartWeekday(now.weekday);
    final todayRow = _rowForCSharpDay(weekly, todayCsharp);
    if (_openFromWeeklyRow(now, localDate, todayRow)) return true;

    final yesterday = localDate.subtract(const Duration(days: 1));
    final yesterdayCsharp = csharpDayOfWeekFromDartWeekday(
      yesterday.weekday,
    );
    final yRow = _rowForCSharpDay(weekly, yesterdayCsharp);
    return _openFromWeeklyRow(now, yesterday, yRow);
  }

  static bool _openFromWeeklyRow(
    DateTime localWallClock,
    DateTime baseDateLocal,
    _WeeklyRow? row,
  ) {
    if (row == null || !row.active) return false;
    final o = row.openMinutes;
    final c = row.closeMinutes;
    if (o == null || c == null) return false;
    return _isOpenInRange(
      localWallClock: localWallClock,
      baseDateLocal: baseDateLocal,
      openMinutes: o,
      closeMinutes: c,
    );
  }

  /// Last API special-hours row for **today’s SAST calendar date** when it marks
  /// the venue closed for the whole day. Same “last matching row wins” rule as
  /// [_specialForDate] / server `OrderByDescending(Id)`.
  static SpecialOperatingHourDto? todaysClosedSpecialEntry(
    List<SpecialOperatingHourDto> specials,
  ) {
    if (specials.isEmpty) return null;
    final n = operatingHoursSouthAfricaLocalNow();
    final y = n.year;
    final m = n.month;
    final d = n.day;
    SpecialOperatingHourDto? last;
    for (final s in specials) {
      final ymd = businessSpecialCalendarYmd(s.date);
      if (ymd.$1 == y && ymd.$2 == m && ymd.$3 == d) {
        last = s;
      }
    }
    if (last != null && last.isClosed) return last;
    return null;
  }

  static bool businessIsOpenNow(
    List<OperatingHourDto> weekly,
    List<SpecialOperatingHourDto> special,
  ) {
    if (weekly.isEmpty && special.isEmpty) return false;
    return _isOpenNowCore(
      weekly: _weeklyRowsFromBusiness(weekly),
      special: _specialDaysFromBusiness(special),
    );
  }

  static bool serviceIsOpenNow(List<ServiceOperatingHourDto> weekly) {
    if (weekly.isEmpty) return false;
    return _isOpenNowCore(weekly: _weeklyRowsFromService(weekly));
  }

  static bool creativeSpaceIsOpenNow(List<CreativeSpaceOperatingHourDto> weekly) {
    if (weekly.isEmpty) return false;
    return _isOpenNowCore(weekly: _weeklyRowsFromCreativeSpace(weekly));
  }
}
