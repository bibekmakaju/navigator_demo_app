import 'package:analyzer/dart/ast/ast.dart';

bool isDisallowedNavigatorPop(MethodInvocation node) {
  if (node.methodName.name != 'pop') return false;

  return _isNavigatorPopWithContext(node) ||
      _isNavigatorOfContextPop(node.realTarget);
}

bool _isNavigatorPopWithContext(MethodInvocation node) {
  return _isNavigatorIdentifier(node.target) &&
      _hasContextPositionalArgument(node.argumentList);
}

bool _isNavigatorOfContextPop(Expression? target) {
  if (target is! MethodInvocation) return false;

  return target.methodName.name == 'of' &&
      _isNavigatorIdentifier(target.target) &&
      _hasContextPositionalArgument(target.argumentList);
}

bool _hasContextPositionalArgument(ArgumentList argumentList) {
  for (final argument in argumentList.arguments) {
    if (argument is NamedArgument) continue;
    return _isContextIdentifier(argument.argumentExpression);
  }

  return false;
}

bool _isContextIdentifier(Expression expression) {
  return expression is SimpleIdentifier && expression.name == 'context';
}

bool _isNavigatorIdentifier(Expression? expression) {
  return expression is SimpleIdentifier && expression.name == 'Navigator';
}
