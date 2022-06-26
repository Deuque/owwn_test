import 'dart:convert';

import 'package:http/http.dart';
import 'package:owwn_coding_challenge/bloc/users_cubit.dart';
import 'package:owwn_coding_challenge/helpers/http_helper.dart';
import 'package:owwn_coding_challenge/helpers/request_mapper.dart';
import 'package:owwn_coding_challenge/model/credentials.dart';

class UsersServiceImpl extends UsersService {
  final HttpHelper httpHelper;

  UsersServiceImpl(this.httpHelper);

  @override
  Future<ResponseModel<UsersResponse>> loadUsers(int limit, int page) async {
    return makeRequest(
      call: () => httpHelper.sendRequest(
        method: 'GET',
        endPoint: 'users?limit=$limit&page=$page',
      ),
      onSuccess: (response) {
        return ResponseModel(
          value: UsersResponse.fromJson(
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

abstract class UsersService {
  Future<ResponseModel<UsersResponse>> loadUsers(int limit, int page);
}
