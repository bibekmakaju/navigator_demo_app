import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_router_demo/app_router.dart';
import 'package:navigation_router_demo/models/navigation_results.dart';
import 'package:navigation_router_demo/pages/login_view.dart';
import 'package:navigation_router_demo/pages/overlay_toast_lab_view.dart';
import 'package:navigation_router_demo/pages/product_view.dart';
import 'package:navigation_router_demo/pages/route_lab_view.dart';
import 'package:navigation_router_demo/pages/settings_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({
    super.key,
    this.canReturnToLogin = false,
  });

  final bool canReturnToLogin;

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  String _lastEvent = 'Choose a navigation action.';

  Future<void> _openProductForResult() async {
    final result = await ref.push<ProductSelection>(
      RoutePage(
        child: const ProductView(
          productId: 'SKU-1001',
          productName: 'Riverpod Router Kit',
        ),
        name: Routes.product,
        transitionType: TransitionType.cupertino,
      ),
    );

    if (!mounted) return;
    setState(() {
      _lastEvent = result == null
          ? 'Product page closed without result.'
          : 'Product result: ${result.label}';
    });
  }

  Future<void> _openSettingsForResult() async {
    final result = await ref.push<SettingsResult>(
      RoutePage(
        child: const SettingsView(),
        name: Routes.settings,
        transitionType: TransitionType.fade,
      ),
    );

    if (!mounted) return;
    setState(() {
      _lastEvent = result == null
          ? 'Settings closed without result.'
          : 'Settings result: ${result.label}';
    });
  }

  void _openSettingsWithoutWaiting() {
    unawaited(
      ref.push<void>(
        RoutePage(
          child: const SettingsView(showSaveAction: false),
          name: Routes.settings,
          transitionType: TransitionType.material,
        ),
      ),
    );

    setState(() {
      _lastEvent = 'Settings pushed. This call intentionally ignores result.';
    });
  }

  void _replaceCurrentWithSettings() {
    ref.replaceCurrent(
      RoutePage(
        child: const SettingsView(showReplaceHomeAction: true),
        name: Routes.settings,
        transitionType: TransitionType.fade,
      ),
    );
  }

  Future<void> _openRouteLab() async {
    final result = await ref.push<String>(
      RoutePage(
        child: const RouteLabView(),
        name: Routes.lab,
        transitionType: TransitionType.cupertino,
      ),
    );

    if (!mounted) return;
    setState(() {
      _lastEvent = result ?? 'Route Lab closed without result.';
    });
  }

  void _openOverlayToastLab() {
    unawaited(
      ref.push<void>(
        OverlayToastLabView.page(transitionType: TransitionType.fade),
      ),
    );

    setState(() {
      _lastEvent = 'Opened Overlay Toast Lab.';
    });
  }

  Future<void> _pushTwoThenRemoveOne() async {
    unawaited(
      ref.push<void>(
        RoutePage(
          child: const SettingsView(showSaveAction: false),
          name: Routes.settings,
        ),
      ),
    );
    unawaited(
      ref.push<void>(
        RoutePage(
          child: const ProductView(
            productId: 'SKU-2002',
            productName: 'Temporary Product',
          ),
          name: Routes.product,
        ),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    ref.removeLast(1);

    if (!mounted) return;
    setState(() {
      _lastEvent = 'Pushed Settings + Product, then removed Product.';
    });
  }

  Future<void> _pushThreeThenRemoveThree() async {
    unawaited(
      ref.push<void>(
        RoutePage(
          child: const SettingsView(showSaveAction: false),
          name: Routes.settings,
        ),
      ),
    );
    unawaited(
      ref.push<void>(
        RoutePage(
          child: const ProductView(
            productId: 'SKU-3003',
            productName: 'First Counted Product',
          ),
          name: Routes.product,
        ),
      ),
    );
    unawaited(
      ref.push<void>(
        RoutePage(
          child: const ProductView(
            productId: 'SKU-4004',
            productName: 'Second Counted Product',
          ),
          name: Routes.product,
        ),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    ref.removeLast(3);

    if (!mounted) return;
    setState(() {
      _lastEvent = 'Pushed three pages, then removed all three by count.';
    });
  }

  void _tryRootPopEdgeCase() {
    final navigator = appNavigatorKey.currentState;
    final canPop = navigator?.canPop() ?? false;

    if (canPop) {
      setState(() {
        _lastEvent = 'Root-pop edge skipped: Home is not root in this stack.';
      });
      return;
    }

    ref.pop<void>();
    setState(() {
      _lastEvent = 'Tried to pop root Home. Guard kept the page in place.';
    });
  }

  Future<void> _openDialogAndBottomSheet() async {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => const _ModalStackBottomSheet(),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Dialog above bottom sheet'),
          content: const Text(
            'Both overlays are pageless routes. Press the action below to pop '
            'the dialog and bottom sheet from the Navigator stack.',
          ),
          actions: [
            TextButton(
              onPressed: _popDialogAndBottomSheet,
              child: const Text('Pop both'),
            ),
            TextButton(
              onPressed: _popLatestOverlayOnly,
              child: const Text('Pop latest'),
            ),
          ],
        ),
      ),
    );

    setState(() {
      _lastEvent = 'Dialog and bottom sheet are open.';
    });
  }

  void _popDialogAndBottomSheet() {
    ref.pop<void>();
    ref.pop<void>();

    if (!mounted) return;
    setState(() {
      _lastEvent = 'Dialog and bottom sheet popped together.';
    });
  }

  void _popLatestOverlayOnly() {
    ref.pop<void>();

    if (!mounted) return;
    setState(() {
      _lastEvent = 'POP only.';
    });
  }

  void _returnToLogin() {
    ref.replaceAll(
      RoutePage(
        child: const LoginView(isInitial: false),
        name: Routes.login,
      ),
    );
  }

  void _replaceAllWithFreshHome() {
    ref.replaceAll(
      RoutePage(
        child: const HomeView(),
        name: Routes.home,
        transitionType: TransitionType.fade,
      ),
    );
  }

  void _popHomeWithResult() {
    ref.pop<String>(
      result: 'Returned from Home at ${TimeOfDay.now().format(context)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          TextButton(
            onPressed: _returnToLogin,
            child: const Text('Logout'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StatusCard(text: _lastEvent),
          const SizedBox(height: 16),
          _ActionTile(
            icon: Icons.shopping_bag_outlined,
            title: 'Push Product and wait for result',
            subtitle: 'Product can pop with a ProductSelection object.',
            onTap: _openProductForResult,
          ),
          _ActionTile(
            icon: Icons.settings_outlined,
            title: 'Push Settings and wait for result',
            subtitle: 'Settings can save and return a SettingsResult.',
            onTap: _openSettingsForResult,
          ),
          _ActionTile(
            icon: Icons.notifications_none,
            title: 'Push Settings without waiting',
            subtitle: 'The page can still pop, but Home ignores the result.',
            onTap: _openSettingsWithoutWaiting,
          ),
          _ActionTile(
            icon: Icons.swap_horiz,
            title: 'Replace current with Settings',
            subtitle: 'Completes the current page result with null.',
            onTap: _replaceCurrentWithSettings,
          ),
          _ActionTile(
            icon: Icons.science_outlined,
            title: 'Open Route Lab',
            subtitle: 'Try replacement, full reset, and count removal cases.',
            onTap: _openRouteLab,
          ),
          _ActionTile(
            icon: Icons.notifications_active_outlined,
            title: 'Open Overlay Toast Lab',
            subtitle: 'Test the app-wide OverlayEntry toast example.',
            onTap: _openOverlayToastLab,
          ),
          _ActionTile(
            icon: Icons.layers_clear_outlined,
            title: 'Push two pages, then remove one',
            subtitle: 'Calls removeLast(1) after stacking Product on Settings.',
            onTap: _pushTwoThenRemoveOne,
          ),
          _ActionTile(
            icon: Icons.format_list_numbered,
            title: 'Push three pages, remove three',
            subtitle: 'Adds three pages, then removes them by count.',
            onTap: _pushThreeThenRemoveThree,
          ),
          _ActionTile(
            icon: Icons.shield_outlined,
            title: 'Try root pop edge case',
            subtitle: 'Shows the guarded no-op when the current page is root.',
            onTap: _tryRootPopEdgeCase,
          ),
          _ActionTile(
            icon: Icons.restart_alt,
            title: 'Full replace stack with Home',
            subtitle: 'Uses replaceAll to reset this app back to fresh Home.',
            onTap: _replaceAllWithFreshHome,
          ),
          _ActionTile(
            icon: Icons.vertical_align_bottom,
            title: 'Open dialog and bottom sheet',
            subtitle: 'Pushes two pageless routes, then pops both together.',
            onTap: _openDialogAndBottomSheet,
          ),
          if (widget.canReturnToLogin)
            _ActionTile(
              icon: Icons.keyboard_return,
              title: 'Pop Home with result',
              subtitle: 'Completes the Future awaited by Login.',
              onTap: _popHomeWithResult,
            ),
        ],
      ),
    );
  }
}

class _ModalStackBottomSheet extends StatelessWidget {
  const _ModalStackBottomSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bottom sheet underneath',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'A dialog is opened above this sheet. The dialog action pops both '
              'overlays without removing the Home page.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
