import 'package:intl/intl.dart';

import '../../models/models.dart';

class ServiceUtils {
  static bool isServiceCurrentlyOpen(List<ServiceOperatingHourDto> operatingHours) {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final today = now.weekday; // 1=Mon..7=Sun

    final todayHours = operatingHours.firstWhere(
      (h) => _normalizeDayOfWeek(h.dayOfWeek) == today,
      orElse: () => const ServiceOperatingHourDto(
        dayOfWeek: 1,
        isAvailable: false,
      ),
    );

    if (!todayHours.isAvailable || todayHours.startTime == null || todayHours.endTime == null) {
      return false;
    }

    final openMinutes = _parseApiTimeToMinutes(todayHours.startTime);
    final closeMinutes = _parseApiTimeToMinutes(todayHours.endTime);
    if (openMinutes == null || closeMinutes == null) return false;

    if (closeMinutes >= openMinutes) {
      return nowMinutes >= openMinutes && nowMinutes <= closeMinutes;
    }

    // Overnight range (e.g. 20:00 - 02:00)
    return nowMinutes >= openMinutes || nowMinutes <= closeMinutes;
  }

  static String getClosingTimeText(List<ServiceOperatingHourDto> operatingHours) {
    try {
      final now = DateTime.now();
      final today = now.weekday;

      final todayHours = operatingHours.firstWhere(
        (h) => _normalizeDayOfWeek(h.dayOfWeek) == today,
        orElse: () => const ServiceOperatingHourDto(dayOfWeek: 1, isAvailable: false),
      );

      if (todayHours.isAvailable && todayHours.endTime != null) {
        return 'Closes at ${formatTime24(todayHours.endTime!)}';
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  static String formatDayOfWeek(int dayOfWeek) {
    // 1=Mon..7=Sun
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final normalized = _normalizeDayOfWeek(dayOfWeek);
    if (normalized < 1 || normalized > 7) return 'Day $dayOfWeek';
    return days[normalized - 1];
  }

  static String formatTime24(String time) {
    final normalized = _normalizeApiTime(time);
    final parts = normalized.split(':');
    if (parts.length < 2) return time;
    final hh = (int.tryParse(parts[0]) ?? 0).toString().padLeft(2, '0');
    final mm = (int.tryParse(parts[1]) ?? 0).toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static int _normalizeDayOfWeek(int dayOfWeek) {
    // API may use:
    // - C# DayOfWeek: 0=Sunday..6=Saturday
    // - 1..7 where 1=Monday..7=Sunday
    if (dayOfWeek == 0) return DateTime.sunday; // 7
    if (dayOfWeek >= 1 && dayOfWeek <= 7) return dayOfWeek;
    if (dayOfWeek >= 1 && dayOfWeek <= 6) return dayOfWeek; // best-effort
    return dayOfWeek;
  }

  static int? _parseApiTimeToMinutes(String? time) {
    if (time == null) return null;
    final normalized = _normalizeApiTime(time);
    final parts = normalized.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  static String _normalizeApiTime(String time) {
    // Accepts: "09:00", "09:00:00", "09:00:00.0000000" and normalizes to "HH:mm"
    final main = time.trim().split('.').first;
    final parts = main.split(':');
    if (parts.length < 2) return time.trim();
    final hh = (int.tryParse(parts[0]) ?? 0).toString().padLeft(2, '0');
    final mm = (int.tryParse(parts[1]) ?? 0).toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static String todayName() => DateFormat('EEEE').format(DateTime.now());
}

