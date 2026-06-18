import 'package:flutter/material.dart';
import 'package:navigation_router_demo/app_router.dart';
import 'package:navigation_router_demo/models/navigation_results.dart';
import 'package:navigation_router_demo/pages/settings_view.dart';

class ProductView extends StatefulWidget {
  const ProductView({
    super.key,
    required this.productId,
    required this.productName,
  });

  final String productId;
  final String productName;

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  int _quantity = 1;
  String _nestedResult = 'No nested route result yet.';

  ProductSelection get _selection => ProductSelection(
        productId: widget.productId,
        productName: widget.productName,
        quantity: _quantity,
      );

  Future<void> _openSettingsFromProduct() async {
    final result = await context.push<SettingsResult>(
      RoutePage(
        child: const SettingsView(),
        name: Routes.settings,
        transitionType: TransitionType.fade,
      ),
    );

    if (!mounted) return;
    setState(() {
      _nestedResult = result == null
          ? 'Nested Settings popped without result.'
          : 'Nested Settings returned: ${result.label}';
    });
  }

  Future<void> _pushAnotherProduct() async {
    final result = await context.push<ProductSelection>(
      RoutePage(
        child: const ProductView(
          productId: 'SKU-3003',
          productName: 'Stacked Product',
        ),
        name: Routes.product,
        transitionType: TransitionType.cupertino,
      ),
    );

    if (!mounted) return;
    setState(() {
      _nestedResult = result == null
          ? 'Stacked Product popped without result.'
          : 'Stacked Product returned: ${result.label}';
    });
  }

  void _returnSelection() {
    context.pop<ProductSelection>(result: _selection);
  }

  void _closeWithoutResult() {
    context.pop<void>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.productName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(widget.productId),
          const SizedBox(height: 24),
          Row(
            children: [
              IconButton(
                onPressed: _quantity == 1
                    ? null
                    : () => setState(() => _quantity -= 1),
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  'Quantity: $_quantity',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _quantity += 1),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoPanel(text: _nestedResult),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _returnSelection,
            icon: const Icon(Icons.check),
            label: const Text('Pop with product result'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _closeWithoutResult,
            icon: const Icon(Icons.close),
            label: const Text('Pop without result'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openSettingsFromProduct,
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Push Settings from Product'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pushAnotherProduct,
            icon: const Icon(Icons.layers_outlined),
            label: const Text('Push another Product'),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text),
      ),
    );
  }
}
