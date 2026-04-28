# Normalization

A Haskell implementation of normalization in untyped lambda calculus with detour and permutation conversions, based on Philippe de Groote, On the Strong Normalisation of Natural
Deduction with Permutation-Conversions (2002).

Under Curry-Howard, proof normalization in IPPL corresponds to term reduction in typed lambda calculus.

## Building and running

```
cabal build
cabal run normalization
```

## What is implemented

### The term language λ→∧∨

The calculus λ→∧∨ (Section 2.2, de Groote) is implemented as an **untyped** lambda calculus extended with products and coproducts. There are no type annotations on binders and no typechecking, so reduction is purely syntactic. This corresponds to the fact observed after Proposition 1 in de Groote that strong normalisation for permutation-conversions holds for *untyped* terms.

Formula grammar for IPPL (not represented in the current syntax):
```
A ::= p | A → B | A ∧ B | A ∨ B
```

Terms (the grammar from Section 2.2 of de Groote):
```
M ::= x                                    variable
    | λx. M                                implication introduction
    | M M                                  implication elimination
    | ⟨M, M⟩                               conjunction introduction
    | fst M  |  snd M                      conjunction elimination
    | inl M  |  inr M                      disjunction introduction
    | case M of { inl x → M | inr y → M }  disjunction elimination  D_{x,y}(M,N,O)
```

### Detour-conversion rules

Detour conversions (Definition 1, de Groote) eliminate a proof detour: an introduction rule immediately followed by an elimination rule. All five rules are implemented in `Reduction/Detour.hs`:

| Rule | Redex | Reduct | Connective |
|------|-------|--------|------------|
| 1 | `(λx. M) N` | `M[x := N]` | Implication (β) |
| 2 | `fst ⟨M, N⟩` | `M` | Conjunction |
| 3 | `snd ⟨M, N⟩` | `N` | Conjunction |
| 4 | `case (inl M) of { inl x → N \| inr y → O }` | `N[x := M]` | Disjunction |
| 5 | `case (inr M) of { inl x → N \| inr y → O }` | `O[y := M]` | Disjunction |

## Permutation-conversion rules

Permutation conversions (Definition 2, de Groote) are implemented in `Reduction/Permutation.hs`. These are needed to satisfy the subformula property for disjunction (Section 2.4, de Groote). They move an elimination rule *inside* the branches of a disjunction elimination.

The four rules (Definition 2) implemented in `Reduction/Permutation.hs`:

1. **Application over case** (function application, or-elim):
   `(case M of { inl x → N | inr y → O }) P`
   →P `case M of { inl x → N P | inr y → O P }`

2. **fst over case** (and-elim 1 over or-elim):
   `fst (case M of { inl x → N | inr y → O })`
   →P `case M of { inl x → fst N | inr y → fst O }`

3. **snd over case** (and-elim 2 over or-elim):
   `snd (case M of { inl x → N | inr y → O })`
   →P `case M of { inl x → snd N | inr y → snd O }`

4. **case over case** (or-elim over or-elim):
   `case (case M of { inl x → N | inr y → O }) of { inl u → P | inr v → Q }`
   →P `case M of { inl x → case N of { inl u → P | inr v → Q } | inr y → case O of { inl u → P | inr v → Q } }`

## Reduction strategy (DetourFirst)

`Normalize.hs` uses a DetourFirst scheduling policy for mixed reduction. We try a detour conversion first, then try a permutation conversion if none exists.

This is a good strategy because detour conversions carry computational content, while permutation conversions mearly rearrange structure.

### Project structure

| File | Purpose |
|------|---------|
| `src/Syntax.hs` | `Name` and `Term` (all 9 constructors). This is the untyped raw term syntax for λ→∧∨. |
| `src/Pretty.hs` | `ppTerm`. Unicode output: λ, ⟨⟩, and case syntax. |
| `src/FreeVars.hs` | `freeVars` and `freshLike`. |
| `src/Substitution.hs` | Capture-avoiding `subst`. |
| `src/Reduction/Common.hs` | `Step` record: `stepBefore`, `stepAfter`, `stepNote`. |
| `src/Reduction/Detour.hs` | `stepDetour`: all 5 detour-conversion rules (Definition 1) plus recursion rules. |
| `src/Reduction/Permutation.hs` | `stepPerm`: all 4 permutation-conversion rules (Definition 2) plus recursion rules. |
| `src/Normalize.hs` | `normalizeTrace` (returns `[Step]`), `normalize`, and `printTrace`. |
| `src/Examples.hs` | Sample terms for reducing. |
| `app/Main.hs` | Runs all examples and prints reduction traces. |

### Sample output

```
=== λ→∧∨: Detour + Permutation conversions ===

--- Implication (rule 1: β-reduction) ---

--- Identity ---
  Term:  λx. x
  Trace:
  [0] λx. x
  Normal form: λx. x

--- Identity Application ---
  Term:  (λx. x) a
  Trace:
  [0] (λx. x) a
  [1] a  (β)
  Normal form: a

--- Constant Application ---
  Term:  (λx. λy. x) a b
  Trace:
  [0] (λx. λy. x) a b
  [1] (λy. a) b  (β)
  [2] a  (β)
  Normal form: a

--- Nested Application ---
  Term:  (λf. λx. f x) (λx. x)
  Trace:
  [0] (λf. λx. f x) (λx. x)
  [1] λx. (λx. x) x  (β)
  [2] λx. x  (β)
  Normal form: λx. x

--- Capture Avoidance ---
  Term:  (λz. z y) (λx. λy. x)
  Trace:
  [0] (λz. z y) (λx. λy. x)
  [1] (λx. λy. x) y  (β)
  [2] λy'. y  (β)
  Normal form: λy'. y

--- Self Application ---
  Term:  (λf. f (λx. x)) (λg. λx. g x)
  Trace:
  [0] (λf. f (λx. x)) (λg. λx. g x)
  [1] (λg. λx. g x) (λx. x)  (β)
  [2] λx. (λx. x) x  (β)
  [3] λx. x  (β)
  Normal form: λx. x

--- Conjunction (rules 2 & 3: fst/snd detour) ---

--- First Projection ---
  Term:  fst ⟨a, b⟩
  Trace:
  [0] fst ⟨a, b⟩
  [1] a  (fst-pair)
  Normal form: a

--- Second Projection ---
  Term:  snd ⟨a, b⟩
  Trace:
  [0] snd ⟨a, b⟩
  [1] b  (snd-pair)
  Normal form: b

--- Nested Projection ---
  Term:  fst ((λp. p) ⟨a, b⟩)
  Trace:
  [0] fst ((λp. p) ⟨a, b⟩)
  [1] fst ⟨a, b⟩  (β)
  [2] a  (fst-pair)
  Normal form: a

--- Disjunction (rules 4 & 5: case detour) ---

--- Left Case Reduction ---
  Term:  case (inl a) of { inl x → x | inr y → b }
  Trace:
  [0] case (inl a) of { inl x → x | inr y → b }
  [1] a  (case-inl)
  Normal form: a

--- Right Case Reduction ---
  Term:  case (inr b) of { inl x → a | inr y → y }
  Trace:
  [0] case (inr b) of { inl x → a | inr y → y }
  [1] b  (case-inr)
  Normal form: b

--- Permutation (Definition 2) ---

--- App Over Case ---
  Term:  (case s of { inl x → λz. x | inr y → λz. y }) u
  Trace:
  [0] (case s of { inl x → λz. x | inr y → λz. y }) u
  [1] case s of { inl x → (λz. x) u | inr y → (λz. y) u }  (perm-app-case)
  [2] case s of { inl x → x | inr y → (λz. y) u }  (β)
  [3] case s of { inl x → x | inr y → y }  (β)
  Normal form: case s of { inl x → x | inr y → y }

--- Fst Over Case ---
  Term:  fst (case s of { inl x → ⟨x, a⟩ | inr y → ⟨a, y⟩ })
  Trace:
  [0] fst (case s of { inl x → ⟨x, a⟩ | inr y → ⟨a, y⟩ })
  [1] case s of { inl x → fst ⟨x, a⟩ | inr y → fst ⟨a, y⟩ }  (perm-fst-case)
  [2] case s of { inl x → x | inr y → fst ⟨a, y⟩ }  (fst-pair)
  [3] case s of { inl x → x | inr y → a }  (fst-pair)
  Normal form: case s of { inl x → x | inr y → a }

--- Snd Over Case ---
  Term:  snd (case s of { inl x → ⟨x, a⟩ | inr y → ⟨a, y⟩ })
  Trace:
  [0] snd (case s of { inl x → ⟨x, a⟩ | inr y → ⟨a, y⟩ })
  [1] case s of { inl x → snd ⟨x, a⟩ | inr y → snd ⟨a, y⟩ }  (perm-snd-case)
  [2] case s of { inl x → a | inr y → snd ⟨a, y⟩ }  (snd-pair)
  [3] case s of { inl x → a | inr y → y }  (snd-pair)
  Normal form: case s of { inl x → a | inr y → y }

--- Case Over Case ---
  Term:  case (case s of { inl x → inl x | inr y → inr y }) of { inl u → u | inr v → v }
  Trace:
  [0] case (case s of { inl x → inl x | inr y → inr y }) of { inl u → u | inr v → v }
  [1] case s of { inl x → case (inl x) of { inl u → u | inr v → v } | inr y → case (inr y) of { inl u → u | inr v → v } }  (perm-case-case)
  [2] case s of { inl x → x | inr y → case (inr y) of { inl u → u | inr v → v } }  (case-inl)
  [3] case s of { inl x → x | inr y → y }  (case-inr)
  Normal form: case s of { inl x → x | inr y → y }

--- DetourFirst Interaction ---
  Term:  (case (inl a) of { inl x → λz. x | inr y → λz. y }) u
  Trace:
  [0] (case (inl a) of { inl x → λz. x | inr y → λz. y }) u
  [1] (λz. a) u  (case-inl)
  [2] a  (β)
  Normal form: a

--- Mixed ---

--- Beta Then Projection ---
  Term:  (λp. fst p) ⟨a, b⟩
  Trace:
  [0] (λp. fst p) ⟨a, b⟩
  [1] fst ⟨a, b⟩  (β)
  [2] a  (fst-pair)
  Normal form: a
```
