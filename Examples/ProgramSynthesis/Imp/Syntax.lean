import SmtLibDsl

namespace ProgramSynthesis.Imp

open SmtLibDsl.SMT

def W : Nat := 8

abbrev BV := Expr .bv (Ty.bitVec W)
abbrev Value := Nat
abbrev Env (alpha : Type) := List (String × alpha)

def modulus : Nat := 2 ^ W

def normalize (n : Nat) : Nat := n % modulus

def lookupEnvD (env : Env alpha) (name : String) (fallback : alpha) : alpha :=
  match env with
  | [] => fallback
  | (key, value) :: rest =>
    if key == name then value else lookupEnvD rest name fallback

def updateEnv (env : Env alpha) (name : String) (value : alpha) : Env alpha :=
  match env with
  | [] => [(name, value)]
  | (key, current) :: rest =>
    if key == name then
      (name, value) :: rest
    else
      (key, current) :: updateEnv rest name value

def addName (names : List String) (name : String) : List String :=
  if name ∈ names then names else names ++ [name]

inductive AExpr where
  | var (name : String)
  | const (value : Nat)
  | add (lhs rhs : AExpr)
  | sub (lhs rhs : AExpr)
  | mul (lhs rhs : AExpr)
deriving Repr, BEq, DecidableEq, Inhabited

inductive BExpr where
  | tt
  | ff
  | eq (lhs rhs : AExpr)
  | lt (lhs rhs : AExpr)
  | le (lhs rhs : AExpr)
  | not (expr : BExpr)
  | and (lhs rhs : BExpr)
  | or (lhs rhs : BExpr)
deriving Repr, BEq, DecidableEq, Inhabited

inductive Stmt where
  | skip
  | assign (name : String) (expr : AExpr)
  | seq (first second : Stmt)
  | ite (cond : BExpr) (thenBranch elseBranch : Stmt)
deriving Repr, BEq, DecidableEq, Inhabited

mutual

private def aExprToString : AExpr -> String
  | .var name => name
  | .const value => toString value
  | .add lhs rhs => "(" ++ aExprToString lhs ++ " + " ++ aExprToString rhs ++ ")"
  | .sub lhs rhs => "(" ++ aExprToString lhs ++ " - " ++ aExprToString rhs ++ ")"
  | .mul lhs rhs => "(" ++ aExprToString lhs ++ " * " ++ aExprToString rhs ++ ")"

private def bExprToString : BExpr -> String
  | .tt => "true"
  | .ff => "false"
  | .eq lhs rhs => "(" ++ aExprToString lhs ++ " = " ++ aExprToString rhs ++ ")"
  | .lt lhs rhs => "(" ++ aExprToString lhs ++ " < " ++ aExprToString rhs ++ ")"
  | .le lhs rhs => "(" ++ aExprToString lhs ++ " <= " ++ aExprToString rhs ++ ")"
  | .not expr => "(not " ++ bExprToString expr ++ ")"
  | .and lhs rhs => "(" ++ bExprToString lhs ++ " and " ++ bExprToString rhs ++ ")"
  | .or lhs rhs => "(" ++ bExprToString lhs ++ " or " ++ bExprToString rhs ++ ")"

private def stmtToString : Stmt -> String
  | .skip => "skip"
  | .assign name expr => name ++ " := " ++ aExprToString expr
  | .seq first second => stmtToString first ++ "; " ++ stmtToString second
  | .ite cond thenBranch elseBranch =>
    "if " ++ bExprToString cond ++ " then { " ++ stmtToString thenBranch ++
      " } else { " ++ stmtToString elseBranch ++ " }"

end

instance : ToString AExpr where
  toString := aExprToString

instance : ToString BExpr where
  toString := bExprToString

instance : ToString Stmt where
  toString := stmtToString

def varsAExpr : AExpr -> List String
  | .var name => [name]
  | .const _ => []
  | .add lhs rhs => (varsAExpr lhs).foldl addName (varsAExpr rhs)
  | .sub lhs rhs => (varsAExpr lhs).foldl addName (varsAExpr rhs)
  | .mul lhs rhs => (varsAExpr lhs).foldl addName (varsAExpr rhs)

def varsBExpr : BExpr -> List String
  | .tt | .ff => []
  | .eq lhs rhs => (varsAExpr lhs).foldl addName (varsAExpr rhs)
  | .lt lhs rhs => (varsAExpr lhs).foldl addName (varsAExpr rhs)
  | .le lhs rhs => (varsAExpr lhs).foldl addName (varsAExpr rhs)
  | .not expr => varsBExpr expr
  | .and lhs rhs => (varsBExpr lhs).foldl addName (varsBExpr rhs)
  | .or lhs rhs => (varsBExpr lhs).foldl addName (varsBExpr rhs)

def varsStmt : Stmt -> List String
  | .skip => []
  | .assign name expr => addName (varsAExpr expr) name
  | .seq first second => (varsStmt first).foldl addName (varsStmt second)
  | .ite cond thenBranch elseBranch =>
    let withCond := (varsStmt thenBranch).foldl addName (varsStmt elseBranch)
    (varsBExpr cond).foldl addName withCond

def evalAExpr (env : Env Value) : AExpr -> Value
  | .var name => normalize (lookupEnvD env name 0)
  | .const value => normalize value
  | .add lhs rhs => normalize (evalAExpr env lhs + evalAExpr env rhs)
  | .sub lhs rhs => normalize (evalAExpr env lhs + modulus - evalAExpr env rhs)
  | .mul lhs rhs => normalize (evalAExpr env lhs * evalAExpr env rhs)

def evalBExpr (env : Env Value) : BExpr -> Bool
  | .tt => true
  | .ff => false
  | .eq lhs rhs => evalAExpr env lhs == evalAExpr env rhs
  | .lt lhs rhs => evalAExpr env lhs < evalAExpr env rhs
  | .le lhs rhs => evalAExpr env lhs <= evalAExpr env rhs
  | .not expr => !(evalBExpr env expr)
  | .and lhs rhs => evalBExpr env lhs && evalBExpr env rhs
  | .or lhs rhs => evalBExpr env lhs || evalBExpr env rhs

def evalStmt (env : Env Value) : Stmt -> Env Value
  | .skip => env
  | .assign name expr => updateEnv env name (evalAExpr env expr)
  | .seq first second =>
    let env' := evalStmt env first
    evalStmt env' second
  | .ite cond thenBranch elseBranch =>
    if evalBExpr env cond then evalStmt env thenBranch else evalStmt env elseBranch

def showEnv (vars : List String) (env : Env Value) : String :=
  String.intercalate ", " <| vars.map (fun name => s!"{name}={lookupEnvD env name 0}")

end ProgramSynthesis.Imp
