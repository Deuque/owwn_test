import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:owwn_coding_challenge/model/credentials.dart';

class CredentialServiceImpl extends CredentialService {
  final FlutterSecureStorage secureStorage;

  CredentialServiceImpl(this.secureStorage);

  String credentialKey = 'Credential';

  @override
  Future<Credential?> getCredentials() async {
    try {
      final result = await secureStorage.read(key: credentialKey);
      if (result == null) return null;

      final decodedResult = jsonDecode(result);
      return Credential.fromJson(decodedResult as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveCredentials(Credential credential) async {
    try {
      final encodedString = jsonEncode(credential.toJson());
      return await secureStorage.write(
        key: credentialKey,
        value: encodedString,
      );
    } catch (_) {}
  }

  @override
  Future<void> deleteCredentials() {
    throw UnimplementedError();
  }
}

abstract class CredentialService {
  Future<void> saveCredentials(Credential credential);

  Future<Credential?> getCredentials();

  Future<void> deleteCredentials();
}
