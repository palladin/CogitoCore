/-
  SmtLibDsl - one language-indexed solving API
-/
import SmtLibDsl.Backend.Cvc5
import SmtLibDsl.Backend.Kissat
import SmtLibDsl.Backend.Cadical
import SmtLibDsl.Backend.CNF

namespace SmtLibDsl.SMT

/-- A first-class solver for exactly one SMT language.  The implementation may
be a direct SMT backend or a composed CNF/SAT pipeline. -/
structure Solver (lang : Language) where
  name : String
  check : IO (Except String String)
  run : (smt : Smt lang Unit) → SolveConfig → IO (Result smt.schema)

namespace Solver

/-- Lift any compatible direct SMT backend into the indexed solver API. -/
def ofSmtBackend [SmtBackend backend] [SupportsLanguage backend lang]
    (backend : backend) : Solver lang where
  name := backendName backend
  check := checkBackend backend
  run := fun smt config => runSmtBackend backend smt config

/-- Lift a direct SMT backend and require the language's Lean model validator. -/
def ofCheckedSmtBackend
    [SmtBackend backend] [SupportsLanguage backend lang] [ModelValidator lang]
    (backend : backend) : Solver lang where
  name := backendName backend
  check := checkBackend backend
  run := fun smt config => runCheckedSmtBackend backend smt config

/-- Compose any mapped-CNF lowerer and SAT backend into a `.bv` solver. -/
def ofCnf [CnfLowerer lowerer] [SatBackend satBackend]
    (lowerer : lowerer) (satBackend : satBackend) : Solver .bv where
  name := s!"{lowererName lowerer} → {satBackendName satBackend}"
  check := do
    match ← checkLowerer lowerer with
    | .error error => return .error error
    | .ok lowererVersion =>
      match ← checkSatBackend satBackend with
      | .error error => return .error error
      | .ok satVersion => return .ok s!"{lowererVersion}; {satVersion}"
  run := fun smt config => do
    if config.dumpSmt then
      IO.println s!"SMT-LIB2 script for {lowererName lowerer}:"
      IO.println (compile smt)
    let report ← runCnfPipeline lowerer satBackend smt config
    if config.profile then
      IO.println s!"{lowererName lowerer} → {satBackendName satBackend} profile:"
      IO.println s!"  Lowering time: {report.timing.bridgeMs}ms"
      IO.println s!"  SAT solve time: {report.timing.solveMs}ms"
      IO.println s!"  Lean check time: {report.timing.leanCheckMs}ms"
    pure report.result

private def z3For : (lang : Language) → Solver lang
  | .bool => ofSmtBackend SmtLibDsl.z3
  | .bv => ofCheckedSmtBackend SmtLibDsl.z3
  | .abv => ofSmtBackend SmtLibDsl.z3
  | .all => ofSmtBackend SmtLibDsl.z3

private def cvc5For : (lang : Language) → Solver lang
  | .bool => ofSmtBackend SmtLibDsl.cvc5
  | .bv => ofCheckedSmtBackend SmtLibDsl.cvc5
  | .abv => ofSmtBackend SmtLibDsl.cvc5
  | .all => ofSmtBackend SmtLibDsl.cvc5

/-- Z3 selected at the language inferred from the query. -/
def z3 {lang : Language} : Solver lang :=
  z3For lang

/-- cvc5 selected at the language inferred from the query. -/
def cvc5 {lang : Language} : Solver lang :=
  cvc5For lang

/-- Z3 mapped-CNF lowering followed by Kissat. -/
def kissat : Solver .bv :=
  ofCnf z3Cnf SmtLibDsl.kissat

/-- Z3 mapped-CNF lowering followed by CaDiCaL. -/
def cadical : Solver .bv :=
  ofCnf z3Cnf SmtLibDsl.cadical

end Solver

/-- Solve using one explicit implementation whose language index must match
the query's language index. -/
def solve (solver : Solver lang) (smt : Smt lang Unit)
    (config : SolveConfig := {}) : IO (Result smt.schema) :=
  solver.run smt config

/-- Check all executables required by an indexed solver value. -/
def checkSolver (solver : Solver lang) : IO (Except String String) :=
  solver.check

end SmtLibDsl.SMT
