import 'dart:async';

import 'package:flutter/material.dart';
import 'package:navigation_router_demo/app_router.dart';

/// App-wide singleton instance.
/// Usage: appToast.show(...)
final appToast = AppToastService._();

enum ToastType {
  success,
  error,
  warning,
  info,
}

enum ToastPlacementAnchor { top, center, bottom }

class ToastPlacement {
  const ToastPlacement.bottom({this.offset = 80})
      : anchor = ToastPlacementAnchor.bottom;

  const ToastPlacement.top({this.offset = 80})
      : anchor = ToastPlacementAnchor.top;

  const ToastPlacement.center()
      : anchor = ToastPlacementAnchor.center,
        offset = 0;

  final ToastPlacementAnchor anchor;
  final double offset;
}

int _toastIdCounter = 0;

String _generateToastId() {
  _toastIdCounter++;
  return 'toast_$_toastIdCounter';
}

class ToastMessage {
  ToastMessage({
    String? id,
    this.title = '',
    required this.message,
    this.type = ToastType.info,
    this.showClose = true,
    this.leadingIcon,
    this.trailingIcon,
    this.onClose,
    this.onTrailingPressed,
    this.duration = const Duration(seconds: 2),
    this.placement = const ToastPlacement.bottom(),
  }) : id = id ?? _generateToastId();

  factory ToastMessage.success({
    String title = 'Success',
    required String message,
    bool showClose = true,
    IconData? leadingIcon,
    IconData? trailingIcon,
    VoidCallback? onClose,
    VoidCallback? onTrailingPressed,
    Duration duration = const Duration(seconds: 2),
    ToastPlacement placement = const ToastPlacement.bottom(),
  }) {
    return ToastMessage(
      title: title,
      message: message,
      type: ToastType.success,
      showClose: showClose,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      onClose: onClose,
      onTrailingPressed: onTrailingPressed,
      duration: duration,
      placement: placement,
    );
  }

  factory ToastMessage.error({
    String title = 'Error',
    required String message,
    bool showClose = true,
    IconData? leadingIcon,
    IconData? trailingIcon,
    VoidCallback? onClose,
    VoidCallback? onTrailingPressed,
    Duration duration = const Duration(seconds: 3),
    ToastPlacement placement = const ToastPlacement.bottom(),
  }) {
    return ToastMessage(
      title: title,
      message: message,
      type: ToastType.error,
      showClose: showClose,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      onClose: onClose,
      onTrailingPressed: onTrailingPressed,
      duration: duration,
      placement: placement,
    );
  }

  factory ToastMessage.warning({
    String title = 'Warning',
    required String message,
    bool showClose = true,
    IconData? leadingIcon,
    IconData? trailingIcon,
    VoidCallback? onClose,
    VoidCallback? onTrailingPressed,
    Duration duration = const Duration(seconds: 3),
    ToastPlacement placement = const ToastPlacement.bottom(),
  }) {
    return ToastMessage(
      title: title,
      message: message,
      type: ToastType.warning,
      showClose: showClose,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      onClose: onClose,
      onTrailingPressed: onTrailingPressed,
      duration: duration,
      placement: placement,
    );
  }

  factory ToastMessage.info({
    String title = '',
    required String message,
    bool showClose = true,
    IconData? leadingIcon,
    IconData? trailingIcon,
    VoidCallback? onClose,
    VoidCallback? onTrailingPressed,
    Duration duration = const Duration(seconds: 2),
    ToastPlacement placement = const ToastPlacement.bottom(),
  }) {
    return ToastMessage(
      title: title,
      message: message,
      type: ToastType.info,
      showClose: showClose,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      onClose: onClose,
      onTrailingPressed: onTrailingPressed,
      duration: duration,
      placement: placement,
    );
  }

  final String id;
  final String title;
  final String message;
  final ToastType type;

  /// If true and [trailingIcon] is null, default close icon is shown.
  final bool showClose;

  /// If null, default icon is used based on [type].
  final IconData? leadingIcon;

  /// If passed, this icon is shown on the right side.
  /// If null and [showClose] is true, close icon is shown.
  final IconData? trailingIcon;

  /// Called when default close icon is tapped.
  final VoidCallback? onClose;

  /// Called when custom trailing icon is tapped.
  final VoidCallback? onTrailingPressed;

  final Duration duration;
  final ToastPlacement placement;
}

class AppToastService {
  AppToastService._();

  OverlayEntry? _entry;
  Timer? _timer;
  ToastMessage? _currentMessage;

  ToastMessage? get currentMessage => _currentMessage;

  void show(
    ToastMessage toast, {
    ToastPlacement? placement,
    double? bottom,
  }) {
    hide();

    final overlay = appNavigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _currentMessage = toast;

    _entry = OverlayEntry(
      builder: (_) {
        return _ToastOverlay(
          placement: placement ??
              (bottom == null
                  ? toast.placement
                  : ToastPlacement.bottom(offset: bottom)),
          child: AppToastView(
            toast: toast,
            onClose: () {
              toast.onClose?.call();
              hide();
            },
            onTrailingPressed: () {
              if (toast.trailingIcon != null) {
                toast.onTrailingPressed?.call();
              } else {
                toast.onClose?.call();
              }

              hide();
            },
          ),
        );
      },
    );

    overlay.insert(_entry!);
    _timer = Timer(toast.duration, hide);
  }

  void showCustom({
    required Widget Function(BuildContext context, VoidCallback close) builder,
    Duration duration = const Duration(seconds: 2),
    ToastPlacement placement = const ToastPlacement.bottom(),
    double? bottom,
  }) {
    hide();

    final overlay = appNavigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _entry = OverlayEntry(
      builder: (context) {
        return _ToastOverlay(
          placement: bottom == null
              ? placement
              : ToastPlacement.bottom(offset: bottom),
          child: builder(context, hide),
        );
      },
    );

    overlay.insert(_entry!);
    _timer = Timer(duration, hide);
  }

  void hide() {
    _timer?.cancel();
    _timer = null;

    _entry?.remove();
    _entry = null;

    _currentMessage = null;
  }
}

class _ToastOverlay extends StatelessWidget {
  const _ToastOverlay({
    required this.child,
    required this.placement,
  });

  final Widget child;
  final ToastPlacement placement;

  @override
  Widget build(BuildContext context) {
    final toast = _AnimatedToastPlacement(
      verticalOffset: switch (placement.anchor) {
        ToastPlacementAnchor.top => -12,
        ToastPlacementAnchor.center => 0,
        ToastPlacementAnchor.bottom => 12,
      },
      child: child,
    );

    final overlayChild = SafeArea(
      child: IgnorePointer(
        ignoring: false,
        child: Material(
          color: Colors.transparent,
          child: Center(child: toast),
        ),
      ),
    );

    return switch (placement.anchor) {
      ToastPlacementAnchor.top => Positioned(
          left: 16,
          right: 16,
          top: placement.offset,
          child: overlayChild,
        ),
      ToastPlacementAnchor.center => Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: overlayChild,
          ),
        ),
      ToastPlacementAnchor.bottom => Positioned(
          left: 16,
          right: 16,
          bottom: placement.offset,
          child: overlayChild,
        ),
    };
  }
}

class _AnimatedToastPlacement extends StatelessWidget {
  const _AnimatedToastPlacement({
    required this.child,
    required this.verticalOffset,
  });

  final Widget child;
  final double verticalOffset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: child,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, verticalOffset * (1 - value)),
            child: animatedChild,
          ),
        );
      },
    );
  }
}

class AppToastView extends StatelessWidget {
  const AppToastView({
    super.key,
    required this.toast,
    required this.onClose,
    required this.onTrailingPressed,
  });

  final ToastMessage toast;
  final VoidCallback onClose;
  final VoidCallback onTrailingPressed;

  @override
  Widget build(BuildContext context) {
    final colors = _ToastColors.fromType(toast.type);
    final leadingIcon = toast.leadingIcon ?? _defaultLeadingIcon(toast.type);
    final IconData? trailingIcon =
        toast.trailingIcon ?? (toast.showClose ? Icons.close : null);

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            leadingIcon,
            color: colors.icon,
            size: 22,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (toast.title.trim().isNotEmpty) ...[
                  Text(
                    toast.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  toast.message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 10),
            InkWell(
              onTap: onTrailingPressed,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  trailingIcon,
                  size: 20,
                  color: colors.trailingIcon,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _defaultLeadingIcon(ToastType type) {
    return switch (type) {
      ToastType.success => Icons.check_circle,
      ToastType.error => Icons.error,
      ToastType.warning => Icons.warning_amber_rounded,
      ToastType.info => Icons.info,
    };
  }
}

class _ToastColors {
  const _ToastColors({
    required this.background,
    required this.border,
    required this.icon,
    required this.trailingIcon,
  });

  final Color background;
  final Color border;
  final Color icon;
  final Color trailingIcon;

  factory _ToastColors.fromType(ToastType type) {
    return switch (type) {
      ToastType.success => const _ToastColors(
          background: Color(0xFFF0FDF4),
          border: Color(0xFFBBF7D0),
          icon: Color(0xFF16A34A),
          trailingIcon: Color(0xFF166534),
        ),
      ToastType.error => const _ToastColors(
          background: Color(0xFFFEF2F2),
          border: Color(0xFFFECACA),
          icon: Color(0xFFDC2626),
          trailingIcon: Color(0xFF991B1B),
        ),
      ToastType.warning => const _ToastColors(
          background: Color(0xFFFFFBEB),
          border: Color(0xFFFDE68A),
          icon: Color(0xFFD97706),
          trailingIcon: Color(0xFF92400E),
        ),
      ToastType.info => const _ToastColors(
          background: Color(0xFFEFF6FF),
          border: Color(0xFFBFDBFE),
          icon: Color(0xFF2563EB),
          trailingIcon: Color(0xFF1E40AF),
        ),
    };
  }
}
