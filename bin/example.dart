import 'package:lambda_calculus/lambda_calculus.dart';
import 'package:lambda_calculus/src/lambda_constants.dart';

void main(List<String> arguments) {
  // This main function is a walkthrough for this lambda-calculus interpreter,
  // assuming you already know about untyped lambda-calculus.
  // Check out each function for more details.

  print('PART I:  PURE UNTYPED LAMBDA CALCULUS\n');
  _printExamples();
  _parseLambda();
  _evaluationsByValue();
  _fullEvaluations();
  _evaluationsByName();
  _factorial();
  print('');
}

void _printExamples() {
  // This function prints out several useful lambda expressions.

  print('Some lambda expressions with minimal brackets: ');
  print('Lambda Id:    ' + LambdaConstants.lambdaIdentity.toString());
  print('Lambda True:  ' + LambdaConstants.lambdaTrue.toString());
  print('Lambda False: ' + LambdaConstants.lambdaFalse.toString());
  print('Lambda Test:  ' + LambdaConstants.lambdaTest.toString());
  print('Lambda And:   ' + LambdaConstants.lambdaAnd.toString());
  print('Lambda Pair:  ' + LambdaConstants.lambdaPair.toString());
  print('Lambda Not:   ' + LambdaConstants.lambdaNot.toString());
  print('Lambda Succ:  ' + LambdaConstants.lambdaSucc.toString());
  print('Lambda Times: ' + LambdaConstants.lambdaTimes.toString());
  print('Lambda Plus:  ' + LambdaConstants.lambdaPlus.toString());
  print('Lambda Seven: ' + LambdaConstants.lambdaSeven.toString());
  print('Omega:        ' + LambdaConstants.omega.toString());
  print('Y-Combinator: ' + LambdaConstants.yCombinator.toString());
  print('');
}

void _parseLambda() {
  // This function parses several lambda expressions from String.

  String str;
  Lambda? temp;

  print('Lambda parser: ');

  // The names of the variables are not preserved (everything is converted to
  // x1, x2 etc.), but otherwise they are syntactically identical.
  print("1. Print the 'succ' expression:");
  str = 'λa. λb. λc. b (a b c)';
  temp = str.toLambda();
  print('    original: $str');
  print('    parsed:   $temp');
  // We can also use slash and backslash to replace the lambda letter.
  print('2. Print the Y-Combinator:');
  str = r'/x. (\y. x (\z. y y z)) (/y. x (/z. y y z))';
  temp = str.toLambda();
  print('    original: $str');
  print('    parsed:   $temp');
  print('3. Print an invalid lambda expression:');
  str = 'λx. ';
  temp = str.toLambda();
  print('    original: $str');
  print('    parsed:   $temp');
  // We can omit the variable after 'λ' if it is not used.
  print('4. Print a lambda expression with an unused variable:');
  str = 'λx. λ. x';
  temp = str.toLambda();
  print('    original: $str');
  print('    parsed:   $temp');
  // We can also parse lambda expression written in De Bruijn Indices.
  print('5. Print a lambda expression with De Bruijn Indices:');
  str = 'λ. λ. 1 (1 0)';
  temp = str.toLambda();
  print('    original: $str');
  print('    parsed:   $temp');
  print('');
}

void _evaluationsByValue() {
  // This function demonstrates the evaluation of lambda expressions through
  // beta-reduction with the "call by value" scheme.

  Lambda temp;

  print('Evaluate lambda expressions with the "call by value" scheme: ');
  temp = Lambda.applyAll([
    LambdaConstants.lambdaTest,
    LambdaConstants.lambdaTrue,
    LambdaConstants.lambdaTwo,
    LambdaConstants.lambdaOne,
  ]);
  // We use the .eval1() method to evaluate a lambda expression by one step.
  print("1. Evaluate 'test true 2 1' step-by-step: ");
  print('    $temp');
  print('  = ' + temp.eval1().toString());
  print('  = ' + temp.eval1().eval1().toString());
  print('  = ' + temp.eval1().eval1().eval1().toString());
  print('  = ' + temp.eval1().eval1().eval1().eval1().toString());
  print('  = ' + temp.eval1().eval1().eval1().eval1().eval1().toString());
  temp = Lambda.applyAll([
    LambdaConstants.lambdaTest,
    LambdaConstants.lambdaFalse,
    LambdaConstants.lambdaTwo,
    LambdaConstants.lambdaOne,
  ]);
  // We use the .eval() method to evaluate a lambda expression fully.
  print("2. Evaluate 'test false 2 1' directly to its simplest form: ");
  print('    $temp\n  = ' + temp.eval().toString());
  temp = Lambda(
    type: LambdaType.ABSTRACTION,
    exp1: Lambda.applyAll(
      [LambdaConstants.lambdaIdentity, LambdaConstants.lambdaFalse],
    ),
  );
  // Demonstration of the "call by value" scheme.
  print('3. An application within an abstraction is not reduced: ');
  print('    $temp\n  = ' + temp.eval().toString());
  temp = Lambda.applyAll([
    LambdaConstants.lambdaSucc,
    LambdaConstants.lambdaTwo,
  ]);
  // Another example: 'succ 2' results an expression behaviourally equivalent to
  // but syntactically distinct from 3.
  print("4. Evaluate 'succ 2', but the result is not the same as '3': ");
  print('    $temp\n  = ' + temp.eval().toString());
  print("5. Evaluate 'succ 2', converting it to a natural number: ");
  print('    $temp\n  = ' + temp.toInt().toString());
  print('');
}

void _fullEvaluations() {
  // This function demonstrates the evaluation of lambda expressions through
  // full beta-reduction.

  Lambda temp;

  print('Evaluate lambda expressions using full beta-reduction: ');
  temp = Lambda.applyAll([
    LambdaConstants.lambdaPlus,
    LambdaConstants.lambdaTwo,
    LambdaConstants.lambdaThree,
  ]);
  // We pass 'LambdaEvaluationType.FULL_REDUCTION' to the 'evalType' parameter
  // in .eval() method to evaluate a lambda expression through full
  // beta-reduction.
  print("1. Evaluate '2 + 3' directly to its simplest form: ");
  print('    $temp');
  print('  = ' +
      temp.eval(evalType: LambdaEvaluationType.FULL_REDUCTION).toString());
  temp = Lambda.applyAll([
    LambdaConstants.lambdaTimes,
    LambdaConstants.lambdaTwo,
    LambdaConstants.lambdaThree,
  ]);
  print("2. Evaluate '2 * 3' directly to its simplest form: ");
  print('    $temp');
  print('  = ' +
      temp.eval(evalType: LambdaEvaluationType.FULL_REDUCTION).toString());
  temp = Lambda.applyAll([
    LambdaConstants.lambdaPower,
    LambdaConstants.lambdaTwo,
    LambdaConstants.lambdaThree,
  ]);
  print("3. Evaluate '2 ^ 3' directly to its simplest form: ");
  print('    $temp');
  print('  = ' +
      temp.eval(evalType: LambdaEvaluationType.FULL_REDUCTION).toString());
  print('');
}

void _evaluationsByName() {
  // This function demonstrates the evaluation of lambda expressions through
  // beta-reduction with the "call by name" scheme.

  Lambda temp;

  print('Compare "call by name" with "call by value": ');
  temp = Lambda.applyAll([
    LambdaConstants.lambdaTrue,
    LambdaConstants.lambdaOne,
    LambdaConstants.omega,
  ]);
  // We pass 'LambdaEvaluationType.CALL_BY_NAME' to the 'evalType' parameter
  // in .eval1() method to evaluate a lambda expression through the
  // "call-by-name" scheme.
  print("1. Evaluate 'true 1 omega' lazily (call by name): ");
  print('    $temp');
  print('  = ' +
      temp.eval1(evalType: LambdaEvaluationType.CALL_BY_NAME).toString());
  print('  = ' +
      temp
          .eval1(evalType: LambdaEvaluationType.CALL_BY_NAME)
          .eval1(evalType: LambdaEvaluationType.CALL_BY_NAME)
          .toString());
  // In contrast, the expression diverges in a "call by value" scheme.
  print("2. Evaluate 'true 1 omega' strictly (call by value): ");
  print('    $temp');
  print('  = ' + temp.eval1().toString());
  print('  = ' + temp.eval1().eval1().toString());
  print('  = ' + temp.eval1().eval1().eval1().toString());
  print('  = ' + temp.eval1().eval1().eval1().eval1().toString());
  print('  = ' + temp.eval1().eval1().eval1().eval1().eval1().toString());
  print('  ...');
  print('');
}

void _factorial() {
  // The factorial function.

  Lambda result;

  print('Recursive factorial function with the Y-Combinator: ');
  final factorial = Lambda.applyAll([
    LambdaConstants.yCombinator,
    r'''
    \a\b(\\c\2(c)(0))((\0(\\\0)(\\1))b)(\\\1(0))(\(\\d\2(d(0)))b(a((\c(\0(\\1))
    (c(\d(\a\b\0(a)(b))((\0(\\0))d)((\a\\1(a(1)(0)))((\0(\\0))d)))((\d\a\0(d)
    (a))(\\0)(\\0))))b)))(\0)
    '''
        .toLambda()!,
  ]);
  print('The factorial lamdba expression: ');
  print('    $factorial');
  print('1. Evaluate 0!: ');
  result = Lambda.applyAll([factorial, LambdaConstants.lambdaZero]).eval();
  print('    $result');
  print('  = ${result.toInt()}');
  print('2. Evaluate 3!: ');
  result = Lambda.applyAll([factorial, LambdaConstants.lambdaThree]).eval();
  print('    $result');
  print('  = ${result.toInt()}');
  print('');
}
