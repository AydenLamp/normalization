module Pretty
  ( ppTerm
  ) where

import Syntax

-- Pretty-print a term.
ppTerm :: Term -> String
ppTerm = ppTermPrec 0 0

-- Application is left-assoc so (f g) x prints as f g x
-- Precedence levels:
--   0 = top-level (lambdas and case expressions printed without outer parens)
--   1 = function position of application (lambdas/case need parens)
--   2 = argument position of application (applications, lambdas, case need parens)
-- Indentation level tracks nesting depth (for pretty multi-line output)
ppTermPrec :: Int -> Int -> Term -> String
ppTermPrec _ _ (Var x) = x
ppTermPrec p ind (Lam x body) =
  parensIf (p > 0)
    ("λ" ++ x ++ ". " ++ ppTermPrec 0 ind body)
ppTermPrec p ind (App f a) =
  parensIf (p > 1)
    (ppTermPrec 1 ind f ++ " " ++ ppTermPrec 2 ind a)
ppTermPrec _ _ (Pair m n) =
  "⟨" ++ ppTermPrec 0 0 m ++ ", " ++ ppTermPrec 0 0 n ++ "⟩"
ppTermPrec p ind (Fst m) =
  parensIf (p > 1) ("fst " ++ ppTermPrec 2 ind m)
ppTermPrec p ind (Snd m) =
  parensIf (p > 1) ("snd " ++ ppTermPrec 2 ind m)
ppTermPrec p ind (Inl m) =
  parensIf (p > 1) ("inl " ++ ppTermPrec 2 ind m)
ppTermPrec p ind (Inr m) =
  parensIf (p > 1) ("inr " ++ ppTermPrec 2 ind m)
ppTermPrec p ind (Case x y m n o) =
  parensIf (p > 0)
    ("case " ++ ppTermPrec 2 ind m ++ " of\n" ++
     indentStr (ind + 2) ++ "{ inl " ++ x ++ " → " ++ ppTermPrec 0 (ind + 2) n ++ "\n" ++
     indentStr (ind + 2) ++ "| inr " ++ y ++ " → " ++ ppTermPrec 0 (ind + 2) o ++ " }")

-- Generate indentation string (spaces)
indentStr :: Int -> String
indentStr n = replicate n ' '

-- Wrap in parentheses if the condition is true.
parensIf :: Bool -> String -> String
parensIf True  s = "(" ++ s ++ ")"
parensIf False s = s
