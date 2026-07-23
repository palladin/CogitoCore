/-
  SmtLibDsl - cvc5 direct SMT backend
-/
import SmtLibDsl.Backend.Core

namespace SmtLibDsl

open SMT

/-- Configuration for the cvc5 executable backend. -/
structure Cvc5 where
  executable : Option String := none

/-- Default cvc5 backend, using the common solver executable resolution order. -/
def cvc5 : Cvc5 := {}

def Cvc5.executablePath (backend : Cvc5) : IO String :=
  resolveSolverExecutable backend.executable "SMTLIBDSL_CVC5_PATH" "cvc5"

def Cvc5.check (backend : Cvc5) : IO (Except String String) := do
  let path ← backend.executablePath
  try
    let output ← IO.Process.output { cmd := path, args := #["--version"] }
    if output.exitCode == 0 then
      let firstLine := (output.stdout.splitOn "\n").head?.getD output.stdout
      return .ok firstLine.trimAscii.toString
    return .error s!"cvc5 returned an error: {output.stderr}"
  catch _ =>
    return .error s!"cvc5 not found at '{path}'. Run scripts/setup.sh or set SMTLIBDSL_CVC5_PATH."

def Cvc5.run (backend : Cvc5) (vars : VarSchema) (script : String)
    (config : SolveConfig) : IO (Result vars) := do
  let path ← backend.executablePath
  try
    let timeoutArgs :=
      match config.timeout with
      | some milliseconds => #[s!"--tlimit-per={milliseconds}"]
      | none => #[]
    let output ← IO.Process.output {
      cmd := path
      args := #["--lang=smt2", "--produce-models"] ++ timeoutArgs
    } (some script)
    if output.exitCode != 0 then
      return .unknown s!"cvc5 error: {output.stderr}"
    match parseSmtLibResult output.stdout with
    | .inl model => return .sat ⟨model⟩
    | .inr "unsat" => return .unsat
    | .inr reason =>
      if reason == "unknown" ||
          (reason.splitOn "timeout").length > 1 ||
          (output.stderr.splitOn "timeout").length > 1 then
        match config.timeout with
        | some milliseconds => return .unknown s!"timeout ({milliseconds}ms)"
        | none => return .unknown reason
      return .unknown reason
  catch error =>
    return .unknown s!"failed to run cvc5: {error}"

instance : SmtBackend Cvc5 where
  name _ := "cvc5"
  check := Cvc5.check
  run := Cvc5.run

instance : SupportsLanguage Cvc5 .bool where
instance : SupportsLanguage Cvc5 .bv where
instance : SupportsLanguage Cvc5 .abv where
instance : SupportsLanguage Cvc5 .all where

def getCvc5Path : IO String :=
  cvc5.executablePath

def checkCvc5 : IO (Except String String) :=
  checkBackend cvc5

end SmtLibDsl
