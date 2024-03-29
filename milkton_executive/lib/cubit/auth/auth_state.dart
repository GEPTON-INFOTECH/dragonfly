part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoadingState extends AuthState {}

final class AuthCodeSentState extends AuthState {}

final class AuthCodeVerifiedState extends AuthState {}

final class AuthLoggedInState extends AuthState {
  final User firebaseUser;
  final Future<String?> idToken;

  AuthLoggedInState({required this.firebaseUser})
      : idToken = firebaseUser.getIdToken();
}

final class AuthLoggedOutState extends AuthState {}

final class AuthErrorState extends AuthState {
  final String error;
  AuthErrorState({required this.error});
}
