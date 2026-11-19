import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/resource/model/location_model.dart';
import 'package:flutter_foodstore/resource/remote/checkout_remote_resource.dart';
sealed class LocationState { const LocationState(); }
class LocationInitial extends LocationState { const LocationInitial(); }
class LocationLoading extends LocationState { const LocationLoading(); }
class LocationLoaded extends LocationState { final List<LocationModel> locations; const LocationLoaded(this.locations); }
class LocationError extends LocationState { final String message; const LocationError(this.message); }
class LocationCubit extends Cubit<LocationState> {
  final CheckoutRemoteResource checkoutRemoteResource;
  LocationCubit(this.checkoutRemoteResource) : super(const LocationInitial());
  Future<void> getLocation(String search) async {
    if (search.trim().isEmpty) { emit(const LocationInitial()); return; }
    emit(const LocationLoading());
    final res = await checkoutRemoteResource.getLocation(search);
    res.fold((e) => emit(LocationError(e)), (l) => emit(LocationLoaded(l)));
  }
  void clearLocation() => emit(const LocationInitial());
}
