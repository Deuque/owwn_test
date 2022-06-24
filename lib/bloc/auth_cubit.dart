import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owwn_coding_challenge/service/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthServiceInterface authService;

  AuthCubit(this.authService) : super(AuthState.unknown);

  void authorize() => emit(AuthState.authorized);
}

enum AuthState { unknown, loading, authorized, unAuthorized }
