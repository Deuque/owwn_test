part of 'users_cubit.dart';

class UsersState extends Equatable {
  final bool loading;
  final List<List<User>> userPages;
  final String? error;
  final bool hasLoadedAllUsers;

  const UsersState({
    required this.loading,
    required this.userPages,
    this.error,
    required this.hasLoadedAllUsers,
  });

  factory UsersState.initial() => const UsersState(
        loading: false,
        userPages: [],
        hasLoadedAllUsers: false,
      );

  UsersState copyWith({
    bool? loading,
    List<List<User>>? userPages,
    bool? hasLoadedAllUsers,
  }) =>
      UsersState(
        loading: loading ?? this.loading,
        userPages: userPages ?? this.userPages,
        hasLoadedAllUsers: hasLoadedAllUsers ?? this.hasLoadedAllUsers,
      );

  UsersState withError(
    String? newError,
  ) =>
      UsersState(
        loading: false,
        userPages: userPages,
        hasLoadedAllUsers: hasLoadedAllUsers,
        error: newError,
      );

  @override
  List<Object?> get props => [loading, userPages, error, hasLoadedAllUsers];
}

class UsersResponse {
  final List<User> users;
  final int totalUsers;

  UsersResponse(this.users, this.totalUsers);

  factory UsersResponse.fromJson(Map<String, dynamic> json) => UsersResponse(
        (json['users'] as List)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList(),
        json['total'] as int,
      );
}
