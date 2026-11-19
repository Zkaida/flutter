part of 'profile_bloc.dart';
sealed class ProfileState { const ProfileState(); }
class ProfileInitial extends ProfileState { const ProfileInitial(); }
class ProfileLoading extends ProfileState { const ProfileLoading(); }
class ProfileLoaded extends ProfileState { final CustomerModel customer; const ProfileLoaded(this.customer); }
class ProfileUpdated extends ProfileState { final String message; const ProfileUpdated(this.message); }
class ProfileFailure extends ProfileState { final Map<String, dynamic> error; const ProfileFailure({required this.error}); }
