/-
  SmtLibDsl - Z3 direct SMT backend
-/
import SmtLibDsl.Backend.Core

namespace SmtLibDsl

open SMT

/-- Configuration for the Z3 executable backend. -/
structure Z3 where
  executable : Option String := none

/-- Default Z3 backend, using the common solver executable resolution order. -/
def z3 : Z3 := {}

def Z3.executablePath (backend : Z3) : IO String :=
  resolveSolverExecutable backend.executable "SMTLIBDSL_Z3_PATH" "z3"

def Z3.check (backend : Z3) : IO (Except String String) := do
  let path ← backend.executablePath
  try
    let output ← IO.Process.output { cmd := path, args := #["--version"] }
    if output.exitCode == 0 then
      return .ok output.stdout.trimAscii.toString
    return .error s!"Z3 returned an error: {output.stderr}"
  catch _ =>
    return .error s!"Z3 not found at '{path}'. Run scripts/setup.sh or set SMTLIBDSL_Z3_PATH."

def Z3.run (backend : Z3) (vars : VarSchema) (script : String)
    (config : SolveConfig) : IO (Result vars) := do
  let path ← backend.executablePath
  try
    let timeoutArgs :=
      match config.timeout with
      | some milliseconds => #[s!"-t:{milliseconds}"]
      | none => #[]
    let output ← IO.Process.output {
      cmd := path
      args := timeoutArgs ++ #["-in", "-smt2"]
    } (some script)
    if output.exitCode != 0 && output.exitCode != 1 then
      return .unknown s!"Z3 error: {output.stderr}"
    match parseSmtLibResult output.stdout with
    | .inl model => return .sat ⟨model⟩
    | .inr "unsat" => return .unsat
    | .inr reason =>
      if reason == "unknown" ||
          (reason.splitOn "model is not available").length > 1 then
        match config.timeout with
        | some milliseconds => return .unknown s!"timeout ({milliseconds}ms)"
        | none => return .unknown reason
      return .unknown reason
  catch error =>
    return .unknown s!"failed to run Z3: {error}"

instance : SmtBackend Z3 where
  name _ := "Z3"
  check := Z3.check
  run := Z3.run

instance : SupportsLanguage Z3 .bool where
instance : SupportsLanguage Z3 .bv where
instance : SupportsLanguage Z3 .abv where
instance : SupportsLanguage Z3 .all where

namespace SMT

/-- Compatibility API: resolve the default Z3 executable. -/
def getZ3Path : IO String :=
  z3.executablePath

/-- Compatibility API: check the default Z3 backend. -/
def checkZ3 : IO (Except String String) :=
  checkBackend z3

/-- Compatibility API: run Z3 on an already compiled SMT-LIB script. -/
def runZ3 (vars : VarSchema) (script : String) (timeout : Option Nat := none)
    (profile : Bool := false) : IO (Result vars) :=
  Z3.run z3 vars script { timeout, profile }

/-- Print the compiled SMT-LIB2 script. -/
def printScript (smt : Smt lang Unit) : IO Unit :=
  IO.println (compile smt)

end SMT
end SmtLibDsl
