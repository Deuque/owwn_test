import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/src/response.dart';
import 'package:owwn_coding_challenge/bloc/users_cubit.dart';
import 'package:owwn_coding_challenge/helpers/http_helper.dart';
import 'package:owwn_coding_challenge/service/users_service.dart';
import 'package:owwn_coding_challenge/view/all_users_screen.dart';

import 'widget_object.dart';

void main() {
  late WidgetObject widgetObject;
  late UsersCubit usersCubit;
  testWidgets(
    'Users list loads the first page and fails on the second page',
    (WidgetTester tester) async {
      widgetObject = WidgetObject<AllUsersScreen>(tester);
      final httpHelper = MockHttpHelper(
        (endpoint) => endpoint.contains('page=1')
            ? Response(sampleUsersResponse, 200)
            : Response('An error occurred', 400),
      );
      usersCubit = UsersCubit(UsersServiceImpl(httpHelper));
      await tester.pumpWidget(
        _buildWidget(usersCubit: usersCubit, layout: const AllUsersScreen()),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // finds loaded users view when first page is loaded
      expect(
        widgetObject.pageFinderByKey(AllUsersScreenKeys.loadedUsersView),
        findsOneWidget,
      );
      // finds no error on first page load
      expect(usersCubit.state.error, null);

      // tapping load more button to load second page...
      await widgetObject.tapView(
        widgetObject.pageFinderByKey(AllUsersScreenKeys.loadMoreButton),
      );
      expect(
        widgetObject.pageFinderByKey(AllUsersScreenKeys.loadedUsersView),
        findsOneWidget,
      );
      // finds error snackbar view when second page is loaded
      expect(
        widgetObject.pageFinderByKey(AllUsersScreenKeys.errorSnackBarView),
        findsOneWidget,
      );
      // finds error on second page load
      expect(usersCubit.state.error, 'An error occurred');
    },
  );

  testWidgets(
    'Tap on an item and change users name then pop and check if details are updated',
    (WidgetTester tester) async {},
  );

  testWidgets(
    'Panning on the chart shows the currect value',
    (WidgetTester tester) async {},
  );
}

String sampleUsersResponse = jsonEncode({
  'users': [
    {
      "id": "id1",
      "name": "Ralph",
      "gender": "male",
      "status": "inactive",
    }
  ],
  'total': 30
});

Widget _buildWidget({required UsersCubit usersCubit, required Widget layout}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => usersCubit),
    ],
    child: MaterialApp(
      home: layout,
    ),
  );
}

class MockHttpHelper extends HttpHelper {
  final Response Function(String endPoint) responseToReturn;

  MockHttpHelper(this.responseToReturn);

  @override
  Future<Response> sendRequest({
    required String method,
    required String endPoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) =>
      Future.value(responseToReturn(endPoint));
}
