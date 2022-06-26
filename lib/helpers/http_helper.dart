import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:owwn_coding_challenge/model/credentials.dart';

class HttpHelper {
  final String baseUrl;
  final http.Client client;
  final String Function() getAccessToken;
  final String Function() getRefreshToken;
  final VoidCallback onRefreshTokenExpired;
  final Future<void> Function(Credential) onRefreshCredential;

  HttpHelper({
    required this.baseUrl,
    required this.client,
    required this.getAccessToken,
    required this.getRefreshToken,
    required this.onRefreshTokenExpired,
    required this.onRefreshCredential,
  });

  Future<http.Response> sendRequest({
    required String method,
    required String endPoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    http.Response? sendResponse;

    final modifiedRequest =
        http.Request(method, Uri.parse('$baseUrl/$endPoint'))
          ..headers.addAll(headers ?? {})
          ..headers[HttpHeaders.authorizationHeader] =
              'Bearer ${getAccessToken()}'
          ..headers['X-API-KEY'] = 'test-hermes'
          ..body = jsonEncode(body);

    log('REQUEST: $modifiedRequest $body');

    final requestResponse = await client.send(modifiedRequest);

    if (requestResponse.statusCode == 401) {
      log('ACCESS TOKEN REFRESH INITIATED');
      await _refreshCredentials(
        refreshToken: getRefreshToken(),
        onSuccess: (credentials) async {
          log('ACCESS TOKEN REFRESH SUCCESS');
          await onRefreshCredential(credentials);

          sendResponse = await sendRequest(
            method: method,
            endPoint: endPoint,
            headers: headers,
            body: body,
          );
        },
        onError: (response) {
          log('ACCESS TOKEN REFRESH ERROR');
          if (response.statusCode == 401) {
            log('REFRESH TOKEN EXPIRED');
            onRefreshTokenExpired();
          }
          sendResponse = response;
        },
      );
    }

    return sendResponse ?? await http.Response.fromStream(requestResponse);
  }

  Future<void> _refreshCredentials({
    required String refreshToken,
    required ValueChanged<Credential> onSuccess,
    required ValueChanged<http.Response> onError,
  }) async {
    final url = Uri.parse('$baseUrl/refresh');
    final body = jsonEncode({'refresh_token': refreshToken});
    log('REQUEST: POST $url $body');
    final response = await client.post(url, body: body);
    if (response.statusCode == 200) {
      return onSuccess(
        Credential.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        ),
      );
    }
    return onError(response);
  }
}
