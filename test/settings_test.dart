import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_hub_demo/authentication/model/user.dart';
import 'package:student_hub_demo/authentication/service/auth_provider.dart';
import 'package:student_hub_demo/main.dart';
import 'package:student_hub_demo/pages/faq/model/question.dart';
import 'package:student_hub_demo/pages/faq/service/question_provider.dart';
import 'package:student_hub_demo/pages/news_feed/model/news_feed_item.dart';
import 'package:student_hub_demo/pages/news_feed/service/news_provider.dart';
import 'package:student_hub_demo/pages/portal/service/website_provider.dart';
import 'package:student_hub_demo/pages/settings/service/request_provider.dart';
import 'package:student_hub_demo/pages/settings/view/request_permissions.dart';
import 'package:student_hub_demo/pages/settings/view/settings_page.dart';
import 'package:student_hub_demo/resources/locale_provider.dart';
import 'package:student_hub_demo/widgets/dialog.dart';

import 'test_utils.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

class MockWebsiteProvider extends Mock implements WebsiteProvider {}

class MockQuestionProvider extends Mock implements QuestionProvider {}

class MockRequestProvider extends Mock implements RequestProvider {}

class MockNewsProvider extends Mock implements NewsProvider {}

void main() {
  AuthProvider mockAuthProvider;
  WebsiteProvider mockWebsiteProvider;
  MockQuestionProvider mockQuestionProvider;
  RequestProvider mockRequestProvider;
  MockNewsProvider mockNewsProvider;

  group('Settings', () {
    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      PrefService.enableCaching();
      PrefService.cache = {};
      // Assuming mock system language is English
      SharedPreferences.setMockInitialValues({'language': 'auto'});

      LocaleProvider.cultures = testCultures;
      LocaleProvider.rruleL10ns = {'en': await RruleL10nTest.create()};

      // Pretend an anonymous user is already logged in
      mockAuthProvider = MockAuthProvider();
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      // ignore: invalid_use_of_protected_member
      when(mockAuthProvider.hasListeners).thenReturn(false);
      when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(null));
      when(mockAuthProvider.isAnonymous).thenReturn(true);
      when(mockAuthProvider.getProfilePictureURL(context: anyNamed('context')))
          .thenAnswer((_) => Future.value(null));
      when(mockAuthProvider.isVerified).thenAnswer((_) => Future.value(true));

      mockWebsiteProvider = MockWebsiteProvider();
      // ignore: invalid_use_of_protected_member
      when(mockWebsiteProvider.hasListeners).thenReturn(false);
      when(mockWebsiteProvider.deleteWebsite(any, context: anyNamed('context')))
          .thenAnswer((_) => Future.value(true));
      when(mockWebsiteProvider.fetchWebsites(any, context: anyNamed('context')))
          .thenAnswer((_) => Future.value([]));
      when(mockWebsiteProvider.fetchFavouriteWebsites(
              uid: anyNamed('uid'), context: anyNamed('context')))
          .thenAnswer((_) => Future.value(null));

      mockQuestionProvider = MockQuestionProvider();
      // ignore: invalid_use_of_protected_member
      when(mockQuestionProvider.hasListeners).thenReturn(false);
      when(mockQuestionProvider.fetchQuestions(context: anyNamed('context')))
          .thenAnswer((_) => Future.value(<Question>[]));
      when(mockQuestionProvider.fetchQuestions(limit: anyNamed('limit')))
          .thenAnswer((_) => Future.value(<Question>[]));

      mockRequestProvider = MockRequestProvider();
      when(mockRequestProvider.makeRequest(any, context: anyNamed('context')))
          .thenAnswer((_) => Future.value(true));
      when(mockRequestProvider.userAlreadyRequested(any,
              context: anyNamed('context')))
          .thenAnswer((_) => Future.value(false));

      mockNewsProvider = MockNewsProvider();
      // ignore: invalid_use_of_protected_member
      when(mockNewsProvider.hasListeners).thenReturn(false);
      when(mockNewsProvider.fetchNewsFeedItems(context: anyNamed('context')))
          .thenAnswer((_) => Future.value(<NewsFeedItem>[]));
      when(mockNewsProvider.fetchNewsFeedItems(limit: anyNamed('limit')))
          .thenAnswer((_) => Future.value(<NewsFeedItem>[]));
    });

    testWidgets('Dark Mode', (WidgetTester tester) async {
      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => mockAuthProvider),
        ChangeNotifierProvider<WebsiteProvider>(
            create: (_) => mockWebsiteProvider),
        ChangeNotifierProvider<QuestionProvider>(
            create: (_) => mockQuestionProvider),
        ChangeNotifierProvider<NewsProvider>(create: (_) => mockNewsProvider),
      ], child: const MyApp()));
      await tester.pumpAndSettle();

      MaterialApp app = find.byType(MaterialApp).evaluate().first.widget;
      expect(app.theme.brightness, equals(Brightness.light));

      // Open settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Toggle dark mode
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();

      app = find.byType(MaterialApp).evaluate().first.widget;
      expect(app.theme.brightness, equals(Brightness.dark));

      // Toggle dark mode
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();

      app = find.byType(MaterialApp).evaluate().first.widget;
      expect(app.theme.brightness, equals(Brightness.light));
    });

    testWidgets('Language', (WidgetTester tester) async {
      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => mockAuthProvider),
        ChangeNotifierProvider<WebsiteProvider>(
            create: (_) => mockWebsiteProvider),
        ChangeNotifierProvider<QuestionProvider>(
            create: (_) => mockQuestionProvider),
        ChangeNotifierProvider<NewsProvider>(create: (_) => mockNewsProvider),
      ], child: const MyApp()));
      await tester.pumpAndSettle();

      // Open settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Auto'), findsOneWidget);

      // Romanian
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Romanian'));
      await tester.pumpAndSettle();

      expect(find.text('Setări'), findsOneWidget);
      expect(find.text('Română'), findsOneWidget);

      // English
      await tester.tap(find.text('Limbă'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Engleză'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // Back to Auto (English)
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Auto'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
    });
    group('Request permissions', () {
      setUpAll(() async {
        when(mockAuthProvider.currentUser).thenAnswer((_) =>
            Future.value(User(uid: '0', firstName: 'John', lastName: 'Doe')));
        when(mockAuthProvider.isAnonymous).thenReturn(false);
      });

      testWidgets('Normal scenario', (WidgetTester tester) async {
        when(mockAuthProvider.isVerified).thenAnswer((_) => Future.value(true));

        await tester.pumpWidget(MultiProvider(providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => mockAuthProvider),
          ChangeNotifierProvider<WebsiteProvider>(
              create: (_) => mockWebsiteProvider),
          ChangeNotifierProvider<QuestionProvider>(
              create: (_) => mockQuestionProvider),
          Provider<RequestProvider>(create: (_) => mockRequestProvider),
          ChangeNotifierProvider<NewsProvider>(create: (_) => mockNewsProvider),
        ], child: const MyApp()));
        await tester.pumpAndSettle();

        // Open settings
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        // Open Ask Permissions page
        expect(find.text('Request editing permissions'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('ask_permissions')));
        await tester.pumpAndSettle();
        expect(find.byType(RequestPermissionsPage), findsOneWidget);

        // Send a request
        await tester.enterText(
            find.byType(TextFormField), 'I love League of Legends');
        await tester.tap(find.byType(Checkbox));
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify the request is sent and Settings Page pops back
        verify(
            mockRequestProvider.makeRequest(any, context: anyNamed('context')));
        expect(find.byType(SettingsPage), findsOneWidget);
      });

      testWidgets('User has already sent a request scenario',
          (WidgetTester tester) async {
        when(mockAuthProvider.isVerified).thenAnswer((_) => Future.value(true));
        when(mockRequestProvider.userAlreadyRequested(any,
                context: anyNamed('context')))
            .thenAnswer((_) => Future.value(true));

        await tester.pumpWidget(MultiProvider(providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => mockAuthProvider),
          ChangeNotifierProvider<WebsiteProvider>(
              create: (_) => mockWebsiteProvider),
          ChangeNotifierProvider<QuestionProvider>(
              create: (_) => mockQuestionProvider),
          Provider<RequestProvider>(create: (_) => mockRequestProvider),
          ChangeNotifierProvider<NewsProvider>(create: (_) => mockNewsProvider),
        ], child: const MyApp()));
        await tester.pumpAndSettle();

        // Open settings
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        // Open Ask Permissions page
        expect(find.text('Request editing permissions'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('ask_permissions')));
        await tester.pumpAndSettle();
        expect(find.byType(RequestPermissionsPage), findsOneWidget);

        // Send a request
        await tester.enterText(
            find.byType(TextFormField), 'I love League of Legends');
        await tester.tap(find.byType(Checkbox));
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Check that warning Dialog appears and press Send
        expect(find.byType(AppDialog), findsOneWidget);
        await tester.tap(find.text('SEND'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify the request is sent and Settings Page pops back
        verify(
            mockRequestProvider.makeRequest(any, context: anyNamed('context')));
        expect(find.byType(SettingsPage), findsOneWidget);
      });

      testWidgets('User is anonymous scenario', (WidgetTester tester) async {
        when(mockAuthProvider.isVerified).thenAnswer((_) => Future.value(true));
        when(mockAuthProvider.isAnonymous).thenReturn(true);
        when(mockRequestProvider.userAlreadyRequested(any,
                context: anyNamed('context')))
            .thenAnswer((_) => Future.value(true));

        await tester.pumpWidget(MultiProvider(providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => mockAuthProvider),
          ChangeNotifierProvider<WebsiteProvider>(
              create: (_) => mockWebsiteProvider),
          ChangeNotifierProvider<QuestionProvider>(
              create: (_) => mockQuestionProvider),
          Provider<RequestProvider>(create: (_) => mockRequestProvider),
          ChangeNotifierProvider<NewsProvider>(create: (_) => mockNewsProvider),
        ], child: const MyApp()));
        await tester.pumpAndSettle();

        // Open settings
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        // Press Ask Permissions page
        expect(find.text('Request editing permissions'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('ask_permissions')));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify nothing happens
        expect(find.byType(SettingsPage), findsOneWidget);
      });

      testWidgets('User is not verified scenario', (WidgetTester tester) async {
        when(mockAuthProvider.isVerified)
            .thenAnswer((_) => Future.value(false));
        when(mockAuthProvider.isAnonymous).thenReturn(false);
        when(mockRequestProvider.userAlreadyRequested(any,
                context: anyNamed('context')))
            .thenAnswer((_) => Future.value(true));

        await tester.pumpWidget(MultiProvider(providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => mockAuthProvider),
          ChangeNotifierProvider<WebsiteProvider>(
              create: (_) => mockWebsiteProvider),
          ChangeNotifierProvider<QuestionProvider>(
              create: (_) => mockQuestionProvider),
          Provider<RequestProvider>(create: (_) => mockRequestProvider),
          ChangeNotifierProvider<NewsProvider>(create: (_) => mockNewsProvider),
        ], child: const MyApp()));
        await tester.pumpAndSettle();

        // Open settings
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        // Press Ask Permissions page
        expect(find.text('Request editing permissions'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('ask_permissions')));

        // Verify Ask Permissions page is not opened
        await tester.pumpAndSettle(const Duration(seconds: 4));
        expect(find.byType(SettingsPage), findsOneWidget);
        expect(find.byType(RequestPermissionsPage), findsNothing);

        // Verify account
        when(mockAuthProvider.isVerified).thenAnswer((_) => Future.value(true));

        // Go back and open settings again
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        // Press Ask Permissions page
        expect(find.text('Request editing permissions'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('ask_permissions')));

        // Verify Ask Permissions page is opened
        await tester.pumpAndSettle();
        expect(find.byType(RequestPermissionsPage), findsOneWidget);
      });
    });
  });
}
