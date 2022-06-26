import 'dart:convert';

import 'package:owwn_coding_challenge/helpers/http_helper.dart';
import 'package:owwn_coding_challenge/helpers/request_mapper.dart';
import 'package:owwn_coding_challenge/model/credentials.dart';

class AuthServiceImpl extends AuthService {
  final HttpHelper httpHelper;

  AuthServiceImpl(this.httpHelper);

  @override
  Future<ResponseModel<Credential>> signIn(String email) async {
    final body = {'email': email};
    return makeRequest(
      call: () =>
          httpHelper.sendRequest(method: 'POST', endPoint: 'auth', body: body),
      onSuccess: (response) {
        return ResponseModel(
          value: Credential.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>,
          ),
        );
      },
      onError: (error, _) {
        return ResponseModel(error: error);
      },
      successCode: 200,
    );
  }
}

abstract class AuthService {
  Future<ResponseModel<Credential>> signIn(String email);
}
