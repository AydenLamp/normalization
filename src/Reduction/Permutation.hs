module Reduction.Permutation
  ( stepPerm
  ) where

import Control.Applicative ((<|>))

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
  rewrite1 (App f a) (`App` a) f
    <|> rewrite1 (App f a) (App f) a
stepPerm (Lam x body) =
  rewrite1 (Lam x body) (Lam x) body
stepPerm (Pair m n) =
  rewrite1 (Pair m n) (`Pair` n) m
    <|> rewrite1 (Pair m n) (Pair m) n
stepPerm (Fst m) =
  rewrite1 (Fst m) Fst m
stepPerm (Snd m) =
  rewrite1 (Snd m) Snd m
stepPerm (Inl m) =
  rewrite1 (Inl m) Inl m
stepPerm (Inr m) =
  rewrite1 (Inr m) Inr m
stepPerm (Case x y m n o) =
  rewrite1 (Case x y m n o) (\m' -> Case x y m' n o) m
    <|> rewrite1 (Case x y m n o) (\n' -> Case x y m n' o) n
    <|> rewrite1 (Case x y m n o) (Case x y m n) o
stepPerm (Var _) = Nothing

-- whole is the original outer term
-- rebuild is a function that plugs a rewritten subterm back into the outer term
-- part is the subterm we're trying to rewrite
rewrite1 :: Term -> (Term -> Term) -> Term -> Maybe Step
rewrite1 whole rebuild part = do
  s <- stepPerm part
  pure s {stepBefore = whole, stepAfter = rebuild (stepAfter s)}