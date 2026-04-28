module Pretty
  ( ppTerm
  ) where

import Syntax

-- Pretty-print a term.
ppTerm :: Term -> String
ppTerm = ppTermPrec 0

-- Application is left-assoc so (f g) x prints as f g x
-- Precedence levels:
--   0 = top-level (lambdas and case expressions printed without outer parens)
--   1 = function position of application (lambdas/case need parens)
--   2 = argument position of application (applications, lambdas, case need parens)
ppTermPrec :: Int -> Term -> String
ppTermPrec _ (Var x) = x
ppTermPrec p (Lam x body) =
  parensIf (p > 0)
    ("λ" ++ x ++ ". " ++ ppTermPrec 0 body)
ppTermPrec p (App f a) =
  parensIf (p > 1)
    (ppTermPrec 1 f ++ " " ++ ppTermPrec 2 a)
ppTermPrec _ (Pair m n) =
  "⟨" ++ ppTermPrec 0 m ++ ", " ++ ppTermPrec 0 n ++ "⟩"
ppTermPrec p (Fst m) =
  parensIf (p > 1) ("fst " ++ ppTermPrec 2 m)
ppTermPrec p (Snd m) =
  parensIf (p > 1) ("snd " ++ ppTermPrec 2 m)
ppTermPrec p (Inl m) =
  parensIf (p > 1) ("inl " ++ ppTermPrec 2 m)
ppTermPrec p (Inr m) =
  parensIf (p > 1) ("inr " ++ ppTermPrec 2 m)
ppTermPrec p (Case x y m n o) =
  parensIf (p > 0)
    ("case " ++ ppTermPrec 2 m ++
     " of { inl " ++ x ++ " → " ++ ppTermPrec 0 n ++
     " | inr " ++ y ++ " → " ++ ppTermPrec 0 o ++ " }")

-- Wrap in parentheses if the condition is true.
parensIf :: Bool -> String -> String
parensIf True  s = "(" ++ s ++ ")"
parensIf False s = s
