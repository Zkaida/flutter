import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/resource/model/shipping_cost_model.dart';
import 'package:flutter_foodstore/resource/remote/checkout_remote_resource.dart';
sealed class ShippingCostState { const ShippingCostState(); }
class ShippingCostInitial extends ShippingCostState { const ShippingCostInitial(); }
class ShippingCostLoading extends ShippingCostState { const ShippingCostLoading(); }
class ShippingCostLoaded extends ShippingCostState { final List<ShippingCostModel> shippingCost; const ShippingCostLoaded(this.shippingCost); }
class ShippingCostError extends ShippingCostState { final String message; const ShippingCostError(this.message); }
class ShippingCostCubit extends Cubit<ShippingCostState> {
  final CheckoutRemoteResource checkoutRemoteResource;
  ShippingCostCubit(this.checkoutRemoteResource) : super(const ShippingCostInitial());
  Future<void> getShippingCost(int destination, int weight, String courier) async {
    emit(const ShippingCostLoading());
    final res = await checkoutRemoteResource.getShippingCost(destination, weight, courier);
    res.fold((e) => emit(ShippingCostError(e)), (s) => emit(ShippingCostLoaded(s)));
  }
  void resetShippingCost() => emit(const ShippingCostInitial());
}
