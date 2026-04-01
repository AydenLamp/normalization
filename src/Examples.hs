module Examples
  ( -- * Atomic types
    tyA, tyB, tyC
    -- * Sample terms and their contexts
  , exIdentity,     ctxIdentity
  , exConst,        ctxConst
  , exAppId,        ctxAppId
  , exAppConst,     ctxAppConst
  , exNested,       ctxNested
  , exCapture,      ctxCapture
  , exSelfApp,      ctxSelfApp
  ) where

import qualified Data.Map as Map

import Syntax
import Typecheck (Context)

-- Define atomic types
tyA, tyB, tyC :: Type
tyA = TyAtom "A"
tyB = TyAtom "B"
tyC = TyAtom "C"

-- Example 1: λx:A. x
exIdentity :: Term
exIdentity = Lam "x" tyA (Var "x")

ctxIdentity :: Context
ctxIdentity = Map.empty

-- Example 2: λx:A. λy:B. x
exConst :: Term
exConst = Lam "x" tyA (Lam "y" tyB (Var "x"))

ctxConst :: Context
ctxConst = Map.empty

-- Example 3: (λx:A. x) a
-- with a : A in context.
exAppId :: Term
exAppId = App exIdentity (Var "a")

ctxAppId :: Context
ctxAppId = Map.singleton "a" tyA

-- Example 4: (λx:A. λy:B. x) a b
-- with a : A, b : B in context.
exAppConst :: Term
exAppConst = App (App exConst (Var "a")) (Var "b")

ctxAppConst :: Context
ctxAppConst = Map.fromList [("a", tyA), ("b", tyB)]

-- Example 5: (λf:A→A. λx:A. f x) (λy:A. y)
-- Should reduce to λx:A. x in two steps.
exNested :: Term
exNested = App
  (Lam "f" (TyArr tyA tyA) (Lam "x" tyA (App (Var "f") (Var "x"))))
  exIdentity

ctxNested :: Context
ctxNested = Map.empty

-- Example 6: (λz:A→A. z y) (λx:A. λy:A. x)
-- where y : A is free.
-- The beta step substitutes (λx:A. λy:A. x) for z in (z y),
-- giving ((λx:A. λy:A. x) y), which then reduces to (λy':A. y).
-- The binder y must be renamed to avoid capturing the free y.

exCapture :: Term
exCapture = App
  (Lam "z" (TyArr tyA (TyArr tyA tyA))
    (App (Var "z") (Var "y")))
  (Lam "x" tyA (Lam "y" tyA (Var "x")))

ctxCapture :: Context
ctxCapture = Map.singleton "y" tyA

-- Example 7: (λf:(A→A)→A→A. f (λx:A. x)) (λg:A→A. λx:A. g x)
--   Should reduce to λx:A. x
exSelfApp :: Term
exSelfApp = App
  (Lam "f" (TyArr (TyArr tyA tyA) (TyArr tyA tyA))
    (App (Var "f") (Lam "x" tyA (Var "x"))))
  (Lam "g" (TyArr tyA tyA) (Lam "x" tyA (App (Var "g") (Var "x"))))

ctxSelfApp :: Context
ctxSelfApp = Map.empty
