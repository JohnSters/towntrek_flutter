import 'package:intl/intl.dart';
import '../../models/models.dart';
import 'operating_hours_display_format.dart';
import 'operating_hours_open_calc.dart';

class BusinessUtils {
  /// Uses [OperatingHoursOpenCalc] (SA local time, same rules as server).
  static bool isBusinessCurrentlyOpen(
    List<OperatingHourDto> operatingHours, {
    List<SpecialOperatingHourDto> specialOperatingHours = const [],
  }) {
    return OperatingHoursOpenCalc.businessIsOpenNow(
      operatingHours,
      specialOperatingHours,
    );
  }

  /// List/search cards: if the API sends weekly or special hours, recompute open/closed
  /// on-device (same rules as details) so specials cannot disagree with [isOpenNow].
  static bool isBusinessOpenForListingCard(BusinessDto business) {
    if (business.operatingHours.isEmpty && business.specialOperatingHours.isEmpty) {
      return business.isOpenNow ?? false;
    }
    return OperatingHoursOpenCalc.businessIsOpenNow(
      business.operatingHours,
      business.specialOperatingHours,
    );
  }

  /// Calendar label for grids and copy (Monday … Sunday).
  static String formatDayOfWeek(String dayOfWeek) {
    return canonicalEnglishDayNameFromApiDayField(dayOfWeek);
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
      final now = operatingHoursSouthAfricaLocalNow();
      const ordered = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final todayName = ordered[now.weekday - 1];

      final todayHours = operatingHours.firstWhere(
        (h) =>
            formatDayOfWeek(h.dayOfWeek) == todayName && !h.isSpecialHours,
        orElse: () => const OperatingHourDto(
          dayOfWeek: '',
          isOpen: false,
          isSpecialHours: false,
        ),
      );

      if (todayHours.isOpen && todayHours.closeTime != null) {
        return 'Closes at ${formatOperatingHoursTimeForDisplay(todayHours.closeTime!)}';
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

}

