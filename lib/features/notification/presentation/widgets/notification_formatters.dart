String formatNotificationDate(DateTime date) {
  final now = DateTime.now();
  final isToday =
      now.year == date.year && now.month == date.month && now.day == date.day;
  if (isToday) return _formatTime(date);
  return '${date.day} ${_shortMonths[date.month - 1]}';
}

String formatNotificationDateTime(DateTime date) {
  return '${date.day} ${_shortMonths[date.month - 1]} ${date.year} ${_formatTime(date)}';
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

const _shortMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];
