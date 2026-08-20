/// Formats a [DateTime] as a local-calendar-day key 'yyyy-MM-dd', ignoring
/// time-of-day. Used wherever data is keyed by day (emotions, exercise
/// completions) so the format stays consistent across features.
String dateKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
