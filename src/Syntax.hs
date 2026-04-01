module Syntax
  ( Name
  , Type(..)
  , Term(..)
  ) where

-- Variable names are just strings.
type Name = String

-- Types for the simply typed lambda calculus
-- This is the grammar A ::= p | A -> B
-- I will extend this with TyAnd and TyOr later.
data Type
  = TyAtom String      -- Atomic type for propositional variables
  | TyArr  Type Type   -- Function type for implications
  deriving (Eq, Ord, Show) -- show is for converting to strings (for errors)

-- Terms for the simply typed lambda calculus.
-- I will extend this with Pair, Fst, Snd, Inl, Inr, Case later.
data Term
  = Var Name            -- Variable (free or bound)
  | Lam Name Type Term  -- Lambda with type annotation
  | App Term Term       -- Application
  deriving (Eq, Ord, Show)
