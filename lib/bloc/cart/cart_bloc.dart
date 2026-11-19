import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/resource/model/cart_response_model.dart';
import 'package:flutter_foodstore/resource/remote/cart_remote_resource.dart';
sealed class CartEvent { const CartEvent(); }
class CartFetch extends CartEvent { const CartFetch(); }
class CartAddItem extends CartEvent { final int productId; final int qty; const CartAddItem({required this.productId, required this.qty}); }
class CartRemoveItem extends CartEvent { final int cartId; const CartRemoveItem({required this.cartId}); }
class CartIncrementItem extends CartEvent { final int productId; final int cartId; const CartIncrementItem({required this.productId, required this.cartId}); }
class CartDecrementItem extends CartEvent { final int productId; final int cartId; const CartDecrementItem({required this.productId, required this.cartId}); }
sealed class CartState { const CartState(); }
class CartInitial extends CartState { const CartInitial(); }
class CartLoading extends CartState { const CartLoading(); }
class CartLoaded extends CartState { final CartResponseModel cartResponse; const CartLoaded(this.cartResponse); }
class CartStored extends CartState { final String message; const CartStored(this.message); }
class CartError extends CartState { final String message; const CartError(this.message); }
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRemoteResource cartRemoteResource;
  CartBloc(this.cartRemoteResource) : super(const CartInitial()) {
    on<CartFetch>((e, emit) async {
      emit(const CartLoading());
      final res = await cartRemoteResource.fetchCart();
      res.fold((err) => emit(CartError(err)), (c) => emit(CartLoaded(c)));
    });
    on<CartAddItem>((e, emit) async {
      final res = await cartRemoteResource.cartStore(e.productId, e.qty);
      await res.fold((err) async => emit(CartError(err)), (msg) async { emit(CartStored(msg)); add(const CartFetch()); });
    });
    on<CartRemoveItem>((e, emit) async {
      final res = await cartRemoteResource.removeCart(e.cartId);
      await res.fold((err) async => emit(CartError(err)), (_) async => add(const CartFetch()));
    });
    on<CartIncrementItem>((e, emit) async {
      final res = await cartRemoteResource.incrementCart(e.productId, e.cartId);
      await res.fold((err) async => emit(CartError(err)), (_) async => add(const CartFetch()));
    });
    on<CartDecrementItem>((e, emit) async {
      final res = await cartRemoteResource.decrementCart(e.productId, e.cartId);
      await res.fold((err) async => emit(CartError(err)), (_) async => add(const CartFetch()));
    });
  }
}
