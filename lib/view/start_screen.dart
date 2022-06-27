import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owwn_coding_challenge/bloc/credential_cubit.dart';

abstract class StartScreenKeys{
  static const startButton = Key('startButton');
}
class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Transform.translate(
          offset: const Offset(0, -68),
          child: SizedBox.square(
            dimension: 136,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                BlocProvider.of<CredentialCubit>(context).checkCredentials();
              },
              child: const DecoratedBox(
                key: StartScreenKeys.startButton,
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
    );
  }
}
