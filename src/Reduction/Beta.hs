module Reduction.Beta
  ( isBetaRedex
  , stepBeta
  ) where

import Syntax
import Substitution (subst)
import Reduction.Common (Step(..))

-- Check whether a term is itself a beta redex (top-level only).
isBetaRedex :: Term -> Bool
isBetaRedex (App (Lam _ _ _) _) = True
isBetaRedex _ = False

-- One-step beta reduction (outermost then leftmost first)
-- Returns 'Nothing' if the term is already in normal form.
stepBeta :: Term -> Maybe Step
stepBeta t@(App (Lam x _ body) arg) =
  -- (λx. M) N → M[x := N]
  Just (Step t (subst x arg body) "beta")
stepBeta (App f a) =
  -- Try reducing the function
  case stepBeta f of
    Just step -> Just step { stepBefore = App f a
                           , stepAfter  = App (stepAfter step) a }
    Nothing ->
      -- Function is normal; try the argument
      case stepBeta a of
        Just step -> Just step { stepBefore = App f a
                               , stepAfter  = App f (stepAfter step) }
        Nothing -> Nothing
stepBeta (Lam x ty body) =
  -- Reduce the body
  case stepBeta body of
    Just step -> Just step { stepBefore = Lam x ty body
                           , stepAfter  = Lam x ty (stepAfter step) }
    Nothing    -> Nothing
stepBeta (Var _) = Nothing
