int calculateLeaveWorkdays({
  required DateTime startDate,
  required DateTime endDate,
  required Set<DateTime> holidays,
}) {
  final start = _dateOnly(startDate);
  final end = _dateOnly(endDate);
  if (end.isBefore(start)) return 0;

  var total = 0;
  var current = start;
  while (!current.isAfter(end)) {
    if (!_isWeekend(current) && !holidays.contains(current)) {
      total++;
    }
    current = current.add(const Duration(days: 1));
  }

  return total;
}

DateTime normalizeLeaveDate(DateTime date) {
  return _dateOnly(date);
}

bool _isWeekend(DateTime date) {
  return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
