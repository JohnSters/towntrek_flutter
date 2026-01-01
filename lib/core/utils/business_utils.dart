import 'package:intl/intl.dart';
import '../../models/models.dart';

class BusinessUtils {
  static bool isBusinessCurrentlyOpen(List<OperatingHourDto> operatingHours) {
    final now = DateTime.now();
    final currentDay = DateFormat('EEEE').format(now); // Monday, Tuesday, etc.
    final nowMinutes = now.hour * 60 + now.minute;

    // Find today's operating hours
    final todayHours = operatingHours.firstWhere(
      (hour) => formatDayOfWeek(hour.dayOfWeek) == currentDay && !hour.isSpecialHours,
      orElse: () => OperatingHourDto(
        dayOfWeek: currentDay,
        isOpen: false,
        isSpecialHours: false,
      ),
    );

    if (!todayHours.isOpen || todayHours.openTime == null || todayHours.closeTime == null) {
      return false;
    }

    final openMinutes = _parseApiTimeToMinutes(todayHours.openTime);
    final closeMinutes = _parseApiTimeToMinutes(todayHours.closeTime);
    if (openMinutes == null || closeMinutes == null) return false;

    // Normal case: same-day range
    if (closeMinutes >= openMinutes) {
      return nowMinutes >= openMinutes && nowMinutes <= closeMinutes;
    }

    // Overnight range (e.g. 20:00 - 02:00)
    return nowMinutes >= openMinutes || nowMinutes <= closeMinutes;
  }

  static String formatDayOfWeek(String dayOfWeek) {
    // Handle numeric day values (1-7) from API
    final dayNames = [
      '', // 0-indexed, not used
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    // If it's a numeric string, convert to day name
    final dayNumber = int.tryParse(dayOfWeek);
    if (dayNumber == 0) {
      // Backend (C#) uses 0=Sunday..6=Saturday
      return 'Sunday';
    }
    if (dayNumber != null && dayNumber >= 1 && dayNumber <= 7) {
      return dayNames[dayNumber];
    }

    // Fallback: if it's already a full day name, just capitalize first letter
    if (dayOfWeek.length > 3) {
      return dayOfWeek.substring(0, 1).toUpperCase() + dayOfWeek.substring(1).toLowerCase();
    }

    // Unknown format, return as-is
    return dayOfWeek;
  }

  static String formatTime(String time) {
    // Assuming time is in HH:mm format, convert to 12-hour format
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts[1];

      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  static String formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  static String getClosingTime(List<OperatingHourDto> operatingHours) {
    try {
      final now = DateTime.now();
      final currentDay = formatDayOfWeek(DateFormat('EEEE').format(now));
      
      final todayHours = operatingHours.firstWhere(
        (h) => formatDayOfWeek(h.dayOfWeek) == currentDay && !h.isSpecialHours,
        orElse: () => OperatingHourDto(dayOfWeek: '', isOpen: false, isSpecialHours: false),
      );
      
      if (todayHours.isOpen && todayHours.closeTime != null) {
        return 'Closes at ${formatTime(todayHours.closeTime!)}';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static List<SpecialOperatingHourDto> getUpcomingSpecialOperatingHours(List<SpecialOperatingHourDto> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcoming = all
        .where((s) {
          final d = DateTime(s.date.year, s.date.month, s.date.day);
          return d.isAtSameMomentAs(today) || d.isAfter(today);
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Keep it readable on mobile; show next 3.
    return upcoming.take(3).toList();
  }

  static bool hasSocialMedia(BusinessDetailDto business) {
    return business.facebook != null ||
           business.instagram != null ||
           business.whatsApp != null;
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
}

