part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  final User? user;

  const ProfileState({this.user});
  @override
  List<dynamic> get props => [user];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial({super.user});
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({super.user});
}

final class ProfileError extends ProfileState {}
