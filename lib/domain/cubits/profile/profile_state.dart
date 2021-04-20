part of 'profile_cubit.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoadedWithGoogleInfo extends ProfileState {
  final User user;

  ProfileLoadedWithGoogleInfo(this.user);
}

class ProfileLoadedWithInfo extends ProfileState {
  final String name;

  ProfileLoadedWithInfo(this.name);
}

class ProfileLoadedWithoutInfo extends ProfileState {}

class ProfileEditing extends ProfileState {
  final String name;

  ProfileEditing(this.name);
}
