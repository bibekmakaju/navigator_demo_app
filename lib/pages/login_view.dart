import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_router_demo/app_router.dart';
import 'package:navigation_router_demo/pages/home_view.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({
    super.key,
    required this.isInitial,
  });

  final bool isInitial;

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  String _lastResult = 'No page has returned a result yet.';

  Future<void> _pushHomeAndWait() async {
    final result = await ref.push<String>(
      RoutePage(
        child: const HomeView(canReturnToLogin: true),
        name: Routes.home,
        transitionType: TransitionType.fade,
      ),
    );

    if (!mounted) return;
    setState(() {
      _lastResult = result ?? 'Home popped without a result.';
    });
  }

  void _replaceWithHome() {
    ref.replaceAll(
      RoutePage(
        child: const HomeView(),
        name: Routes.home,
        transitionType: TransitionType.fade,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.route,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Custom Router Demo',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isInitial
                        ? 'Initial route: ${Routes.login}'
                        : 'Stack was replaced back to login.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _ResultPanel(text: _lastResult),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _replaceWithHome,
                    icon: const Icon(Icons.login),
                    label: const Text('Replace stack with Home'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pushHomeAndWait,
                    icon: const Icon(Icons.call_made),
                    label: const Text('Push Home and wait for result'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
