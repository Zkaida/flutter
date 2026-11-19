import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_foodstore/resource/local/auth_local_resource.dart';
import 'package:flutter_foodstore/resource/model/auth_response_model.dart';

class AuthRemoteResource {
  final Dio dio;
  AuthRemoteResource(this.dio);

  Future<Either<String, AuthResponseModel>> login(String email, String password) async {
    try {
      final response = await dio.post('customer/login', data: {'email': email, 'password': password});
      if (response.statusCode == 200) {
        final String token = response.data['token'];
        await AuthLocalResource.saveToken(token);
        return Right(AuthResponseModel.fromMap(response.data));
      }
      return Left(response.data['message'] ?? 'Login gagal');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return Left(e.response?.data['message'] ?? 'Email atau password salah');
      }
      return Left(e.response?.data?['message'] ?? e.message ?? 'Error koneksi');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<dynamic, String>> register(String name, String email, String password, String passwordConfirmation) async {
    try {
      final response = await dio.post('customer/register', data: {
        'name': name, 'email': email, 'password': password, 'password_confirmation': passwordConfirmation,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(response.data['message'] ?? 'Registrasi berhasil');
      }
      return Left(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) return Left(e.response?.data);
      return Left({'message': e.message ?? 'Registrasi gagal'});
    } catch (e) {
      return Left({'message': e.toString()});
    }
  }

  Future<String> logout() async {
    try {
      final token = await AuthLocalResource.getToken();
      final response = await dio.post(
        'customer/logout',
        options: Options(headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'}),
      );
      await AuthLocalResource.deleteToken();
      return response.data['message'] ?? 'Logout berhasil';
    } catch (e) {
      await AuthLocalResource.deleteToken();
      return e.toString();
    }
  }
}
