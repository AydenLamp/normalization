module Main (main) where

import Pretty (ppType, ppTerm)
import Typecheck (Context, inferType)
import Normalize (isNormal, normalize, printTrace)
import Syntax (Term)
import Examples

main :: IO ()
main = do
  putStrLn "=== Stage 1: Implication-only STLC ==="
  putStrLn ""

  runExample "Identity: λx:A. x"
    ctxIdentity exIdentity

  runExample "Constant: λx:A. λy:B. x"
    ctxConst exConst

  runExample "Identity applied: (λx:A. x) a"
    ctxAppId exAppId

  runExample "Constant applied: (λx:A. λy:B. x) a b"
    ctxAppConst exAppConst

  runExample "Nested: (λf:A→A. λx:A. f x) (λy:A. y)"
    ctxNested exNested

  runExample "Capture test: (λz:(A→A→A). z y) (λx:A. λy:A. x)"
    ctxCapture exCapture

  runExample "Self-app: (λf:((A→A)→A→A). f (λx:A. x)) (λg:A→A. λx:A. g x)"
    ctxSelfApp exSelfApp

-- Run a single example: show the term, infer its type, print the
--   reduction trace, and report whether the result is normal.
runExample :: String -> Context -> Term -> IO ()
runExample label ctx term = do
  putStrLn $ "--- " ++ label ++ " ---"
  putStrLn $ "  Term:  " ++ ppTerm term
  case inferType ctx term of -- try to infer the type
    Left err -> putStrLn $ "  Type error: " ++ show err
    Right ty -> do
      putStrLn $ "  Type:  " ++ ppType ty
      putStrLn   "  Trace:"
      printTrace term
      let nf = normalize term
      putStrLn $ "  Normal form: " ++ ppTerm nf
      putStrLn $ "  Is normal:   " ++ show (isNormal nf)
  putStrLn ""
