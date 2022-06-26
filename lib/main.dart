import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:owwn_coding_challenge/bloc/auth_cubit.dart';
import 'package:owwn_coding_challenge/bloc/credential_cubit.dart';
import 'package:owwn_coding_challenge/helpers/http_helper.dart';
import 'package:owwn_coding_challenge/helpers/selectors.dart';
import 'package:owwn_coding_challenge/service/auth_service.dart';
import 'package:owwn_coding_challenge/service/credential_service.dart';
import 'package:owwn_coding_challenge/styles.dart';
import 'package:owwn_coding_challenge/view/auth_screen.dart';
import 'package:owwn_coding_challenge/view/start_screen.dart';
import 'package:owwn_coding_challenge/view/users_screen.dart';

class Config {
  final CredentialService credentialService;
  final AuthService Function(BuildContext) authService;

  Config({
    required this.credentialService,
    required this.authService,
  });
}

void main() {
  HttpHelper getHttpHelper(BuildContext context) => HttpHelper(
        baseUrl: 'https://ccoding.owwn.com/hermes',
        client: http.Client(),
        getAccessToken: () => credentialSel(context)?.accessToken ?? '',
        getRefreshToken: () => credentialSel(context)?.refreshToken ?? '',
        onRefreshTokenExpired: () =>
            BlocProvider.of<CredentialCubit>(context).deleteCredentials,
        onRefreshCredential:
            BlocProvider.of<CredentialCubit>(context).saveCredentials,
      );

  final config = Config(
    credentialService: CredentialServiceImpl(const FlutterSecureStorage()),
    authService: (context) => AuthServiceImpl(getHttpHelper(context)),
  );
  runApp(
    MyApp(
      config: config,
    ),
  );
}

class MyApp extends StatefulWidget {
  final Config config;

  const MyApp({
    super.key,
    required this.config,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CredentialCubit credentialCubit;
  late GoRouter router;

  @override
  void initState() {
    super.initState();

    credentialCubit = CredentialCubit(
      widget.config.credentialService,
    );

    final authListenable = credentialCubit.credentialsListenable;

    router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: authListenable,
      redirect: (state) {
        final authorized = authListenable.value is CredentialsAuthorized;
        final unAuthorized = authListenable.value is CredentialsUnAuthorized;

        if (unAuthorized && state.location != RoutePaths.authScreen) {
          return RoutePaths.authScreen;
        }

        if (authorized &&
            (state.location == RoutePaths.startScreen ||
                state.location == RoutePaths.authScreen)) {
          return RoutePaths.users;
        }

        return null;
      },
      routes: <GoRoute>[
        GoRoute(
          path: RoutePaths.startScreen,
          builder: (BuildContext context, GoRouterState state) =>
              const StartScreen(),
        ),
        GoRoute(
          path: RoutePaths.authScreen,
          builder: (BuildContext context, GoRouterState state) =>
              const AuthScreen(),
        ),
        GoRoute(
          path: RoutePaths.users,
          builder: (BuildContext context, GoRouterState state) =>
              const UsersScreen(),
          routes: [
            GoRoute(
              name: RouteNames.userDetails,
              path: RoutePaths.userDetails,
              builder: (BuildContext context, GoRouterState state) => ThirdPage(
                userName: state.params['name'] ?? '',
              ),
            ),
          ],
        ),
      ],
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => credentialCubit,
          ),
          BlocProvider(
            create: (context) => AuthCubit(
              widget.config.authService(context),
              BlocProvider.of<CredentialCubit>(context),
            ),
          )
        ],
        child: MaterialApp.router(
          routeInformationProvider: router.routeInformationProvider,
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          title: 'Coding Test',
          theme: darkTheme,
        ),
      );
}

class RoutePaths {
  static const startScreen = '/';
  static const authScreen = '/auth';
  static const users = '/users';
  static const userDetails = ':name';
}

class RouteNames {
  static const userDetails = 'user_details';
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            onPressed: () {
              BlocProvider.of<CredentialCubit>(context).deleteCredentials();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: users.map((user) {
          return GestureDetector(
            onTap: () => context
                .goNamed(RouteNames.userDetails, params: {'name': user.name}),
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
