import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/resource/model/checkout_model.dart';
import 'package:flutter_foodstore/resource/remote/checkout_remote_resource.dart';
sealed class CheckoutState { const CheckoutState(); }
class CheckoutInitial extends CheckoutState { const CheckoutInitial(); }
class CheckoutLoading extends CheckoutState { const CheckoutLoading(); }
class CheckoutSuccess extends CheckoutState { final String snapToken; const CheckoutSuccess(this.snapToken); }
class CheckoutError extends CheckoutState { final String message; const CheckoutError(this.message); }
class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutRemoteResource checkoutRemoteResource;
  CheckoutCubit(this.checkoutRemoteResource) : super(const CheckoutInitial());
  Future<void> checkout(CheckoutModel checkout) async {
    emit(const CheckoutLoading());
    final res = await checkoutRemoteResource.checkOut(checkout);
    res.fold((e) => emit(CheckoutError(e)), (s) => emit(CheckoutSuccess(s)));
  }
}
