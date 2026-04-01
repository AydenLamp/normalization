module FreeVars
  ( freeVars
  , freshLike
  ) where

import Data.Set (Set) -- imports the type `Set`
import qualified Data.Set as Set 

import Syntax

-- Compute the set of free variables in a term.
freeVars :: Term -> Set Name
freeVars (Var x) = Set.singleton x
freeVars (Lam x _ body) = Set.delete x (freeVars body)
freeVars (App f a) = Set.union (freeVars f) (freeVars a)

-- Generate a fresh variable name not in the set by appending ' until it's fresh.
freshLike :: Name -> Set Name -> Name
freshLike x avoid
  | x `Set.notMember` avoid = x
  | otherwise = freshLike (x ++ "'") avoid
