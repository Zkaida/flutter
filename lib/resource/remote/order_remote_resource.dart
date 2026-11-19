import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_foodstore/resource/model/order_model.dart';
import 'package:flutter_foodstore/resource/model/paging_model.dart';

class OrderRemoteResource {
  final Dio dio;
  OrderRemoteResource(this.dio);

  Future<Either<String, PagingModel<OrderModel>>> fetchOrders({int page = 1}) async {
    try {
      final response = await dio.get('customer/my-orders?page=$page');
      if (response.statusCode == 200) {
        return Right(PagingModel<OrderModel>.fromMap(response.data['data'], (map) => OrderModel.fromMap(map)));
      }
      return const Left('Gagal memuat pesanan');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, OrderModel>> detailOrder(String snapToken) async {
    try {
      final response = await dio.get('customer/my-orders/$snapToken');
      if (response.statusCode == 200) {
        return Right(OrderModel.fromMap(response.data['data'] ?? response.data));
      }
      return const Left('Detail pesanan tidak ditemukan');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> reviewProduct({
    required int transactionDetailId, required int productId, required int rating, required String review,
  }) async {
    try {
      final response = await dio.post('customer/ratings', data: {
        'transaction_detail_id': transactionDetailId, 'product_id': productId, 'rating': rating, 'review': review,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(response.data['message'] ?? 'Terima kasih telah memberikan ulasan');
      }
      return Left(response.data['message'] ?? 'Gagal mengirim ulasan');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Gagal mengirim ulasan');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
