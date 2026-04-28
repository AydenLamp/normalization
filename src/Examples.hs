module Examples
  ( -- * Implication examples (rule 1: β-reduction)
    exIdentity
  , exConst
  , exAppId
  , exAppConst
  , exNested
  , exCapture
  , exSelfApp
    -- * Conjunction examples (rules 2 & 3: fst/snd detour)
  , exFstPair
  , exSndPair
  , exFstNested
    -- * Disjunction examples (rules 4 & 5: case detour)
  , exCaseInl
  , exCaseInr
    -- * Permutation examples (Definition 2)
  , exPermAppCase
  , exPermFstCase
  , exPermSndCase
  , exPermCaseCase
  , exDetourFirstVsPerm
    -- * Mixed examples
  , exBetaThenFst
  ) where

import Syntax

-- -----------------------------------------------------------------------
-- Implication examples
-- -----------------------------------------------------------------------

-- λx. x
exIdentity :: Term
exIdentity = Lam "x" (Var "x")

-- λx. λy. x
exConst :: Term
exConst = Lam "x" (Lam "y" (Var "x"))

-- (λx. x) a  →D  a
exAppId :: Term
exAppId = App exIdentity (Var "a")

-- (λx. λy. x) a b  →D*  a
exAppConst :: Term
exAppConst = App (App exConst (Var "a")) (Var "b")

-- (λf. λx. f x) (λy. y)  →D*  λx. x
exNested :: Term
exNested = App
  (Lam "f" (Lam "x" (App (Var "f") (Var "x"))))
  exIdentity

-- (λz. z y) (λx. λy. x)  →D*  λy'. y
-- The binder y must be renamed to avoid capturing the free variable y.
exCapture :: Term
exCapture = App
  (Lam "z" (App (Var "z") (Var "y")))
  (Lam "x" (Lam "y" (Var "x")))

-- (λf. f (λx. x)) (λg. λx. g x)  →D*  λx. x
exSelfApp :: Term
exSelfApp = App
  (Lam "f" (App (Var "f") (Lam "x" (Var "x"))))
  (Lam "g" (Lam "x" (App (Var "g") (Var "x"))))

-- -----------------------------------------------------------------------
-- Conjunction examples
-- -----------------------------------------------------------------------

-- fst ⟨a, b⟩  →D  a  
-- (detour rule 2)
exFstPair :: Term
exFstPair = Fst (Pair (Var "a") (Var "b"))

-- snd ⟨a, b⟩  →D  b                      
-- (detour rule 3)
exSndPair :: Term
exSndPair = Snd (Pair (Var "a") (Var "b"))

-- fst ((λp. p) ⟨a, b⟩)  →D*  a           
-- (rule 1 then rule 2)
exFstNested :: Term
exFstNested = Fst (App (Lam "p" (Var "p")) (Pair (Var "a") (Var "b")))

-- -----------------------------------------------------------------------
-- Disjunction examples
-- -----------------------------------------------------------------------

-- case (inl a) of { inl x → x | inr y → b }  →D  a     
-- (detour rule 4)
exCaseInl :: Term
exCaseInl = Case "x" "y" (Inl (Var "a")) (Var "x") (Var "b")

-- case (inr b) of { inl x → a | inr y → y }  →D  b     
-- (detour rule 5)
exCaseInr :: Term
exCaseInr = Case "x" "y" (Inr (Var "b")) (Var "a") (Var "y")

-- -----------------------------------------------------------------------
-- Permutation examples
-- -----------------------------------------------------------------------

-- Rule 1: application over case
-- (case s of { inl x → (λz. x) | inr y → (λz. y) }) u
--   →P case s of { inl x → (λz. x) u | inr y → (λz. y) u }
exPermAppCase :: Term
exPermAppCase =
  App
    (Case "x" "y" (Var "s")
      (Lam "z" (Var "x"))
      (Lam "z" (Var "y")))
    (Var "u")

-- Rule 2: fst over case
-- fst (case s of { inl x → ⟨x, a⟩ | inr y → ⟨a, y⟩ })
--   →P case s of { inl x → fst ⟨x, a⟩ | inr y → fst ⟨a, y⟩ }
exPermFstCase :: Term
exPermFstCase =
  Fst (Case "x" "y" (Var "s")
    (Pair (Var "x") (Var "a"))
    (Pair (Var "a") (Var "y")))

-- Rule 3: snd over case
-- snd (case s of { inl x → ⟨x, a⟩ | inr y → ⟨a, y⟩ })
--   →P case s of { inl x → snd ⟨x, a⟩ | inr y → snd ⟨a, y⟩ }
exPermSndCase :: Term
exPermSndCase =
  Snd (Case "x" "y" (Var "s")
    (Pair (Var "x") (Var "a"))
    (Pair (Var "a") (Var "y")))

-- Rule 4: case over case
-- case (case s of { inl x → inl x | inr y → inr y }) of { inl u → u | inr v → v }
--   →P case s of { inl x → case (inl x) of ... | inr y → case (inr y) of ... }
exPermCaseCase :: Term
exPermCaseCase =
  Case "u" "v"
    (Case "x" "y" (Var "s") (Inl (Var "x")) (Inr (Var "y")))
    (Var "u")
    (Var "v")

-- Both a detour step (inside the function position) and a permutation step are possible.
exDetourFirstVsPerm :: Term
exDetourFirstVsPerm =
  App
    (Case "x" "y" (Inl (Var "a"))
      (Lam "z" (Var "x"))
      (Lam "z" (Var "y")))
    (Var "u")

-- -----------------------------------------------------------------------
-- Mixed
-- -----------------------------------------------------------------------

-- (λp. fst p) ⟨a, b⟩  →D*  a             
-- (rule 1 then rule 2)
exBetaThenFst :: Term
exBetaThenFst = App (Lam "p" (Fst (Var "p"))) (Pair (Var "a") (Var "b"))
