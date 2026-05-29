import '../../models/models.dart';

sealed class LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardSuccess extends LeaderboardState {
  LeaderboardSuccess(this.data);

  final LeaderboardResponseDto data;
}

class LeaderboardError extends LeaderboardState {
  LeaderboardError(this.message);

  final String message;
}
