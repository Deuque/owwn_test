import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:owwn_coding_challenge/bloc/auth_cubit.dart';
import 'package:owwn_coding_challenge/service/auth_service.dart';
import 'package:owwn_coding_challenge/styles.dart';
import 'package:owwn_coding_challenge/view/auth_screen.dart';
import 'package:owwn_coding_challenge/view/start_screen.dart';

class BlocConfig {
  final AuthCubit authCubit;

  BlocConfig(this.authCubit);
}

void main() {
  runApp(
    MyApp(
      blocConfig:
          BlocConfig(AuthCubit(AuthService(const FlutterSecureStorage()))),
    ),
  );
}

class MyApp extends StatelessWidget {
  final BlocConfig blocConfig;

  MyApp({
    super.key,
    required this.blocConfig,
  });

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: <GoRoute>[
      GoRoute(
        name: RouteNames.startScreen,
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const StartScreen(),
      ),
      GoRoute(
        name: RouteNames.authScreen,
        path: '/auth',
        builder: (BuildContext context, GoRouterState state) =>
            const AuthScreen(),
      ),
      GoRoute(
        name: RouteNames.secondPage,
        path: '/page2',
        builder: (BuildContext context, GoRouterState state) =>
            const SecondPage(),
        routes: [
          GoRoute(
            name: RouteNames.thirdPage,
            path: ':name',
            builder: (BuildContext context, GoRouterState state) => ThirdPage(
              userName: state.params['name'] ?? '',
            ),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => blocConfig.authCubit,
          )
        ],
        child: MaterialApp.router(
          routeInformationProvider: _router.routeInformationProvider,
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
          title: 'Coding Test',
          theme: darkTheme,
        ),
      );
}

class RouteNames {
  static const startScreen = '/';
  static const authScreen = 'auth';
  static const secondPage = 'secondpage';
  static const thirdPage = 'thirdpage';
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: Column(
        children: users.map((user) {
          return GestureDetector(
            onTap: () => context
                .goNamed(RouteNames.thirdPage, params: {'name': user.name}),
            child: Container(
              margin: const EdgeInsets.only(bottom: 1),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Text(user.name.substring(0, 1)),
                  ),
                  Expanded(
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Colors.black),
                      child: Column(
                        children: [
                          Text(user.name),
                          Text(user.email),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  final String userName;

  const ThirdPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final user = users.firstWhere(
      (element) => element.name == userName,
      orElse: () => const User(
        name: 'name',
        email: 'email',
        gender: Gender.male,
        status: Status.active,
        statistics: [],
      ),
    );
    return Scaffold(
      body: Align(
        alignment: const Alignment(0, -.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Text(user.name.substring(0, 1)),
            ),
            SizedBox(
              height: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(user.name),
                  Text(user.email),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum Gender { male, female }

enum Status { active, inactive }

class User {
  final String name;
  final String email;
  final Gender gender;
  final Status status;
  final List<double> statistics;

  const User({
    required this.name,
    required this.email,
    required this.gender,
    required this.status,
    required this.statistics,
  });
}

List<User> users = const [
  User(
    name: 'Soheil',
    email: 'soheil@owwn.com',
    gender: Gender.male,
    status: Status.active,
    statistics: [],
  ),
  User(
    name: 'Daniel',
    email: 'daniel@owwn.com',
    gender: Gender.male,
    status: Status.active,
    statistics: [],
  ),
  User(
    name: 'Amir',
    email: 'amir@owwn.com',
    gender: Gender.male,
    status: Status.inactive,
    statistics: [],
  ),
  User(
    name: 'Umit',
    email: 'umit@owwn.com',
    gender: Gender.male,
    status: Status.inactive,
    statistics: [],
  ),
];
