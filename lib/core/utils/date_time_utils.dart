DateTime? parseBackendDateTime(Object? value) {
  if (value is DateTime) return value.toLocal();

  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;

  return DateTime.tryParse(text)?.toLocal();
}
