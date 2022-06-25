import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:owwn_coding_challenge/service/http_helper.dart';

void main() {
  final actions = [];
  final sampleStreamedResponse = Stream.fromFuture(Future.value(<int>[]));
  setUp(() {
    actions.clear();
  });
  test('Token refresh is initiated when 401 error is encountered ', () async {
    String access = '';
    final refreshResponse = http.Response('', 200);
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

    final httpHelper = HttpHelper(
      baseUrl: '',
      client: client,
      getAccessToken: () => access,
      onRefreshTokenExpired: () => actions.add('refresh_token_expired'),
      onRefreshCredential: (credentials) async {
        access = 'new_access';
        actions.add('new_access_token');
      },
    );
    await httpHelper.sendRequest(http.Request('GET', Uri.parse('')));

    expect(access, 'new_access');
    expect(actions.first, 'new_access_token');
  });

  // test(
  //     'onRefreshTokenExpired is called when trying to refresh access token'
  //     ' and 401 is encountered', () async {
  //   String access = '';
  //   final refreshResponse = http.Response('', 200);
  //   final client = MockClient(
  //     (req) => (req.headers[HttpHeaders.authorizationHeader] ?? '').trim() ==
  //             'Bearer'
  //         ? http.StreamedResponse(
  //             sampleStreamedResponse,
  //             401,
  //           )
  //         : http.StreamedResponse(
  //             sampleStreamedResponse,
  //             200,
  //           ),
  //     refreshResponse,
  //   );
  //
  //   final httpHelper = HttpHelper(
  //     baseUrl: '',
  //     client: client,
  //     getAccessToken: () => access,
  //     onRefreshTokenExpired: () => actions.add('refresh_token_expired'),
  //     onRefreshCredential: (credentials) async {
  //       access = 'new_access';
  //       actions.add('new_access_token');
  //     },
  //   );
  //   await httpHelper.sendRequest(http.Request('GET', Uri.parse('')));
  //
  //   expect(access, 'new_access');
  //   expect(actions.first, 'new_access_token');
  // });
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
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return Future.value(refreshResponse);
  }
}
