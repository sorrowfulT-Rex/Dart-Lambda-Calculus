import 'package:lambda_calculus/src/lambda_constants.dart';
import 'package:lambda_calculus/src/lambda_conversion.dart';
import 'package:lambda_calculus/src/lambda_evaluator.dart';
import 'package:lambda_calculus/src/lambda.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Clone Test',
    () {
      expect(
        identityHashCode(LambdaConstants.lambdaTrue),
        isNot(identityHashCode(LambdaConstants.lambdaTrue.clone())),
      );
      expect(LambdaConstants.lambdaTrue, LambdaConstants.lambdaTrue.clone());
      expect(
        identityHashCode(LambdaConstants.lambdaSeven),
        isNot(identityHashCode(LambdaConstants.lambdaSeven.clone())),
      );
      expect(LambdaConstants.lambdaSeven, LambdaConstants.lambdaSeven.clone());
      expect(
        identityHashCode(LambdaConstants.yCombinator),
        isNot(identityHashCode(LambdaConstants.yCombinator.clone())),
      );
      expect(LambdaConstants.yCombinator, LambdaConstants.yCombinator.clone());
    },
  );
  test(
    'Evaluation Test',
    () async {
      expect(
        Lambda.applyAll([
          LambdaConstants.lambdaTest,
          LambdaConstants.lambdaFalse,
          LambdaConstants.lambdaTwo,
          LambdaConstants.lambdaOne,
        ]).eval(),
        LambdaConstants.lambdaOne,
      );
      expect(LambdaConstants.yCombinator.eval(), LambdaConstants.yCombinator);
      expect(
        Lambda.applyAll([
          LambdaConstants.lambdaSucc,
          LambdaConstants.lambdaSix,
        ]).toInt(),
        7,
      );
      expect(
        Lambda.applyAll([
          LambdaConstants.lambdaPlus,
          LambdaConstants.lambdaTwo,
          LambdaConstants.lambdaThree,
        ]).toInt(),
        5,
      );
      expect(
        Lambda.applyAll([
          LambdaConstants.lambdaTimes,
          LambdaConstants.lambdaTwo,
          LambdaConstants.lambdaThree,
        ]).toInt(),
        6,
      );
      expect(
        Lambda.applyAll([
          LambdaConstants.lambdaPower,
          LambdaConstants.lambdaTwo,
          LambdaConstants.lambdaThree,
        ]).toInt(),
        8,
      );
      expect(
        Lambda.applyAll([
          LambdaConstants.lambdaIsZero,
          LambdaConstants.lambdaTwo,
        ]).eval(),
        LambdaConstants.lambdaFalse,
      );
      expect(
        Lambda.applyAll([
          LambdaConstants.lambdaIsZero,
          LambdaConstants.lambdaZero,
        ]).eval(),
        LambdaConstants.lambdaTrue,
      );
      expect(
        Lambda.applyAll([
          LambdaConstants.lambdaAnd,
          LambdaConstants.lambdaFalse,
          LambdaConstants.omega
        ]).eval(evalType: LambdaEvaluationType.CALL_BY_NAME),
        LambdaConstants.lambdaFalse,
      );
    },
  );
}
