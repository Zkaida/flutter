import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_foodstore/resource/model/api_response.dart';
import 'package:flutter_foodstore/resource/model/category_model.dart';
import 'package:flutter_foodstore/resource/model/paging_model.dart';
import 'package:flutter_foodstore/resource/model/product_model.dart';
import 'package:flutter_foodstore/resource/model/slider_model.dart';

class HomeRemoteResource {
  final Dio dio;
  HomeRemoteResource(this.dio);

  Future<Either<String, List<SliderModel>>> fetchSliders() async {
    try {
      final response = await dio.get('public/sliders');
      if (response.statusCode == 200) {
        final res = ApiResponse<List<SliderModel>>.fromJson(
          response.data, (json) => List<SliderModel>.from((json as List).map((x) => SliderModel.fromMap(x))),
        );
        return Right(res.data ?? []);
      }
      return const Left('Gagal memuat slider');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<CategoryModel>>> fetchCategories() async {
    try {
      final response = await dio.get('public/categories');
      if (response.statusCode == 200) {
        final res = ApiResponse<List<CategoryModel>>.fromJson(
          response.data, (json) => List<CategoryModel>.from((json as List).map((x) => CategoryModel.fromMap(x))),
        );
        return Right(res.data ?? []);
      }
      return const Left('Gagal memuat kategori');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, CategoryModel>> fetchCategoryBySlug(String slug) async {
    try {
      final response = await dio.get('public/categories/$slug');
      if (response.statusCode == 200) {
        final res = ApiResponse<CategoryModel>.fromJson(response.data, (json) => CategoryModel.fromMap(json));
        if (res.data != null) return Right(res.data!);
      }
      return const Left('Kategori tidak ditemukan');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, PagingModel<ProductModel>>> fetchProducts({int page = 1, String query = ''}) async {
    try {
      final response = await dio.get('public/products', queryParameters: {'page': page, if (query.isNotEmpty) 'search': query});
      if (response.statusCode == 200) {
        return Right(PagingModel<ProductModel>.fromMap(response.data['data'], (map) => ProductModel.fromMap(map)));
      }
      return const Left('Gagal memuat produk');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<ProductModel>>> fetchProductsPopuler() async {
    try {
      final response = await dio.get('public/products-popular');
      if (response.statusCode == 200) {
        final res = ApiResponse<List<ProductModel>>.fromJson(
          response.data, (json) => List<ProductModel>.from((json as List).map((x) => ProductModel.fromMap(x))),
        );
        return Right(res.data ?? []);
      }
      return const Left('Gagal memuat produk populer');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, ProductModel>> detailProduct(String slug) async {
    try {
      final response = await dio.get('public/products/$slug');
      if (response.statusCode == 200) {
        final res = ApiResponse<ProductModel>.fromJson(response.data, (json) => ProductModel.fromMap(json));
        if (res.data != null) return Right(res.data!);
      }
      return const Left('Produk tidak ditemukan');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
