import 'package:flutter/foundation.dart';

@immutable
class ProductSelection {
  const ProductSelection({
    required this.productId,
    required this.productName,
    required this.quantity,
  });

  final String productId;
  final String productName;
  final int quantity;

  String get label => '$quantity x $productName ($productId)';

  @override
  String toString() => label;
}

@immutable
class SettingsResult {
  const SettingsResult({
    required this.themeName,
    required this.notificationsEnabled,
  });

  final String themeName;
  final bool notificationsEnabled;

  String get label =>
      '$themeName theme, notifications ${notificationsEnabled ? 'on' : 'off'}';

  @override
  String toString() => label;
}
