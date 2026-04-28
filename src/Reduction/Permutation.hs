module Reduction.Permutation
  ( stepPerm
  ) where

import Syntax
import Reduction.Common (Step(..))

-- One-step permutation-conversion (Definition 2, de Groote 2002).
-- Tries the outermost-leftmost redex first; returns Nothing if no
-- permutation redex exists.
stepPerm :: Term -> Maybe Step
-- Rule 1 (app-over-case): D_{x,y}(M, N, O) P →P D_{x,y}(M, N P, O P)
stepPerm t@(App (Case x y m n o) p) =
  Just (Step t (Case x y m (App n p) (App o p)) "perm-app-case")
-- Rule 2 (fst-over-case): fst D_{x,y}(M, N, O) →P D_{x,y}(M, fst N, fst O)
stepPerm t@(Fst (Case x y m n o)) =
  Just (Step t (Case x y m (Fst n) (Fst o)) "perm-fst-case")
-- Rule 3 (snd-over-case): snd D_{x,y}(M, N, O) →P D_{x,y}(M, snd N, snd O)
stepPerm t@(Snd (Case x y m n o)) =
  Just (Step t (Case x y m (Snd n) (Snd o)) "perm-snd-case")
-- Rule 4 (case-over-case):
-- D_{u,v}(D_{x,y}(M, N, O), P, Q) →P D_{x,y}(M, D_{u,v}(N, P, Q), D_{u,v}(O, P, Q))
stepPerm t@(Case u v (Case x y m n o) p q) =
  Just (Step t (Case x y m (Case u v n p q) (Case u v o p q)) "perm-case-case")

-- Structural (recursive) rules
stepPerm (App f a) =
  case stepPerm f of
    Just s  -> Just s { stepBefore = App f a, stepAfter = App (stepAfter s) a }
    Nothing ->
      case stepPerm a of
        Just s  -> Just s { stepBefore = App f a, stepAfter = App f (stepAfter s) }
        Nothing -> Nothing
stepPerm (Lam x body) =
  case stepPerm body of
    Just s  -> Just s { stepBefore = Lam x body, stepAfter = Lam x (stepAfter s) }
    Nothing -> Nothing
stepPerm (Pair m n) =
  case stepPerm m of
    Just s  -> Just s { stepBefore = Pair m n, stepAfter = Pair (stepAfter s) n }
    Nothing ->
      case stepPerm n of
        Just s  -> Just s { stepBefore = Pair m n, stepAfter = Pair m (stepAfter s) }
        Nothing -> Nothing
stepPerm (Fst m) =
  case stepPerm m of
    Just s  -> Just s { stepBefore = Fst m, stepAfter = Fst (stepAfter s) }
    Nothing -> Nothing
stepPerm (Snd m) =
  case stepPerm m of
    Just s  -> Just s { stepBefore = Snd m, stepAfter = Snd (stepAfter s) }
    Nothing -> Nothing
stepPerm (Inl m) =
  case stepPerm m of
    Just s  -> Just s { stepBefore = Inl m, stepAfter = Inl (stepAfter s) }
    Nothing -> Nothing
stepPerm (Inr m) =
  case stepPerm m of
    Just s  -> Just s { stepBefore = Inr m, stepAfter = Inr (stepAfter s) }
    Nothing -> Nothing
stepPerm (Case x y m n o) =
  case stepPerm m of
    Just s  -> Just s { stepBefore = Case x y m n o
                      , stepAfter  = Case x y (stepAfter s) n o }
    Nothing ->
      case stepPerm n of
        Just s  -> Just s { stepBefore = Case x y m n o
                          , stepAfter  = Case x y m (stepAfter s) o }
        Nothing ->
          case stepPerm o of
            Just s  -> Just s { stepBefore = Case x y m n o
                              , stepAfter  = Case x y m n (stepAfter s) }
            Nothing -> Nothing
stepPerm (Var _) = Nothing