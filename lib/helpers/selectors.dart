import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owwn_coding_challenge/bloc/credential_cubit.dart';
import 'package:owwn_coding_challenge/model/credentials.dart';

Credential? credentialSel(BuildContext context) {
  final credentialState = BlocProvider.of<CredentialCubit>(context).state;
  if (credentialState is CredentialsAuthorized) {
    return credentialState.credential;
  }
  return null;
}
