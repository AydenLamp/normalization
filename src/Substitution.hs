module Substitution
  ( renameBound
  , subst
  ) where

import Data.Set (Set) -- import the type `Set`
import qualified Data.Set as Set

import Syntax
import FreeVars (freeVars, freshLike)

-- Rename all free occurrences of `old` with `new` inside a term.
-- We call this renameBound because it is used by the proceding function to 
-- rename bound variables within the body of a lambda to avoid capture. 
renameBound :: Name -> Name -> Term -> Term
renameBound old new = go
  where
    go (Var x)  -- just replace the variable if it is old
      | x == old = Var new
      | otherwise = Var x
    go (Lam x ty body)
      | x == old = Lam x ty body   -- leave as-is
      | otherwise = Lam x ty (go body)
    go (App f a) = App (go f) (go a)

-- subst x s t replaces free occurrences of x in t by s, while renaming bound variables
-- in t to avoid capture of free variables. 
-- e.g. given, subst "x" (Var "y") (Lam "y" A (Var "x"))
--   Wrong: Lam "y" A (Var "y") 
--   Correct: Lam "y'" A (Var "y") 
subst :: Name -> Term -> Term -> Term
subst x s = go
  where
    sFV :: Set Name
    sFV = freeVars s -- the set of free variables in s (the thing we are replacing x with)

    go (Var y)
      | y == x = s  -- replace x with s
      | otherwise = Var y
    go (App f a)   = App (go f) (go a)
    go (Lam y ty body)
      | y == x = Lam y ty body  -- x is bound here, so leave as is
      | y `Set.member` sFV =  
          -- If the binder y is free in s, then we rename y in the lambda so that we avoid capture. 
          -- `avoid` is the set of variables we cannot use for the new name
          let avoid = Set.unions [sFV, freeVars body, Set.singleton x]
              y' = freshLike y avoid -- generate a fresh name for y
          -- replace y with y' in the body, and continue substituting
          in  Lam y' ty (go (renameBound y y' body))
      | otherwise   = Lam y ty (go body)
