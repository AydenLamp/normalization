module FreeVars
  ( freeVars
  , freshLike
  ) where

import Data.Set (Set)
import qualified Data.Set as Set

import Syntax

-- Compute the set of free variables in a term.
freeVars :: Term -> Set Name
freeVars (Var x) = Set.singleton x
freeVars (Lam x body) = Set.delete x (freeVars body)
freeVars (App f a) = freeVars f `Set.union` freeVars a
freeVars (Pair m n) = freeVars m `Set.union` freeVars n
freeVars (Fst m) = freeVars m
freeVars (Snd m) = freeVars m
freeVars (Inl m) = freeVars m
freeVars (Inr m) = freeVars m
-- M is the disjunction; x is bound in n; y is bound in o.
freeVars (Case x y m n o)  = freeVars m
                           `Set.union` Set.delete x (freeVars n)
                           `Set.union` Set.delete y (freeVars o)

-- Generate a fresh variable name not in the set by appending ' until it's fresh.
freshLike :: Name -> Set Name -> Name
freshLike x avoid
  | x `Set.notMember` avoid = x
  | otherwise = freshLike (x ++ "'") avoid
