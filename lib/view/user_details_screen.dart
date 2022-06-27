import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owwn_coding_challenge/bloc/users_cubit.dart';
import 'package:owwn_coding_challenge/model/user.dart';
import 'package:owwn_coding_challenge/styles.dart';

abstract class UserDetailsScreenKeys {
  static const emailField = Key('emailField');
  static const nameField = Key('nameField');
  static const saveButton = Key('saveButton');
  static const backButton = Key('backButton');
}

class UserDetailsScreen extends StatefulWidget {
  final String userId;

  const UserDetailsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  bool _editing = false;
  final _formKey = GlobalKey<FormState>();
  late FocusNode _nameFocusNode;
  late FocusNode _emailFocusNode;
  late String name;
  late String email;

  void _editingListener() {
    if ((_nameFocusNode.hasFocus || _emailFocusNode.hasFocus) && !_editing) {
      if (mounted) {
        setState(() {
          _editing = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _nameFocusNode.addListener(_editingListener);
    _emailFocusNode.addListener(_editingListener);
  }

  @override
  void dispose() {
    super.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
  }

  UsersCubit get usersCubit => BlocProvider.of<UsersCubit>(context);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_editing) {
          _stopEditing();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: !_editing
              ? IconButton(
                  key: UserDetailsScreenKeys.backButton,
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios),
                )
              : null,
          actions: [
            if (_editing)
              IconButton(
                onPressed: _stopEditing,
                icon: const Icon(Icons.close),
              )
          ],
        ),
        body: Stack(
          children: [
            BlocBuilder<UsersCubit, UsersState>(
              builder: (context, state) {
                final user = usersCubit.getUser(widget.userId);
                if (user == null) {
                  return const Center(
                    child: Text(
                      'User not found',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final genderIcon = user.gender == Gender.male
                    ? Icons.male
                    : user.gender == Gender.female
                        ? Icons.female
                        : Icons.circle_outlined;
                name = user.name;
                email = user.email;
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Hero(
                                tag: user.initials,
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.grey3,
                                      radius: 55,
                                      child: Text(
                                        user.initials,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          genderIcon,
                                          size: 19,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 34,
                              ),
                              Hero(
                                tag: user.name,
                                child: Material(
                                  color: Colors.transparent,
                                  child: TextFormField(
                                    key: UserDetailsScreenKeys.nameField,
                                    focusNode: _nameFocusNode,
                                    initialValue: name,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    validator: _requiredField,
                                    onSaved: (s) => name = s!,
                                  ),
                                ),
                              ),
                              Hero(
                                tag: user.email,
                                child: Material(
                                  color: Colors.transparent,
                                  child: TextFormField(
                                    key: UserDetailsScreenKeys.emailField,
                                    focusNode: _emailFocusNode,
                                    initialValue: email,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.grey2,
                                    ),
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    validator: _requiredField,
                                    onSaved: (s) => email = s!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_editing)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        child: ElevatedButton(
                          key: UserDetailsScreenKeys.saveButton,
                          onPressed: () => _onUpdate(user),
                          child: const Text('SAVE'),
                        ),
                      )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredField(String? s) =>
      s?.isNotEmpty == true ? null : 'Required field';

  void _stopEditing() {
    setState(() {
      _editing = false;
    });
    _nameFocusNode.unfocus();
    _emailFocusNode.unfocus();
  }

  void _onUpdate(User oldUser) {
    if (_formKey.currentState?.validate() != true) return;
    _formKey.currentState?.save();

    final newUser = User(
      id: oldUser.id,
      name: name,
      email: email,
      initials: oldUser.initials,
      gender: oldUser.gender,
      status: oldUser.status,
      statistics: oldUser.statistics,
    );

    usersCubit.updateUser(newUser);
    _stopEditing();
  }
}
