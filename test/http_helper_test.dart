import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:owwn_coding_challenge/helpers/http_helper.dart';

void main() {
  final actions = [];
  final sampleStreamedResponse = Stream.fromFuture(Future.value(<int>[]));
  final sampleCredentialResponse =
      jsonEncode({'access_token': '', 'refresh_token': ''});
  setUp(() {
    actions.clear();
  });
  test('Token refresh is initiated when 401 error is encountered ', () async {
    String accessToken = '';
    final refreshResponse = http.Response(sampleCredentialResponse, 200);
    final client = MockClient(
      (req) => (req.headers[HttpHeaders.authorizationHeader] ?? '').trim() ==
              'Bearer'
          ? http.StreamedResponse(
              sampleStreamedResponse,
              401,
            )
          : http.StreamedResponse(
              sampleStreamedResponse,
              200,
            ),
      refreshResponse,
    );

    final httpHelper = HttpHelperImpl(
      baseUrl: '',
      client: client,
      getAccessToken: () => accessToken,
      getRefreshToken: () => '',
      onRefreshTokenExpired: () => actions.add('refresh_token_expired'),
      onRefreshCredential: (credentials) async {
        accessToken = 'new_access';
        actions.add('new_access_token');
      },
    );

    expect(accessToken, '');
    expect(actions.length, 0);
    final response = await httpHelper.sendRequest(method: 'GET', endPoint: '');
    expect(response.statusCode, 200);
    expect(accessToken, 'new_access');
    expect(actions.length, 1);
    expect(actions.first, 'new_access_token');
  });

  test(
      'onRefreshTokenExpired is called when trying to refresh access token'
      ' and 401 is encountered', () async {
    final refreshResponse = http.Response('', 401);
    final client = MockClient(
      (req) => http.StreamedResponse(
        sampleStreamedResponse,
        401,
      ),
      refreshResponse,
    );

    final httpHelper = HttpHelperImpl(
      baseUrl: '',
      client: client,
      getAccessToken: () => '',
      getRefreshToken: () => '',
      onRefreshTokenExpired: () => actions.add('refresh_token_expired'),
      onRefreshCredential: (_) async {},
    );

    expect(actions.length, 0);
    final response = await httpHelper.sendRequest(method: 'GET', endPoint: '');
    expect(response.statusCode, 401);
    expect(actions.length, 1);
    expect(actions.first, 'refresh_token_expired');
  });
}

class MockClient extends http.BaseClient {
  final http.StreamedResponse Function(http.BaseRequest request) sendResponse;
  final http.Response refreshResponse;

  MockClient(
    this.sendResponse,
    this.refreshResponse,
  );

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return Future.value(
      sendResponse(request),
    );
  }

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return Future.value(refreshResponse);
  }
}
