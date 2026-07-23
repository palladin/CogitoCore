/-
  SmtLibDsl - Kissat DIMACS SAT backend
-/
import SmtLibDsl.Backend.Dimacs

namespace SmtLibDsl

/-- Configuration for the Kissat SAT backend. -/
structure Kissat where
  executable : Option String := none

/-- Default Kissat backend. -/
def kissat : Kissat := {}

def Kissat.executablePath (backend : Kissat) : IO String :=
  resolveSolverExecutable backend.executable "SMTLIBDSL_KISSAT_PATH" "kissat"

def Kissat.check (backend : Kissat) : IO (Except String String) := do
  DimacsCli.checkExecutable "Kissat" (← backend.executablePath)
    "SMTLIBDSL_KISSAT_PATH"

def Kissat.run (backend : Kissat) (artifact : CnfArtifact) : IO SatResult := do
  DimacsCli.run "Kissat" (← backend.executablePath) artifact

instance : SatBackend Kissat where
  name _ := "Kissat"
  check := Kissat.check
  run := Kissat.run

namespace SMT

/-- Compatibility API: resolve the default Kissat executable. -/
def getKissatPath : IO String :=
  kissat.executablePath

/-- Compatibility API: check the default Kissat backend. -/
def checkKissat : IO (Except String String) :=
  checkSatBackend kissat

end SMT
end SmtLibDsl
