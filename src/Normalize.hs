module Normalize
  ( isNormal
  , normalizeTrace
  , normalize
  , printTrace
  ) where

import Syntax
import Pretty (ppTerm)
import Reduction.Common (Step(..))
import Reduction.Beta (stepBeta)

-- A term is normal iff no beta redex exists anywhere.
isNormal :: Term -> Bool
isNormal t = case stepBeta t of
  Nothing -> True
  Just _  -> False

-- Produce a reduction trace (list of steps from start to normal form).
-- Returns an empty list if the term is already normal.
normalizeTrace :: Term -> [Step]
normalizeTrace t = case stepBeta t of
  Nothing   -> []
  Just step -> step : normalizeTrace (stepAfter step)

-- Normalize a term, returning the final result.
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
  putStrLn $ "  (" ++ show (length steps) ++ " reduction steps)"
  where
    printStep (i, step) =
      putStrLn $ "  [" ++ show i ++ "] " ++ ppTerm (stepAfter step)
                 ++ "  (" ++ stepNote step ++ ")"
