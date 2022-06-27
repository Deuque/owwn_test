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
      final newUsers = usersResponse!.users
        ..removeWhere((e) => _allUsers(state.userPages).contains(e));
      final newUserPages = [...state.userPages, newUsers];
      emit(
        state.copyWith(
          loading: false,
          userPages: newUserPages,
          hasLoadedAllUsers:
              _allUsers(newUserPages).length >= usersResponse.totalUsers,
        ),
      );
    }
  }

  void updateUser(User newUser) {
    final newUserPages = state.userPages.map((users) {
      return users.map((e) => e.id == newUser.id ? newUser : e).toList();
    }).toList();
    emit(state.copyWith(userPages: newUserPages));
  }

  User? getUser(String id) {
    final allUsers = _allUsers(state.userPages);
    for (final user in allUsers) {
      if (id == user.id) return user;
    }
    return null;
  }

  List<User> _allUsers(List<List<User>> userPages) =>
      userPages.fold<List<User>>(
        [],
        (previousValue, element) => previousValue..addAll(element),
      );
}
