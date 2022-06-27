import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owwn_coding_challenge/bloc/auth_cubit.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _emailValue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign In',
                style: textTheme.headline4?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                ),
                onSaved: (s) => _emailValue = s,
                validator: (s) => s?.isNotEmpty == true
                    ? null
                    : 'Enter a valid email address',
              ),
              const SizedBox(
                height: 25,
              ),
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(state.error)));
                  }
                },
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (_formKey.currentState?.validate() != true) return;
                      _formKey.currentState?.save();
                      BlocProvider.of<AuthCubit>(context).signIn(_emailValue!);
                    },
                    child: state is AuthLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Continue'),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
