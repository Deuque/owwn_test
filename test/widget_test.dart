import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/src/response.dart';
import 'package:owwn_coding_challenge/bloc/users_cubit.dart';
import 'package:owwn_coding_challenge/helpers/http_helper.dart';
import 'package:owwn_coding_challenge/main.dart';
import 'package:owwn_coding_challenge/model/credentials.dart';
import 'package:owwn_coding_challenge/service/auth_service.dart';
import 'package:owwn_coding_challenge/service/credential_service.dart';
import 'package:owwn_coding_challenge/service/users_service.dart';
import 'package:owwn_coding_challenge/view/all_users_screen.dart';
import 'package:owwn_coding_challenge/view/start_screen.dart';
import 'package:owwn_coding_challenge/view/user_details_screen.dart';

import 'widget_object.dart';

void main() {
  late UsersCubit usersCubit;
  testWidgets(
    'Users list loads the first page and fails on the second page',
    (WidgetTester tester) async {
      final allUserObject = WidgetObject<AllUsersScreen>(tester);
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
        allUserObject.pageFinderByKey(AllUsersScreenKeys.loadedUsersView),
        findsOneWidget,
      );
      // finds no error on first page load
      expect(usersCubit.state.error, null);

      // tapping load more button to load second page...
      await allUserObject.tapView(
        allUserObject.pageFinderByKey(AllUsersScreenKeys.loadMoreButton),
      );
      expect(
        allUserObject.pageFinderByKey(AllUsersScreenKeys.loadedUsersView),
        findsOneWidget,
      );
      // finds error snackbar view when second page is loaded
      expect(
        allUserObject.pageFinderByKey(AllUsersScreenKeys.errorSnackBarView),
        findsOneWidget,
      );
      // finds error on second page load
      expect(usersCubit.state.error, 'An error occurred');
    },
  );

  testWidgets(
    'Tap on an item and change users name then pop and check if details are updated',
    (WidgetTester tester) async {
      final allUserObject = WidgetObject<AllUsersScreen>(tester);
      final httpHelper = MockHttpHelper(
        (_) => Response(sampleUsersResponse, 200),
      );
      usersCubit = UsersCubit(UsersServiceImpl(httpHelper));
      final config = Config(
        credentialService: MockCredentialService(),
        authService: (_) => AuthServiceImpl(httpHelper),
        usersService: (_) => UsersServiceImpl(httpHelper),
      );
      await tester.pumpWidget(
        _buildWidget(
          usersCubit: usersCubit,
          layout: MyApp(config: config),
        ),
      );

      await tester.tap(find.byKey(StartScreenKeys.startButton));

      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // verify ralph user shows in user list
      expect(find.text('Ralph'), findsOneWidget);
      expect(find.text('R@gmail.com'), findsOneWidget);
      // click on ralph to move to details screen
      await allUserObject.tapView(find.text('Ralph'));

      final userDetailsObject = WidgetObject<UserDetailsScreen>(tester);
      // verify user details screen is visible
      expect(userDetailsObject.widget, findsOneWidget);
      // tap name field to begin editing
      await userDetailsObject.tapView(
        userDetailsObject.pageFinderByKey(UserDetailsScreenKeys.nameField),
      );
      // enter new name
      await tester.enterText(
        userDetailsObject.pageFinderByKey(UserDetailsScreenKeys.nameField),
        'NewRalph',
      );
      // enter new email
      await tester.enterText(
        userDetailsObject.pageFinderByKey(UserDetailsScreenKeys.emailField),
        'newr@gmail.com',
      );
      // tap save button to save new texts
      await userDetailsObject.tapView(
        userDetailsObject.pageFinderByKey(UserDetailsScreenKeys.saveButton),
      );

      // go back to user list screen
      await userDetailsObject.tapView(
        userDetailsObject.pageFinderByKey(UserDetailsScreenKeys.backButton),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      // verify user list screen is visible
      expect(allUserObject.widget, findsOneWidget);
      // verify new ralph user details shows in user list
      expect(allUserObject.pageFinder(find.text('NewRalph')), findsOneWidget);
      expect(
        allUserObject.pageFinder(find.text('newr@gmail.com')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Panning on the chart shows the correct value',
    (WidgetTester tester) async {
      final userDetailsObject = WidgetObject<UserDetailsScreen>(tester);
      final httpHelper = MockHttpHelper(
        (_) => Response(sampleUsersResponse, 200),
      );
      usersCubit = UsersCubit(UsersServiceImpl(httpHelper));
      await usersCubit.loadUsers();
      await tester.pumpWidget(
        _buildWidget(
          usersCubit: usersCubit,
          layout: const UserDetailsScreen(userId: 'id1'),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // verify statistics chart is visible
      expect(
        userDetailsObject
            .pageFinderByKey(UserDetailsScreenKeys.statisticsChart),
        findsOneWidget,
      );

      // verify that dragging chart shows statistics value
      await tester.dragUntilVisible(
        userDetailsObject
            .pageFinderByKey(UserDetailsScreenKeys.statisticsChart),
        userDetailsObject
            .pageFinderByKey(UserDetailsScreenKeys.statisticsTooltipDisplay),
        const Offset(4, 4),
      );
    },
  );
}

String sampleUsersResponse = jsonEncode({
  'users': [
    {
      "id": "id1",
      "name": "Ralph",
      "gender": "male",
      "status": "inactive",
      "statistics": [20, 40, 60],
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

class MockCredentialService extends CredentialService {
  @override
  Future<void> deleteCredentials() {
    throw UnimplementedError();
  }

  @override
  Future<Credential?> getCredentials() {
    return Future.value(
      const Credential(
        accessToken: 'accessToken',
        refreshToken: 'refreshToken',
      ),
    );
  }

  @override
  Future<void> saveCredentials(Credential credential) {
    throw UnimplementedError();
  }
}
