/-
  SmtLibDsl - Mapped CNF pipeline with Z3 lowering and Kissat
-/
import SmtLibDsl.Backend.Z3

namespace SmtLibDsl.SMT

/-- Compatibility aliases for the solver-independent CNF vocabulary. -/
abbrev SourceBit := SmtLibDsl.CnfSourceBit
abbrev ModelBitMapping := SmtLibDsl.CnfModelBitMapping
abbrev CnfBridge := SmtLibDsl.CnfArtifact

/- Compatibility constructors retained under the historical namespace. -/
namespace SourceBit

def bool (schemaIndex : Nat) (name : String) : SourceBit :=
  SmtLibDsl.CnfSourceBit.bool schemaIndex name

def bit (schemaIndex : Nat) (name : String) (width : Nat) (index : Nat) :
    SourceBit :=
  SmtLibDsl.CnfSourceBit.bit schemaIndex name width index

end SourceBit

/- Compatibility projections retained under the historical namespace. -/
namespace ModelBitMapping

def source (mapping : ModelBitMapping) : SourceBit :=
  SmtLibDsl.CnfModelBitMapping.source mapping

def proxy (mapping : ModelBitMapping) : String :=
  SmtLibDsl.CnfModelBitMapping.proxy mapping

def dimacsVar (mapping : ModelBitMapping) : Nat :=
  SmtLibDsl.CnfModelBitMapping.dimacsVar mapping

end ModelBitMapping

private structure PendingBit where
  source : SourceBit
  proxy : String
deriving Repr

private def duplicateName? (vars : VarSchema) : Option String :=
  let rec go (seen : List String) : VarSchema → Option String
    | [] => none
    | (name, _) :: rest =>
      if seen.contains name then some name else go (name :: seen) rest
  go [] vars

private def pendingBits (vars : VarSchema) : Except String (Array PendingBit) := do
  if let some name := duplicateName? vars then
    throw s!"duplicate declaration '{name}' cannot have an unambiguous SAT-model mapping"
  let mut result := #[]
  for ((name, ty), schemaIndex) in vars.zipIdx do
    if name.startsWith "__smtlibdsl_" then
      throw s!"declaration '{name}' uses the reserved CNF-bridge prefix '__smtlibdsl_'"
    match ty with
    | .bool =>
      result := result.push {
        source := .bool schemaIndex name
        proxy := s!"__smtlibdsl_bool_{schemaIndex}"
      }
    | .bitVec width =>
      if width == 0 then
        throw s!"zero-width bit-vector '{name}' cannot be bit-blasted"
      for index in List.range width do
        result := result.push {
          source := .bit schemaIndex name width index
          proxy := s!"__smtlibdsl_bit_{schemaIndex}_{index}"
        }
    | .array _ _ =>
      throw s!"array variable '{name}' reached the QF_BV-only CNF bridge"
    | .datatype _ =>
      throw s!"datatype variable '{name}' reached the QF_BV-only CNF bridge"
  pure result

private def proxyCommands (bits : Array PendingBit) : String :=
  bits.toList.map (fun bit =>
    let declaration := s!"(declare-const {bit.proxy} Bool)"
    let assertion :=
      match bit.source with
      | .bool _ name => s!"(assert (= {bit.proxy} {name}))"
      | .bit _ name _ index =>
        s!"(assert (= {bit.proxy} (= ((_ extract {index} {index}) {name}) #b1)))"
    declaration ++ "\n" ++ assertion
  ) |> String.intercalate "\n"

/-- Z3 tactic-based mapped-CNF lowerer configuration. -/
structure Z3Cnf where
  backend : Z3 := z3

/-- Default Z3 CNF lowerer. -/
def z3Cnf : Z3Cnf := {}

/-- Build the SMT-LIB script that asks Z3 to bit-blast and Tseitin-encode a
QF_BV program.  Explicit proxy equalities keep every source model bit visible
in the resulting propositional goal. -/
def compileCnfBridgeScript (smt : Smt .bv Unit) : Except String String := do
  let bits ← pendingBits smt.schema
  let body := Compiler.compileCommandsWithCSE smt
  let proxies := proxyCommands bits
  let commands :=
    if body.isEmpty then proxies
    else if proxies.isEmpty then body
    else body ++ "\n" ++ proxies
  pure s!"(set-option :pp.bounded false)\n(set-option :pp.no-lets true)\n(set-logic QF_BV)\n{commands}\n(apply (then simplify bit-blast tseitin-cnf))"

private structure AtomTable where
  ids : Std.HashMap String Nat := {}
  names : Array String := #[]

private def AtomTable.intern (table : AtomTable) (name : String) : Nat × AtomTable :=
  match table.ids.get? name with
  | some id => (id, table)
  | none =>
    let id := table.names.size + 1
    (id, {
      ids := table.ids.insert name id
      names := table.names.push name
    })

private inductive ParsedLiteral where
  | truth (value : Bool)
  | atom (positive : Bool) (name : String)

private def parseLiteral : SExpr → Except String ParsedLiteral
  | .atom "true" => pure (.truth true)
  | .atom "false" => pure (.truth false)
  | .atom name => pure (.atom true name)
  | .list [.atom "not", .atom name] => pure (.atom false name)
  | value => throw s!"Z3 produced a non-literal CNF term: {value}"

private def encodeClauseLiterals (terms : List SExpr) (initial : AtomTable) :
    Except String (Option (Array Int) × AtomTable) := do
  let mut table := initial
  let mut clause := #[]
  for term in terms do
    match ← parseLiteral term with
    | .truth true => return (none, table)
    | .truth false => pure ()
    | .atom positive name =>
      let (id, next) := table.intern name
      table := next
      clause := clause.push (if positive then Int.ofNat id else -Int.ofNat id)
  pure (some clause, table)

private def encodeClause (term : SExpr) (table : AtomTable) :
    Except String (Option (Array Int) × AtomTable) :=
  match term with
  | .list (.atom "or" :: terms) => encodeClauseLiterals terms table
  | other => encodeClauseLiterals [other] table

private def goalClauses : SExpr → Except String (List SExpr)
  | .list [.atom "goals", .list (.atom "goal" :: entries)] =>
    pure (entries.takeWhile fun
      | .atom value => !value.startsWith ":"
      | _ => true)
  | .list (.atom "goals" :: []) =>
    -- No goals means the tactic proved the input, i.e. the CNF is true.
    pure []
  | value =>
    throw s!"unexpected Z3 tactic output: {value}"

private def renderDimacs (atoms : Array String) (clauses : Array (Array Int)) : String :=
  let atomComments := atoms.toList.zipIdx.map fun (name, index) =>
    s!"c atom {index + 1} {name}"
  let clauseLines := clauses.toList.map fun clause =>
    let literals := String.intercalate " " (clause.toList.map toString)
    if literals.isEmpty then "0" else literals ++ " 0"
  String.intercalate "\n" (
    atomComments ++
    [s!"p cnf {atoms.size} {clauses.size}"] ++
    clauseLines
  ) ++ "\n"

private def finalizeMappings (pending : Array PendingBit) (table : AtomTable) :
    Except String (Array ModelBitMapping) := do
  let mut result := #[]
  for bit in pending do
    match table.ids.get? bit.proxy with
    | some id =>
      result := result.push {
        source := bit.source
        proxy := bit.proxy
        dimacsVar := id
      }
    | none =>
      throw s!"Z3 eliminated model proxy '{bit.proxy}'; model mapping is incomplete"
  pure result

/-- Parse Z3's `(apply ... tseitin-cnf)` output into DIMACS while preserving
the source-variable bit map. -/
def parseZ3CnfOutput (vars : VarSchema) (output : String) :
    Except String CnfBridge := do
  let pending ← pendingBits vars
  let sexpr ←
    match SExpr.parse output with
    | some value => pure value
    | none => throw s!"failed to parse Z3 tactic output: {output}"
  let terms ← goalClauses sexpr
  let mut table : AtomTable := {}
  let mut clauses := #[]
  for term in terms do
    let (clause?, next) ← encodeClause term table
    table := next
    if let some clause := clause? then
      clauses := clauses.push clause
  let mappings ← finalizeMappings pending table
  pure {
    dimacs := renderDimacs table.names clauses
    atoms := table.names
    clauses
    modelBits := mappings
  }

/-- Ask a configured Z3 backend to lower QF_BV to mapped CNF. -/
def Z3Cnf.lower (lowerer : Z3Cnf) (smt : Smt .bv Unit) :
    IO (Except String CnfArtifact) := do
  let script ←
    match compileCnfBridgeScript smt with
    | .ok script => pure script
    | .error error => return .error error
  let z3Path ← lowerer.backend.executablePath
  try
    let output ← IO.Process.output {
      cmd := z3Path
      args := #["-in", "-smt2"]
    } (some script)
    if output.exitCode != 0 then
      return .error s!"Z3 CNF bridge failed: {output.stderr}"
    return parseZ3CnfOutput smt.schema output.stdout
  catch error =>
    return .error s!"failed to run Z3 CNF bridge: {error}"

instance : CnfLowerer Z3Cnf where
  name _ := "Z3 bit-blast/tseitin-cnf"
  check lowerer := checkBackend lowerer.backend
  lower := Z3Cnf.lower

/-- Compatibility API using the default Z3 CNF lowerer. -/
def bridgeToCnf (smt : Smt .bv Unit) : IO (Except String CnfBridge) :=
  lowerWith z3Cnf smt

private def assignmentValue (assignment : Std.HashMap Nat Bool) (id : Nat) :
    Except String Bool :=
  match assignment.get? id with
  | some value => pure value
  | none => throw s!"Kissat model omitted DIMACS variable {id}"

private def mappingForBool (mappings : Array ModelBitMapping) (schemaIndex : Nat) :
    Option ModelBitMapping :=
  mappings.find? fun mapping =>
    match mapping.source with
    | .bool index _ => index == schemaIndex
    | _ => false

private def mappingForBit (mappings : Array ModelBitMapping)
    (schemaIndex bitIndex : Nat) : Option ModelBitMapping :=
  mappings.find? fun mapping =>
    match mapping.source with
    | .bit index _ _ bit => index == schemaIndex && bit == bitIndex
    | _ => false

private def decodeModel (vars : VarSchema) (bridge : CnfBridge)
    (assignment : Std.HashMap Nat Bool) : Except String (Model vars) := do
  let mut raw := []
  for ((name, ty), schemaIndex) in vars.zipIdx do
    match ty with
    | .bool =>
      let mapping ←
        match mappingForBool bridge.modelBits schemaIndex with
        | some mapping => pure mapping
        | none => throw s!"missing Boolean mapping for '{name}'"
      let value ← assignmentValue assignment mapping.dimacsVar
      raw := raw ++ [(name, if value then "true" else "false")]
    | .bitVec width =>
      let mut value := 0
      for bitIndex in List.range width do
        let mapping ←
          match mappingForBit bridge.modelBits schemaIndex bitIndex with
          | some mapping => pure mapping
          | none => throw s!"missing bit {bitIndex} mapping for '{name}'"
        if ← assignmentValue assignment mapping.dimacsVar then
          value := value + 2 ^ bitIndex
      raw := raw ++ [(name, toString value)]
    | .array _ _ => throw s!"cannot decode array '{name}' from QF_BV CNF"
    | .datatype _ => throw s!"cannot decode datatype '{name}' from QF_BV CNF"
  pure ⟨raw⟩

private def repeatBits (value width count : Nat) : Nat :=
  List.range count |>.foldl (fun result _ => result * (2 ^ width) + value) 0

/-- Evaluate a QF_BV expression entirely in Lean against a decoded model. -/
partial def evalBvExpr (model : Model vars) :
    (expr : Expr .bv ty) → Except String ty.LeanType
  | @ExprF.var _ name ty _ => model.get name ty
  | .btrue => pure true
  | .bfalse => pure false
  | .and lhs rhs => return (← evalBvExpr model lhs) && (← evalBvExpr model rhs)
  | .or lhs rhs => return (← evalBvExpr model lhs) || (← evalBvExpr model rhs)
  | .not value => return !(← evalBvExpr model value)
  | .imp lhs rhs => return !(← evalBvExpr model lhs) || (← evalBvExpr model rhs)
  | .boolEq lhs rhs => do
    let left ← evalBvExpr model lhs
    let right ← evalBvExpr model rhs
    return (left && right) || (!left && !right)
  | .ite cond onTrue onFalse => do
    match ← evalBvExpr model cond with
    | true => evalBvExpr model onTrue
    | false => evalBvExpr model onFalse
  | @ExprF.bvLit _ value width _ => pure (BitVec.ofNat width value)
  | .bvAdd lhs rhs => return BitVec.add (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvSub lhs rhs => return BitVec.sub (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvMul lhs rhs => return BitVec.mul (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvUDiv lhs rhs => return BitVec.udiv (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvSDiv lhs rhs => return BitVec.sdiv (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvURem lhs rhs => return BitVec.umod (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvSMod lhs rhs => return BitVec.smod (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvSRem lhs rhs => return BitVec.srem (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvNeg value => return BitVec.neg (← evalBvExpr model value)
  | .bvAnd lhs rhs => return BitVec.and (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvOr lhs rhs => return BitVec.or (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvXor lhs rhs => return BitVec.xor (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvNot value => return BitVec.not (← evalBvExpr model value)
  | .bvNand lhs rhs =>
    return BitVec.not (BitVec.and (← evalBvExpr model lhs) (← evalBvExpr model rhs))
  | .bvNor lhs rhs =>
    return BitVec.not (BitVec.or (← evalBvExpr model lhs) (← evalBvExpr model rhs))
  | .bvXnor lhs rhs =>
    return BitVec.not (BitVec.xor (← evalBvExpr model lhs) (← evalBvExpr model rhs))
  | .bvShl lhs rhs =>
    return BitVec.shiftLeft (← evalBvExpr model lhs) (← evalBvExpr model rhs).toNat
  | .bvLShr lhs rhs =>
    return BitVec.ushiftRight (← evalBvExpr model lhs) (← evalBvExpr model rhs).toNat
  | .bvAShr lhs rhs =>
    return BitVec.sshiftRight (← evalBvExpr model lhs) (← evalBvExpr model rhs).toNat
  | .rotateLeft amount value =>
    return BitVec.rotateLeft (← evalBvExpr model value) amount
  | .rotateRight amount value =>
    return BitVec.rotateRight (← evalBvExpr model value) amount
  | .bvEq lhs rhs =>
    return (← evalBvExpr model lhs).toNat == (← evalBvExpr model rhs).toNat
  | .bvULt lhs rhs => return BitVec.ult (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvULe lhs rhs => return BitVec.ule (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvUGt lhs rhs => return BitVec.ult (← evalBvExpr model rhs) (← evalBvExpr model lhs)
  | .bvUGe lhs rhs => return BitVec.ule (← evalBvExpr model rhs) (← evalBvExpr model lhs)
  | .bvSLt lhs rhs => return BitVec.slt (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvSLe lhs rhs => return BitVec.sle (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvSGt lhs rhs => return BitVec.slt (← evalBvExpr model rhs) (← evalBvExpr model lhs)
  | .bvSGe lhs rhs => return BitVec.sle (← evalBvExpr model rhs) (← evalBvExpr model lhs)
  | .bvComp lhs rhs =>
    return BitVec.ofNat 1 (
      if (← evalBvExpr model lhs).toNat == (← evalBvExpr model rhs).toNat then 1 else 0)
  | .concat lhs rhs => return BitVec.append (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .extract hi lo value => return BitVec.extractLsb hi lo (← evalBvExpr model value)
  | @ExprF.zeroExt _ n amount value =>
    return BitVec.zeroExtend (n + amount) (← evalBvExpr model value)
  | @ExprF.signExt _ n amount value =>
    return BitVec.signExtend (n + amount) (← evalBvExpr model value)
  | @ExprF.repeat _ n count value => do
    let evaluated ← evalBvExpr model value
    return BitVec.ofNat (count * n) (repeatBits evaluated.toNat n count)
  | .bvNegO value => return BitVec.negOverflow (← evalBvExpr model value)
  | .bvUAddO lhs rhs =>
    return BitVec.uaddOverflow (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvSAddO lhs rhs =>
    return BitVec.saddOverflow (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvUMulO lhs rhs =>
    return BitVec.umulOverflow (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | .bvSMulO lhs rhs =>
    return BitVec.smulOverflow (← evalBvExpr model lhs) (← evalBvExpr model rhs)
  | @ExprF.mkArray _ _ _ _ _ => throw "array expression reached QF_BV evaluator"
  | .select _ _ => throw "array expression reached QF_BV evaluator"
  | .store _ _ _ => throw "array expression reached QF_BV evaluator"
  | .arrEq _ _ => throw "array expression reached QF_BV evaluator"
  | .dtEq _ _ => throw "datatype expression reached QF_BV evaluator"
  | @ExprF.distinctBV _ width names _ => do
    let values : List (BitVec width) ←
      names.mapM (fun name => model.get name (.bitVec width))
    let unique := (values.map BitVec.toNat).eraseDups
    return unique.length == values.length
  | .dtSelect _ _ _ => throw "datatype expression reached QF_BV evaluator"

/-- Replay every assertion in Lean.  A SAT model is accepted only if this
function reaches the end of the original free-monad program. -/
partial def checkBvModel (smt : Smt .bv Unit) (model : Model smt.schema) :
    Except String Unit :=
  check smt
where
  check : (program : Smt .bv Unit) → Except String Unit
    | .pure () => pure ()
    | .bind (@Cmd.declareConst _ name ty supported) continuation =>
      check (continuation (@ExprF.var .bv name ty supported))
    | .bind (@Cmd.declareDatatypeConstOf _ _ _ _) _ =>
      throw "datatype declaration reached QF_BV model checker"
    | .bind (.assert expression) continuation => do
      let holds ← evalBvExpr model expression
      if !holds then
        throw s!"decoded SAT model falsifies assertion {compileExpr expression}"
      check (continuation ())

instance : ModelValidator .bv where
  validate := checkBvModel

/-- Timing information for any checked CNF pipeline. -/
structure PipelineTiming where
  bridgeMs : Float
  solveMs : Float
  leanCheckMs : Float
deriving Repr

/-- Solver-independent result of a checked CNF pipeline. -/
structure CnfSolveReport (vars : VarSchema) where
  result : Result vars
  cnfVars : Nat
  cnfClauses : Nat
  timing : PipelineTiming
  modelChecked : Bool

/-- Lower with any mapped-CNF backend, solve with any SAT backend, decode the
stable bit mapping, and Lean-check SAT before returning it. -/
def runCnfPipeline [CnfLowerer lowerer] [SatBackend satBackend]
    (lowerer : lowerer) (satBackend : satBackend) (smt : Smt .bv Unit) :
    IO (CnfSolveReport smt.schema) := do
  let bridgeStart ← IO.monoNanosNow
  let bridged ← lowerWith lowerer smt
  let bridgeEnd ← IO.monoNanosNow
  let bridgeMs := (bridgeEnd - bridgeStart).toFloat / 1_000_000.0
  match bridged with
  | .error error =>
    return {
      result := .unknown error
      cnfVars := 0
      cnfClauses := 0
      timing := { bridgeMs, solveMs := 0, leanCheckMs := 0 }
      modelChecked := false
    }
  | .ok bridge =>
    let solveStart ← IO.monoNanosNow
    let raw ← runSatBackend satBackend bridge
    let solveEnd ← IO.monoNanosNow
    let solveMs := (solveEnd - solveStart).toFloat / 1_000_000.0
    match raw with
    | .unsat =>
      return {
        result := .unsat
        cnfVars := bridge.numVars
        cnfClauses := bridge.numClauses
        timing := { bridgeMs, solveMs, leanCheckMs := 0 }
        modelChecked := false
      }
    | .error error =>
      return {
        result := .unknown error
        cnfVars := bridge.numVars
        cnfClauses := bridge.numClauses
        timing := { bridgeMs, solveMs, leanCheckMs := 0 }
        modelChecked := false
      }
    | .sat assignment =>
      let checkStart ← IO.monoNanosNow
      let checked := do
        let model ← decodeModel smt.schema bridge assignment
        checkBvModel smt model
        pure model
      let checkEnd ← IO.monoNanosNow
      let leanCheckMs := (checkEnd - checkStart).toFloat / 1_000_000.0
      match checked with
      | .ok model =>
        return {
          result := .sat model
          cnfVars := bridge.numVars
          cnfClauses := bridge.numClauses
          timing := { bridgeMs, solveMs, leanCheckMs }
          modelChecked := true
        }
      | .error error =>
        return {
          result := .unknown s!"SAT backend produced an invalid decoded model: {error}"
          cnfVars := bridge.numVars
          cnfClauses := bridge.numClauses
          timing := { bridgeMs, solveMs, leanCheckMs }
          modelChecked := false
        }

/-- Comparison of one direct SMT backend with one independently selected
CNF-lowering and SAT-backend pipeline. -/
structure SmtCnfComparison (vars : VarSchema) where
  smtBackendName : String
  smtResult : Result vars
  smtMs : Float
  lowererName : String
  satBackendName : String
  cnf : CnfSolveReport vars
  agree : Bool

/-- Compare a checked direct SMT solve with any checked CNF/SAT composition. -/
def compareWithCnf
    [SmtBackend smtBackend] [SupportsLanguage smtBackend .bv]
    [CnfLowerer lowerer] [SatBackend satBackend]
    (smtBackend : smtBackend) (lowerer : lowerer) (satBackend : satBackend)
    (smt : Smt .bv Unit) (config : SolveConfig := {}) :
    IO (SmtCnfComparison smt.schema) := do
  let smtStart ← IO.monoNanosNow
  let smtResult ← runCheckedSmtBackend smtBackend smt config
  let smtEnd ← IO.monoNanosNow
  let cnf ← runCnfPipeline lowerer satBackend smt
  pure {
    smtBackendName := backendName smtBackend
    smtResult
    smtMs := (smtEnd - smtStart).toFloat / 1_000_000.0
    lowererName := SmtLibDsl.lowererName lowerer
    satBackendName := SmtLibDsl.satBackendName satBackend
    cnf
    agree := SmtLibDsl.sameSatStatus smtResult cnf.result
  }

end SmtLibDsl.SMT
