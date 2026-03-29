import '../../utils/business_utils.dart';
import '../../utils/service_utils.dart';
import '../../../models/models.dart';
import 'detail_hours_grid.dart';

const _orderedDays = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

List<DetailHoursDayRow> detailHoursFromBusiness(
  List<OperatingHourDto> operatingHours,
) {
  final today = _orderedDays[DateTime.now().weekday - 1];

  final normalized = operatingHours
      .where((hour) => !hour.isSpecialHours)
      .map(
        (hour) => MapEntry(
          BusinessUtils.formatDayOfWeek(hour.dayOfWeek),
          hour,
        ),
      )
      .toList();

  return _orderedDays.map((day) {
    OperatingHourDto? match;
    for (final entry in normalized) {
      if (entry.key == day) {
        match = entry.value;
        break;
      }
    }

    final isOpen = match?.isOpen == true &&
        match?.openTime != null &&
        match?.closeTime != null;
    final timeLabel = isOpen
        ? '${BusinessUtils.formatTime(match!.openTime!)} - ${BusinessUtils.formatTime(match.closeTime!)}'
        : 'Closed';

    return DetailHoursDayRow(
      dayShortLabel: day.substring(0, 3),
      timeLabel: timeLabel,
      isToday: day == today,
    );
  }).toList();
}

List<DetailHoursDayRow> detailHoursFromService(
  List<ServiceOperatingHourDto> operatingHours,
) {
  final today = _orderedDays[DateTime.now().weekday - 1];

  final byDay = <String, ServiceOperatingHourDto>{
    for (final hour in operatingHours)
      ServiceUtils.formatDayOfWeek(hour.dayOfWeek): hour,
  };

  return _orderedDays.map((day) {
    final match = byDay[day];
    final isAvailable = match?.isAvailable == true &&
        match?.startTime != null &&
        match?.endTime != null;
    final timeLabel = isAvailable
        ? '${ServiceUtils.formatTime24(match!.startTime!)} - ${ServiceUtils.formatTime24(match.endTime!)}'
        : 'Closed';

    return DetailHoursDayRow(
      dayShortLabel: day.substring(0, 3),
      timeLabel: timeLabel,
      isToday: day == today,
    );
  }).toList();
}

List<DetailHoursDayRow> detailHoursFromCreativeSpace(
  List<CreativeSpaceOperatingHourDto> hours,
) {
  final today = _orderedDays[DateTime.now().weekday - 1];

  final byDay = <String, CreativeSpaceOperatingHourDto>{};
  for (final hour in hours) {
    final key = BusinessUtils.formatDayOfWeek(hour.dayOfWeek);
    byDay[key] = hour;
  }

  return _orderedDays.map((day) {
    final match = byDay[day];
    String timeLabel = 'Closed';
    if (match != null &&
        match.isOpen &&
        match.openTime != null &&
        match.closeTime != null &&
        match.openTime!.trim().isNotEmpty &&
        match.closeTime!.trim().isNotEmpty) {
      timeLabel = '${match.openTime!.trim()} - ${match.closeTime!.trim()}';
    }

    return DetailHoursDayRow(
      dayShortLabel: day.substring(0, 3),
      timeLabel: timeLabel,
      isToday: day == today,
    );
  }).toList();
}
