module Reduction.Detour
  ( stepDetour
  ) where

import Syntax
import Substitution (subst)
import Reduction.Common (Step(..))

-- One-step detour-conversion (Definition 1, de Groote 2002).
-- Tries the outermost-leftmost redex first; returns Nothing if the term is
-- already in detour-normal form.
-- The @t syntax matches and binds the whole term to t.
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
  case stepDetour f of
    Just s  -> Just s { stepBefore = App f a, stepAfter = App (stepAfter s) a }
    Nothing ->
      case stepDetour a of
        Just s  -> Just s { stepBefore = App f a, stepAfter = App f (stepAfter s) }
        Nothing -> Nothing

-- Reduce inside the body of a lambda when no top-level detour rule applies.
stepDetour (Lam x body) =
  case stepDetour body of
    Just s  -> Just s { stepBefore = Lam x body, stepAfter = Lam x (stepAfter s) }
    Nothing -> Nothing

-- For pairs, reduce left then right.
stepDetour (Pair m n) =
  case stepDetour m of
    Just s  -> Just s { stepBefore = Pair m n, stepAfter = Pair (stepAfter s) n }
    Nothing ->
      case stepDetour n of
        Just s  -> Just s { stepBefore = Pair m n, stepAfter = Pair m (stepAfter s) }
        Nothing -> Nothing

-- If fst is not a top-level fst-pair redex, continue searching inside.
stepDetour (Fst m) =
  case stepDetour m of
    Just s  -> Just s { stepBefore = Fst m, stepAfter = Fst (stepAfter s) }
    Nothing -> Nothing

-- If snd is not a top-level snd-pair redex, continue searching inside.
stepDetour (Snd m) =
  case stepDetour m of
    Just s  -> Just s { stepBefore = Snd m, stepAfter = Snd (stepAfter s) }
    Nothing -> Nothing

-- try to reduce m.
stepDetour (Inl m) =
  case stepDetour m of
    Just s  -> Just s { stepBefore = Inl m, stepAfter = Inl (stepAfter s) }
    Nothing -> Nothing

-- try to reduce m.
stepDetour (Inr m) =
  case stepDetour m of
    Just s  -> Just s { stepBefore = Inr m, stepAfter = Inr (stepAfter s) }
    Nothing -> Nothing

-- Reduce m, then n, then o
stepDetour (Case x y m n o) =
  case stepDetour m of
    Just s  -> Just s { stepBefore = Case x y m n o
                      , stepAfter  = Case x y (stepAfter s) n o }
    Nothing ->
      case stepDetour n of
        Just s  -> Just s { stepBefore = Case x y m n o
                          , stepAfter  = Case x y m (stepAfter s) o }
        Nothing ->
          case stepDetour o of
            Just s  -> Just s { stepBefore = Case x y m n o
                              , stepAfter  = Case x y m n (stepAfter s) }
            Nothing -> Nothing
stepDetour (Var _) = Nothing