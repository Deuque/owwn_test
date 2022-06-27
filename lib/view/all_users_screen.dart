import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owwn_coding_challenge/bloc/users_cubit.dart';
import 'package:owwn_coding_challenge/main.dart';
import 'package:owwn_coding_challenge/model/user.dart';
import 'package:owwn_coding_challenge/styles.dart';

abstract class AllUsersScreenKeys {
  static const errorView = Key('errorView');
  static const errorSnackBarView = Key('errorSnackBarView');
  static const loadedUsersView = Key('loadedUsersView');
  static const loadMoreButton = Key('loadMoreButton');
}

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({Key? key}) : super(key: key);

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController = ScrollController()
      ..addListener(() {
        final pixels = _scrollController.position.pixels;
        final maxExtent = _scrollController.position.maxScrollExtent;
        if (pixels == maxExtent) {
          _loadUsers();
        }
      });
  }

  void _loadUsers() => BlocProvider.of<UsersCubit>(context).loadUsers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            backgroundColor: AppColors.dark1,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final top = constraints.biggest.height;
                return FlexibleSpaceBar(
                  title: top <= 80 ? const Text('Users') : null,
                  centerTitle: true,
                  background: _background(),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              BlocConsumer<UsersCubit, UsersState>(
                listener: (_, state) {
                  if (state.userPages.isNotEmpty && state.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        key: AllUsersScreenKeys.errorSnackBarView,
                        content: Text(state.error!),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.userPages.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 20,
                      ),
                      child: Column(
                        key: AllUsersScreenKeys.loadedUsersView,
                        children: [
                          ...state.userPages.map(
                            (e) => _UsersPageLayout(
                              users: e,
                            ),
                          ),
                          if (state.loading)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          else if (!state.hasLoadedAllUsers)
                            TextButton(
                              key: AllUsersScreenKeys.loadMoreButton,
                              onPressed: _loadUsers,
                              child: const Text('Load more users'),
                            )
                        ],
                      ),
                    );
                  }
                  if (state.loading) {
                    return Container(
                      height: 40,
                      width: 40,
                      margin: const EdgeInsets.only(top: 30),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (state.error != null) {
                    return Container(
                      key: AllUsersScreenKeys.errorView,
                      padding: const EdgeInsets.only(top: 30),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            state.error.toString(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextButton(
                            onPressed: _loadUsers,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _background() => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/users_bg.png',
            fit: BoxFit.cover,
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.dark1,
                  ],
                  stops: [.4, 5],
                ),
              ),
            ),
          )
        ],
      );
}

class _UsersPageLayout extends StatelessWidget {
  final List<User> users;

  const _UsersPageLayout({
    Key? key,
    required this.users,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeUsers =
        users.where((element) => element.status == Status.active);
    final inActiveUsers =
        users.where((element) => element.status == Status.inactive);
    return Column(
      children: [
        if (activeUsers.isNotEmpty)
          _userGroup(
            context,
            'Active',
            activeUsers.toList(),
          ),
        if (inActiveUsers.isNotEmpty)
          _userGroup(context, 'Inactive', inActiveUsers.toList()),
      ],
    );
  }

  Widget _userGroup(BuildContext context, String title, List<User> groupUsers) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
        const SizedBox(
          height: 30,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.grey4,
          ),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) {
              final user = groupUsers[i];
              return ListTile(
                onTap: () => context
                    .goNamed(RouteNames.userDetails, params: {'id': user.id}),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                leading: Hero(
                  tag: user.initials,
                  child: CircleAvatar(
                    backgroundColor: AppColors.grey3,
                    radius: 19,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                title: Hero(
                  tag: user.name,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      user.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                subtitle: Hero(
                  tag: user.email,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey2,
                      ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, i) => const Divider(
              height: 1.5,
              thickness: 1.5,
              color: AppColors.dark1,
            ),
            itemCount: groupUsers.length,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
