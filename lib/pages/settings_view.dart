import 'package:flutter/material.dart';
import 'package:navigation_router_demo/app_router.dart';
import 'package:navigation_router_demo/models/navigation_results.dart';
import 'package:navigation_router_demo/pages/home_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    this.showSaveAction = true,
    this.showReplaceHomeAction = false,
  });

  final bool showSaveAction;
  final bool showReplaceHomeAction;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _darkTheme = false;
  bool _notifications = true;

  void _saveWithResult() {
    context.pop<SettingsResult>(
      result: SettingsResult(
        themeName: _darkTheme ? 'Dark' : 'Light',
        notificationsEnabled: _notifications,
      ),
    );
  }

  void _closeWithoutResult() {
    Navigator.pop(context);
    // context.pop<void>();
  }

  void _replaceWithHome() {
    context.replaceCurrent(
      RoutePage(
        child: const HomeView(),
        name: Routes.home,
        transitionType: TransitionType.fade,
      ),
    );
  }

  void _removeThisPage() {
    context.removeLast(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            value: _darkTheme,
            title: const Text('Dark theme'),
            subtitle: const Text('Returned as part of SettingsResult.'),
            onChanged: (value) => setState(() => _darkTheme = value),
          ),
          SwitchListTile(
            value: _notifications,
            title: const Text('Notifications'),
            subtitle: const Text('Returned as part of SettingsResult.'),
            onChanged: (value) => setState(() => _notifications = value),
          ),
          const SizedBox(height: 24),
          if (widget.showSaveAction) ...[
            FilledButton.icon(
              onPressed: _saveWithResult,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Pop with settings result'),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: _closeWithoutResult,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Pop without result'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _removeThisPage,
            icon: const Icon(Icons.layers_clear_outlined),
            label: const Text('Remove this page'),
          ),
          if (widget.showReplaceHomeAction) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _replaceWithHome,
              icon: const Icon(Icons.home_outlined),
              label: const Text('Replace Settings with Home'),
            ),
          ],
        ],
      ),
    );
  }
}
