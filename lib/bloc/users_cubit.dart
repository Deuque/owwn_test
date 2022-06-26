import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owwn_coding_challenge/model/user.dart';
import 'package:owwn_coding_challenge/service/users_service.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final UsersService usersService;

  UsersCubit(this.usersService) : super(UsersState.initial());

  int get limit => 11;

  Future<void> loadUsers() async {
    if (state.loading || state.hasLoadedAllUsers) return;
    emit(state.copyWith(loading: true));
    final pageToLoad = state.userPages.length + 1;
    final response = await usersService.loadUsers(limit, pageToLoad);
    if (response.error != null) {
      emit(state.withError(response.error.toString()));
    } else {
      final usersResponse = response.value;
      emit(
        state.copyWith(
          loading: false,
          userPages: [...state.userPages, usersResponse!.users],
          hasLoadedAllUsers: hasLoadedAllUsers(
            userPagesLength: pageToLoad,
            totalUsers: usersResponse.totalUsers,
          ),
        ),
      );
    }
  }

  bool hasLoadedAllUsers({
    required int userPagesLength,
    required int totalUsers,
  }) {
    return (limit * userPagesLength) >= totalUsers;
  }
}
