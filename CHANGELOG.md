## 1.0.0

- Initial version. 
- Can parse and evaluate pure untyped Lambda Calculus.
- Supports three types of evaluation strategy, namely call-by-name (lazy), call-by-value (strict), and full beta-reduction.

## 1.0.1

- Add support for parsing lambda expressions written with De Bruijn Indices.

## 1.0.2

- Can omit spaces in lambda expression strings as long as there is no ambiguity.
	1. `)(`
	2. `a(b`
	3. `a)b`
	4. `.(a`
	5. `λ0`

## 1.0.3

- Calculate the number of free variable, both by appearance and by distinct count.
