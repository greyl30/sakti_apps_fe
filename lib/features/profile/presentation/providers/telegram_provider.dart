import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/telegram_remote_data_source.dart';
import '../../data/models/telegram_status_model.dart';
import '../../data/repositories/telegram_repository.dart';

enum TelegramAction { none, connect, disconnect }

class TelegramState {
  const TelegramState({
    this.status,
    this.isStatusLoading = false,
    this.action = TelegramAction.none,
    this.errorMessage,
  });

  final TelegramStatusModel? status;
  final bool isStatusLoading;
  final TelegramAction action;
  final String? errorMessage;

  bool get isConnected => status?.isConnected ?? false;
  bool get isActionLoading => action != TelegramAction.none;
  bool get isConnectLoading => action == TelegramAction.connect;
  bool get isDisconnectLoading => action == TelegramAction.disconnect;

  TelegramState copyWith({
    TelegramStatusModel? status,
    bool? isStatusLoading,
    TelegramAction? action,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TelegramState(
      status: status ?? this.status,
      isStatusLoading: isStatusLoading ?? this.isStatusLoading,
      action: action ?? this.action,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final telegramRemoteDataSourceProvider = Provider<TelegramRemoteDataSource>((
  ref,
) {
  return TelegramRemoteDataSource(ApiClient.dio);
});

final telegramRepositoryProvider = Provider<TelegramRepository>((ref) {
  final remoteDataSource = ref.watch(telegramRemoteDataSourceProvider);
  return TelegramRepository(remoteDataSource);
});

final telegramProvider = StateNotifierProvider<TelegramNotifier, TelegramState>(
  (ref) {
    final repository = ref.watch(telegramRepositoryProvider);
    return TelegramNotifier(repository)..loadStatus();
  },
);

class TelegramNotifier extends StateNotifier<TelegramState> {
  TelegramNotifier(this._repository) : super(const TelegramState());

  final TelegramRepository _repository;

  Future<void> loadStatus() async {
    state = state.copyWith(isStatusLoading: true, clearError: true);
    try {
      final status = await _repository.getStatus();
      state = TelegramState(status: status);
    } on TelegramException catch (error) {
      state = state.copyWith(
        isStatusLoading: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isStatusLoading: false,
        errorMessage: 'Gagal mengambil status Telegram.',
      );
    }
  }

  Future<void> refreshStatus() => loadStatus();

  Future<bool> connect(String verificationCode) async {
    if (state.isActionLoading) return false;

    state = state.copyWith(action: TelegramAction.connect, clearError: true);
    try {
      await _repository.connect(verificationCode);
      final status = await _repository.getStatus();
      state = TelegramState(status: status);
      return true;
    } on TelegramException catch (error) {
      state = state.copyWith(
        action: TelegramAction.none,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        action: TelegramAction.none,
        errorMessage: 'Gagal menghubungkan Telegram.',
      );
      return false;
    }
  }

  Future<bool> disconnect() async {
    if (state.isActionLoading) return false;

    state = state.copyWith(action: TelegramAction.disconnect, clearError: true);
    try {
      await _repository.disconnect();
      final status = await _repository.getStatus();
      state = TelegramState(status: status);
      return true;
    } on TelegramException catch (error) {
      state = state.copyWith(
        action: TelegramAction.none,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        action: TelegramAction.none,
        errorMessage: 'Gagal memutuskan koneksi Telegram.',
      );
      return false;
    }
  }
}
