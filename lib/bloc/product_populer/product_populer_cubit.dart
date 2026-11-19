import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/resource/model/product_model.dart';
import 'package:flutter_foodstore/resource/remote/home_remote_resource.dart';
sealed class ProductPopulerState { const ProductPopulerState(); }
class ProductPopulerInitial extends ProductPopulerState { const ProductPopulerInitial(); }
class ProductPopulerLoading extends ProductPopulerState { const ProductPopulerLoading(); }
class ProductPopulerLoaded extends ProductPopulerState { final List<ProductModel> products; const ProductPopulerLoaded(this.products); }
class ProductPopulerError extends ProductPopulerState { final String message; const ProductPopulerError(this.message); }
class ProductPopulerCubit extends Cubit<ProductPopulerState> {
  final HomeRemoteResource homeRemoteResource;
  ProductPopulerCubit(this.homeRemoteResource) : super(const ProductPopulerInitial());
  Future<void> fetchProductsPopuler() async {
    emit(const ProductPopulerLoading());
    final res = await homeRemoteResource.fetchProductsPopuler();
    res.fold((e) => emit(ProductPopulerError(e)), (p) => emit(ProductPopulerLoaded(p)));
  }
}
