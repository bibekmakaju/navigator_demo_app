import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:navigation_lints/src/no_navigator_pop_rule.dart';

final plugin = NavigationLintsPlugin();

class NavigationLintsPlugin extends Plugin {
  @override
  String get name => 'Navigation lints';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(NoNavigatorPopRule());
  }
}
