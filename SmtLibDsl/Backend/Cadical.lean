/-
  SmtLibDsl - CaDiCaL DIMACS SAT backend
-/
import SmtLibDsl.Backend.Dimacs

namespace SmtLibDsl

/-- Configuration for the CaDiCaL SAT backend. -/
structure Cadical where
  executable : Option String := none

/-- Default CaDiCaL backend. -/
def cadical : Cadical := {}

def Cadical.executablePath (backend : Cadical) : IO String :=
  resolveSolverExecutable backend.executable "SMTLIBDSL_CADICAL_PATH" "cadical"

def Cadical.check (backend : Cadical) : IO (Except String String) := do
  DimacsCli.checkExecutable "CaDiCaL" (← backend.executablePath)
    "SMTLIBDSL_CADICAL_PATH"

def Cadical.run (backend : Cadical) (artifact : CnfArtifact) : IO SatResult := do
  DimacsCli.run "CaDiCaL" (← backend.executablePath) artifact

instance : SatBackend Cadical where
  name _ := "CaDiCaL"
  check := Cadical.check
  run := Cadical.run

end SmtLibDsl
