import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_router_demo/app_router.dart';

void main() {
  runApp(const ProviderScope(child: RouterDemoBootstrap()));
}

class RouterDemoBootstrap extends ConsumerStatefulWidget {
  const RouterDemoBootstrap({super.key});

  @override
  ConsumerState<RouterDemoBootstrap> createState() =>
      _RouterDemoBootstrapState();
}

class _RouterDemoBootstrapState extends ConsumerState<RouterDemoBootstrap> {
  late final AppRouteDelegate _routeDelegate;
  final AppRouteParser _routeParser = AppRouteParser();

  @override
  void initState() {
    super.initState();
    _routeDelegate = AppRouteDelegate(ref);
  }

  @override
  void dispose() {
    _routeDelegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Navigation Router Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerDelegate: _routeDelegate,
      routeInformationParser: _routeParser,
    );
  }
}
