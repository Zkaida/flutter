import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/resource/local/auth_local_resource.dart';
import 'package:flutter_foodstore/resource/remote/auth_remote_resource.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteResource authRemoteResource;
  AuthBloc(this.authRemoteResource) : super(const AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(const AuthLoading());
      final result = await authRemoteResource.login(event.email, event.password);
      await result.fold(
        (error) async => emit(AuthFailure(error: error)),
        (response) async {
          if (response.token != null) await AuthLocalResource.saveToken(response.token!);
          emit(const AuthAuthenticated());
        },
      );
    });
    on<AuthRegisterRequested>((event, emit) async {
      emit(const AuthLoading());
      final result = await authRemoteResource.register(event.name, event.email, event.password, event.passwordConfirmation);
      result.fold(
        (error) => emit(AuthRegisterFailure(error: error is Map<String, dynamic> ? error : {'message': error.toString()})),
        (message) => emit(AuthRegisterSuccess(message: message)),
      );
    });
    on<AuthCheckLoginStatus>((event, emit) async {
      final token = await AuthLocalResource.getToken();
      emit((token != null && token.isNotEmpty) ? const AuthAuthenticated() : const AuthUnauthenticated());
    });
    on<AuthLogoutRequested>((event, emit) async {
      await authRemoteResource.logout();
      emit(const AuthUnauthenticated());
    });
    on<AuthSessionExpired>((event, emit) {
      emit(const AuthUnauthenticated());
    });
  }
}
