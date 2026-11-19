part of 'auth_bloc.dart';
sealed class AuthState { const AuthState(); }
class AuthInitial extends AuthState { const AuthInitial(); }
class AuthLoading extends AuthState { const AuthLoading(); }
class AuthAuthenticated extends AuthState { const AuthAuthenticated(); }
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }
class AuthFailure extends AuthState { final String error; const AuthFailure({required this.error}); }
class AuthRegisterSuccess extends AuthState { final String message; const AuthRegisterSuccess({required this.message}); }
class AuthRegisterFailure extends AuthState { final Map<String, dynamic> error; const AuthRegisterFailure({required this.error}); }
