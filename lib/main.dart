import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_router_demo/app_router.dart';

void main() {
  runApp(const RouterDemoBootstrap());
}

class RouterDemoBootstrap extends StatefulWidget {
  const RouterDemoBootstrap({super.key});

  @override
  State<RouterDemoBootstrap> createState() => _RouterDemoBootstrapState();
}

class _RouterDemoBootstrapState extends State<RouterDemoBootstrap> {
  final ProviderContainer _container = ProviderContainer();
  late final AppRouteDelegate _routeDelegate;
  final AppRouteParser _routeParser = AppRouteParser();

  @override
  void initState() {
    super.initState();
    _routeDelegate = AppRouteDelegate(_container);
  }

  @override
  void dispose() {
    _routeDelegate.dispose();
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: _container,
      child: MaterialApp.router(
        title: 'Navigation Router Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerDelegate: _routeDelegate,
        routeInformationParser: _routeParser,
      ),
    );
  }
}
