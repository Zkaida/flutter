import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_foodstore/resource/model/checkout_model.dart';
import 'package:flutter_foodstore/resource/model/location_model.dart';
import 'package:flutter_foodstore/resource/model/shipping_cost_model.dart';

class CheckoutRemoteResource {
  final Dio dio;
  CheckoutRemoteResource(this.dio);

  Future<Either<String, List<LocationModel>>> getLocation(String search) async {
    try {
      final response = await dio.get('public/search-destination', queryParameters: {'search': search});
      if (response.statusCode == 200) {
        final rawList = (response.data['data'] ?? []) as List;
        return Right(rawList.map((e) => LocationModel.fromMap(e)).toList());
      }
      return const Left('Lokasi tidak ditemukan');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<ShippingCostModel>>> getShippingCost(int destination, int weight, String courier) async {
    try {
      final response = await dio.post('public/check-ongkir', data: {
        'destination': destination, 'weight': weight, 'courier': courier.toLowerCase(),
      });
      if (response.statusCode == 200) {
        final rawList = (response.data['data'] ?? []) as List;
        return Right(rawList.map((e) => ShippingCostModel.fromMap(e)).toList());
      }
      return const Left('Gagal menghitung ongkos kirim');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> checkOut(CheckoutModel checkout) async {
    try {
      final response = await dio.post('public/checkout', data: checkout.toMap());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final snapToken = response.data['snap_token'] ?? response.data['data']?['snap_token'] ?? '';
        return Right(snapToken.toString());
      }
      return Left(response.data['message'] ?? 'Checkout gagal');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
