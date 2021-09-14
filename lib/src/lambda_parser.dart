import 'package:lambda_calculus/src/lambda.dart';

/// Types of lambda tokens.
enum LambdaTokenType {
  LAMBDA,
  SPACE,
  LBRACE,
  RBRACE,
  VARIABLE,
}

/// The class representing lambda tokens after lexing.
class LambdaToken {
  LambdaToken(
    this.type,
    this.index,
  );
  final LambdaTokenType type;
  final int? index;

  @override
  String toString() {
    switch (type) {
      case LambdaTokenType.LAMBDA:
        return '{λ}';
      case LambdaTokenType.SPACE:
        return '{ }';
      case LambdaTokenType.LBRACE:
        return '{(}';
      case LambdaTokenType.RBRACE:
        return '{)}';
      case LambdaTokenType.VARIABLE:
        return '{x$index}';
    }
  }
}

/// Convert a [String] to a [List]<[LambdaToken]>?.
///
/// Returns null only if the [String] is not a valid lambda expression.
List<LambdaToken>? _lambdaLexer(String str) {
  final tokens = <LambdaToken>[];
  final iterator = str.runes.iterator;
  final boundedVarStack = <String>[];
  final freeVarStack = <String>[];
  // The int represents the number of 'λ's since here before the next bracket.
  // We push an 0 on left brackets and pop at right brackets.
  final bracketStack = [0];
  final alpha = RegExp(r'^[a-zA-Z]+$');
  final numeric = RegExp(r'^[0-9]+$');
  final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
  final blank = RegExp(r'^[\r\n\t\v ]+$');

  while (iterator.moveNext()) {
    switch (String.fromCharCode(iterator.current)) {
      // MARK: Left Bracket
      case r'(':
        bracketStack.add(0);
        tokens.add(LambdaToken(LambdaTokenType.LBRACE, null));
        break;
      // MARK: Right Bracket
      case r')':
        // MARK: Extraneous Right Bracket
        if (bracketStack.length == 1) return null;
        // Remove out-of-scope variables.
        boundedVarStack.removeRange(0, bracketStack.removeLast());
        tokens.add(LambdaToken(LambdaTokenType.RBRACE, null));
        // MARK: Space if Necessary
        if (iterator.moveNext()) {
          if (blank.hasMatch(String.fromCharCode(iterator.current)) ||
              String.fromCharCode(iterator.current) != ')') {
            tokens.add(LambdaToken(LambdaTokenType.SPACE, null));
          }
          iterator.movePrevious();
        }
        break;
      // MARK: Lambda
      case r'λ':
      case r'/':
      case r'\':
        bracketStack.last++;
        if (!iterator.moveNext()) return null;
        // Determine the name of the variable.
        final tempVarBuffer = StringBuffer();
        // MARK: Anonymous Variable
        if (String.fromCharCode(iterator.current) == '.') {
          tokens.add(LambdaToken(LambdaTokenType.LAMBDA, null));
          boundedVarStack.insert(0, '');
          break;
        }
        if (!alpha.hasMatch(String.fromCharCode(iterator.current))) {
          tokens.add(LambdaToken(LambdaTokenType.LAMBDA, null));
          boundedVarStack.insert(0, '');
          iterator.movePrevious();
          break;
        }
        // MARK: Explicit Variable
        while (alphanumeric.hasMatch(String.fromCharCode(iterator.current))) {
          tempVarBuffer.write(String.fromCharCode(iterator.current));
          if (!iterator.moveNext()) return null;
        }
        if (String.fromCharCode(iterator.current) == '.' &&
            !iterator.moveNext()) {
          return null;
        }
        iterator.movePrevious();

        final tempVar = tempVarBuffer.toString();
        tokens.add(LambdaToken(LambdaTokenType.LAMBDA, null));
        boundedVarStack.insert(0, tempVar);
        break;
      default:
        // MARK: Ignore Space
        if (blank.hasMatch(String.fromCharCode(iterator.current))) break;
        // MARK: Named Variable
        if (alpha.hasMatch(String.fromCharCode(iterator.current))) {
          final tempVarBuffer = StringBuffer();
          while (alphanumeric.hasMatch(String.fromCharCode(iterator.current))) {
            tempVarBuffer.write(String.fromCharCode(iterator.current));
            if (!iterator.moveNext()) break;
          }

          final tempVar = tempVarBuffer.toString();
          var index = boundedVarStack.indexOf(tempVar);
          if (index != -1) {
            // Bounded variable.
            tokens.add(LambdaToken(LambdaTokenType.VARIABLE, index));
          } else if ((index = freeVarStack.indexOf(tempVar)) != -1) {
            // Free variable (appeared before).
            tokens.add(LambdaToken(
              LambdaTokenType.VARIABLE,
              boundedVarStack.length + index,
            ));
          } else {
            // Free variable (first appearance).
            tokens.add(LambdaToken(
              LambdaTokenType.VARIABLE,
              boundedVarStack.length + freeVarStack.length,
            ));
            freeVarStack.add(tempVar);
          }

          // MARK: Space if Necessary
          if (iterator.current >= 0 &&
              (blank.hasMatch(String.fromCharCode(iterator.current)) ||
                  String.fromCharCode(iterator.current) == '(')) {
            tokens.add(LambdaToken(LambdaTokenType.SPACE, null));
          }
          iterator.movePrevious();

          break;
        }
        // MARK: De Bruijn Index
        if (numeric.hasMatch(String.fromCharCode(iterator.current))) {
          var index = 0;
          while (numeric.hasMatch(String.fromCharCode(iterator.current))) {
            index *= 10;
            index += int.parse(String.fromCharCode(iterator.current));
            if (!iterator.moveNext()) break;
          }
          // Does not support De Bruijn Index for free variables.
          if (index >= boundedVarStack.length) return null;
          tokens.add(LambdaToken(LambdaTokenType.VARIABLE, index));

          if (iterator.current >= 0) {
            // Does not allow letters immediately after an index.
            if (alpha.hasMatch(String.fromCharCode(iterator.current))) {
              return null;
            }
            // MARK: Space if Necessary
            if (blank.hasMatch(String.fromCharCode(iterator.current)) ||
                String.fromCharCode(iterator.current) == '(') {
              tokens.add(LambdaToken(LambdaTokenType.SPACE, null));
            }
            iterator.movePrevious();
          }
          break;
        }
        return null;
    }
  }

  // Trim for potential final space.
  if (tokens.last.type == LambdaTokenType.SPACE) tokens.removeLast();

  return tokens;
}

/// Parse a [List]<[LambdaToken]> to a [Lambda]?.
///
/// Returns null if the tokens do not represent a valid lambda expression.
Lambda? _lambdaParser(List<LambdaToken> tokens) {
  final lambdaStack = <Lambda>[];
  final opStack = <LambdaTokenType>[LambdaTokenType.RBRACE];

  if (tokens.isEmpty) return null;

  // Shunting Yard Algorithm.
  for (final token in tokens) {
    switch (token.type) {
      // MARK: Lambda
      // Has lowest precedence.
      case LambdaTokenType.LAMBDA:
        opStack.add(LambdaTokenType.LAMBDA);
        break;
      // MARK: Application
      // Has hitghes precedence.
      case LambdaTokenType.SPACE:
        while (opStack.last == LambdaTokenType.SPACE) {
          opStack.removeLast();
          final lambda2 = lambdaStack.removeLast();
          final lambda1 = lambdaStack.removeLast();
          lambdaStack.add(
            Lambda(type: LambdaType.APPLICATION, exp1: lambda1, exp2: lambda2),
          );
        }
        opStack.add(LambdaTokenType.SPACE);
        break;
      // MARK: Left Bracket
      case LambdaTokenType.LBRACE:
        opStack.add(LambdaTokenType.LBRACE);
        break;
      // MARK: Left Bracket
      case LambdaTokenType.RBRACE:
        while (true) {
          final op = opStack.removeLast();
          if (op == LambdaTokenType.LBRACE) break;
          if (op == LambdaTokenType.RBRACE) return null;
          if (op == LambdaTokenType.LAMBDA) {
            lambdaStack.add(Lambda.abstract(lambdaStack.removeLast()));
            continue;
          }
          final lambda2 = lambdaStack.removeLast();
          final lambda1 = lambdaStack.removeLast();
          lambdaStack.add(
            Lambda(type: LambdaType.APPLICATION, exp1: lambda1, exp2: lambda2),
          );
        }
        break;
      case LambdaTokenType.VARIABLE:
        lambdaStack.add(Lambda.fromIndex(token.index!));
        break;
    }
  }

  while (opStack.last != LambdaTokenType.RBRACE) {
    final op = opStack.removeLast();
    // MARK: Lambda
    if (op == LambdaTokenType.LAMBDA) {
      if (lambdaStack.isEmpty) return null;
      lambdaStack.add(Lambda.abstract(lambdaStack.removeLast()));
      continue;
    }
    // MARK: Application
    if (op == LambdaTokenType.SPACE) {
      if (lambdaStack.length <= 1) return null;
      final lambda2 = lambdaStack.removeLast();
      final lambda1 = lambdaStack.removeLast();
      lambdaStack.add(
        Lambda(type: LambdaType.APPLICATION, exp1: lambda1, exp2: lambda2),
      );
      continue;
    }
    // MARK: Invalid Operator
    return null;
  }

  return lambdaStack.last;
}

extension ToLambdaExtension on String {
  Lambda? toLambda() {
    final tokens = _lambdaLexer(this);
    if (tokens == null) return null;
    return _lambdaParser(tokens);
  }
}
