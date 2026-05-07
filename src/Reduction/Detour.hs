module Reduction.Detour
  ( stepDetour
  ) where

import Control.Applicative ((<|>))

import Syntax
import Substitution (subst)
import Reduction.Common (Step(..))

-- One-step detour-conversion (Definition 1, de Groote 2002).
-- Tries the outermost-leftmost redex first; returns Nothing if the term is
-- already in detour-normal form.
-- The t@ syntax matches and binds the whole term to t.
stepDetour :: Term -> Maybe Step
-- Rule 1 (β): (λx. M) N →D M[x := N]
stepDetour t@(App (Lam x body) arg) =
  Just (Step t (subst x arg body) "β")
-- Rule 2 (fst-pair): fst ⟨M, N⟩ →D M
stepDetour t@(Fst (Pair m _)) =
  Just (Step t m "fst-pair")
-- Rule 3 (snd-pair): snd ⟨M, N⟩ →D N
stepDetour t@(Snd (Pair _ n)) =
  Just (Step t n "snd-pair")
-- Rule 4 (case-inl): D_{x,y}(k1 M, N, O) →D N[x := M]
stepDetour t@(Case x _ (Inl m) n _) =
  Just (Step t (subst x m n) "case-inl")
-- Rule 5 (case-inr): D_{x,y}(k2 M, N, O) →D O[y := M]
stepDetour t@(Case _ y (Inr m) _ o) =
  Just (Step t (subst y m o) "case-inr")

-- Structural (recursive) rules

-- outermost-leftmost first. For example, in App f a we reduce f then a
stepDetour (App f a) =
  rewrite1 (App f a) (`App` a) f
    <|> rewrite1 (App f a) (App f) a

-- Reduce inside the body of a lambda when no top-level detour rule applies.
stepDetour (Lam x body) =
  rewrite1 (Lam x body) (Lam x) body

-- For pairs, reduce left then right.
stepDetour (Pair m n) =
  rewrite1 (Pair m n) (`Pair` n) m
    <|> rewrite1 (Pair m n) (Pair m) n

-- If fst is not a top-level fst-pair redex, continue searching inside.
stepDetour (Fst m) =
  rewrite1 (Fst m) Fst m

-- If snd is not a top-level snd-pair redex, continue searching inside.
stepDetour (Snd m) =
  rewrite1 (Snd m) Snd m

-- try to reduce m.
stepDetour (Inl m) =
  rewrite1 (Inl m) Inl m

-- try to reduce m.
stepDetour (Inr m) =
  rewrite1 (Inr m) Inr m

-- Reduce m, then n, then o
stepDetour (Case x y m n o) =
  rewrite1 (Case x y m n o) (\m' -> Case x y m' n o) m
    <|> rewrite1 (Case x y m n o) (\n' -> Case x y m n' o) n
    <|> rewrite1 (Case x y m n o) (Case x y m n) o
stepDetour (Var _) = Nothing

rewrite1 :: Term -> (Term -> Term) -> Term -> Maybe Step
rewrite1 whole rebuild part = do
  s <- stepDetour part
  pure s {stepBefore = whole, stepAfter = rebuild (stepAfter s)}