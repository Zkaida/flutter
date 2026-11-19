import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/resource/remote/order_remote_resource.dart';
sealed class ReviewProductState { const ReviewProductState(); }
class ReviewProductInitial extends ReviewProductState { const ReviewProductInitial(); }
class ReviewProductLoading extends ReviewProductState { const ReviewProductLoading(); }
class ReviewProductSuccess extends ReviewProductState { final String message; const ReviewProductSuccess(this.message); }
class ReviewProductError extends ReviewProductState { final String message; const ReviewProductError(this.message); }
class ReviewProductCubit extends Cubit<ReviewProductState> {
  final OrderRemoteResource orderRemoteResource;
  ReviewProductCubit(this.orderRemoteResource) : super(const ReviewProductInitial());
  Future<void> submitReview({required int transactionDetailId, required int productId, required int rating, required String review}) async {
    emit(const ReviewProductLoading());
    final res = await orderRemoteResource.reviewProduct(transactionDetailId: transactionDetailId, productId: productId, rating: rating, review: review);
    res.fold((e) => emit(ReviewProductError(e)), (m) => emit(ReviewProductSuccess(m)));
  }
}
