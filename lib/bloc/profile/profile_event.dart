part of 'profile_bloc.dart';
sealed class ProfileEvent { const ProfileEvent(); }
class LoadProfile extends ProfileEvent { const LoadProfile(); }
class UpdateProfile extends ProfileEvent {
  final String name; final String email; final File? image; final String? password; final String? passwordConfirmation;
  const UpdateProfile({required this.name, required this.email, this.image, this.password, this.passwordConfirmation});
}
