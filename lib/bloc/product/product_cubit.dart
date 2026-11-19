import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/resource/model/product_model.dart';
import 'package:flutter_foodstore/resource/remote/home_remote_resource.dart';
sealed class ProductState { const ProductState(); }
class ProductInitial extends ProductState { const ProductInitial(); }
class ProductLoading extends ProductState { const ProductLoading(); }
class ProductLoaded extends ProductState {
  final List<ProductModel> products; final int currentPage; final int lastPage; final bool isLoadingMore;
  const ProductLoaded({required this.products, this.currentPage = 1, this.lastPage = 1, this.isLoadingMore = false});
}
class ProductDetailLoaded extends ProductState { final ProductModel product; const ProductDetailLoaded(this.product); }
class ProductError extends ProductState { final String message; const ProductError(this.message); }
class ProductCubit extends Cubit<ProductState> {
  final HomeRemoteResource homeRemoteResource;
  ProductCubit(this.homeRemoteResource) : super(const ProductInitial());
  Future<void> fetchProducts({int page = 1, String query = '', bool loadMore = false}) async {
    final cur = state;
    if (loadMore && cur is ProductLoaded) {
      emit(ProductLoaded(products: cur.products, currentPage: cur.currentPage, lastPage: cur.lastPage, isLoadingMore: true));
    } else {
      emit(const ProductLoading());
    }
    final res = await homeRemoteResource.fetchProducts(page: page, query: query);
    res.fold((e) => emit(ProductError(e)), (p) {
      final combined = (loadMore && cur is ProductLoaded) ? [...cur.products, ...p.data] : p.data;
      emit(ProductLoaded(products: combined, currentPage: p.currentPage ?? 1, lastPage: p.lastPage ?? 1));
    });
  }
  Future<void> detailProduct(String slug) async {
    emit(const ProductLoading());
    final res = await homeRemoteResource.detailProduct(slug);
    res.fold((e) => emit(ProductError(e)), (p) => emit(ProductDetailLoaded(p)));
  }
}
