part of 'auth_bloc.dart';
sealed class AuthEvent { const AuthEvent(); }
class AuthLoginRequested extends AuthEvent { final String email; final String password; const AuthLoginRequested({required this.email, required this.password}); }
class AuthRegisterRequested extends AuthEvent { final String name; final String email; final String password; final String passwordConfirmation; const AuthRegisterRequested({required this.name, required this.email, required this.password, required this.passwordConfirmation}); }
class AuthCheckLoginStatus extends AuthEvent { const AuthCheckLoginStatus(); }
class AuthLogoutRequested extends AuthEvent { const AuthLogoutRequested(); }
class AuthSessionExpired extends AuthEvent { const AuthSessionExpired(); }
