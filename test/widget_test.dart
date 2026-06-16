import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_router_demo/main.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RouterDemoBootstrap()));
    await tester.pumpAndSettle();
  }

  Future<void> replaceStackWithHome(WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Replace stack with Home'));
    await tester.pumpAndSettle();
  }

  Future<void> scrollToText(WidgetTester tester, String text) async {
    final finder = find.text(text);

    await tester.scrollUntilVisible(finder, 300);
    await tester.pumpAndSettle();
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapVisibleText(WidgetTester tester, String text) async {
    await scrollToText(tester, text);
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the login screen on startup', (tester) async {
    await pumpApp(tester);

    expect(find.text('Custom Router Demo'), findsOneWidget);
    expect(find.text('Initial route: login'), findsOneWidget);
    expect(find.text('Replace stack with Home'), findsOneWidget);
    expect(find.text('Push Home and wait for result'), findsOneWidget);
  });

  testWidgets('can replace the stack with Home', (tester) async {
    await replaceStackWithHome(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Choose a navigation action.'), findsOneWidget);
    expect(find.text('Custom Router Demo'), findsNothing);
  });

  testWidgets('pushes Home and receives its pop result', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Push Home and wait for result'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Pop Home with result'), 200);
    await tester.pumpAndSettle();

    expect(find.text('Pop Home with result'), findsOneWidget);

    await tester.tap(find.text('Pop Home with result'));
    await tester.pumpAndSettle();

    expect(find.text('Custom Router Demo'), findsOneWidget);
    expect(find.textContaining('Returned from Home at'), findsOneWidget);
  });

  testWidgets('opens dialog and bottom sheet, then pops both', (tester) async {
    await replaceStackWithHome(tester);

    await tapVisibleText(tester, 'Open dialog and bottom sheet');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Bottom sheet underneath'), findsOneWidget);
    expect(find.text('Dialog above bottom sheet'), findsOneWidget);

    await tester.tap(find.text('Pop both'));
    await tester.pumpAndSettle();

    expect(find.text('Bottom sheet underneath'), findsNothing);
    expect(find.text('Dialog above bottom sheet'), findsNothing);
    expect(find.text('Home'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Dialog and bottom sheet popped together.'),
      -200,
    );
    expect(
      find.text('Dialog and bottom sheet popped together.'),
      findsOneWidget,
    );
  });

  testWidgets('pushes three pages and removes three by count', (tester) async {
    await replaceStackWithHome(tester);

    await tapVisibleText(tester, 'Push three pages, remove three');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Pushed three pages, then removed all three by count.'),
      -200,
    );
    expect(
      find.text('Pushed three pages, then removed all three by count.'),
      findsOneWidget,
    );
  });

  testWidgets('root pop edge case keeps root Home in place', (tester) async {
    await replaceStackWithHome(tester);

    await tapVisibleText(tester, 'Try root pop edge case');

    expect(find.text('Home'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Tried to pop root Home. Guard kept the page in place.'),
      -200,
    );
    expect(
      find.text('Tried to pop root Home. Guard kept the page in place.'),
      findsOneWidget,
    );
  });

  testWidgets('Route Lab can pop with a result to Home', (tester) async {
    await replaceStackWithHome(tester);

    await tapVisibleText(tester, 'Open Route Lab');

    expect(find.text('Route Lab'), findsOneWidget);

    await tapVisibleText(tester, 'Pop Lab with result');

    expect(find.text('Home'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Route Lab returned a result.'),
      -200,
    );
    expect(find.text('Route Lab returned a result.'), findsOneWidget);
  });

  testWidgets('Overlay Toast Lab shows toast through the Navigator overlay',
      (tester) async {
    await replaceStackWithHome(tester);

    await tapVisibleText(tester, 'Open Overlay Toast Lab');
    expect(find.text('Overlay Toast Lab'), findsOneWidget);

    await tapVisibleText(tester, 'Show success toast');
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Profile saved through an OverlayEntry.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Profile saved through an OverlayEntry.'), findsNothing);

    await tapVisibleText(tester, 'Show top toast');
    await tester.pump(const Duration(milliseconds: 200));

    final topToast = find.text(
      'This toast was created with ToastPlacement.top().',
    );
    expect(topToast, findsOneWidget);
    expect(tester.getTopLeft(topToast).dy, lessThan(160));

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('Android back pops a pushed page', (tester) async {
    await replaceStackWithHome(tester);

    await tapVisibleText(tester, 'Open Route Lab');
    expect(find.text('Route Lab'), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isTrue);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Route Lab'), findsNothing);
  });

  testWidgets('Route Lab can replace itself with Product', (tester) async {
    await replaceStackWithHome(tester);

    await tapVisibleText(tester, 'Open Route Lab');

    await tester.tap(find.text('Replace Lab with Product'));
    await tester.pumpAndSettle();

    expect(find.text('Product'), findsOneWidget);
    expect(find.text('Replacement Product'), findsOneWidget);
    expect(find.text('LAB-4004'), findsOneWidget);
  });

  testWidgets('Route Lab shows the current stack dialog', (tester) async {
    await replaceStackWithHome(tester);

    await tapVisibleText(tester, 'Open Route Lab');
    await tapVisibleText(tester, 'Show current stack dialog');

    expect(find.text('Current route stack'), findsOneWidget);
    expect(find.text('home -> lab'), findsOneWidget);
  });

  testWidgets('Route Lab can replace until Settings by route name',
      (tester) async {
    await replaceStackWithHome(tester);

    await tapVisibleText(tester, 'Open Route Lab');
    await tapVisibleText(tester, 'Push two pages, replace until Settings');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(
      find.text('Replaced from the nearest Settings route back to Route Lab.'),
      findsOneWidget,
    );
  });

  testWidgets('Route Lab starts checkout flow and receives null result',
      (tester) async {
    await replaceStackWithHome(tester);

    await tapVisibleText(tester, 'Open Route Lab');
    await tapVisibleText(tester, 'Start checkout flow');

    expect(find.text('Cart'), findsWidgets);

    await tapVisibleText(tester, 'Push Address and wait');
    expect(find.text('Address'), findsWidgets);

    await tapVisibleText(tester, 'Pop without result');
    expect(find.text('Cart'), findsWidgets);

    await tapVisibleText(tester, 'Pop without result');
    expect(find.text('Route Lab'), findsOneWidget);
  });

  testWidgets('Route Lab builds a deep checkout stack', (tester) async {
    await replaceStackWithHome(tester);

    await tapVisibleText(tester, 'Open Route Lab');
    await tapVisibleText(tester, 'Build full checkout stack');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Review'), findsWidgets);

    await tapVisibleText(tester, 'Show checkout stack');

    expect(find.text('Checkout stack'), findsOneWidget);
    expect(
      find.text('home -> lab -> cart -> address -> payment -> review'),
      findsOneWidget,
    );
  });
}
