import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

// State untuk menyimpan status proses auth
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final UserModel? user;
  final String? errorMessage;
  final String? successMessage;

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? errorMessage,
    String? successMessage,
    bool clearMessage = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: clearMessage ? null : errorMessage,
      successMessage: clearMessage ? null : successMessage,
    );
  }
}

// Provider remote data source auth
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ApiClient.dio);
});

// Provider repository auth
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepository(remoteDataSource);
});

// Provider untuk mengelola state login
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  // Valid login akan mengirim request ke repository
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearMessage: true);

    try {
      final user = await _repository.login(email: email, password: password);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    }
  }

  // Restore session Supabase dari Splash saat aplikasi dibuka.
  Future<bool> restoreSession() async {
    state = state.copyWith(isLoading: true, clearMessage: true);

    final user = await _repository.restoreSession();
    if (user == null) {
      state = const AuthState();
      return false;
    }

    state = state.copyWith(isLoading: false, user: user);
    return true;
  }

  // Mengirim permintaan lupa password ke repository
  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, clearMessage: true);

    try {
      await _repository.forgotPassword(email);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Link reset password telah dikirim ke email Anda.',
      );
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    }
  }

  Future<void> logout() async {
    // TODO(Backend):
    // Hapus access token dan refresh token sebelum logout.
    await _repository.logout();
    state = const AuthState();
  }
}
