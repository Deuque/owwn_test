import 'package:equatable/equatable.dart';

class Credential extends Equatable {
  final String accessToken;
  final String refreshToken;

  const Credential({
    required this.accessToken,
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() =>
      {'access_token': accessToken, 'refresh_token': refreshToken};

  factory Credential.fromJson(Map<String, dynamic> json) => Credential(
        accessToken: (json['access_token'] ?? '') as String,
        refreshToken: (json['refresh_token'] ?? '') as String,
      );

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
