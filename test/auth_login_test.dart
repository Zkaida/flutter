import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_foodstore/bloc/auth/auth_bloc.dart';
import 'package:flutter_foodstore/core/utils/auth_interceptor.dart';
import 'package:flutter_foodstore/resource/remote/auth_remote_resource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('accepts a login token at the response root', () async {
    final adapter = _FakeAdapter(
      statusCode: 200,
      body: {'token': 'root-token'},
    );
    final resource = AuthRemoteResource(_dio(adapter));

    final result = await resource.login('user@example.com', 'password');

    result.fold(
      (error) => fail(error),
      (response) => expect(response.token, 'root-token'),
    );
  });

  test('accepts a nested token from a 201 response', () async {
    final adapter = _FakeAdapter(
      statusCode: 201,
      body: {
        'data': {
          'token': 'nested-token',
          'customer': {'id': 1},
        },
      },
    );
    final resource = AuthRemoteResource(_dio(adapter));

    final result = await resource.login('user@example.com', 'password');

    result.fold(
      (error) => fail(error),
      (response) => expect(response.token, 'nested-token'),
    );
  });

  test('rejects a successful response without a token', () async {
    final adapter = _FakeAdapter(
      statusCode: 200,
      body: {'message': 'Login berhasil'},
    );
    final resource = AuthRemoteResource(_dio(adapter));

    final result = await resource.login('user@example.com', 'password');

    result.fold(
      (error) => expect(error, 'Login berhasil'),
      (_) => fail('A tokenless response must not authenticate the user'),
    );
  });

  test('does not send another logout request for login 401', () async {
    final adapter = _FakeAdapter(
      statusCode: 401,
      body: {'message': 'email atau password salah'},
    );
    final dio = _dio(adapter);
    final authBloc = AuthBloc(AuthRemoteResource(dio));
    dio.interceptors.add(AuthInterceptor(authBloc));

    final result = await AuthRemoteResource(dio).login(
      'user@example.com',
      'wrong-password',
    );

    expect(adapter.requestCount, 1);
    result.fold(
      (error) => expect(error, 'email atau password salah'),
      (_) => fail('A 401 response must not authenticate the user'),
    );
    await authBloc.close();
  });

  test('expires the local session without calling the logout endpoint',
      () async {
    final adapter = _FakeAdapter(
      statusCode: 401,
      body: {'message': 'Unauthenticated'},
    );
    final dio = _dio(adapter);
    final authBloc = AuthBloc(AuthRemoteResource(dio));
    dio.interceptors.add(AuthInterceptor(authBloc));

    await expectLater(
      dio.get('customer/profile'),
      throwsA(isA<DioException>()),
    );
    await Future<void>.delayed(Duration.zero);

    expect(adapter.requestCount, 1);
    expect(authBloc.state, isA<AuthUnauthenticated>());
    await authBloc.close();
  });
}

Dio _dio(_FakeAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'https://foodstore.test/api/'))
    ..httpClientAdapter = adapter;
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.statusCode, required this.body});

  final int statusCode;
  final Map<String, dynamic> body;
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
