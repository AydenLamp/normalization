module Normalize
  ( normalizeTrace
  , normalize
  , printTrace
  ) where

import Syntax
import Pretty (ppTerm)
import Reduction.Common (Step(..))
import Reduction.Detour (stepDetour)
import Reduction.Permutation (stepPerm)

-- Perform a detour conversion if possible.
-- Otherwise, apply a permutation conversion if possible.
stepAny :: Term -> Maybe Step
stepAny t =
  case stepDetour t of
    Just s  -> Just s
    Nothing -> stepPerm t

-- Produce a reduction trace (list of steps from start to mixed normal form).
-- Returns an empty list if no detour or permutation step is available.
normalizeTrace :: Term -> [Step]
normalizeTrace t = case stepAny t of
  Nothing   -> []
  Just step -> step : normalizeTrace (stepAfter step)

-- Normalize a term with respect to detour and permutation conversions.
normalize :: Term -> Term
normalize t = case normalizeTrace t of
  []    -> t
  steps -> stepAfter (last steps)

-- Print a full reduction trace to stdout, numbering each step.
printTrace :: Term -> IO ()
printTrace t = do
  let steps = normalizeTrace t
  putStrLn $ "  [0] " ++ ppTerm t
  mapM_ printStep (zip [1 :: Int ..] steps)
  where
    printStep (i, step) =
      putStrLn $ "  [" ++ show i ++ "] " ++ ppTerm (stepAfter step)
                 ++ "  (" ++ stepNote step ++ ")"
