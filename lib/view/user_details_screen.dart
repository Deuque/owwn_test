import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:line_chart/charts/line-chart.widget.dart';
import 'package:line_chart/model/line-chart.model.dart';
import 'package:owwn_coding_challenge/bloc/users_cubit.dart';
import 'package:owwn_coding_challenge/model/user.dart';
import 'package:owwn_coding_challenge/styles.dart';

abstract class UserDetailsScreenKeys {
  static const emailField = Key('emailField');
  static const nameField = Key('nameField');
  static const saveButton = Key('saveButton');
  static const backButton = Key('backButton');
  static const statisticsChart = Key('statisticsChart');
  static const statisticsTooltipDisplay = Key('statisticsTooltipDisplay');
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Hero(
                                tag: user.initials + user.id,
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
                                tag: user.name + user.id,
                                child: Material(
                                  color: Colors.transparent,
                                  child: TextFormField(
                                    key: UserDetailsScreenKeys.nameField,
                                    focusNode: _nameFocusNode,
                                    initialValue: name,
                                    maxLines: 2,
                                    minLines: 1,
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
                                tag: user.email + user.id,
                                child: Material(
                                  color: Colors.transparent,
                                  child: TextFormField(
                                    key: UserDetailsScreenKeys.emailField,
                                    focusNode: _emailFocusNode,
                                    initialValue: email,
                                    maxLines: 2,
                                    minLines: 1,
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
                              const SizedBox(
                                height: 100,
                              ),
                              SizedBox(
                                height: 160.0,
                                child: _UserStatistics(
                                  statistics: user.statistics
                                      .map((e) => e.toDouble())
                                      .toList(),
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

class _UserStatistics extends StatefulWidget {
  final List<double> statistics;

  const _UserStatistics({Key? key, required this.statistics}) : super(key: key);

  @override
  State<_UserStatistics> createState() => _UserStatisticsState();
}

class _UserStatisticsState extends State<_UserStatistics> {
  double _panXUpdate = 0;
  double _panStatisticsValue = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: _panXUpdate <= 0 ? 0 : 1,
          child: Transform.translate(
            offset: Offset(_panXUpdate == 0 ? 0 : _panXUpdate - 15, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                key: UserDetailsScreenKeys.statisticsTooltipDisplay,
                '$_panStatisticsValue',
                style: const TextStyle(color: AppColors.dark1),
              ),
            ),
          ),
        ),
        if (widget.statistics.isNotEmpty)
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 10,
                  left: 0,
                  bottom: 0,
                  child: Sparkline(
                    data: widget.statistics,
                    lineWidth: 2.0,
                    lineColor: Colors.white,
                    useCubicSmoothing: true,
                    cubicSmoothingFactor: 0.2,
                  ),
                ),
                LayoutBuilder(
                  builder: (_, constraints) {
                    return Listener(
                      key: UserDetailsScreenKeys.statisticsChart,
                      onPointerMove: (moveEvent) {
                        setState(() {
                          _panXUpdate = moveEvent.position.dx;
                        });
                      },
                      child: LineChart(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        data: List.generate(
                          widget.statistics.length,
                          (index) => LineChartModel(
                            date: DateTime.now().add(
                              Duration(days: index + 1),
                            ),
                            amount: widget.statistics[index],
                          ),
                        ),
                        linePaint: Paint()
                          ..strokeWidth = 2
                          ..style = PaintingStyle.stroke
                          ..color = Colors.transparent,
                        circlePaint: Paint()..color = Colors.white,
                        showPointer: true,
                        linePointerDecoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        pointerDecoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        onValuePointer: (LineChartModelCallback value) {
                          setState(() {
                            _panStatisticsValue = value.chart?.amount ?? 0;
                          });
                        },
                        onDropPointer: () {
                          setState(() {
                            _panXUpdate = 0;
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        const SizedBox(
          height: 40,
        ),
        LayoutBuilder(
          builder: (_, constraints) {
            const double dashWidth = 6;
            const double dashSpacing = 4;
            final amountOfDashes =
                constraints.maxWidth ~/ (dashWidth + dashSpacing);
            return SizedBox(
              height: 2.5,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(
                  amountOfDashes,
                  (index) => Container(
                    width: dashWidth,
                    margin: const EdgeInsets.only(right: dashSpacing),
                    decoration: const BoxDecoration(color: AppColors.grey4),
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
