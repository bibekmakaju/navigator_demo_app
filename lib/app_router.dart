// app_router.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_router_demo/pages/login_view.dart';

// ─────────────────────────────────────────────
// 1. ROUTE NAMES
// ─────────────────────────────────────────────

abstract class Routes {
  static const login = 'login';
  static const home = 'home';
  static const settings = 'settings';
  static const product = 'product';
  static const lab = 'lab';
}

// ─────────────────────────────────────────────
// 2. TRANSITION TYPES
// ─────────────────────────────────────────────

enum TransitionType { material, cupertino, fade }

// ─────────────────────────────────────────────
// 3. ROUTE PAGE
// ─────────────────────────────────────────────

class RoutePage<T extends Object?> extends Page<T> {
  RoutePage({
    required this.child,
    required String name,
    String? id,
    this.completer,
    this.transitionType = TransitionType.material,
  })  : id = id ?? name,
        super(name: name, key: ValueKey(id ?? name));

  final Widget child;
  final String id;
  final Completer<T?>? completer;
  final TransitionType transitionType;

  @override
  Route<T> createRoute(BuildContext context) {
    late final Route<T> route;

    switch (transitionType) {
      case TransitionType.cupertino:
        route = CupertinoPageRoute<T>(
          builder: (_) => child,
          settings: this,
        );
      case TransitionType.fade:
        route = PageRouteBuilder<T>(
          settings: this,
          pageBuilder: (_, __, ___) => child,
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        );
      case TransitionType.material:
        route = MaterialPageRoute<T>(builder: (_) => child, settings: this);
    }

    unawaited(route.popped.then(complete, onError: completeError));
    return route;
  }

  void complete(Object? result) {
    final pageCompleter = completer;
    if (pageCompleter == null || pageCompleter.isCompleted) return;

    if (result != null && result is! T) {
      _completeResultTypeError(pageCompleter, result);
      return;
    }

    try {
      pageCompleter.complete(result as T?);
    } on TypeError catch (error, stackTrace) {
      if (pageCompleter.isCompleted) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      _completeResultTypeError(pageCompleter, result, stackTrace);
    }
  }

  void completeError(Object error, StackTrace stackTrace) {
    final pageCompleter = completer;
    if (pageCompleter == null || pageCompleter.isCompleted) return;
    pageCompleter.completeError(error, stackTrace);
  }

  void _completeResultTypeError(
    Completer<T?> pageCompleter,
    Object? result, [
    StackTrace? stackTrace,
  ]) {
    pageCompleter.completeError(
      StateError(
        'Route "$name" expected result type $T but received '
        '${result.runtimeType}.',
      ),
      stackTrace,
    );
  }
}

// ─────────────────────────────────────────────
// 4. NAVIGATOR KEY
// ─────────────────────────────────────────────

final appNavigatorKey = GlobalKey<NavigatorState>();

// ─────────────────────────────────────────────
// 5. PROVIDER
// ─────────────────────────────────────────────

final routeProvider = ChangeNotifierProvider<RouteChangeNotifier>(
  (ref) => RouteChangeNotifier(),
);

// ─────────────────────────────────────────────
// 6. ROUTE NOTIFIER
// ─────────────────────────────────────────────

class RouteChangeNotifier extends ChangeNotifier {
  RouteChangeNotifier() {
    _pages.add(
      _createPage(
        RoutePage(
          child: const LoginView(isInitial: true),
          name: Routes.login,
        ),
      ),
    );
  }

  final List<RoutePage<dynamic>> _pages = [];
  int _nextPageId = 0;

  List<RoutePage<dynamic>> get pages => List.unmodifiable(_pages);

  Future<T?> push<T extends Object?>(RoutePage<T> page) {
    final completer = Completer<T?>();
    _pages.add(_createPage(page, completer: completer));
    notifyListeners();
    return completer.future;
  }

  void pop<T extends Object?>({T? result}) {
    if (_pages.length <= 1) return;
    final page = _pages.removeLast();
    page.complete(result);
    notifyListeners();
  }

  void replaceCurrent<T extends Object?>(RoutePage<T> page) {
    if (_pages.isNotEmpty) {
      final removed = _pages.removeLast();
      removed.complete(null);
    }
    _pages.add(_createPage(page));
    notifyListeners();
  }

  void replaceAll<T extends Object?>(RoutePage<T> page) {
    for (final p in _pages) {
      p.complete(null);
    }
    _pages
      ..clear()
      ..add(_createPage(page));
    notifyListeners();
  }

  void removePages(int count) {
    assert(count > 0, 'count must be positive');
    final safeCount = count.clamp(0, _pages.length - 1);
    final removed = _pages.sublist(_pages.length - safeCount);
    for (final p in removed) {
      p.complete(null);
    }
    _pages.removeRange(_pages.length - safeCount, _pages.length);
    notifyListeners();
  }

  void didRemovePage(Page<Object?> page) {
    if (page is! RoutePage<dynamic>) return;

    final index = _pages.indexWhere((candidate) => candidate.id == page.id);
    if (index == -1) return;

    _pages.removeAt(index);
    notifyListeners();
  }

  RoutePage<T> _createPage<T extends Object?>(
    RoutePage<T> page, {
    Completer<T?>? completer,
  }) {
    final name = page.name;
    if (name == null) {
      throw ArgumentError.value(page, 'page', 'RoutePage.name is required');
    }

    return RoutePage<T>(
      id: '$name-${_nextPageId++}',
      child: page.child,
      name: name,
      completer: completer ?? page.completer,
      transitionType: page.transitionType,
    );
  }
}

// ─────────────────────────────────────────────
// 7. ROUTER DELEGATE
// ─────────────────────────────────────────────

class AppRouteDelegate extends RouterDelegate<List<RoutePage<dynamic>>>
    with PopNavigatorRouterDelegateMixin, ChangeNotifier {
  AppRouteDelegate(this._container) {
    _container.read(routeProvider).addListener(notifyListeners);
  }

  final ProviderContainer _container;

  @override
  GlobalKey<NavigatorState> get navigatorKey => appNavigatorKey;

  @override
  List<RoutePage<dynamic>> get currentConfiguration =>
      _container.read(routeProvider).pages;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final pages = ref.watch(routeProvider).pages;
        return Navigator(
          key: navigatorKey,
          pages: pages,
          observers: [AppNavObserver()],
          onDidRemovePage:
              _container.read(routeProvider.notifier).didRemovePage,
        );
      },
    );
  }

  // FIX 2: Delegate to navigator.pop() so it handles whatever is actually
  // on top — dialog, bottom sheet, or page — in the correct order.
  // onDidRemovePage then handles _pages sync only when a RoutePage is removed.
  @override
  Future<bool> popRoute() async {
    final navigator = appNavigatorKey.currentState;

    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return true;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await SystemNavigator.pop();
      return true;
    }

    return false;
  }

  @override
  Future<void> setNewRoutePath(List<RoutePage<dynamic>> configuration) async {}
}

// ─────────────────────────────────────────────
// 8. ROUTE INFORMATION PARSER
// ─────────────────────────────────────────────

class AppRouteParser extends RouteInformationParser<List<RoutePage<dynamic>>> {
  @override
  Future<List<RoutePage<dynamic>>> parseRouteInformation(
    RouteInformation routeInformation,
  ) async =>
      [];

  @override
  RouteInformation restoreRouteInformation(
    List<RoutePage<dynamic>> configuration,
  ) =>
      RouteInformation(uri: Uri.parse('/'));
}

// ─────────────────────────────────────────────
// 9. NAVIGATOR OBSERVER
// ─────────────────────────────────────────────

class AppNavObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) =>
      debugPrint('NAV ▶ push:    ${route.settings.name}');

  @override
  void didPop(Route route, Route? previousRoute) =>
      debugPrint('NAV ◀ pop:     ${route.settings.name}');

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => debugPrint(
      'NAV ↔ replace: ${oldRoute?.settings.name} → ${newRoute?.settings.name}');

  @override
  void didRemove(Route route, Route? previousRoute) =>
      debugPrint('NAV ✕ remove:  ${route.settings.name}');
}

// ─────────────────────────────────────────────
// 10. EXTENSION
// ─────────────────────────────────────────────

extension AppRoute on WidgetRef {
  // FIX 3: Delegate to navigator.pop() first so it handles whatever is on
  // top — dialog, bottom sheet, or page.
  // - Dialog/sheet on top → navigator closes it, page stack untouched.
  //   _pages untouched ✅
  // - RoutePage on top   → navigator pops it, Route.popped completes
  //   the result and onDidRemovePage syncs _pages ✅
  // - Nothing to pop     → falls back to notifier.pop() (no-op, guarded) ✅
  void pop<T>({T? result}) {
    final navigator = appNavigatorKey.currentState;

    if (navigator != null && navigator.canPop()) {
      navigator.pop(result);
      return;
    }

    read(routeProvider.notifier).pop<T>(result: result);
  }

  Future<T?> push<T extends Object?>(RoutePage<T> page) =>
      read(routeProvider.notifier).push<T>(page);

  void replaceCurrent<T extends Object?>(RoutePage<T> page) =>
      read(routeProvider.notifier).replaceCurrent<T>(page);

  void replaceAll<T extends Object?>(RoutePage<T> page) =>
      read(routeProvider.notifier).replaceAll<T>(page);

  void removeLast(int count) => read(routeProvider.notifier).removePages(count);
}
