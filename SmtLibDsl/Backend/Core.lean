/-
  SmtLibDsl - Solver-independent backend interfaces
-/
import Std.Data.HashMap
import SmtLibDsl.SMT.Model

namespace SmtLibDsl

open SMT

/-- Configuration shared by external SMT solver backends. -/
structure SolveConfig where
  dumpSmt : Bool := false
  timeout : Option Nat := none
  profile : Bool := false

instance : Inhabited SolveConfig where
  default := {}

/-- Find a solver installed by `scripts/setup.sh`, starting at the current
directory and walking toward the filesystem root.  This keeps project-local
tools usable when an example is launched from a repository subdirectory. -/
private def findProjectSolver (executable : String) :
    IO (Option String) := do
  let rec visit (directory : System.FilePath) (remaining : Nat) :
      IO (Option String) := do
    match remaining with
    | 0 => return none
    | remaining + 1 =>
      let candidate := directory / ".tools" / "solvers" / "bin" / executable
      if ← candidate.pathExists then
        return some candidate.toString
      match directory.parent with
      | some parent => visit parent remaining
      | none => return none
  visit (← IO.currentDir) 64

/-- Resolve an external solver consistently for every backend.

Resolution order:
1. the path configured on the backend value;
2. the solver-specific environment variable;
3. `<SMTLIBDSL_SOLVER_DIR>/<executable>`;
4. a project-local `.tools/solvers/bin/<executable>`;
5. the executable name, resolved by the operating system through `PATH`.
-/
def resolveSolverExecutable (configured : Option String)
    (environmentVariable executable : String) : IO String := do
  match configured with
  | some path => return path
  | none => pure ()

  match ← IO.getEnv environmentVariable with
  | some path =>
    if !path.isEmpty then
      return path
  | none => pure ()

  match ← IO.getEnv "SMTLIBDSL_SOLVER_DIR" with
  | some directory =>
    if !directory.isEmpty then
      let candidate := System.FilePath.mk directory / executable
      if ← candidate.pathExists then
        return candidate.toString
  | none => pure ()

  match ← findProjectSolver executable with
  | some path => pure path
  | none => pure executable

/-- A direct SMT-LIB solver backend. -/
class SmtBackend (backend : Type) where
  name : backend → String
  check : backend → IO (Except String String)
  run : (self : backend) → (vars : VarSchema) → String → SolveConfig →
    IO (Result vars)

/-- Open-world backend/language compatibility marker.  A backend opts into
only the explicit language indices it supports; new backends require no edits
to this module. -/
class SupportsLanguage (backend : Type) (lang : Language)
    [SmtBackend backend] : Prop where
  supported : True := by trivial

/-- Language-specific validation of decoded solver models.  Validators are
independent of solver backends and can be added as Lean evaluators grow. -/
class ModelValidator (lang : Language) where
  validate : (smt : Smt lang Unit) → Model smt.schema → Except String Unit

/-- Resolve a backend's human-readable name. -/
def backendName [SmtBackend backend] (backend : backend) : String :=
  SmtBackend.name backend

/-- Check whether an SMT backend executable is available. -/
def checkBackend [SmtBackend backend] (backend : backend) :
    IO (Except String String) :=
  SmtBackend.check backend

/-- Compile and solve through any compatible direct SMT backend. -/
def runSmtBackend [SmtBackend backend] [SupportsLanguage backend lang]
    (backend : backend) (smt : Smt lang Unit) (config : SolveConfig := {}) :
    IO (Result smt.schema) := do
  let compileStart ← IO.monoNanosNow
  let script := compile smt
  -- `compile` is pure, so Lean may otherwise delay it until the backend first
  -- consumes `script`, incorrectly charging compilation to solver time.
  if script.isEmpty then
    return .unknown "SMT compiler generated an empty script"
  let compileEnd ← IO.monoNanosNow
  let compileMs := (compileEnd - compileStart).toFloat / 1_000_000.0
  let scriptBytes := script.utf8ByteSize

  if config.dumpSmt then
    IO.println s!"SMT-LIB2 script for {backendName backend}:"
    IO.println (String.ofList (List.replicate 40 '─'))
    IO.println script
    IO.println (String.ofList (List.replicate 40 '─'))
    IO.println ""

  let solveStart ← IO.monoNanosNow
  let result ← SmtBackend.run backend smt.schema script config
  let solveEnd ← IO.monoNanosNow
  let solveMs := (solveEnd - solveStart).toFloat / 1_000_000.0

  if config.profile then
    IO.println s!"{backendName backend} profile:"
    IO.println (String.ofList (List.replicate 40 '─'))
    IO.println s!"  SMT file size: {scriptBytes} bytes ({scriptBytes.toFloat / 1024.0}KB)"
    IO.println s!"  Compile time: {compileMs}ms"
    IO.println s!"  Solve time: {solveMs}ms"
    IO.println s!"  Total time: {compileMs + solveMs}ms"
    IO.println (String.ofList (List.replicate 40 '─'))
    IO.println ""

  pure result

/-- Solve through any compatible backend and reject a decoded SAT model unless
the language's Lean validator accepts it. -/
def runCheckedSmtBackend
    [SmtBackend backend] [SupportsLanguage backend lang] [ModelValidator lang]
    (backend : backend) (smt : Smt lang Unit) (config : SolveConfig := {}) :
    IO (Result smt.schema) := do
  let result ← runSmtBackend backend smt config
  match result with
  | .sat model =>
    match ModelValidator.validate smt model with
    | .ok () => pure result
    | .error error =>
      pure (.unknown s!"{backendName backend} produced an invalid decoded model: {error}")
  | _ => pure result

/-- One source-level Boolean represented by a DIMACS variable. -/
inductive CnfSourceBit where
  | bool (schemaIndex : Nat) (name : String)
  | bit (schemaIndex : Nat) (name : String) (width : Nat) (index : Nat)
deriving Repr, BEq

/-- Stable source-level model bit to DIMACS-variable mapping. -/
structure CnfModelBitMapping where
  source : CnfSourceBit
  proxy : String
  dimacsVar : Nat
deriving Repr, BEq

/-- Solver-independent CNF artifact. -/
structure CnfArtifact where
  dimacs : String
  atoms : Array String
  clauses : Array (Array Int)
  modelBits : Array CnfModelBitMapping
deriving Repr

def CnfArtifact.numVars (artifact : CnfArtifact) : Nat :=
  artifact.atoms.size

def CnfArtifact.numClauses (artifact : CnfArtifact) : Nat :=
  artifact.clauses.size

/-- A backend that lowers explicitly QF_BV programs to mapped CNF. -/
class CnfLowerer (lowerer : Type) where
  name : lowerer → String
  check : lowerer → IO (Except String String)
  lower : lowerer → Smt .bv Unit → IO (Except String CnfArtifact)

def lowererName [CnfLowerer lowerer] (lowerer : lowerer) : String :=
  CnfLowerer.name lowerer

def checkLowerer [CnfLowerer lowerer] (lowerer : lowerer) :
    IO (Except String String) :=
  CnfLowerer.check lowerer

/-- Portable SAT backend output. -/
inductive SatResult where
  | sat (assignment : Std.HashMap Nat Bool)
  | unsat
  | error (message : String)

/-- A backend that solves DIMACS CNF. -/
class SatBackend (backend : Type) where
  name : backend → String
  check : backend → IO (Except String String)
  run : backend → CnfArtifact → IO SatResult

def satBackendName [SatBackend backend] (backend : backend) : String :=
  SatBackend.name backend

def checkSatBackend [SatBackend backend] (backend : backend) :
    IO (Except String String) :=
  SatBackend.check backend

def lowerWith [CnfLowerer lowerer] (lowerer : lowerer)
    (smt : Smt .bv Unit) : IO (Except String CnfArtifact) :=
  CnfLowerer.lower lowerer smt

def runSatBackend [SatBackend backend] (backend : backend)
    (artifact : CnfArtifact) : IO SatResult :=
  SatBackend.run backend artifact

/-- Solver-independent two-backend comparison. -/
structure BackendComparison (vars : VarSchema) where
  lhsName : String
  lhs : Result vars
  lhsMs : Float
  rhsName : String
  rhs : Result vars
  rhsMs : Float
  agree : Bool

def sameSatStatus (lhs rhs : Result vars) : Bool :=
  match lhs, rhs with
  | .sat _, .sat _ => true
  | .unsat, .unsat => true
  | .unknown _, .unknown _ => true
  | _, _ => false

/-- Solve one program using any two compatible SMT backends. -/
def compareBackends
    [SmtBackend lhs] [SupportsLanguage lhs lang]
    [SmtBackend rhs] [SupportsLanguage rhs lang]
    (left : lhs) (right : rhs) (smt : Smt lang Unit)
    (config : SolveConfig := {}) :
    IO (BackendComparison smt.schema) := do
  let lhsStart ← IO.monoNanosNow
  let lhsResult ← runSmtBackend left smt config
  let lhsEnd ← IO.monoNanosNow
  let rhsStart ← IO.monoNanosNow
  let rhsResult ← runSmtBackend right smt config
  let rhsEnd ← IO.monoNanosNow
  pure {
    lhsName := backendName left
    lhs := lhsResult
    lhsMs := (lhsEnd - lhsStart).toFloat / 1_000_000.0
    rhsName := backendName right
    rhs := rhsResult
    rhsMs := (rhsEnd - rhsStart).toFloat / 1_000_000.0
    agree := sameSatStatus lhsResult rhsResult
  }

/-- Compare two direct SMT backends while validating every decoded SAT model in
Lean through the selected language validator. -/
def compareCheckedBackends
    [SmtBackend lhs] [SupportsLanguage lhs lang]
    [SmtBackend rhs] [SupportsLanguage rhs lang]
    [ModelValidator lang]
    (left : lhs) (right : rhs) (smt : Smt lang Unit)
    (config : SolveConfig := {}) :
    IO (BackendComparison smt.schema) := do
  let lhsStart ← IO.monoNanosNow
  let lhsResult ← runCheckedSmtBackend left smt config
  let lhsEnd ← IO.monoNanosNow
  let rhsStart ← IO.monoNanosNow
  let rhsResult ← runCheckedSmtBackend right smt config
  let rhsEnd ← IO.monoNanosNow
  pure {
    lhsName := backendName left
    lhs := lhsResult
    lhsMs := (lhsEnd - lhsStart).toFloat / 1_000_000.0
    rhsName := backendName right
    rhs := rhsResult
    rhsMs := (rhsEnd - rhsStart).toFloat / 1_000_000.0
    agree := sameSatStatus lhsResult rhsResult
  }

end SmtLibDsl
