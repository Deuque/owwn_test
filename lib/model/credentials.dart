import 'package:equatable/equatable.dart';

class Credential extends Equatable {
  final String accessToken;
  final String refreshToken;

  const Credential({
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
