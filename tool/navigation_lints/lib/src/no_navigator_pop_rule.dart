import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:navigation_lints/src/navigator_pop_matcher.dart';

class NoNavigatorPopRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_navigator_pop',
    "Use 'context.pop()' instead of direct Navigator pop calls.",
    correctionMessage: "Replace this with 'context.pop(...)'.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'NavigationLintCode.no_navigator_pop',
  );

  NoNavigatorPopRule()
    : super(
        name: 'no_navigator_pop',
        description: 'Prefer AppRoute context.pop() for route popping.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodInvocation(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final NoNavigatorPopRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (isDisallowedNavigatorPop(node)) {
      rule.reportAtNode(node.methodName);
    }
  }
}
