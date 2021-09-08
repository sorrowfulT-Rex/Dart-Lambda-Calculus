import 'package:dartz/dartz.dart';

/// Types of lambda expressions.
enum LambdaType {
  VARIABLE,
  APPLICATION,
  ABSTRACTION,
  DUMMY,
}

/// The class representing lambda expressions.
class Lambda {
  Lambda({
    required this.type,
    this.index, // For variable
    this.exp1, // For application and abstraction
    this.exp2, // For application
  }) : assert(!(type == LambdaType.VARIABLE &&
                (index == null || exp1 != null || exp2 != null)) &&
            !(type == LambdaType.APPLICATION &&
                (index != null || exp1 == null || exp2 == null)) &&
            !(type == LambdaType.ABSTRACTION &&
                (index != null || exp1 == null || exp2 != null)));
  LambdaType type;
  int? index;
  Lambda? exp1;
  Lambda? exp2;

  /// Construct a lambda variable with the given De Bruijn index.
  static Lambda fromIndex(int index) =>
      Lambda(type: LambdaType.VARIABLE, index: index);

  /// Construct the abstraction of a given lambda expression.
  static Lambda abstract(Lambda lambda) =>
      Lambda(type: LambdaType.ABSTRACTION, exp1: lambda);

  /// Apply a list of lambda expressions together from left to right.
  static Lambda applyAll(List<Lambda> lambdas) {
    if (lambdas.isEmpty) {
      return Lambda(
        type: LambdaType.ABSTRACTION,
        exp1: Lambda(type: LambdaType.VARIABLE, index: 0),
      );
    }

    return lambdas.reduce(
      (previousValue, element) => Lambda(
        type: LambdaType.APPLICATION,
        exp1: previousValue,
        exp2: element,
      ),
    );
  }

  /// Apply a list of lambda expressions together from right to left.
  static Lambda applyAllReversed(List<Lambda> lambdas) {
    if (lambdas.isEmpty) {
      return Lambda(
        type: LambdaType.ABSTRACTION,
        exp1: Lambda(type: LambdaType.VARIABLE, index: 0),
      );
    }

    Lambda _applyAllReversed(List<Lambda> lambdas) {
      if (lambdas.length == 1) {
        return lambdas.first;
      }

      final first = lambdas.removeAt(0);
      return Lambda(
        type: LambdaType.APPLICATION,
        exp1: first,
        exp2: applyAllReversed(lambdas),
      );
    }

    return _applyAllReversed(lambdas);
  }

  /// A higher-order function that iterates on the [Lambda], returning a value.
  R fold<R, T>({
    required T initialParam,
    required R Function(T) select,
    T Function(Lambda, T)? onVar,
    T Function(T)? onAbsEnter,
    T Function(T)? onAbsExit,
    T Function(T)? onAppEnter,
    T Function(T)? onAppExit,
  }) {
    final lambdaStack = [this];
    final isExp1Stack = [true];
    var param = initialParam;

    while (lambdaStack.isNotEmpty) {
      print(lambdaStack.last);
      if (lambdaStack.last.type == LambdaType.VARIABLE) {
        param = onVar?.call(lambdaStack.last, param) ?? param;
        while (true) {
          lambdaStack.removeLast();
          if (lambdaStack.isEmpty) break;
          if (lambdaStack.last.type == LambdaType.ABSTRACTION) {
            isExp1Stack.removeLast();
            param = onAbsExit?.call(param) ?? param;
          } else if (isExp1Stack.last) {
            lambdaStack.add(lambdaStack.last.exp2!);
            isExp1Stack.last = false;
            param = onAppExit?.call(param) ?? param;
            param = onAppEnter?.call(param) ?? param;
            break;
          } else {
            isExp1Stack.removeLast();
            param = onAppExit?.call(param) ?? param;
          }
        }
      } else if (lambdaStack.last.type == LambdaType.ABSTRACTION) {
        lambdaStack.add(lambdaStack.last.exp1!);
        isExp1Stack.add(true);
        param = onAbsEnter?.call(param) ?? param;
      } else {
        lambdaStack.add(lambdaStack.last.exp1!);
        isExp1Stack.add(true);
        param = onAppEnter?.call(param) ?? param;
      }
    }

    return select(param);
  }

  /// A higher-order function that turns recursion on the [Lambda] to iteration,
  /// returning another [Lambda].
  Lambda fmap<T>({
    required Lambda Function(Lambda, T?) onVar,
    T? initialParam,
    T? Function(T?)? onAbsEnter,
    T? Function(T?)? onAbsExit,
    T? Function(T?)? onAppEnter,
    T? Function(T?)? onAppExit,
  }) {
    final lambdaStack = [this];
    final resultStack = <Lambda>[Lambda(type: LambdaType.DUMMY)];
    final isExp1Stack = [true];
    var param = initialParam;

    while (lambdaStack.isNotEmpty) {
      if (lambdaStack.last.type == LambdaType.VARIABLE) {
        resultStack.last = onVar(lambdaStack.last, param);
        while (true) {
          lambdaStack.removeLast();
          if (lambdaStack.isEmpty) break;
          var tempLambda = resultStack.removeLast();
          if (resultStack.last.type == LambdaType.ABSTRACTION) {
            resultStack.last.exp1 = tempLambda;
            isExp1Stack.removeLast();
            param = onAbsExit?.call(param) ?? param;
          } else if (isExp1Stack.last) {
            resultStack.last.exp1 = tempLambda;
            lambdaStack.add(lambdaStack.last.exp2!);
            resultStack.add(Lambda(type: LambdaType.DUMMY));
            isExp1Stack.last = false;
            param = onAppExit?.call(param) ?? param;
            param = onAppEnter?.call(param) ?? param;
            break;
          } else {
            resultStack.last.exp2 = tempLambda;
            isExp1Stack.removeLast();
            param = onAppExit?.call(param) ?? param;
          }
        }
      } else if (lambdaStack.last.type == LambdaType.ABSTRACTION) {
        resultStack.last.type = LambdaType.ABSTRACTION;
        resultStack.add(Lambda(type: LambdaType.DUMMY));
        lambdaStack.add(lambdaStack.last.exp1!);
        isExp1Stack.add(true);
        param = onAbsEnter?.call(param) ?? param;
      } else {
        resultStack.last.type = LambdaType.APPLICATION;
        resultStack.add(Lambda(type: LambdaType.DUMMY));
        lambdaStack.add(lambdaStack.last.exp1!);
        isExp1Stack.add(true);
        param = onAppEnter?.call(param) ?? param;
      }
    }

    assert(resultStack.length == 1);
    return resultStack.first;
  }

  /// Clone this lambda expression.
  ///
  /// Avoids recursion.
  Lambda clone() => fmap<Null>(
        onVar: (lambda, _) => Lambda(
          type: LambdaType.VARIABLE,
          index: lambda.index,
        ),
      );

  /// Returns the number of free variables in the lambda expression.
  ///
  /// If the 'isDistinct' parameter is set to true, count for the number of
  /// distinct free variables; otherwise count for the total appearances.
  int freeCount({bool isDistinct = false}) =>
      fold<int, Tuple3<int, int, Set<int>>>(
        initialParam: Tuple3(0, 0, {}),
        select: (tuple3) => tuple3.value1,
        onAbsEnter: (tuple3) => tuple3.copyWith(value2: tuple3.value2 + 1),
        onAbsExit: (tuple3) => tuple3.copyWith(value2: tuple3.value2 - 1),
        onVar: isDistinct
            ? (lambda, tuple3) {
                if (tuple3.value2 - lambda.index! <= 0 &&
                    !tuple3.value3.contains(tuple3.value2 - lambda.index!)) {
                  tuple3.value3.add(tuple3.value2 - lambda.index!);
                  return tuple3.copyWith(value1: tuple3.value1 + 1);
                } else {
                  return tuple3;
                }
              }
            : (lambda, tuple3) {
                if (tuple3.value2 - lambda.index! <= 0) {
                  return tuple3.copyWith(value1: tuple3.value1 + 1);
                } else {
                  return tuple3;
                }
              },
      );
  // {
  //   var count = 0;
  //   final lambdaStack = [this];
  //   final isExp1Stack = [true];
  //   var depth = 0;
  //   final indices = <int>{};

  //   while (lambdaStack.isNotEmpty) {
  //     if (lambdaStack.last.type == LambdaType.VARIABLE) {
  //       if (lambdaStack.last.index! >= depth) {
  //         if (isDistinct && indices.contains(depth - lambdaStack.last.index!)) {
  //         } else {
  //           indices.add(depth - lambdaStack.last.index!);
  //           count++;
  //         }
  //       }
  //       while (true) {
  //         lambdaStack.removeLast();
  //         if (lambdaStack.isEmpty) break;
  //         var tempLambda = lambdaStack.removeLast();
  //         if (tempLambda.type == LambdaType.ABSTRACTION) {
  //           isExp1Stack.removeLast();
  //           depth--;
  //         } else if (isExp1Stack.last) {
  //           lambdaStack.add(tempLambda.exp2!);
  //           isExp1Stack.last = false;
  //           break;
  //         } else {
  //           isExp1Stack.removeLast();
  //         }
  //       }
  //     } else if (lambdaStack.last.type == LambdaType.ABSTRACTION) {
  //       lambdaStack.add(lambdaStack.last.exp1!);
  //       isExp1Stack.add(true);
  //       depth++;
  //     } else {
  //       lambdaStack.add(lambdaStack.last.exp1!);
  //       isExp1Stack.add(true);
  //     }
  //   }

  //   return count;
  // }

  @override
  int get hashCode => toString().hashCode;

  /// The equality operator.
  ///
  /// Returns true iff the two [Lambda]s are syntactically identical.
  ///
  /// Avoids recursion.
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != Lambda) return false;

    final lambdaStack1 = [this];
    final lambdaStack2 = [other as Lambda];
    final isExp1Stack = [true];

    while (lambdaStack1.isNotEmpty) {
      if (lambdaStack1.last.type != lambdaStack2.last.type) return false;
      if (lambdaStack1.last.type == LambdaType.VARIABLE) {
        if (lambdaStack1.last.index != lambdaStack2.last.index) return false;
        while (true) {
          lambdaStack1.removeLast();
          lambdaStack2.removeLast();
          if (lambdaStack1.isEmpty) break;
          if (lambdaStack1.last.type == LambdaType.ABSTRACTION) {
            isExp1Stack.removeLast();
          } else if (isExp1Stack.last) {
            lambdaStack1.add(lambdaStack1.last.exp2!);
            lambdaStack2.add(lambdaStack2.last.exp2!);
            isExp1Stack.last = false;
            break;
          } else {
            isExp1Stack.removeLast();
          }
        }
      } else {
        lambdaStack1.add(lambdaStack1.last.exp1!);
        lambdaStack2.add(lambdaStack2.last.exp1!);
        isExp1Stack.add(true);
      }
    }

    return true;
  }

  /// A string representation of the [Lambda] without redundant brackets.
  ///
  /// Avoids recursion.
  @override
  String toString() {
    if (type == LambdaType.DUMMY) return '[DUMMY]';

    final lambdaStack = <Lambda?>[];
    final sb = StringBuffer();
    var cur = this;
    var depth = 0;
    final useBraces = [false];

    while (true) {
      if (cur.type == LambdaType.VARIABLE) {
        sb.write('x${depth - cur.index!}');
        while (lambdaStack.isNotEmpty) {
          if (lambdaStack.last == null) {
            depth--;
            useBraces.removeLast();
            if (useBraces.last) {
              sb.write(')');
            }
            lambdaStack.removeLast();
          } else if (lambdaStack.last!.type == LambdaType.DUMMY) {
            useBraces.removeLast();
            if (useBraces.last) {
              sb.write(')');
            }
            lambdaStack.removeLast();
          } else {
            break;
          }
        }
        if (lambdaStack.isEmpty) break;
        sb.write(' ');
        cur = lambdaStack.removeLast()!;
        useBraces.removeLast();
        useBraces.add(true);
      } else if (cur.type == LambdaType.APPLICATION) {
        if (useBraces.last) {
          sb.write('(');
        }
        lambdaStack.add(Lambda(type: LambdaType.DUMMY));
        lambdaStack.add(cur.exp2);
        cur = cur.exp1!;
        useBraces.add(cur.type == LambdaType.ABSTRACTION);
      } else {
        depth++;
        if (useBraces.last) {
          sb.write('(');
        }
        sb.write('λx$depth. ');
        lambdaStack.add(null);
        useBraces.add(false);
        cur = cur.exp1!;
      }
    }

    return sb.toString();
  }
}
