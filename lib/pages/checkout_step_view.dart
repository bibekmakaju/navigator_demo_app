import 'dart:async';

import 'package:flutter/material.dart';
import 'package:navigation_router_demo/app_router.dart';

enum CheckoutStep { cart, address, payment, review, success }

extension CheckoutStepInfo on CheckoutStep {
  String get routeName {
    return switch (this) {
      CheckoutStep.cart => Routes.cart,
      CheckoutStep.address => Routes.address,
      CheckoutStep.payment => Routes.payment,
      CheckoutStep.review => Routes.review,
      CheckoutStep.success => Routes.success,
    };
  }

  String get title {
    return switch (this) {
      CheckoutStep.cart => 'Cart',
      CheckoutStep.address => 'Address',
      CheckoutStep.payment => 'Payment',
      CheckoutStep.review => 'Review',
      CheckoutStep.success => 'Success',
    };
  }

  String get subtitle {
    return switch (this) {
      CheckoutStep.cart => 'Start a nested checkout stack.',
      CheckoutStep.address => 'Try push, replace, and pop-until from here.',
      CheckoutStep.payment => 'Try remove and replace-until examples.',
      CheckoutStep.review => 'Finish the flow or reset the whole stack.',
      CheckoutStep.success => 'A terminal page created by replaceAll.',
    };
  }

  IconData get icon {
    return switch (this) {
      CheckoutStep.cart => Icons.shopping_cart_outlined,
      CheckoutStep.address => Icons.local_shipping_outlined,
      CheckoutStep.payment => Icons.credit_card_outlined,
      CheckoutStep.review => Icons.rate_review_outlined,
      CheckoutStep.success => Icons.check_circle_outline,
    };
  }

  CheckoutStep? get next {
    return switch (this) {
      CheckoutStep.cart => CheckoutStep.address,
      CheckoutStep.address => CheckoutStep.payment,
      CheckoutStep.payment => CheckoutStep.review,
      CheckoutStep.review || CheckoutStep.success => null,
    };
  }
}

class CheckoutStepView extends StatefulWidget {
  const CheckoutStepView({
    super.key,
    required this.step,
    this.initialMessage,
  });

  final CheckoutStep step;
  final String? initialMessage;

  static RoutePage<String> page(
    CheckoutStep step, {
    String? initialMessage,
    TransitionType transitionType = TransitionType.material,
  }) {
    return RoutePage<String>(
      child: CheckoutStepView(
        step: step,
        initialMessage: initialMessage,
      ),
      name: step.routeName,
      transitionType: transitionType,
    );
  }

  @override
  State<CheckoutStepView> createState() => _CheckoutStepViewState();
}

class _CheckoutStepViewState extends State<CheckoutStepView> {
  late String _lastEvent;

  @override
  void initState() {
    super.initState();
    _lastEvent = widget.initialMessage ?? widget.step.subtitle;
  }

  Future<void> _pushNextAndWait() async {
    final next = widget.step.next;
    if (next == null) return;

    final result = await context.push<String>(
      CheckoutStepView.page(
        next,
        initialMessage: 'Pushed from ${widget.step.title}.',
        transitionType: TransitionType.cupertino,
      ),
    );

    if (!mounted) return;
    setState(() {
      _lastEvent = result ?? '${next.title} closed without a result.';
    });
  }

  void _replaceCurrentWithNext() {
    final next = widget.step.next;
    if (next == null) return;

    context.replaceCurrent(
      CheckoutStepView.page(
        next,
        initialMessage: '${widget.step.title} was replaced by ${next.title}.',
        transitionType: TransitionType.fade,
      ),
    );
  }

  void _pushDuplicateCart() {
    unawaited(
      context.push<String>(
        CheckoutStepView.page(
          CheckoutStep.cart,
          initialMessage: 'This is another Cart page with the same route name.',
        ),
      ),
    );

    setState(() {
      _lastEvent = 'Pushed another Cart route with a unique page key.';
    });
  }

  void _removeThisPage() {
    context.removeLast(1);
  }

  void _popUntilCart() {
    final found = context.popUntilRouteName(Routes.cart);
    if (!mounted) return;

    setState(() {
      _lastEvent = found
          ? 'Already on Cart, so popUntil kept this page.'
          : 'Cart was not found before reaching root.';
    });
  }

  void _replaceUntilAddressWithReview() {
    final found = context.replaceUntilRouteName(
      Routes.address,
      CheckoutStepView.page(
        CheckoutStep.review,
        initialMessage: 'Address and everything above it became Review.',
        transitionType: TransitionType.fade,
      ),
    );

    if (!found) {
      setState(() {
        _lastEvent = 'Address route was not found; stack stayed unchanged.';
      });
    }
  }

  void _replaceUntilMissingRoute() {
    final found = context.replaceUntilRouteName(
      'missing-route',
      CheckoutStepView.page(CheckoutStep.success),
    );

    setState(() {
      _lastEvent = found
          ? 'Unexpectedly found missing-route.'
          : 'Missing route was not found; replaceUntil did nothing.';
    });
  }

  void _replaceAllWithSuccess() {
    context.replaceAll(
      CheckoutStepView.page(
        CheckoutStep.success,
        initialMessage: 'The whole stack was replaced with Success.',
        transitionType: TransitionType.fade,
      ),
    );
  }

  void _replaceAllWithCart() {
    context.replaceAll(
      CheckoutStepView.page(
        CheckoutStep.cart,
        initialMessage: 'Checkout restarted from Success.',
        transitionType: TransitionType.fade,
      ),
    );
  }

  void _popWithResult() {
    context.pop<String>(result: '${widget.step.title} completed.');
  }

  void _popWithoutResult() {
    context.pop<void>();
  }

  void _showStackDialog() {
    final routeNames =
        context.routePages.map((page) => page.name ?? 'unnamed').join(' -> ');

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Checkout stack'),
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

  @override
  Widget build(BuildContext context) {
    final next = widget.step.next;

    return Scaffold(
      appBar: AppBar(title: Text(widget.step.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StepStatusCard(
            icon: widget.step.icon,
            title: widget.step.title,
            text: _lastEvent,
          ),
          const SizedBox(height: 16),
          if (next != null) ...[
            _StepActionTile(
              icon: Icons.call_made,
              title: 'Push ${next.title} and wait',
              subtitle: 'Pushes a page and awaits the result Future.',
              onTap: _pushNextAndWait,
            ),
            _StepActionTile(
              icon: Icons.swap_horiz,
              title: 'Replace current with ${next.title}',
              subtitle: 'Removes this page and inserts the next step.',
              onTap: _replaceCurrentWithNext,
            ),
          ],
          if (widget.step == CheckoutStep.cart)
            _StepActionTile(
              icon: Icons.copy_outlined,
              title: 'Push duplicate Cart',
              subtitle: 'Shows same route names with unique page keys.',
              onTap: _pushDuplicateCart,
            ),
          if (widget.step != CheckoutStep.cart &&
              widget.step != CheckoutStep.success) ...[
            _StepActionTile(
              icon: Icons.low_priority,
              title: 'Pop until Cart',
              subtitle: 'Removes pages until the Cart route is on top.',
              onTap: _popUntilCart,
            ),
            _StepActionTile(
              icon: Icons.layers_clear_outlined,
              title: 'Remove this page',
              subtitle: 'Calls removeLast(1) from the current page.',
              onTap: _removeThisPage,
            ),
          ],
          if (widget.step == CheckoutStep.payment)
            _StepActionTile(
              icon: Icons.find_replace,
              title: 'Replace until Address with Review',
              subtitle: 'Replaces Address and every page above it.',
              onTap: _replaceUntilAddressWithReview,
            ),
          if (widget.step == CheckoutStep.review) ...[
            _StepActionTile(
              icon: Icons.check,
              title: 'Complete flow with result',
              subtitle: 'Pops Review and returns a String result.',
              onTap: _popWithResult,
            ),
            _StepActionTile(
              icon: Icons.restart_alt,
              title: 'Replace all with Success',
              subtitle: 'Clears the whole stack and shows Success as root.',
              onTap: _replaceAllWithSuccess,
            ),
          ],
          if (widget.step == CheckoutStep.success)
            _StepActionTile(
              icon: Icons.shopping_cart_checkout,
              title: 'Replace all with Cart',
              subtitle: 'Restarts the checkout stack from the first step.',
              onTap: _replaceAllWithCart,
            ),
          _StepActionTile(
            icon: Icons.search_off_outlined,
            title: 'Try replaceUntil missing route',
            subtitle: 'Demonstrates the false/no-op branch.',
            onTap: _replaceUntilMissingRoute,
          ),
          _StepActionTile(
            icon: Icons.account_tree_outlined,
            title: 'Show checkout stack',
            subtitle: 'Displays the current page stack by route name.',
            onTap: _showStackDialog,
          ),
          if (widget.step != CheckoutStep.success)
            _StepActionTile(
              icon: Icons.close,
              title: 'Pop without result',
              subtitle: 'Closes this page and completes with null.',
              onTap: _popWithoutResult,
            ),
        ],
      ),
    );
  }
}

class _StepStatusCard extends StatelessWidget {
  const _StepStatusCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepActionTile extends StatelessWidget {
  const _StepActionTile({
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
