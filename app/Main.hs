module Main (main) where

import Pretty (ppTerm)
import Normalize (normalize, printTrace)
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
  runExample "Constant Application" exAppConst
  runExample "Nested Application" exNested
  runExample "Capture Avoidance" exCapture
  runExample "Self Application" exSelfApp

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
  runExample "DetourFirst Interaction" exDetourFirstVsPerm

  putStrLn "--- Mixed ---"
  putStrLn ""
  runExample "Beta Then Projection" exBetaThenFst

-- Run a single example: pretty-print the term and show the reduction trace.
runExample :: String -> Term -> IO ()
runExample label term = do
  putStrLn $ "--- " ++ label ++ " ---"
  putStrLn $ "  Term:  " ++ ppTerm term
  putStrLn   "  Trace:"
  printTrace term
  let nf = normalize term
  putStrLn $ "  Normal form: " ++ ppTerm nf
  putStrLn ""
