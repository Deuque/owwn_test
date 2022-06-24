import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:owwn_coding_challenge/model/credentials.dart';

class AuthService extends AuthServiceInterface {
  final FlutterSecureStorage secureStorage;

  AuthService(this.secureStorage);

  @override
  Future<Credential> getCredentials(Credential credential) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveCredentials(Credential credential) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCredentials() {
    throw UnimplementedError();
  }
}

abstract class AuthServiceInterface {
  Future<void> saveCredentials(Credential credential);

  Future<Credential> getCredentials(Credential credential);

  Future<void> deleteCredentials();
}
