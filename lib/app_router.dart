import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_router_demo/pages/login_view.dart';

abstract class Routes {
  static const login = 'login';
  static const home = 'home';
  static const settings = 'settings';
  static const product = 'product';
  static const lab = 'lab';
  static const overlayToast = 'overlay-toast';
  static const cart = 'cart';
  static const address = 'address';
  static const payment = 'payment';
  static const review = 'review';
  static const success = 'success';
}

enum TransitionType { material, cupertino, fade }

class RoutePage<T extends Object?> extends Page<T> {
  RoutePage({
    required this.child,
    required String name,
    super.arguments,
    this.transitionType = TransitionType.material,
  })  : id = name,
        _complete = null,
        super(
          name: name,
          key: ValueKey(name),
        );

  RoutePage._({
    required this.child,
    required String name,
    required this.id,
    required super.arguments,
    required this.transitionType,
    Completer<T?>? completer,
    PopInvokedWithResultCallback<T>? onPop,
  })  : _complete =
            completer == null ? null : _completionHandler(name, completer),
        super(
          name: name,
          key: ValueKey(id),
          onPopInvoked: onPop ?? _ignorePop,
        );

  final Widget child;
  final String id;
  final TransitionType transitionType;
  final void Function(Object? result)? _complete;

  @override
  Route<T> createRoute(BuildContext context) {
    return switch (transitionType) {
      TransitionType.cupertino => CupertinoPageRoute<T>(
          builder: (_) => child,
          settings: this,
        ),
      TransitionType.fade => PageRouteBuilder<T>(
          settings: this,
          pageBuilder: (_, __, ___) => child,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      TransitionType.material => MaterialPageRoute<T>(
          builder: (_) => child,
          settings: this,
        ),
    };
  }

  void complete(Object? result) {
    _complete?.call(result);
  }

  static void _ignorePop<T>(bool didPop, T? result) {}

  static void Function(Object? result) _completionHandler<T extends Object?>(
    String name,
    Completer<T?> completer,
  ) {
    return (result) {
      if (completer.isCompleted) return;

      if (result != null && result is! T) {
        _completeWithTypeError<T>(name, completer, result);
        return;
      }

      try {
        completer.complete(result as T?);
      } on TypeError catch (_, stackTrace) {
        _completeWithTypeError<T>(name, completer, result, stackTrace);
      }
    };
  }

  static void _completeWithTypeError<T extends Object?>(
    String name,
    Completer<T?> completer,
    Object? result, [
    StackTrace? stackTrace,
  ]) {
    completer.completeError(
      StateError(
        'Route "$name" expected result type $T but received '
        '${result.runtimeType}.',
      ),
      stackTrace,
    );
  }
}

final appNavigatorKey = GlobalKey<NavigatorState>();

final routeProvider = ChangeNotifierProvider<RouteChangeNotifier>(
  (ref) => RouteChangeNotifier(),
);

class RouteChangeNotifier extends ChangeNotifier {
  RouteChangeNotifier() {
    _pages.add(
      _trackedPage(
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
  bool get canPop => _pages.length > 1;

  Future<T?> push<T extends Object?>(RoutePage<T> page) {
    final completer = Completer<T?>();
    _pages.add(_trackedPage(page, completer: completer));
    notifyListeners();
    return completer.future;
  }

  void pop<T extends Object?>({T? result}) {
    if (!canPop) return;
    _removeLast(result);
    notifyListeners();
  }

  void replaceCurrent<T extends Object?>(RoutePage<T> page) {
    if (_pages.isNotEmpty) {
      _removeLast(null);
    }

    _pages.add(_trackedPage(page));
    notifyListeners();
  }

  void replaceAll<T extends Object?>(RoutePage<T> page) {
    for (final routePage in _pages) {
      routePage.complete(null);
    }

    _pages
      ..clear()
      ..add(_trackedPage(page));
    notifyListeners();
  }

  void removePages(int count) {
    assert(count > 0, 'count must be positive');

    final removableCount = count.clamp(0, _pages.length - 1).toInt();
    if (removableCount == 0) return;

    for (var i = 0; i < removableCount; i++) {
      _removeLast(null);
    }
    notifyListeners();
  }

  bool popUntilRouteName(String routeName) {
    if (_pages.isEmpty || _pages.last.name == routeName) {
      return _pages.isNotEmpty;
    }

    var removedAny = false;
    while (_pages.length > 1 && _pages.last.name != routeName) {
      _removeLast(null);
      removedAny = true;
    }

    if (removedAny) notifyListeners();
    return _pages.last.name == routeName;
  }

  bool replaceUntilRouteName<T extends Object?>(
    String routeName,
    RoutePage<T> page,
  ) {
    final index = _pages.lastIndexWhere((page) => page.name == routeName);
    if (index == -1) return false;

    final removedPages = _pages.sublist(index);
    for (final removedPage in removedPages) {
      removedPage.complete(null);
    }

    _pages
      ..removeRange(index, _pages.length)
      ..add(_trackedPage(page));
    notifyListeners();
    return true;
  }

  void didRemovePage(Page<Object?> page) {
    if (page is RoutePage<dynamic> && _removePage(page, null)) {
      notifyListeners();
    }
  }

  RoutePage<T> _trackedPage<T extends Object?>(
    RoutePage<T> page, {
    Completer<T?>? completer,
  }) {
    final name = page.name!;

    late final RoutePage<T> trackedPage;
    trackedPage = RoutePage<T>._(
      id: '$name-${_nextPageId++}',
      child: page.child,
      name: name,
      arguments: page.arguments,
      completer: completer,
      transitionType: page.transitionType,
      onPop: (didPop, result) {
        if (didPop && _removePage(trackedPage, result)) {
          notifyListeners();
        }
      },
    );

    return trackedPage;
  }

  void _removeLast(Object? result) {
    _pages.removeLast().complete(result);
  }

  bool _removePage(RoutePage<dynamic> page, Object? result) {
    final index = _pages.indexWhere((routePage) => routePage.id == page.id);
    if (index == -1) return false;

    _pages.removeAt(index).complete(result);
    return true;
  }
}

class AppRouteDelegate extends RouterDelegate<List<RoutePage<dynamic>>>
    with PopNavigatorRouterDelegateMixin, ChangeNotifier {
  AppRouteDelegate(WidgetRef ref) : _router = ref.read(routeProvider) {
    _router.addListener(notifyListeners);
  }

  final RouteChangeNotifier _router;

  @override
  GlobalKey<NavigatorState> get navigatorKey => appNavigatorKey;

  @override
  List<RoutePage<dynamic>> get currentConfiguration => _router.pages;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _router.pages,
      observers: [AppNavObserver()],
      onDidRemovePage: _router.didRemovePage,
    );
  }

  @override
  Future<bool> popRoute() async {
    final navigator = appNavigatorKey.currentState;
    if (navigator != null && await navigator.maybePop()) {
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

  @override
  void dispose() {
    _router.removeListener(notifyListeners);
    super.dispose();
  }
}

class AppRouteParser extends RouteInformationParser<List<RoutePage<dynamic>>> {
  @override
  Future<List<RoutePage<dynamic>>> parseRouteInformation(
    RouteInformation routeInformation,
  ) async =>
      [];

  @override
  RouteInformation restoreRouteInformation(
    List<RoutePage<dynamic>> configuration,
  ) {
    return RouteInformation(uri: Uri.parse('/'));
  }
}

class AppNavObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    debugPrint('NAV push: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    debugPrint('NAV pop: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    debugPrint('NAV replace: ${oldRoute?.settings.name} -> '
        '${newRoute?.settings.name}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    debugPrint('NAV remove: ${route.settings.name}');
  }
}

extension AppRoute on BuildContext {
  RouteChangeNotifier get _router {
    return ProviderScope.containerOf(this, listen: false)
        .read(routeProvider.notifier);
  }

  List<RoutePage<dynamic>> get routePages {
    return ProviderScope.containerOf(this, listen: false)
        .read(routeProvider)
        .pages;
  }

  void pop<T extends Object?>({T? result}) {
    final navigator = Navigator.of(this);

    if (navigator.canPop()) {
      navigator.pop(result);
      return;
    }

    _router.pop<T>(result: result);
  }

  Future<T?> push<T extends Object?>(RoutePage<T> page) {
    return _router.push<T>(page);
  }

  void replaceCurrent<T extends Object?>(RoutePage<T> page) {
    _router.replaceCurrent<T>(page);
  }

  void replaceAll<T extends Object?>(RoutePage<T> page) {
    _router.replaceAll<T>(page);
  }

  void removeLast(int count) {
    _router.removePages(count);
  }

  bool popUntilRouteName(String routeName) {
    return _router.popUntilRouteName(routeName);
  }

  bool replaceUntilRouteName<T extends Object?>(
    String routeName,
    RoutePage<T> page,
  ) {
    return _router.replaceUntilRouteName(routeName, page);
  }
}
