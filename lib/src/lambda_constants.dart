import 'package:lambda_calculus/src/lambda.dart';
import 'package:lambda_calculus/src/lambda_conversion.dart';

/// Common lambda expressions.
class LambdaConstants {
  /// The identity expression.
  static final lambdaIdentity = Lambda.abstract(
    Lambda(type: LambdaType.VARIABLE, index: 0),
  );

  /// Church boolean: true.
  static final lambdaTrue = Lambda.abstract(
    Lambda.abstract(Lambda(type: LambdaType.VARIABLE, index: 1)),
  );

  /// Church boolean: false.
  static final lambdaFalse = Lambda.abstract(
    Lambda.abstract(Lambda(type: LambdaType.VARIABLE, index: 0)),
  );

  /// The if expression.
  static final lambdaTest = Lambda.abstract(
    Lambda.abstract(
      Lambda.abstract(
        Lambda.applyAll([
          Lambda(type: LambdaType.VARIABLE, index: 2),
          Lambda(type: LambdaType.VARIABLE, index: 1),
          Lambda(type: LambdaType.VARIABLE, index: 0),
        ]),
      ),
    ),
  );

  /// The and expression.
  static final lambdaAnd = Lambda.abstract(
    Lambda.abstract(
      Lambda.applyAll([
        Lambda(type: LambdaType.VARIABLE, index: 1),
        Lambda(type: LambdaType.VARIABLE, index: 0),
        lambdaFalse,
      ]),
    ),
  );

  /// The or expression.
  static final lambdaOr = Lambda.abstract(
    Lambda.abstract(
      Lambda.applyAll([
        Lambda(type: LambdaType.VARIABLE, index: 1),
        lambdaTrue,
        Lambda(type: LambdaType.VARIABLE, index: 0),
      ]),
    ),
  );

  /// The not expression.
  static final lambdaNot = Lambda.abstract(
    Lambda.applyAll([
      Lambda(type: LambdaType.VARIABLE, index: 0),
      lambdaFalse,
      lambdaTrue,
    ]),
  );

  /// The church pair.
  static final lambdaPair = Lambda.abstract(
    Lambda.abstract(
      Lambda.abstract(
        Lambda.applyAll([
          Lambda(type: LambdaType.VARIABLE, index: 0),
          Lambda(type: LambdaType.VARIABLE, index: 2),
          Lambda(type: LambdaType.VARIABLE, index: 1),
        ]),
      ),
    ),
  );

  /// The fst expression.
  static final lambdaFst = Lambda.abstract(
    Lambda.applyAll([
      Lambda(type: LambdaType.VARIABLE, index: 0),
      LambdaConstants.lambdaTrue,
    ]),
  );

  /// The snd expression.
  static final lambdaSnd = Lambda.abstract(
    Lambda.applyAll([
      Lambda(type: LambdaType.VARIABLE, index: 0),
      LambdaConstants.lambdaFalse,
    ]),
  );

  /// The succ (+1) expression.
  static final lambdaSucc = LambdaConversionExtension.lambdaSucc;

  /// The plus expression.
  static final lambdaPlus = Lambda.abstract(
    Lambda.abstract(
      Lambda.abstract(
        Lambda.abstract(
          Lambda.applyAll([
            Lambda(type: LambdaType.VARIABLE, index: 3),
            Lambda(type: LambdaType.VARIABLE, index: 1),
            Lambda.applyAll([
              Lambda(type: LambdaType.VARIABLE, index: 2),
              Lambda(type: LambdaType.VARIABLE, index: 1),
              Lambda(type: LambdaType.VARIABLE, index: 0),
            ]),
          ]),
        ),
      ),
    ),
  );

  /// The times expression.
  static final lambdaTimes = Lambda.abstract(
    Lambda.abstract(
      Lambda.abstract(
        Lambda.applyAll([
          Lambda(type: LambdaType.VARIABLE, index: 2),
          Lambda.applyAll([
            Lambda(type: LambdaType.VARIABLE, index: 1),
            Lambda(type: LambdaType.VARIABLE, index: 0),
          ]),
        ]),
      ),
    ),
  );

  /// The power expression.
  static final lambdaPower = Lambda.abstract(
    Lambda.abstract(
      Lambda.applyAll([
        Lambda(type: LambdaType.VARIABLE, index: 0),
        Lambda(type: LambdaType.VARIABLE, index: 1),
      ]),
    ),
  );

  /// The is_zero expression.
  static final lambdaIsZero = Lambda.abstract(
    Lambda.applyAll([
      Lambda(type: LambdaType.VARIABLE, index: 0),
      Lambda(type: LambdaType.ABSTRACTION, exp1: LambdaConstants.lambdaFalse),
      LambdaConstants.lambdaTrue,
    ]),
  );

  /// Church number: 0.
  static final lambdaZero = lambdaFalse;

  /// Church number: 1.
  static final lambdaOne = 1.toChurchNumber();

  /// Church number: 2.
  static final lambdaTwo = 2.toChurchNumber();

  /// Church number: 3.
  static final lambdaThree = 3.toChurchNumber();

  /// Church number: 4.
  static final lambdaFour = 4.toChurchNumber();

  /// Church number: 5.
  static final lambdaFive = 5.toChurchNumber();

  /// Church number: 6.
  static final lambdaSix = 6.toChurchNumber();

  /// Church number: 7.
  static final lambdaSeven = 7.toChurchNumber();

  /// Church number: 8.
  static final lambdaEight = 8.toChurchNumber();

  /// Church number: 9.
  static final lambdaNine = 9.toChurchNumber();

  /// Church number: 10.
  static final lambdaTen = 10.toChurchNumber();

  /// The diverging omega expression.
  static final omega = Lambda.applyAll([
    Lambda.abstract(
      Lambda.applyAll([
        Lambda(type: LambdaType.VARIABLE, index: 0),
        Lambda(type: LambdaType.VARIABLE, index: 0),
      ]),
    ),
    Lambda.abstract(
      Lambda.applyAll([
        Lambda(type: LambdaType.VARIABLE, index: 0),
        Lambda(type: LambdaType.VARIABLE, index: 0),
      ]),
    ),
  ]);

  /// The Y-Combinator that works for both 'call by name' and 'call by value'
  /// schemes.
  static final yCombinator = Lambda.abstract(
    Lambda(
      type: LambdaType.APPLICATION,
      exp1: Lambda.abstract(
        Lambda(
          type: LambdaType.APPLICATION,
          exp1: Lambda(type: LambdaType.VARIABLE, index: 1),
          exp2: Lambda.abstract(
            Lambda(
              type: LambdaType.APPLICATION,
              exp1: Lambda(
                type: LambdaType.APPLICATION,
                exp1: Lambda(type: LambdaType.VARIABLE, index: 1),
                exp2: Lambda(type: LambdaType.VARIABLE, index: 1),
              ),
              exp2: Lambda(type: LambdaType.VARIABLE, index: 0),
            ),
          ),
        ),
      ),
      exp2: Lambda.abstract(
        Lambda(
          type: LambdaType.APPLICATION,
          exp1: Lambda(type: LambdaType.VARIABLE, index: 1),
          exp2: Lambda.abstract(
            Lambda(
              type: LambdaType.APPLICATION,
              exp1: Lambda(
                type: LambdaType.APPLICATION,
                exp1: Lambda(type: LambdaType.VARIABLE, index: 1),
                exp2: Lambda(type: LambdaType.VARIABLE, index: 1),
              ),
              exp2: Lambda(type: LambdaType.VARIABLE, index: 0),
            ),
          ),
        ),
      ),
    ),
  );
}
