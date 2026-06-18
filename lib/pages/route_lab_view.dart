import 'dart:async';

import 'package:flutter/material.dart';
import 'package:navigation_router_demo/app_router.dart';
import 'package:navigation_router_demo/pages/checkout_step_view.dart';
import 'package:navigation_router_demo/pages/login_view.dart';
import 'package:navigation_router_demo/pages/overlay_toast_lab_view.dart';
import 'package:navigation_router_demo/pages/product_view.dart';
import 'package:navigation_router_demo/pages/settings_view.dart';

class RouteLabView extends StatefulWidget {
  const RouteLabView({
    super.key,
    this.initialMessage,
  });

  final String? initialMessage;

  @override
  State<RouteLabView> createState() => _RouteLabViewState();
}

class _RouteLabViewState extends State<RouteLabView> {
  late String _lastEvent;

  @override
  void initState() {
    super.initState();
    _lastEvent =
        widget.initialMessage ?? 'Use this page for stack navigation cases.';
  }

  void _replaceWithSettings() {
    context.replaceCurrent(
      RoutePage(
        child: const SettingsView(showReplaceHomeAction: true),
        name: Routes.settings,
        transitionType: TransitionType.fade,
      ),
    );
  }

  void _replaceWithProduct() {
    context.replaceCurrent(
      RoutePage(
        child: const ProductView(
          productId: 'LAB-4004',
          productName: 'Replacement Product',
        ),
        name: Routes.product,
        transitionType: TransitionType.cupertino,
      ),
    );
  }

  Future<void> _startCheckoutFlow() async {
    final result = await context.push<String>(
      CheckoutStepView.page(
        CheckoutStep.cart,
        initialMessage: 'Checkout flow started from Route Lab.',
        transitionType: TransitionType.cupertino,
      ),
    );

    if (!mounted) return;
    setState(() {
      _lastEvent = result ?? 'Checkout flow closed without a result.';
    });
  }

  void _openOverlayToastLab() {
    unawaited(
      context.push<void>(
        OverlayToastLabView.page(transitionType: TransitionType.fade),
      ),
    );

    setState(() {
      _lastEvent = 'Opened Overlay Toast Lab.';
    });
  }

  Future<void> _pushFullCheckoutStack() async {
    unawaited(
      context.push<String>(
        CheckoutStepView.page(
          CheckoutStep.cart,
          initialMessage: 'Cart was pushed as the checkout root.',
        ),
      ),
    );
    unawaited(
      context.push<String>(
        CheckoutStepView.page(
          CheckoutStep.address,
          initialMessage: 'Address was pushed by a batch stack action.',
        ),
      ),
    );
    unawaited(
      context.push<String>(
        CheckoutStepView.page(
          CheckoutStep.payment,
          initialMessage: 'Payment was pushed by a batch stack action.',
        ),
      ),
    );
    unawaited(
      context.push<String>(
        CheckoutStepView.page(
          CheckoutStep.review,
          initialMessage: 'Review is now on top of a deep checkout stack.',
        ),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;
    setState(() {
      _lastEvent =
          'Built checkout stack: Cart -> Address -> Payment -> Review.';
    });
  }

  Future<void> _pushTwoThenRemoveTwo() async {
    unawaited(
      context.push<void>(
        RoutePage(
          child: const SettingsView(showSaveAction: false),
          name: Routes.settings,
        ),
      ),
    );
    unawaited(
      context.push<void>(
        RoutePage(
          child: const ProductView(
            productId: 'LAB-5005',
            productName: 'Count Removal Product',
          ),
          name: Routes.product,
        ),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    context.removeLast(2);
    setState(() {
      _lastEvent = 'Pushed Settings + Product, then removed both by count.';
    });
  }

  Future<void> _pushTwoThenPopUntilLab() async {
    unawaited(
      context.push<void>(
        RoutePage(
          child: const SettingsView(showSaveAction: false),
          name: Routes.settings,
        ),
      ),
    );
    unawaited(
      context.push<void>(
        RoutePage(
          child: const ProductView(
            productId: 'LAB-6006',
            productName: 'Pop Until Product',
          ),
          name: Routes.product,
        ),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final found = context.popUntilRouteName(Routes.lab);
    setState(() {
      _lastEvent = found
          ? 'Pushed Settings + Product, then popped back until Lab.'
          : 'Lab was not found in the stack.';
    });
  }

  Future<void> _pushTwoThenReplaceUntilSettings() async {
    unawaited(
      context.push<void>(
        RoutePage(
          child: const SettingsView(showSaveAction: false),
          name: Routes.settings,
        ),
      ),
    );
    unawaited(
      context.push<void>(
        RoutePage(
          child: const ProductView(
            productId: 'LAB-7007',
            productName: 'Replace Until Product',
          ),
          name: Routes.product,
        ),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    context.replaceUntilRouteName(
      Routes.settings,
      RoutePage(
        child: const RouteLabView(
          initialMessage:
              'Replaced from the nearest Settings route back to Route Lab.',
        ),
        name: Routes.lab,
        transitionType: TransitionType.fade,
      ),
    );
  }

  void _showStackDialog() {
    final routeNames =
        context.routePages.map((page) => page.name ?? 'unnamed').join(' -> ');

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Current route stack'),
        content: Text(routeNames),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNavigationDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Stack actions'),
        content: const Text('Choose a navigation operation to run.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showStackDialog();
            },
            child: const Text('Show stack'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              unawaited(_pushTwoThenPopUntilLab());
            },
            child: const Text('Pop until Lab'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              unawaited(_pushTwoThenReplaceUntilSettings());
            },
            child: const Text('Replace until Settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop('sdsds');
              unawaited(_startCheckoutFlow());
            },
            child: const Text('Checkout flow'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              unawaited(_pushFullCheckoutStack());
            },
            child: const Text('Full checkout stack'),
          ),
        ],
      ),
    );
  }

  void _tryReplaceUntilMissingRoute() {
    final found = context.replaceUntilRouteName(
      'missing-route',
      CheckoutStepView.page(CheckoutStep.success),
    );

    setState(() {
      _lastEvent = found
          ? 'Unexpectedly found missing-route.'
          : 'Missing route was not found; replaceUntil left the stack alone.';
    });
  }

  void _replaceAllWithLogin() {
    context.replaceAll(
      RoutePage(
        child: const LoginView(isInitial: false),
        name: Routes.login,
        transitionType: TransitionType.fade,
      ),
    );
  }

  void _popWithResult() {
    context.pop<String>(result: 'Route Lab returned a result.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Lab')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _LabStatusCard(text: _lastEvent),
          const SizedBox(height: 16),
          _LabActionTile(
            icon: Icons.swap_horiz,
            title: 'Replace Lab with Settings',
            subtitle: 'Uses replaceCurrent and completes Lab with null.',
            onTap: _replaceWithSettings,
          ),
          _LabActionTile(
            icon: Icons.inventory_2_outlined,
            title: 'Replace Lab with Product',
            subtitle: 'Replaces this page with a Product route.',
            onTap: _replaceWithProduct,
          ),
          _LabActionTile(
            icon: Icons.shopping_cart_outlined,
            title: 'Start checkout flow',
            subtitle: 'Pushes Cart and waits for a final String result.',
            onTap: _startCheckoutFlow,
          ),
          _LabActionTile(
            icon: Icons.notifications_active_outlined,
            title: 'Open overlay toast lab',
            subtitle: 'Tests OverlayEntry toast messages above this Navigator.',
            onTap: _openOverlayToastLab,
          ),
          _LabActionTile(
            icon: Icons.account_tree_outlined,
            title: 'Build full checkout stack',
            subtitle: 'Pushes Cart -> Address -> Payment -> Review.',
            onTap: _pushFullCheckoutStack,
          ),
          _LabActionTile(
            icon: Icons.layers_clear_outlined,
            title: 'Push two pages, remove two',
            subtitle: 'Demonstrates count-wise removal while keeping Lab.',
            onTap: _pushTwoThenRemoveTwo,
          ),
          _LabActionTile(
            icon: Icons.low_priority,
            title: 'Push two pages, pop until Lab',
            subtitle: 'Stacks Settings + Product, then returns to Lab by name.',
            onTap: _pushTwoThenPopUntilLab,
          ),
          _LabActionTile(
            icon: Icons.find_replace,
            title: 'Push two pages, replace until Settings',
            subtitle: 'Replaces the found Settings route and pages above it.',
            onTap: _pushTwoThenReplaceUntilSettings,
          ),
          _LabActionTile(
            icon: Icons.search_off_outlined,
            title: 'Try replaceUntil missing route',
            subtitle: 'Shows the false/no-op branch without changing pages.',
            onTap: _tryReplaceUntilMissingRoute,
          ),
          _LabActionTile(
            icon: Icons.account_tree_outlined,
            title: 'Show current stack dialog',
            subtitle: 'Displays the live Navigator page list by route name.',
            onTap: _showStackDialog,
          ),
          _LabActionTile(
            icon: Icons.rule_folder_outlined,
            title: 'Open stack action dialog',
            subtitle: 'Runs stack examples from an AlertDialog.',
            onTap: _showNavigationDialog,
          ),
          _LabActionTile(
            icon: Icons.restart_alt,
            title: 'Full replace stack with Login',
            subtitle: 'Uses replaceAll to reset the whole Navigator stack.',
            onTap: _replaceAllWithLogin,
          ),
          _LabActionTile(
            icon: Icons.keyboard_return,
            title: 'Pop Lab with result',
            subtitle: 'Completes the Future awaited by Home.',
            onTap: _popWithResult,
          ),
        ],
      ),
    );
  }
}

class _LabStatusCard extends StatelessWidget {
  const _LabStatusCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
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

class _LabActionTile extends StatelessWidget {
  const _LabActionTile({
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
