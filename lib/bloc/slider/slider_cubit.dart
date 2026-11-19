import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/resource/model/slider_model.dart';
import 'package:flutter_foodstore/resource/remote/home_remote_resource.dart';
sealed class SliderState { const SliderState(); }
class SliderInitial extends SliderState { const SliderInitial(); }
class SliderLoading extends SliderState { const SliderLoading(); }
class SliderLoaded extends SliderState { final List<SliderModel> sliders; const SliderLoaded(this.sliders); }
class SliderError extends SliderState { final String message; const SliderError(this.message); }
class SliderCubit extends Cubit<SliderState> {
  final HomeRemoteResource homeRemoteResource;
  SliderCubit(this.homeRemoteResource) : super(const SliderInitial());
  Future<void> fetchSliders() async {
    emit(const SliderLoading());
    final res = await homeRemoteResource.fetchSliders();
    res.fold((e) => emit(SliderError(e)), (s) => emit(SliderLoaded(s)));
  }
}
