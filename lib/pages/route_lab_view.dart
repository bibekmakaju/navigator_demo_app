import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_router_demo/app_router.dart';
import 'package:navigation_router_demo/pages/login_view.dart';
import 'package:navigation_router_demo/pages/product_view.dart';
import 'package:navigation_router_demo/pages/settings_view.dart';

class RouteLabView extends ConsumerStatefulWidget {
  const RouteLabView({super.key});

  @override
  ConsumerState<RouteLabView> createState() => _RouteLabViewState();
}

class _RouteLabViewState extends ConsumerState<RouteLabView> {
  String _lastEvent = 'Use this page for replacement and remove-count cases.';

  void _replaceWithSettings() {
    ref.replaceCurrent(
      RoutePage(
        child: const SettingsView(showReplaceHomeAction: true),
        name: Routes.settings,
        transitionType: TransitionType.fade,
      ),
    );
  }

  void _replaceWithProduct() {
    ref.replaceCurrent(
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

  Future<void> _pushTwoThenRemoveTwo() async {
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
            productId: 'LAB-5005',
            productName: 'Count Removal Product',
          ),
          name: Routes.product,
        ),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    ref.removeLast(2);

    if (!mounted) return;
    setState(() {
      _lastEvent = 'Pushed Settings + Product, then removed both by count.';
    });
  }

  void _replaceAllWithLogin() {
    ref.replaceAll(
      RoutePage(
        child: const LoginView(isInitial: false),
        name: Routes.login,
        transitionType: TransitionType.fade,
      ),
    );
  }

  void _popWithResult() {
    ref.pop<String>(result: 'Route Lab returned a result.');
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
            icon: Icons.layers_clear_outlined,
            title: 'Push two pages, remove two',
            subtitle: 'Demonstrates count-wise removal while keeping Lab.',
            onTap: _pushTwoThenRemoveTwo,
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
