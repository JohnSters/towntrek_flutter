import 'package:intl/intl.dart';

import '../../models/event_detail_dto.dart';
import '../../models/event_dto.dart';

/// Presentation + time-derived helpers for [EventDto].
///
/// Kept out of the DTO so the model stays a plain data object (no `intl`,
/// no `DateTime.now()` business rules).
extension EventDisplay on EventDto {
  /// Start date used for cards and sorting (next occurrence when recurring).
  DateTime get effectiveListStartDate =>
      isRecurring && nextOccurrenceDate != null
          ? nextOccurrenceDate!
          : startDate;

  /// Get display date string
  String get displayDate {
    final listStart = effectiveListStartDate;
    if (endDate != null) {
      final spanDays = endDate!.difference(startDate).inDays;
      final listEnd = spanDays > 0 ? listStart.add(Duration(days: spanDays)) : endDate!;
      if (listStart.year != listEnd.year ||
          listStart.month != listEnd.month ||
          listStart.day != listEnd.day) {
        return '${listStart.month}/${listStart.day} - ${listEnd.month}/${listEnd.day}, ${listEnd.year}';
      }
    }
    return '${listStart.month}/${listStart.day}, ${listStart.year}';
  }

  /// Get display price string
  String get displayPrice {
    if (isFreeEvent) {
      return 'Free';
    }
    if (entryFeeAmount != null) {
      return '${entryFeeAmount!.toStringAsFixed(2)} ${entryFeeCurrency ?? 'ZAR'}';
    }
    return 'Price TBA';
  }

  /// Get the effective end date/time of the event
  DateTime get effectiveEndDateTime {
    final end = endDate ?? effectiveListStartDate;
    // If there's an end time, assume the event ends at that time.
    // Otherwise, assume it ends at the end of the day (23:59).
    final timeString = endTime;
    final parts = (timeString ?? '').split(':');
    final hour = parts.isNotEmpty && parts[0].isNotEmpty ? int.tryParse(parts[0]) : null;
    final minute = parts.length > 1 && parts[1].isNotEmpty ? int.tryParse(parts[1]) : null;

    return DateTime(
      end.year,
      end.month,
      end.day,
      hour ?? 23,
      minute ?? 59,
    );
  }

  /// Check if the event has finished
  bool get isFinished {
    return status == 'Completed' || DateTime.now().isAfter(effectiveEndDateTime);
  }

  /// Get the number of days since the event finished (negative if not finished)
  int get daysSinceFinished {
    if (!isFinished) return -1;
    return DateTime.now().difference(effectiveEndDateTime).inDays;
  }

  /// Check if the event should be hidden (finished more than 2 days ago)
  bool get shouldHide {
    return daysSinceFinished > 2;
  }

  /// Check if the event should be greyed out (finished within the last 24 hours)
  bool get shouldGreyOut {
    return daysSinceFinished >= 0 && daysSinceFinished <= 1;
  }
}

/// Presentation helpers for [EventDetailDto].
extension EventDetailDisplay on EventDetailDto {
  DateTime get effectiveListStartDate =>
      isRecurring && nextOccurrenceDate != null
          ? nextOccurrenceDate!
          : startDate;

  String get displayDate {
    final formatter = DateFormat('MMM d, yyyy');
    final listStart = effectiveListStartDate;
    if (endDate != null &&
        endDate!.year != 1 &&
        (listStart.year != endDate!.year ||
            listStart.month != endDate!.month ||
            listStart.day != endDate!.day)) {
      final spanDays = endDate!.difference(startDate).inDays;
      final listEnd = spanDays > 0 ? listStart.add(Duration(days: spanDays)) : endDate!;
      return '${formatter.format(listStart)} - ${formatter.format(listEnd)}';
    }
    return formatter.format(listStart);
  }

  String get displayPrice {
    if (isFreeEvent) {
      return 'Free';
    }
    if (entryFeeAmount != null) {
      return '${entryFeeAmount!.toStringAsFixed(2)} ${entryFeeCurrency ?? 'ZAR'}';
    }
    return 'Price TBA';
  }
}
