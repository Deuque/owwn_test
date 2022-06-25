import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:owwn_coding_challenge/model/credentials.dart';

class HttpHelper {
  final String baseUrl;
  final http.Client client;
  final String Function() getAccessToken;
  final VoidCallback onRefreshTokenExpired;
  final Future<void> Function(Credential) onRefreshCredential;

  HttpHelper({
    required this.baseUrl,
    required this.client,
    required this.getAccessToken,
    required this.onRefreshTokenExpired,
    required this.onRefreshCredential,
  });

  String get apiUrl => baseUrl;

  Future<http.Response> sendRequest(
    http.BaseRequest request,
  ) async {
    http.Response? sendResponse;

    final accessToken = getAccessToken();
    final modifiedRequest = request
      ..headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
    final requestResponse = await client.send(modifiedRequest);

    if (requestResponse.statusCode == 401) {
      await _refreshCredentials(
        onSuccess: (credentials) async {
          await onRefreshCredential(
            const Credential(accessToken: '', refreshToken: ''),
          );
          sendResponse = await sendRequest(request);
        },
        onError: (response) {
          if (response.statusCode == 401) {
            onRefreshTokenExpired();
          }
          sendResponse = response;
        },
      );
    }

    return sendResponse ?? await http.Response.fromStream(requestResponse);
  }

  Future<void> _refreshCredentials({
    required ValueChanged<Credential> onSuccess,
    required ValueChanged<http.Response> onError,
  }) async {
    final response = await client.get(Uri.parse(''));
    if (response.statusCode == 200) {
      return onSuccess(
        const Credential(
          accessToken: 'accessToken',
          refreshToken: 'refreshToken',
        ),
      );
    }
    return onError(response);
  }
}
