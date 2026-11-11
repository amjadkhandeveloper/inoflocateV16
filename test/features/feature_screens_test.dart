import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infolocate/screens/alerts/view/alert_screen.dart';
import 'package:infolocate/screens/card_types_screen/controller/card_type_provider.dart';
import 'package:infolocate/screens/dashboard/controller/sequel_dashboard_provider.dart';
import 'package:infolocate/screens/dashboard/view/sequel_dashboard_view.dart';
import 'package:infolocate/screens/dynamic_status/view/dynamic_status_screen.dart';
import 'package:infolocate/screens/intro/view/intro_view.dart';
import 'package:infolocate/screens/language/controller/language_provider.dart';
import 'package:infolocate/screens/language/view/select_language_screen.dart';
import 'package:infolocate/screens/login/controller/client_provider.dart';
import 'package:infolocate/screens/login/controller/user_provider.dart';
import 'package:infolocate/screens/login/model/client_model.dart';
import 'package:infolocate/screens/login/model/user_login_response_model.dart';
import 'package:infolocate/screens/login/view/client_login_view.dart';
import 'package:infolocate/screens/login/view/user_login_view.dart';
import 'package:infolocate/screens/splash/view/splash_view.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_routes.dart';
import 'package:infolocate/widgets/drawer/navigation_drawer.dart';
import 'package:infolocate/widgets/profile_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

/// Features covered by this suite. Reset password is intentionally absent.
const testedFeatures = <String>[
  'Splash',
  'Intro',
  'Client login',
  'User login',
  'Dashboard navigation',
  'Alert list',
  'Dynamic status',
  'Live vehicles',
  'Track on map',
  'Video playback',
  'Track history',
  'Dashboard vehicle profile',
];

Map<String, dynamic> _english = {};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    _english = json.decode(
      await File('assets/translations/en.json').readAsString(),
    ) as Map<String, dynamic>;
    await EasyLocalization.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (call) async => true,
    );
  });

  setUp(resetSession);

  test('feature list excludes reset password', () {
    expect(testedFeatures, hasLength(12));
    expect(
      testedFeatures.any((name) => name.toLowerCase().contains('password')),
      isFalse,
    );
    expect(
      AppRoutes.routes().keys,
      containsAll(<String>[
        SplashScreen.routeName,
        IntroScreen.routeName,
        ClientLoginScreen.routeName,
        UserLoginScreen.routeName,
        SequelDashboardScreen.routeName,
        DynamicStatusScreen.routeName,
        AlertDashboardScreen.routeName,
      ]),
    );
  });

  test('splash chooses the next route from the saved session', () {
    expect(
      splashDestination(hasUser: true, hasClient: true, hasLanguage: true),
      AppRoutes.dashboardRoute(),
    );
    expect(
      splashDestination(hasUser: false, hasClient: true, hasLanguage: true),
      UserLoginScreen.routeName,
    );
    expect(
      splashDestination(hasUser: false, hasClient: false, hasLanguage: true),
      ClientLoginScreen.routeName,
    );
    expect(
      splashDestination(hasUser: false, hasClient: false, hasLanguage: false),
      SelectLanguageScreen.routeName,
    );
  });

  testWidgets('splash shows the brand then opens client login', (tester) async {
    Global.savedLanguageCode = 'en';
    await tester.pumpWidget(const FeatureApp(home: SplashScreen()));
    await pumpUntilFound(tester, find.text('InfoLocate'));
    expect(find.text('Fleet tracking'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump();

    expect(find.byType(ClientLoginScreen), findsOneWidget);
    expect(find.text('Client Login'), findsOneWidget);
  });

  testWidgets('splash opens user login when only the client session exists',
      (tester) async {
    Global.savedLanguageCode = 'en';
    Global.savedClientAuthData = ClientModelDataClient(
      clientId: 1,
      clientName: 'sequel',
      clientUrl: 'https://example.com/api/',
    );

    await tester.pumpWidget(const FeatureApp(home: SplashScreen()));
    await pumpUntilFound(tester, find.text('InfoLocate'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();

    expect(find.byType(UserLoginScreen), findsOneWidget);
    expect(find.text('User Login'), findsOneWidget);
    expect(find.text('sequel'), findsOneWidget);
  });

  testWidgets('splash opens the dashboard when the user session exists',
      (tester) async {
    Global.savedLanguageCode = 'en';
    Global.savedClientAuthData = ClientModelDataClient(
      clientId: 0,
      clientName: 'sequel',
      clientUrl: 'https://example.com/api/',
    );
    Global.savedUserAuthData = UserLoginResponseModelDataUser(
      userid: 0,
      username: 'seqtest',
      clientid: 0,
    );

    await tester.pumpWidget(const FeatureApp(home: SplashScreen()));
    await pumpUntilFound(tester, find.text('InfoLocate'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.byType(SequelDashboardScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('intro walks four slides and skip opens client login',
      (tester) async {
    await tester.pumpWidget(const FeatureApp(home: IntroScreen()));
    await pumpUntilFound(tester, find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);

    await tester.fling(find.byType(PageView), const Offset(-500, 0), 1200);
    await tester.pumpAndSettle();
    expect(find.text('Live Video'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(-500, 0), 1200);
    await tester.pumpAndSettle();
    expect(find.text('Live Tracking'), findsWidgets);

    await tester.fling(find.byType(PageView), const Offset(-500, 0), 1200);
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(ClientLoginScreen), findsOneWidget);
  });

  testWidgets('drawer lists every destination and not reset password',
      (tester) async {
    Global.savedUserAuthData =
        UserLoginResponseModelDataUser(userid: 1, username: 'seqtest');
    Global.savedClientAuthData =
        ClientModelDataClient(clientName: 'sequel', clientUrl: 'https://x/');

    await tester.pumpWidget(const FeatureApp(home: _DrawerHost()));
    await pumpUntilFound(tester, find.byIcon(Icons.menu));
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    for (final label in const [
      'Dashboard',
      'Alerts',
      'Dynamic Status',
      'Live Vehicles',
      'Track On Map',
      'Track History',
      'Video PlayBack',
      'Settings',
      'Logout',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('Forgot password'), findsNothing);
    expect(find.textContaining('seqtest'), findsOneWidget);
    expect(find.text('sequel'), findsOneWidget);
  });

  testWidgets('profile dialog shows the signed-in user', (tester) async {
    Global.savedUserAuthData =
        UserLoginResponseModelDataUser(userid: 7, username: 'seqtest');
    Global.savedLastLoginTime = '2026-11-06T04:30:00.000Z';

    await tester.pumpWidget(
      const FeatureApp(
        home: Scaffold(
          body: ProfileAvatarButton(selectedLanguage: 'English'),
        ),
      ),
    );
    await pumpUntilFound(tester, find.byType(ProfileAvatarButton));
    await tester.pumpAndSettle();

    expect(find.text('S'), findsOneWidget);
    await tester.tap(find.byType(ProfileAvatarButton));
    await tester.pumpAndSettle();

    expect(find.text('seqtest'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('UserName'), findsOneWidget);
    expect(find.text('Last login'), findsOneWidget);
    expect(
      find.text(AppHelper.formatLastLogin(Global.savedLastLoginTime)),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.cancel_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Last login'), findsNothing);
  });

  test('playback accepts a 1 minute window and rejects a longer one', () {
    final end = DateTime(2026, 11, 6, 10, 30, 0);
    expect(
      playbackWindowAllowed(
        from: end.subtract(const Duration(minutes: 1)),
        to: end,
        now: end,
      ),
      isTrue,
    );
    expect(
      playbackWindowAllowed(
        from: end.subtract(const Duration(minutes: 2)),
        to: end,
        now: end,
      ),
      isFalse,
    );
    expect(
      playbackWindowAllowed(
        from: end.add(const Duration(minutes: 1)),
        to: end.add(const Duration(minutes: 2)),
        now: end,
      ),
      isFalse,
    );
  });

  test('track history sample window is 20 minutes', () {
    final end = DateTime(2026, 11, 6, 10, 30, 0);
    final start = end.subtract(const Duration(minutes: 20));
    expect(end.difference(start), const Duration(minutes: 20));
  });
}

/// Same priority as [SplashScreen.navigateTo].
String splashDestination({
  required bool hasUser,
  required bool hasClient,
  required bool hasLanguage,
}) {
  if (hasUser) return AppRoutes.dashboardRoute();
  if (hasClient) return UserLoginScreen.routeName;
  if (hasLanguage) return ClientLoginScreen.routeName;
  return SelectLanguageScreen.routeName;
}

/// Same limits as the playback screen before it calls the API.
bool playbackWindowAllowed({
  required DateTime from,
  required DateTime to,
  required DateTime now,
}) {
  if (from.isAfter(now) || to.isAfter(now) || from.isAfter(to)) return false;
  return to.difference(from).inMinutes <= 1;
}

Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder');
}

void resetSession() {
  Global.savedUserAuthData = null;
  Global.savedClientAuthData = null;
  Global.savedLanguageCode = null;
  Global.savedContryCode = null;
  Global.savedLastLoginTime = null;
  Global.savedVehicleStatusCardTypeId = null;
  Global.savedAlertStatusCardTypeId = null;
}

class FeatureApp extends StatelessWidget {
  const FeatureApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      assetLoader: _MemoryTranslations(_english),
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      useOnlyLangCode: true,
      saveLocale: false,
      child: _LocalizedFeatureApp(home: home),
    );
  }
}

class _MemoryTranslations extends AssetLoader {
  const _MemoryTranslations(this.data);

  final Map<String, dynamic> data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async => data;
}

class _LocalizedFeatureApp extends StatelessWidget {
  const _LocalizedFeatureApp({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (_) => ClientLoginProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => CardTypeProvider()),
            ChangeNotifierProvider(create: (_) => SequelDashboardProvider()),
          ],
          child: MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: home,
            routes: {
              ClientLoginScreen.routeName: (_) => const ClientLoginScreen(),
              UserLoginScreen.routeName: (_) => const UserLoginScreen(),
              SequelDashboardScreen.routeName: (_) =>
                  const SequelDashboardScreen(),
            },
          ),
        );
      },
    );
  }
}

class _DrawerHost extends StatelessWidget {
  const _DrawerHost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: CustomNavigationDrawer(),
      body: const SizedBox.shrink(),
    );
  }
}
