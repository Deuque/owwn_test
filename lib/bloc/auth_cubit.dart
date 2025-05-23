import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owwn_coding_challenge/bloc/credential_cubit.dart';
import 'package:owwn_coding_challenge/service/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;
  final CredentialCubit credentialCubit;

  AuthCubit(
    this.authService,
    this.credentialCubit,
  ) : super(AuthInitial());

  Future signIn(String email) async {
    emit(AuthLoading());
    final response = await authService.signIn(email);
    if (response.error != null) {
      emit(AuthError(response.error.toString()));
    } else {
      await credentialCubit.saveCredentials(response.value!);
      emit(AuthSuccess());
    }
  }

  Future signOut() => credentialCubit.deleteCredentials();
}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState implements Equatable {
  final String error;

  AuthError(this.error);

  @override
  List<Object?> get props => [error];

  @override
  bool? get stringify => true;
}
