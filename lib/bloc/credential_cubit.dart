import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owwn_coding_challenge/model/credentials.dart';
import 'package:owwn_coding_challenge/service/credential_service.dart';

class CredentialCubit extends Cubit<CredentialState> {
  final CredentialService credentialService;

  CredentialCubit(this.credentialService) : super(CredentialsUnknown());

  ValueNotifier<CredentialState> credentialsListenable =
      ValueNotifier(CredentialsUnknown());

  Future<void> saveCredentials(Credential credential) async {
    await credentialService.saveCredentials(credential);
    emit(CredentialsAuthorized(credential));
  }

  Future<void> checkCredentials() async {
    final credential = await credentialService.getCredentials();
    if (credential == null) {
      emit(CredentialsUnAuthorized());
    } else {
      emit(CredentialsAuthorized(credential));
    }
  }

  Future<void> deleteCredentials() async {
    await credentialService.deleteCredentials();
    emit(CredentialsUnAuthorized());
  }

  @override
  void onChange(Change<CredentialState> change) {
    super.onChange(change);
    credentialsListenable.value = change.nextState;
  }
}

abstract class CredentialState {}

class CredentialsUnknown extends CredentialState {}

class CredentialsUnAuthorized extends CredentialState {}

class CredentialsAuthorized extends CredentialState implements Equatable {
  final Credential credential;

  CredentialsAuthorized(this.credential);

  @override
  List<Object?> get props => [credential];

  @override
  bool? get stringify => true;
}
