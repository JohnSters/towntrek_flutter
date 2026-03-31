import 'package:intl/intl.dart';

import '../../models/models.dart';
import 'operating_hours_display_format.dart';
import 'operating_hours_open_calc.dart';

class ServiceUtils {
  static bool isServiceCurrentlyOpen(List<ServiceOperatingHourDto> operatingHours) {
    return OperatingHoursOpenCalc.serviceIsOpenNow(operatingHours);
  }

  static String getClosingTimeText(List<ServiceOperatingHourDto> operatingHours) {
    try {
      final now = operatingHoursSouthAfricaLocalNow();
      final dow = csharpDayOfWeekFromDartWeekday(now.weekday);

      final todayHours = operatingHours.firstWhere(
        (h) => h.dayOfWeek == dow,
        orElse: () => const ServiceOperatingHourDto(dayOfWeek: 0, isAvailable: false),
      );

      if (todayHours.isAvailable && todayHours.endTime != null) {
        return 'Closes at ${formatOperatingHoursTimeForDisplay(todayHours.endTime!)}';
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  static String formatDayOfWeek(int dayOfWeek) {
    const csharpNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    var idx = dayOfWeek;
    if (idx < 0 || idx > 6) return 'Day $dayOfWeek';
    return csharpNames[idx];
  }

  static String todayName() => DateFormat('EEEE').format(DateTime.now());
}

