import '../../models/models.dart';

sealed class ProgressHistoryState {}

class ProgressHistoryInitial extends ProgressHistoryState {}

class ProgressHistoryLoading extends ProgressHistoryState {}

class ProgressHistorySuccess extends ProgressHistoryState {
  ProgressHistorySuccess(this.page, this.pageNumber);

  final XpHistoryPageDto page;
  final int pageNumber;
}

class ProgressHistoryError extends ProgressHistoryState {
  ProgressHistoryError(this.message);

  final String message;
}
