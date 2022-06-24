import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owwn_coding_challenge/bloc/auth_cubit.dart';
import 'package:owwn_coding_challenge/main.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (_, state) {
        if (state == AuthState.authorized) {
          context.goNamed(RouteNames.authScreen);
        }
      },
      child: Scaffold(
        body: Center(
          child: Transform.translate(
            offset: const Offset(0, -68),
            child: SizedBox.square(
              dimension: 136,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  BlocProvider.of<AuthCubit>(context).authorize();
                },
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        Colors.transparent,
                      ],
                      stops: [.8, 1],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Press to start',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
