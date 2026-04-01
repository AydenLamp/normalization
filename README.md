# normalization

This is a Haskell implementation of normalization for proof terms. Under Curry-Howard, formulas correspond to
types, proofs to terms, and proof normalization to term reduction.

## Building and running

```
cabal build
cabal run normalization
```

## What is implemented so far

Currently, this implements typed lambda calculus with implication only.
Types are `A ::= p | A -> B` and terms are `M ::= x | λx:A. M | M N`.
Normalization is just beta reduction: `(λx. M) N → M[x := N]`.

### Project structure

| File | Purpose |
|------|---------|
| `src/Syntax.hs` | Defines the syntax tree: `Name` (type alias for `String`), `Type` (`TyAtom`, `TyArr`), and `Term` (`Var`, `Lam`, `App`). |
| `src/Pretty.hs` | Pretty printing function `ppType` and `ppTerm`. Handles parentheses. |
| `src/FreeVars.hs` | `freeVars` computes the set of free variables in a term. `freshLike` generates a fresh name for a variable by appending primes. |
| `src/Substitution.hs` | Substitutes terms for variables with `subst`. Renames binders when a free variable in the substituted term would be captured. |
| `src/Typecheck.hs` | Type inference `inferType` for STLC with a typing context (`Map Name Type`). Reports errors for type mismatches and other problems. |
| `src/Reduction/Common.hs` | `Step` record type with `stepBefore`, `stepAfter`, and `stepNote` fields, used for creating labeled reduction traces. |
| `src/Reduction/Beta.hs` | `isBetaRedex` (top-level check) and `stepBeta` (one step reduction, returning a `Step`). |
| `src/Normalize.hs` | `isNormal`, `normalizeTrace` (returns `[Step]`), `normalize` (returns final term), `printTrace` (prints numbered trace). |
| `src/Examples.hs` | Sample terms and contexts for testing. |
| `app/Main.hs` | Runs all examples: prints the term, infers its type, prints the reduction trace, and prints the normal form. |

### Sample output

```
--- Identity applied: (λx:A. x) a ---
  Term:  (λx : A. x) a
  Type:  A
  Trace:
  [0] (λx : A. x) a
  [1] a  (beta)
  (1 reduction steps)
  Normal form: a
  Is normal:   True

--- Capture test: (λz:(A→A→A). z y) (λx:A. λy:A. x) ---
  Term:  (λz : A -> A -> A. z y) (λx : A. λy : A. x)
  Type:  A -> A
  Trace:
  [0] (λz : A -> A -> A. z y) (λx : A. λy : A. x)
  [1] (λx : A. λy : A. x) y  (beta)
  [2] λy' : A. y  (beta)
  (2 reduction steps)
  Normal form: λy' : A. y
  Is normal:   True
```

The logic for renaming y to y' above was tricky and can be found in Substitution.hs.
The logic for handeling parenthesis for pretty printing was also somewhat complex.

## Future work

* Extend the syntax types with types for And and Or.
* Add detour reductions for and and or elimination.
* Define permutation conversions for
    1. function applicatoin over or elim
    2. and elim over or elim
    3. or elim over or elim
* Create a subformula property checker. I am thinking about doing this by checking that every subterm has a type that is part of the types of the assumptions or part of the type of the conclution. I am not sure if this is exactly a correct way to do this, as the subformula property is normally disussed in the context of the formulas in a natural deduction proof, not about the types of subterms in a lambda calculus term. 
* Emperically verify that permutation conversions are normalizing and that normalized terms have the subformula property.
