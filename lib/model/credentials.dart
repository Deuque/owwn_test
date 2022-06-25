import 'package:equatable/equatable.dart';

class Credential extends Equatable {
  final String accessToken;
  final String refreshToken;

  const Credential({
    required this.accessToken,
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() =>
      {'accessToken': accessToken, 'refreshToken': refreshToken};

  factory Credential.fromJson(Map<String, dynamic> json) => Credential(
        accessToken: (json['accessToken'] ?? '') as String,
        refreshToken: (json['refreshToken'] ?? '') as String,
      );

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
