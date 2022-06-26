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

  String get apiUrl => baseUrl;

  Future<http.Response> sendRequest(
    http.BaseRequest request,
  ) async {
    http.Response? sendResponse;

    final modifiedRequest = request
      ..headers[HttpHeaders.authorizationHeader] = 'Bearer ${getAccessToken()}'
      ..headers['X-API-KEY'] = 'test-hermes';

    log('REQUEST: $request ${(request as http.Request).body}');

    final requestResponse = await client.send(modifiedRequest);

    if (requestResponse.statusCode == 401) {
      log('ACCESS TOKEN REFRESH INITIATED');
      await _refreshCredentials(
        refreshToken: getRefreshToken(),
        onSuccess: (credentials) async {
          log('ACCESS TOKEN REFRESH SUCCESS');
          await onRefreshCredential(credentials);
          sendResponse = await sendRequest(request);
        },
        onError: (response) {
          log('ACCESS TOKEN REFRESH ERROR');
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
    required String refreshToken,
    required ValueChanged<Credential> onSuccess,
    required ValueChanged<http.Response> onError,
  }) async {
    final response = await client.post(
      Uri.parse('$apiUrl/refresh'),
      body: {
        'refresh_token': refreshToken,
      },
    );
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
