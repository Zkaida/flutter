import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/resource/model/order_model.dart';
import 'package:flutter_foodstore/resource/remote/order_remote_resource.dart';
sealed class OrderState { const OrderState(); }
class OrderInitial extends OrderState { const OrderInitial(); }
class OrderLoading extends OrderState { const OrderLoading(); }
class OrderLoaded extends OrderState {
  final List<OrderModel> orders; final int currentPage; final int lastPage; final bool isLoadingMore;
  const OrderLoaded({required this.orders, this.currentPage = 1, this.lastPage = 1, this.isLoadingMore = false});
}
class OrderDetailLoaded extends OrderState { final OrderModel order; const OrderDetailLoaded(this.order); }
class OrderError extends OrderState { final String message; const OrderError(this.message); }
class OrderCubit extends Cubit<OrderState> {
  final OrderRemoteResource orderRemoteResource;
  OrderCubit(this.orderRemoteResource) : super(const OrderInitial());
  Future<void> fetchOrders({int page = 1, bool loadMore = false}) async {
    final cur = state;
    if (loadMore && cur is OrderLoaded) {
      emit(OrderLoaded(orders: cur.orders, currentPage: cur.currentPage, lastPage: cur.lastPage, isLoadingMore: true));
    } else {
      emit(const OrderLoading());
    }
    final res = await orderRemoteResource.fetchOrders(page: page);
    res.fold((e) => emit(OrderError(e)), (p) {
      final combined = (loadMore && cur is OrderLoaded) ? [...cur.orders, ...p.data] : p.data;
      emit(OrderLoaded(orders: combined, currentPage: p.currentPage ?? 1, lastPage: p.lastPage ?? 1));
    });
  }
  Future<void> detailOrder(String snapToken) async {
    emit(const OrderLoading());
    final res = await orderRemoteResource.detailOrder(snapToken);
    res.fold((e) => emit(OrderError(e)), (o) => emit(OrderDetailLoaded(o)));
  }
}
