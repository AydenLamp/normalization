module Main (main) where

import Normalize (printTrace)
import Syntax (Term)
import Examples

main :: IO ()
main = do
  putStrLn "=== λ→∧∨: Detour + Permutation conversions ==="
  putStrLn ""

  putStrLn "--- Implication (rule 1: β-reduction) ---"
  putStrLn ""
  runExample "Identity" exIdentity
  runExample "Identity Application" exAppId
  runExample "Application" exAppConst
  runExample "Nested Application" exNested
  runExample "Capture Avoidance example" exCapture
  runExample "self Application" exSelfApp

  putStrLn "--- Conjunction (rules 2 & 3: fst/snd detour) ---"
  putStrLn ""
  runExample "First Projection" exFstPair
  runExample "Second Projection" exSndPair
  runExample "Nested Projection" exFstNested

  putStrLn "--- Disjunction (rules 4 & 5: case detour) ---"
  putStrLn ""
  runExample "Left Case Reduction" exCaseInl
  runExample "Right Case Reduction" exCaseInr

  putStrLn "--- Permutation (Definition 2) ---"
  putStrLn ""
  runExample "App Over Case" exPermAppCase
  runExample "Fst Over Case" exPermFstCase
  runExample "Snd Over Case" exPermSndCase
  runExample "Case Over Case" exPermCaseCase
  runExample "Detour First example" exDetourFirstVsPerm

  putStrLn "--- Mixed ---"
  putStrLn ""
  runExample "Example 1" example1
  runExample "Example 2" example2
  runExample "Example 3 (Normal)" example3_normal
  runExample "Example 3 (Non-normal)" example3_nonnormal

-- Run a single example: print the reduction trace (step [0] is the starting term).
runExample :: String -> Term -> IO ()
runExample label term = do
  putStrLn $ "--- " ++ label ++ " ---"
  putStrLn   "  Trace:"
  printTrace term
  putStrLn ""
