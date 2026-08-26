class TelegramStatusModel {
  const TelegramStatusModel({required this.isConnected});

  final bool isConnected;

  factory TelegramStatusModel.fromJson(Map<String, dynamic> json) {
    return TelegramStatusModel(
      isConnected: _readBool(json['connected'] ?? json['is_connected']),
    );
  }
}

bool _readBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;

  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'ya';
}
