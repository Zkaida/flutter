import 'dart:io';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_foodstore/resource/model/customer_model.dart';

class ProfileRemoteResource {
  final Dio _dio;
  ProfileRemoteResource(this._dio);

  Future<Either<String, CustomerModel>> fetchProfile() async {
    try {
      final response = await _dio.get('customer/profile');
      if (response.statusCode == 200) {
        return Right(CustomerModel.fromMap(response.data['customer']));
      }
      return const Left('Failed to fetch profile');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Error profil');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<dynamic, String>> updateProfile({
    required String name, required String email, File? image, String? password, String? passwordConfirmation,
  }) async {
    try {
      final Map<String, dynamic> mapData = {'name': name, 'email': email};
      if (image != null) mapData['image'] = await MultipartFile.fromFile(image.path);
      if (password != null && password.isNotEmpty) {
        mapData['password'] = password;
        mapData['password_confirmation'] = passwordConfirmation;
      }
      final response = await _dio.post(
        'customer/profile',
        data: FormData.fromMap(mapData),
        options: Options(headers: {'content-type': 'multipart/form-data'}),
      );
      if (response.statusCode == 200) return Right(response.data['message'] ?? 'Profil berhasil diperbarui');
      return Left(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) return Left(e.response?.data);
      return Left({'message': e.message ?? 'Gagal memperbarui profil'});
    } catch (e) {
      return Left({'message': e.toString()});
    }
  }
}
