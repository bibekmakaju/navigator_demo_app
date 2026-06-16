import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_router_demo/app_router.dart';
import 'package:navigation_router_demo/app_toast.dart';

class OverlayToastLabView extends ConsumerStatefulWidget {
  const OverlayToastLabView({super.key});

  static RoutePage<void> page({
    TransitionType transitionType = TransitionType.material,
  }) {
    return RoutePage<void>(
      child: const OverlayToastLabView(),
      name: Routes.overlayToast,
      transitionType: transitionType,
    );
  }

  @override
  ConsumerState<OverlayToastLabView> createState() =>
      _OverlayToastLabViewState();
}

class _OverlayToastLabViewState extends ConsumerState<OverlayToastLabView> {
  String _lastEvent = 'Choose a toast example.';

  @override
  void dispose() {
    appToast.hide();
    super.dispose();
  }

  void _setLastEvent(String value) {
    if (!mounted) return;

    setState(() {
      _lastEvent = value;
    });
  }

  void _showSuccessToast() {
    appToast.show(
      ToastMessage.success(
        message: 'Profile saved through an OverlayEntry.',
        onClose: () => _setLastEvent('Success toast closed.'),
      ),
    );
    _setLastEvent('Showing success toast.');
  }

  void _showErrorToast() {
    appToast.show(
      ToastMessage.error(
        title: 'Upload failed',
        message: 'Check the connection and try again.',
        duration: const Duration(seconds: 4),
        onClose: () => _setLastEvent('Error toast closed.'),
      ),
    );
    _setLastEvent('Showing error toast.');
  }

  void _showWarningToast() {
    appToast.show(
      ToastMessage.warning(
        message: 'This action will replace the currently visible toast.',
      ),
    );
    _setLastEvent('Showing warning toast.');
  }

  void _showInfoToast() {
    appToast.show(
      ToastMessage.info(
        title: 'Navigator overlay',
        message: 'The toast is inserted above the app Navigator.',
      ),
    );
    _setLastEvent('Showing info toast.');
  }

  void _showTopToast() {
    appToast.show(
      ToastMessage.info(
        title: 'Top placement',
        message: 'This toast was created with ToastPlacement.top().',
        placement: const ToastPlacement.top(),
      ),
    );
    _setLastEvent('Showing top toast.');
  }

  void _showCenterToast() {
    appToast.show(
      ToastMessage.warning(
        title: 'Center placement',
        message: 'This toast was created with ToastPlacement.center().',
        placement: const ToastPlacement.center(),
      ),
    );
    _setLastEvent('Showing center toast.');
  }

  void _showTrailingActionToast() {
    appToast.show(
      ToastMessage.info(
        title: 'Queued draft',
        message: 'Tap the trailing icon to run a custom callback.',
        trailingIcon: Icons.undo,
        duration: const Duration(seconds: 5),
        onTrailingPressed: () => _setLastEvent('Trailing action pressed.'),
      ),
    );
    _setLastEvent('Showing toast with trailing action.');
  }

  void _showNoCloseToast() {
    appToast.show(
      ToastMessage.success(
        title: 'Auto dismiss only',
        message: 'This toast has no close button.',
        showClose: false,
      ),
    );
    _setLastEvent('Showing toast without close button.');
  }

  void _showCustomToast() {
    appToast.showCustom(
      duration: const Duration(seconds: 5),
      builder: (context, close) {
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                color: colorScheme.onInverseSurface,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Custom builder toast with its own layout.',
                  style: TextStyle(color: colorScheme.onInverseSurface),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  close();
                  _setLastEvent('Custom toast action closed it.');
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
    _setLastEvent('Showing custom builder toast.');
  }

  void _hideToast() {
    appToast.hide();
    _setLastEvent('Toast hidden manually.');
  }

  void _showStackDialog() {
    final routeNames = ref
        .read(routeProvider)
        .pages
        .map((page) => page.name ?? 'unnamed')
        .join(' -> ');

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

  void _popPage() {
    ref.pop<void>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overlay Toast Lab')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ToastStatusCard(text: _lastEvent),
          const SizedBox(height: 16),
          _ToastActionTile(
            icon: Icons.check_circle_outline,
            title: 'Show success toast',
            subtitle: 'Uses ToastMessage.success with the default close icon.',
            onTap: _showSuccessToast,
          ),
          _ToastActionTile(
            icon: Icons.error_outline,
            title: 'Show error toast',
            subtitle: 'Shows a longer error toast with an explicit title.',
            onTap: _showErrorToast,
          ),
          _ToastActionTile(
            icon: Icons.warning_amber_rounded,
            title: 'Show warning toast',
            subtitle: 'Replaces any active toast before inserting the new one.',
            onTap: _showWarningToast,
          ),
          _ToastActionTile(
            icon: Icons.info_outline,
            title: 'Show info toast',
            subtitle: 'Reads the Navigator overlay from appNavigatorKey.',
            onTap: _showInfoToast,
          ),
          _ToastActionTile(
            icon: Icons.vertical_align_top,
            title: 'Show top toast',
            subtitle: 'Creates the toast with ToastPlacement.top().',
            onTap: _showTopToast,
          ),
          _ToastActionTile(
            icon: Icons.center_focus_strong,
            title: 'Show center toast',
            subtitle: 'Creates the toast with ToastPlacement.center().',
            onTap: _showCenterToast,
          ),
          _ToastActionTile(
            icon: Icons.undo,
            title: 'Show trailing action toast',
            subtitle: 'Uses a custom trailing icon and callback.',
            onTap: _showTrailingActionToast,
          ),
          _ToastActionTile(
            icon: Icons.timer_outlined,
            title: 'Show toast without close',
            subtitle: 'Leaves dismissal to the timer or manual hide action.',
            onTap: _showNoCloseToast,
          ),
          _ToastActionTile(
            icon: Icons.dashboard_customize_outlined,
            title: 'Show custom builder toast',
            subtitle: 'Uses showCustom for arbitrary overlay content.',
            onTap: _showCustomToast,
          ),
          _ToastActionTile(
            icon: Icons.visibility_off_outlined,
            title: 'Hide current toast',
            subtitle: 'Calls the toast service hide method.',
            onTap: _hideToast,
          ),
          _ToastActionTile(
            icon: Icons.account_tree_outlined,
            title: 'Show current stack dialog',
            subtitle: 'Confirms the toast is not a route in the page stack.',
            onTap: _showStackDialog,
          ),
          _ToastActionTile(
            icon: Icons.keyboard_return,
            title: 'Pop Overlay Toast Lab',
            subtitle: 'Returns to the previous page in the route stack.',
            onTap: _popPage,
          ),
        ],
      ),
    );
  }
}

class _ToastStatusCard extends StatelessWidget {
  const _ToastStatusCard({required this.text});

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

class _ToastActionTile extends StatelessWidget {
  const _ToastActionTile({
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
