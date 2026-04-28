module Syntax
  ( Name
  , Term(..)
  ) where

-- Variable names are just strings.
type Name = String

-- Terms of the untyped lambda calculus λ→∧∨.
-- See Section 2.2 of de Groote (2002).
data Term
  = Var  Name  
  | Lam  Name Term -- λx. M  (implication intro)
  | App  Term Term -- M N  (implication elim)
  | Pair Term Term -- p(M, N)  (conjunction intro)
  | Fst  Term      -- p1 M  (conjunction elim)
  | Snd  Term      -- p2 M  (conjunction elim)
  | Inl  Term      -- k1 M  (disjunction intro)
  | Inr  Term      -- k2 M  (disjunction intro)
  -- D_{x,y}(M, N, O)  (disjunction elim; M is disjunction; x bound in N, y bound in O)
  | Case Name Name Term Term Term  
  deriving (Eq, Show)
