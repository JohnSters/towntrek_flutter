class TownRequestSubmitResult {
  const TownRequestSubmitResult({
    required this.outcome,
    required this.message,
    this.requestId,
    this.townId,
    this.townName,
  });

  final String outcome;
  final String message;
  final int? requestId;
  final int? townId;
  final String? townName;

  bool get isAlreadyListed => outcome == 'alreadyListed';
  bool get isSuccess =>
      outcome == 'created' ||
      outcome == 'alreadyRequested' ||
      outcome == 'ignored' ||
      isAlreadyListed;

  factory TownRequestSubmitResult.fromJson(Map<String, dynamic> json) {
    return TownRequestSubmitResult(
      outcome: json['outcome'] as String? ?? '',
      message: json['message'] as String? ?? '',
      requestId: (json['requestId'] as num?)?.toInt(),
      townId: (json['townId'] as num?)?.toInt(),
      townName: json['townName'] as String?,
    );
  }
}
