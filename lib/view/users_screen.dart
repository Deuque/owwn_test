import 'package:flutter/material.dart';
import 'package:owwn_coding_challenge/styles.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      print(_scrollController.position.maxScrollExtent);
      print(_scrollController.position.pixels);
      // if (_scrollController.position.maxScrollExtent ==
      //     _scrollController.position.pixels) {
      //   if (!isLoading) {
      //     isLoading = !isLoading;
      //     // Perform event when user reach at the end of list (e.g. do Api call)
      //   }
      // }
    });
  }

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
          SliverFillRemaining(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Text('Hekkkkkoo'),
            ),
          )
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
            )),
          ))
        ],
      );
}
