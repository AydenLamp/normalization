module Pretty
  ( ppType
  , ppTerm
  ) where

import Syntax

-- Pretty-print a type.
-- Arrow is right-associative: A -> B -> C prints without extra parentheses.
ppType :: Type -> String
ppType = ppTypePrec 0

-- The int parameter is the precedence level that controls when we add parentheses.
ppTypePrec :: Int -> Type -> String
ppTypePrec _ (TyAtom a) = a -- print atoms as-is
ppTypePrec p (TyArr a b) =  
  -- wrap in parenthesis if we are in another arrow's left side.
  parensIf (p > 0) (ppTypePrec 1 a ++ " -> " ++ ppTypePrec 0 b)

-- Pretty-print a term.
ppTerm :: Term -> String
ppTerm = ppTermPrec 0

-- Precedence level 0: top level, no parentheses needed.
-- Precedence level 1: parenthesize lambdas but not applications.
-- Precedence level 2: parenthesize both applications and lambdas.
ppTermPrec :: Int -> Term -> String
ppTermPrec _ (Var x) = x
ppTermPrec p (Lam x ty body) =
  parensIf (p > 0)
    ("λ" ++ x ++ " : " ++ ppType ty ++ ". " ++ ppTermPrec 0 body)
ppTermPrec p (App f a) =
  -- Application is left-associative: (f g) x prints as f g x.
  -- Precedence 1 for function, 2 for argument so f (g x) gets parens.
  parensIf (p > 1) (ppTermPrec 1 f ++ " " ++ ppTermPrec 2 a)

-- Wrap in parentheses if the condition is true.
parensIf :: Bool -> String -> String
parensIf True  s = "(" ++ s ++ ")"
parensIf False s = s
