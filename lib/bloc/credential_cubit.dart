import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owwn_coding_challenge/model/credentials.dart';
import 'package:owwn_coding_challenge/service/credential_service.dart';

class CredentialCubit extends Cubit<CredentialState> {
  final CredentialService credentialService;

  CredentialCubit(this.credentialService) : super(CredentialsUnknown());

  Future<void> saveCredentials(Credential credential) async {
    await credentialService.saveCredentials(credential);
    emit(CredentialsAuthorized(credential));
  }

  Future<void> checkCredentials() async {
    emit(CredentialsChecking());
    final credential = await credentialService.getCredentials();
    print(credential);
    if (credential == null) {
      emit(CredentialsUnAuthorized());
    } else {
      emit(CredentialsAuthorized(credential));
    }
  }
}

abstract class CredentialState {}

class CredentialsUnknown extends CredentialState {}

class CredentialsChecking extends CredentialState {}

class CredentialsUnAuthorized extends CredentialState {}

class CredentialsAuthorized extends CredentialState {
  final Credential credential;

  CredentialsAuthorized(this.credential);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialsAuthorized &&
          runtimeType == other.runtimeType &&
          credential == other.credential;

  @override
  int get hashCode => credential.hashCode;
}
