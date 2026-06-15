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
}
