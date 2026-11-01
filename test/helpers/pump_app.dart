import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:retroplayer/l10n/app_locale_catalog.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/system_back_ownership.dart';
import 'package:retroplayer/ui/core/theme.dart';

const testL10nDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Wraps [child] with localization and app theme for widget tests.
Widget wrapWithL10n(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: testL10nDelegates,
    supportedLocales: AppLocaleCatalog.supportedLocales,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    home: child,
  );
}

/// Wraps a [GoRouter] with localization for widget tests.
Widget wrapRouterWithL10n({
  required GoRouter router,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp.router(
    locale: locale,
    localizationsDelegates: testL10nDelegates,
    supportedLocales: AppLocaleCatalog.supportedLocales,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    routerConfig: router,
    onNavigationNotification: claimSystemBack,
  );
}

Future<void> pumpWithL10n(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(wrapWithL10n(child, locale: locale));
  await tester.pumpAndSettle();
}

AppLocalizations enL10n(WidgetTester tester) =>
    lookupAppLocalizations(const Locale('en'));

/// Pumps a few frames without waiting for all animations to finish.
///
/// Prefer this over [WidgetTester.pumpAndSettle] in tests that navigate with
/// [GoRouter.push], which otherwise never settles until the route is popped.
Future<void> pumpFrames(
  WidgetTester tester, {
  int count = 3,
  Duration step = const Duration(milliseconds: 100),
}) async {
  await tester.pump();
  for (var i = 0; i < count; i++) {
    await tester.pump(step);
  }
}
