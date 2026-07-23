import Examples.ProgramSynthesis.Imp.Syntax

open SmtLibDsl.SMT

namespace ProgramSynthesis.Imp

def zeroBV : BV := bv 0 W

def lookupSym (env : Env BV) (name : String) : BV :=
  lookupEnvD env name zeroBV

def compileAExpr (env : Env BV) : AExpr -> BV
  | .var name => lookupSym env name
  | .const value => bv (normalize value) W
  | .add lhs rhs => compileAExpr env lhs +. compileAExpr env rhs
  | .sub lhs rhs => compileAExpr env lhs -. compileAExpr env rhs
  | .mul lhs rhs => compileAExpr env lhs *. compileAExpr env rhs

def compileBExpr (env : Env BV) : BExpr -> Expr .bv Ty.bool
  | .tt => Expr.btrue
  | .ff => Expr.bfalse
  | .eq lhs rhs => compileAExpr env lhs =. compileAExpr env rhs
  | .lt lhs rhs => compileAExpr env lhs <.ᵤ compileAExpr env rhs
  | .le lhs rhs => compileAExpr env lhs ≤.ᵤ compileAExpr env rhs
  | .not expr => ¬. (compileBExpr env expr)
  | .and lhs rhs => compileBExpr env lhs ∧. compileBExpr env rhs
  | .or lhs rhs => compileBExpr env lhs ∨. compileBExpr env rhs

def freshSsaName (name : String) (idx : Nat) : String :=
  s!"ssa_{name}_{idx}"

def freshGuardName (idx : Nat) : String :=
  s!"guard_{idx}"

def lookupName (env : Env String) (name : String) : String :=
  lookupEnvD env name name

private partial def mergeEnvSsa
    (vars : List String)
    (cond : Expr .bv Ty.bool)
    (thenEnv elseEnv : Env BV)
    (nextIdx : Nat) : Smt .bv (Env BV × Nat) :=
  go vars [] nextIdx
where
  go : List String -> Env BV -> Nat -> Smt .bv (Env BV × Nat)
    | [], acc, idx => pure (acc.reverse, idx)
    | name :: rest, acc, idx => do
      let merged ← declareBV (freshSsaName name idx) W
      assert (merged =. Expr.ite cond (lookupSym thenEnv name) (lookupSym elseEnv name))
      go rest ((name, merged) :: acc) (idx + 1)

partial def compileStmtSsa (vars : List String) (env : Env BV) (nextIdx : Nat) : Stmt -> Smt .bv (Env BV × Nat)
  | .skip => pure (env, nextIdx)
  | .assign name expr => do
    let rhs := compileAExpr env expr
    let assigned ← declareBV (freshSsaName name nextIdx) W
    assert (assigned =. rhs)
    pure (updateEnv env name assigned, nextIdx + 1)
  | .seq first second => do
    let (env', nextIdx') ← compileStmtSsa vars env nextIdx first
    compileStmtSsa vars env' nextIdx' second
  | .ite cond thenBranch elseBranch => do
    let guardExpr := compileBExpr env cond
    let guard ← declareBool (freshGuardName nextIdx)
    assert (guard =. guardExpr)
    let (thenEnv, nextThen) ← compileStmtSsa vars env (nextIdx + 1) thenBranch
    let (elseEnv, nextElse) ← compileStmtSsa vars env nextThen elseBranch
    mergeEnvSsa vars guard thenEnv elseEnv nextElse

private def mergeFinalNames
    (vars : List String)
  (_thenEnv _elseEnv : Env String)
    (nextIdx : Nat) : Env String × Nat :=
  go vars [] nextIdx
where
  go : List String -> Env String -> Nat -> Env String × Nat
    | [], acc, idx => (acc.reverse, idx)
    | name :: rest, acc, idx =>
      let merged := freshSsaName name idx
      go rest ((name, merged) :: acc) (idx + 1)

partial def finalSsaEnv (vars : List String) (env : Env String) (nextIdx : Nat) : Stmt -> Env String × Nat
  | .skip => (env, nextIdx)
  | .assign name _ =>
    let assigned := freshSsaName name nextIdx
    (updateEnv env name assigned, nextIdx + 1)
  | .seq first second =>
    let (env', nextIdx') := finalSsaEnv vars env nextIdx first
    finalSsaEnv vars env' nextIdx' second
  | .ite _ thenBranch elseBranch =>
    let (thenEnv, nextThen) := finalSsaEnv vars env (nextIdx + 1) thenBranch
    let (elseEnv, nextElse) := finalSsaEnv vars env nextThen elseBranch
    mergeFinalNames vars thenEnv elseEnv nextElse

def compiledProgram (program : Stmt) : Smt .bv Unit := do
  let vars := varsStmt program
  let mut env : Env BV := []
  for name in vars do
    let inputVar <- declareBV name W
    assert (inputVar =. zeroBV)
    env := env ++ [(name, inputVar)]

  let _ ← compileStmtSsa vars env 0 program
  pure ()

def extractValue (model : Model schema) (name : String) : String :=
  match model.lookup name with
  | .ok raw =>
    match parseBitVec raw W with
    | some value => toString value.toNat
    | none => raw
  | .error err => s!"error: {err}"

def extractNat (model : Model schema) (name : String) : Except String Nat :=
  match model.lookup name with
  | .ok raw =>
    match parseBitVec raw W with
    | some value => .ok value.toNat
    | none => .error s!"expected bitvector value for {name}, got '{raw}'"
  | .error err => .error s!"failed to lookup {name}: {err}"

def envFromModel (namePrefix : String) (vars : List String) (model : Model schema) : Except String (Env Value) :=
  go vars []
where
  go : List String -> Env Value -> Except String (Env Value)
    | [], acc => .ok acc.reverse
    | name :: rest, acc => do
      let value <- extractNat model s!"{namePrefix}{name}"
      go rest ((name, value) :: acc)

def envFromBindings (bindings : Env String) (model : Model schema) : Except String (Env Value) :=
  go bindings []
where
  go : Env String -> Env Value -> Except String (Env Value)
    | [], acc => .ok acc.reverse
    | (name, symbol) :: rest, acc => do
      let value <- extractNat model symbol
      go rest ((name, value) :: acc)

def validateEnvEquality (vars : List String) (actual expected : Env Value) : Except String Unit :=
  go vars
where
  go : List String -> Except String Unit
    | [] => .ok ()
    | name :: rest =>
      let actualValue := lookupEnvD actual name 0
      let expectedValue := lookupEnvD expected name 0
      if actualValue == expectedValue then
        go rest
      else
        .error s!"mismatch for {name}: solver produced {actualValue}, interpreter produced {expectedValue}"

def showBindings (bindings : Env String) (model : Model schema) : String :=
  String.intercalate ", " <|
    bindings.map fun (name, symbol) => s!"{name}<-{symbol}={extractValue model symbol}"

end ProgramSynthesis.Imp
