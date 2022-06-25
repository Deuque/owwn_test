import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owwn_coding_challenge/bloc/credential_cubit.dart';
import 'package:owwn_coding_challenge/model/credentials.dart';
import 'package:owwn_coding_challenge/service/auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;
  final CredentialCubit credentialCubit;

  AuthCubit(
    this.authService,
    this.credentialCubit,
  ) : super(AuthInitial());

  Future signIn(String email) async {
    emit(AuthLoading());
    await credentialCubit.saveCredentials(
      const Credential(accessToken: 'me', refreshToken: 'me'),
    );
    emit(AuthSuccess());
  }
}
