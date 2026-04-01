module Typecheck
  ( Context
  , TypeError(..)
  , inferType
  ) where

import Data.Map (Map) -- imports the type `Map` (a key-value dictionary)
import qualified Data.Map as Map

import Syntax

-- A typing context maps variable names to their types.
type Context = Map Name Type

-- Type errors that can happen during inference
data TypeError
  = UnboundVar Name  -- We encountered `x` but it's not in the context.
  | ExpectedFunction Type -- Got this type where a function type was expected
  | TypeMismatch Type Type -- Expected, Actual
  deriving (Show, Eq)

-- Infer the type of a term in the given context, or return a type error.
inferType :: Context -> Term -> Either TypeError Type
inferType ctx (Var x) =
  -- Map.lookup returns Nothing if x is not a key
  case Map.lookup x ctx of
    Just ty -> Right ty
    Nothing -> Left (UnboundVar x)
-- Below is the typing rule for implication introduction.
inferType ctx (Lam x ty body) = do
  let ctx' = Map.insert x ty ctx -- Add x to the context with its type
  bodyTy <- inferType ctx' body -- If this returns an error, it will propagate up.
  Right (TyArr ty bodyTy)  -- Return the function type
inferType ctx (App f a) = do
  fTy <- inferType ctx f -- Infer the type of f; if this returns an error, it will propagate up.
  case fTy of
    TyArr argTy resTy -> do -- if f : argTy -> resTy
      aTy <- inferType ctx a -- the type of a
      if aTy == argTy -- make sure a : argTy (this is why we derived Eq on Type)
        then Right resTy -- f a : resTy
        else Left (TypeMismatch argTy aTy)
    other -> Left (ExpectedFunction other) -- If f is not a function type, that's an error. 
