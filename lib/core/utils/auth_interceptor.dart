import 'package:dio/dio.dart';
import 'package:flutter_foodstore/bloc/auth/auth_bloc.dart';
import 'package:flutter_foodstore/resource/local/auth_local_resource.dart';

class AuthInterceptor extends Interceptor {
  final AuthBloc authBloc;
  AuthInterceptor(this.authBloc);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await AuthLocalResource.getToken();
    options.headers['Accept'] = 'application/json';
    if (options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await AuthLocalResource.deleteToken();
      authBloc.add(const AuthLogoutRequested());
    }
    super.onError(err, handler);
  }
}
