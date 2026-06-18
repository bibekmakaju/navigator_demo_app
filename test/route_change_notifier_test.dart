import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_router_demo/app_router.dart';

void main() {
  RoutePage<T> testPage<T extends Object?>(String name) {
    return RoutePage<T>(
      child: const SizedBox.shrink(),
      name: name,
    );
  }

  test('starts with the login page', () {
    final router = RouteChangeNotifier();

    expect(router.pages.map((page) => page.name), [Routes.login]);
  });

  test('push and pop completes with a typed result', () async {
    final router = RouteChangeNotifier();

    final result = router.push<String>(testPage(Routes.product));
    expect(
      router.pages.map((page) => page.name),
      [Routes.login, Routes.product],
    );

    router.pop<String>(result: 'selected-product');

    await expectLater(result, completion('selected-product'));
    expect(router.pages.map((page) => page.name), [Routes.login]);
  });

  test('wrong typed pop result completes pushed future with an error',
      () async {
    final router = RouteChangeNotifier();
    final result = router.push<String>(testPage(Routes.product));

    router.pop<int>(result: 42);

    await expectLater(result, throwsA(isA<StateError>()));
    expect(router.pages.map((page) => page.name), [Routes.login]);
  });

  test('pushed pages with the same route name get unique keys', () async {
    final router = RouteChangeNotifier();
    final firstResult = router.push<void>(testPage(Routes.product));
    final secondResult = router.push<void>(testPage(Routes.product));

    expect(
      router.pages.map((page) => page.name),
      [Routes.login, Routes.product, Routes.product],
    );
    expect(router.pages[1].id, isNot(router.pages[2].id));
    expect(router.pages[1].key, isNot(router.pages[2].key));

    router.removePages(2);

    await expectLater(firstResult, completion(isNull));
    await expectLater(secondResult, completion(isNull));
  });

  test('push preserves page arguments', () {
    final router = RouteChangeNotifier();
    final arguments = {'productId': 'SKU-1001'};

    router.push<void>(
      RoutePage<void>(
        child: const SizedBox.shrink(),
        name: Routes.product,
        arguments: arguments,
      ),
    );

    expect(router.pages.last.arguments, same(arguments));
  });

  test('root page cannot be popped', () {
    final router = RouteChangeNotifier();

    router.pop<void>();

    expect(router.pages.length, 1);
    expect(router.pages.single.name, Routes.login);
  });

  test('replaceAll completes pending pushed pages with null', () async {
    final router = RouteChangeNotifier();
    final result = router.push<String>(testPage(Routes.settings));

    router.replaceAll(testPage(Routes.home));

    await expectLater(result, completion(isNull));
    expect(router.pages.map((page) => page.name), [Routes.home]);
  });

  test('stale page completion after removal does not complete twice', () async {
    final router = RouteChangeNotifier();
    final result = router.push<String>(testPage(Routes.settings));
    final removedPage = router.pages.last;

    router.removePages(1);
    removedPage.complete('late-result');

    await expectLater(result, completion(isNull));
    expect(router.pages.map((page) => page.name), [Routes.login]);
  });

  test('removePages removes from the top without removing root', () async {
    final router = RouteChangeNotifier();
    final settingsResult = router.push<String>(testPage(Routes.settings));
    final productResult = router.push<String>(testPage(Routes.product));

    router.removePages(2);

    await expectLater(settingsResult, completion(isNull));
    await expectLater(productResult, completion(isNull));
    expect(router.pages.map((page) => page.name), [Routes.login]);
  });

  test('popUntilRouteName removes pages until route name is on top', () async {
    final router = RouteChangeNotifier();
    final settingsResult = router.push<String>(testPage(Routes.settings));
    final productResult = router.push<String>(testPage(Routes.product));
    final labResult = router.push<String>(testPage(Routes.lab));

    final found = router.popUntilRouteName(Routes.settings);

    expect(found, isTrue);
    expect(router.pages.map((page) => page.name), [
      Routes.login,
      Routes.settings,
    ]);
    await expectLater(productResult, completion(isNull));
    await expectLater(labResult, completion(isNull));

    router.pop<String>(result: 'settings-result');
    await expectLater(settingsResult, completion('settings-result'));
  });

  test('popUntilRouteName stops at root when route name is missing', () async {
    final router = RouteChangeNotifier();
    final settingsResult = router.push<String>(testPage(Routes.settings));
    final productResult = router.push<String>(testPage(Routes.product));

    final found = router.popUntilRouteName('missing');

    expect(found, isFalse);
    expect(router.pages.map((page) => page.name), [Routes.login]);
    await expectLater(settingsResult, completion(isNull));
    await expectLater(productResult, completion(isNull));
  });

  test('replaceUntilRouteName replaces the found route and pages above it',
      () async {
    final router = RouteChangeNotifier();
    final settingsResult = router.push<String>(testPage(Routes.settings));
    final productResult = router.push<String>(testPage(Routes.product));

    final replaced = router.replaceUntilRouteName(
      Routes.settings,
      testPage(Routes.lab),
    );

    expect(replaced, isTrue);
    expect(router.pages.map((page) => page.name), [Routes.login, Routes.lab]);
    await expectLater(settingsResult, completion(isNull));
    await expectLater(productResult, completion(isNull));
  });

  test('replaceUntilRouteName uses the nearest matching route from the top',
      () async {
    final router = RouteChangeNotifier();
    final firstSettingsResult = router.push<String>(testPage(Routes.settings));
    final productResult = router.push<String>(testPage(Routes.product));
    final secondSettingsResult = router.push<String>(testPage(Routes.settings));
    final labResult = router.push<String>(testPage(Routes.lab));

    final replaced = router.replaceUntilRouteName(
      Routes.settings,
      testPage(Routes.home),
    );

    expect(replaced, isTrue);
    expect(router.pages.map((page) => page.name), [
      Routes.login,
      Routes.settings,
      Routes.product,
      Routes.home,
    ]);
    await expectLater(secondSettingsResult, completion(isNull));
    await expectLater(labResult, completion(isNull));

    router.removePages(3);
    await expectLater(firstSettingsResult, completion(isNull));
    await expectLater(productResult, completion(isNull));
  });

  test('replaceUntilRouteName does nothing when route name is missing',
      () async {
    final router = RouteChangeNotifier();
    final settingsResult = router.push<String>(testPage(Routes.settings));

    final replaced = router.replaceUntilRouteName(
      'missing',
      testPage(Routes.home),
    );

    expect(replaced, isFalse);
    expect(router.pages.map((page) => page.name), [
      Routes.login,
      Routes.settings,
    ]);

    router.pop<String>(result: 'still-here');
    await expectLater(settingsResult, completion('still-here'));
  });
}
