import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/resource/model/customer_model.dart';
import 'package:flutter_foodstore/resource/remote/profile_remote_resource.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRemoteResource profileRemoteResource;
  ProfileBloc(this.profileRemoteResource) : super(const ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(const ProfileLoading());
      final result = await profileRemoteResource.fetchProfile();
      result.fold((error) => emit(ProfileFailure(error: {'message': error})), (customer) => emit(ProfileLoaded(customer)));
    });
    on<UpdateProfile>((event, emit) async {
      emit(const ProfileLoading());
      final result = await profileRemoteResource.updateProfile(
        name: event.name, email: event.email, image: event.image, password: event.password, passwordConfirmation: event.passwordConfirmation,
      );
      await result.fold(
        (error) async => emit(ProfileFailure(error: error is Map<String, dynamic> ? error : {'message': error.toString()})),
        (message) async { emit(ProfileUpdated(message)); add(const LoadProfile()); },
      );
    });
  }
}
