module Reduction.Common
  ( Step(..)
  ) where

import Syntax -- we need `Term` for the field of `Step`

-- A type encoding a single reduction step.
data Step = Step
  { stepBefore :: Term -- The term before the reduction
  , stepAfter  :: Term -- The term after the reduction
  , stepNote   :: String -- A note describing the kind of reduction (e.g. "beta")
  } deriving (Show)
