/// One idempotent XP award, keyed by (activityType, sourceId, date).
/// Re-awarding the same key is a no-op — see XpLedgerRepository.record.
class XpEvent {
  const XpEvent({
    required this.activityType,
    required this.sourceId,
    required this.date,
    required this.amount,
  });

  final String activityType;
  final String sourceId;

  /// yyyy-MM-dd, see core/utils/date_key.dart.
  final String date;
  final int amount;

  String get dedupeKey => '$activityType|$sourceId|$date';

  Map<String, dynamic> toJson() => {
    'activityType': activityType,
    'sourceId': sourceId,
    'date': date,
    'amount': amount,
  };

  static XpEvent? tryParse(dynamic json) {
    if (json is! Map) return null;
    final activityType = json['activityType'];
    final sourceId = json['sourceId'];
    final date = json['date'];
    final amount = json['amount'];
    if (activityType is! String || activityType.isEmpty) return null;
    if (sourceId is! String || sourceId.isEmpty) return null;
    if (date is! String || date.isEmpty) return null;
    if (amount is! int) return null;
    return XpEvent(
      activityType: activityType,
      sourceId: sourceId,
      date: date,
      amount: amount,
    );
  }
}
