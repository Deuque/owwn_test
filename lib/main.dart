import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:owwn_coding_challenge/bloc/auth_cubit.dart';
import 'package:owwn_coding_challenge/bloc/credential_cubit.dart';
import 'package:owwn_coding_challenge/bloc/users_cubit.dart';
import 'package:owwn_coding_challenge/helpers/http_helper.dart';
import 'package:owwn_coding_challenge/helpers/selectors.dart';
import 'package:owwn_coding_challenge/service/auth_service.dart';
import 'package:owwn_coding_challenge/service/credential_service.dart';
import 'package:owwn_coding_challenge/service/users_service.dart';
import 'package:owwn_coding_challenge/styles.dart';
import 'package:owwn_coding_challenge/view/all_users_screen.dart';
import 'package:owwn_coding_challenge/view/auth_screen.dart';
import 'package:owwn_coding_challenge/view/start_screen.dart';
import 'package:owwn_coding_challenge/view/user_details_screen.dart';

class Config {
  final CredentialService credentialService;
  final AuthService Function(BuildContext) authService;
  final UsersService Function(BuildContext) usersService;

  Config({
    required this.credentialService,
    required this.authService,
    required this.usersService,
  });
}

void main() {
  HttpHelper getHttpHelper(BuildContext context) => HttpHelperImpl(
        baseUrl: 'https://ccoding.owwn.com/hermes',
        client: http.Client(),
        getAccessToken: () => credentialSel(context)?.accessToken ?? '',
        getRefreshToken: () => credentialSel(context)?.refreshToken ?? '',
        onRefreshTokenExpired: () =>
            BlocProvider.of<CredentialCubit>(context).deleteCredentials(),
        onRefreshCredential:
            BlocProvider.of<CredentialCubit>(context).saveCredentials,
      );

  final config = Config(
    credentialService: CredentialServiceImpl(const FlutterSecureStorage()),
    authService: (context) => AuthServiceImpl(getHttpHelper(context)),
    usersService: (context) => UsersServiceImpl(getHttpHelper(context)),
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
              const AllUsersScreen(),
          routes: [
            GoRoute(
              name: RouteNames.userDetails,
              path: RoutePaths.userDetails,
              builder: (BuildContext context, GoRouterState state) =>
                  UserDetailsScreen(
                userId: state.params['id'] ?? '',
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
          ),
          BlocProvider(
            create: (context) => UsersCubit(
              widget.config.usersService(context),
            ),
          )
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
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
  static const userDetails = ':id';
}

class RouteNames {
  static const userDetails = 'user_details';
}
