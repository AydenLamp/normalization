module Substitution
  ( renameBound
  , subst
  ) where

import Data.Set (Set)
import qualified Data.Set as Set

import Syntax
import FreeVars (freeVars, freshLike)

-- Rename all free occurrences of `old` with `new` inside a term.
-- We call this renameBound because it is used by the proceding function to 
-- rename bound variables within the body of a lambda to avoid capture. 
renameBound :: Name -> Name -> Term -> Term
renameBound old new = go
  where
    go (Var x)
      | x == old = Var new
      | otherwise = Var x
    go (Lam x body)
      | x == old  = Lam x body -- old is shadowed here
      | otherwise = Lam x (go body)
    go (App f a) = App (go f) (go a)
    go (Pair m n) = Pair (go m) (go n)
    go (Fst m) = Fst (go m)
    go (Snd m) = Snd (go m)
    go (Inl m) = Inl (go m)
    go (Inr m) = Inr (go m)
    -- Case x y m n o: old is shadowed in n by x, in o by y.
    go (Case x y m n o)
      | x == old  = Case x y (go m) n (go o)
      | y == old  = Case x y (go m) (go n) o
      | otherwise = Case x y (go m) (go n) (go o)

-- subst x s t replaces all free occurrences of x in t by s, renaming
-- binders in t whenever necessary to avoid capturing free variables of s.
-- Example: subst "x" (Var "y") (Lam "y" (Var "x"))
--   Wrong:   Lam "y" (Var "y")        (y captured)
--   Correct: Lam "y'" (Var "y")
subst :: Name -> Term -> Term -> Term
subst x s = go
  where
    sFV :: Set Name
    sFV = freeVars s

    go :: Term -> Term
    go (Var y)
      | y == x = s -- replace x with s
      | otherwise = Var y
    go (App f a) = App (go f) (go a)
    go (Pair m n) = Pair (go m) (go n)
    go (Fst m) = Fst (go m)
    go (Snd m) = Snd (go m)
    go (Inl m) = Inl (go m)
    go (Inr m) = Inr (go m)
    go (Lam y body)
      | y == x = Lam y body   -- x is bound here
      | y `Set.member` sFV =  -- y would capture a free var of s, so rename y
          let avoid = Set.unions [sFV, freeVars body, Set.singleton x]
              y' = freshLike y avoid
          in Lam y' (go (renameBound y y' body))
      | otherwise = Lam y (go body)
    go (Case y z m n o) =
      let m'       = go m
          (y', n') = substBinder y n
          (z', o') = substBinder z o
      in  Case y' z' m' n' o'

    -- Perform substitution under a single binder b in term t.
    -- Returns the (possibly renamed) binder and the substituted body.
    substBinder :: Name -> Term -> (Name, Term)
    substBinder b t
      | b == x = (b, t) -- b shadows x; no substitution in t
      | b `Set.member` sFV = -- b would capture a free var of s; rename b
          let avoid = Set.unions [sFV, freeVars t, Set.singleton x]
              b' = freshLike b avoid
          in (b', go (renameBound b b' t))
      | otherwise = (b, go t)
