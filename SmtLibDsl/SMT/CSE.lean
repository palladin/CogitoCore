/-
  SmtLibDsl - collision-safe, type-indexed common-subexpression elimination
-/
import SmtLibDsl.SMT.Cmd
import Std.Data.DHashMap

namespace SmtLibDsl.SMT

namespace Compiler

/-- The operator portion of a canonical expression key. -/
inductive ExprOp where
  | var | btrue | bfalse
  | and | or | not | imp | boolEq | ite
  | bvLit
  | bvAdd | bvSub | bvMul | bvUDiv | bvSDiv | bvURem | bvSMod | bvSRem | bvNeg
  | bvAnd | bvOr | bvXor | bvNot | bvNand | bvNor | bvXnor
  | bvShl | bvLShr | bvAShr | rotateLeft | rotateRight
  | bvEq | bvULt | bvULe | bvUGt | bvUGe | bvSLt | bvSLe | bvSGt | bvSGe | bvComp
  | concat | extract | zeroExt | signExt | repeat
  | bvNegO | bvUAddO | bvSAddO | bvUMulO | bvSMulO
  | mkArray | select | store | arrEq
  | dtEq | distinctBV | dtSelect
deriving Repr, DecidableEq, Hashable

/-- A canonical, structurally comparable expression node.

Children are canonical node IDs, so this is a compact DAG key rather than a
second copy of the source expression language. Proof-only capability arguments
are intentionally absent. -/
structure ExprKey (lang : Language) where
  ty : Ty
  op : ExprOp
  naturals : List Nat := []
  strings : List String := []
  children : List Nat := []
deriving Repr, DecidableEq, Hashable

/-- A reference whose language and SMT sort are carried by its Lean type. -/
structure Ref (lang : Language) (ty : Ty) where
  id : Nat
deriving Repr, Inhabited

/-- The dependent expression memo requested by the compiler API.

`get? key` returns exactly `Ref lang key.ty`; it cannot return a reference of a
different sort. `Std.DHashMap` uses the hash to select a bucket and lawful
structural equality to select the entry inside that bucket. -/
abbrev ExpressionMemo (lang : Language) : Type :=
  Std.DHashMap (ExprKey lang) (fun key => Ref lang key.ty)

/-- Observable statistics for one CSE compilation. -/
structure CompileStats where
  occurrences : Nat
  uniqueNodes : Nat
  reusedOccurrences : Nat
  sharedNodes : Nat
  emittedDefinitions : Nat
deriving Repr, Inhabited

/-- Compiled command text together with CSE statistics. -/
structure CompiledCommands where
  text : String
  stats : CompileStats
deriving Repr, Inhabited

private structure InternState (lang : Language) where
  memo : ExpressionMemo lang := {}
  nodes : Array (ExprKey lang) := #[]
  uses : Array Nat := #[]
  occurrences : Nat := 0
deriving Inhabited

private def bumpUse (uses : Array Nat) (id : Nat) : Array Nat :=
  match uses[id]? with
  | some n => uses.set! id (n + 1)
  | none => uses

/-- Intern one canonical key and continue with its type-indexed reference. -/
private def internKeyK (key : ExprKey lang) (state : InternState lang)
    (k : Ref lang key.ty → InternState lang → α) : α :=
  match state.memo.get? key with
  | some ref =>
      k ref {
        state with
        uses := bumpUse state.uses ref.id
        occurrences := state.occurrences + 1
      }
  | none =>
      let ref : Ref lang key.ty := ⟨state.nodes.size⟩
      k ref {
        memo := state.memo.insert key ref
        nodes := state.nodes.push key
        uses := state.uses.push 1
        occurrences := state.occurrences + 1
      }

private partial def internExprK {ty : Ty} [Nonempty α] (expr : Expr lang ty)
    (state : InternState lang) (k : Ref lang ty → InternState lang → α) : α :=
  let finish (op : ExprOp) (state : InternState lang)
      (naturals : List Nat := []) (strings : List String := [])
      (children : List Nat := []) :=
    internKeyK { ty, op, naturals, strings, children } state k
  let unary {a : Ty} (op : ExprOp) (e : Expr lang a) (state : InternState lang)
      (naturals : List Nat := []) (strings : List String := []) :=
    internExprK e state fun er state =>
      finish op state naturals strings [er.id]
  let binary {a b : Ty} (op : ExprOp) (l : Expr lang a) (r : Expr lang b)
      (state : InternState lang) :=
    internExprK l state fun lr state =>
      internExprK r state fun rr state =>
        finish op state [] [] [lr.id, rr.id]
  match expr with
  | @ExprF.var _ name _ _ => finish .var state [] [name]
  | .btrue => finish .btrue state
  | .bfalse => finish .bfalse state
  | .and l r => binary .and l r state
  | .or l r => binary .or l r state
  | .not e => unary .not e state
  | .imp l r => binary .imp l r state
  | .boolEq l r => binary .boolEq l r state
  | .ite c t e =>
      internExprK c state fun cr state =>
        internExprK t state fun tr state =>
          internExprK e state fun er state =>
            finish .ite state [] [] [cr.id, tr.id, er.id]
  | @ExprF.bvLit _ value width _ => finish .bvLit state [value, width]
  | .bvAdd l r => binary .bvAdd l r state
  | .bvSub l r => binary .bvSub l r state
  | .bvMul l r => binary .bvMul l r state
  | .bvUDiv l r => binary .bvUDiv l r state
  | .bvSDiv l r => binary .bvSDiv l r state
  | .bvURem l r => binary .bvURem l r state
  | .bvSMod l r => binary .bvSMod l r state
  | .bvSRem l r => binary .bvSRem l r state
  | .bvNeg e => unary .bvNeg e state
  | .bvAnd l r => binary .bvAnd l r state
  | .bvOr l r => binary .bvOr l r state
  | .bvXor l r => binary .bvXor l r state
  | .bvNot e => unary .bvNot e state
  | .bvNand l r => binary .bvNand l r state
  | .bvNor l r => binary .bvNor l r state
  | .bvXnor l r => binary .bvXnor l r state
  | .bvShl l r => binary .bvShl l r state
  | .bvLShr l r => binary .bvLShr l r state
  | .bvAShr l r => binary .bvAShr l r state
  | .rotateLeft i e => unary .rotateLeft e state [i]
  | .rotateRight i e => unary .rotateRight e state [i]
  | .bvEq l r => binary .bvEq l r state
  | .bvULt l r => binary .bvULt l r state
  | .bvULe l r => binary .bvULe l r state
  | .bvUGt l r => binary .bvUGt l r state
  | .bvUGe l r => binary .bvUGe l r state
  | .bvSLt l r => binary .bvSLt l r state
  | .bvSLe l r => binary .bvSLe l r state
  | .bvSGt l r => binary .bvSGt l r state
  | .bvSGe l r => binary .bvSGe l r state
  | .bvComp l r => binary .bvComp l r state
  | .concat l r => binary .concat l r state
  | .extract hi lo e => unary .extract e state [hi, lo]
  | .zeroExt i e => unary .zeroExt e state [i]
  | .signExt i e => unary .signExt e state [i]
  | .repeat i e => unary .repeat e state [i]
  | .bvNegO e => unary .bvNegO e state
  | .bvUAddO l r => binary .bvUAddO l r state
  | .bvSAddO l r => binary .bvSAddO l r state
  | .bvUMulO l r => binary .bvUMulO l r state
  | .bvSMulO l r => binary .bvSMulO l r state
  | @ExprF.mkArray _ idxWidth _ value _ => unary .mkArray value state [idxWidth]
  | .select array index => binary .select array index state
  | .store array index value =>
      internExprK array state fun ar state =>
        internExprK index state fun ir state =>
          internExprK value state fun vr state =>
            finish .store state [] [] [ar.id, ir.id, vr.id]
  | .arrEq l r => binary .arrEq l r state
  | .dtEq l r => binary .dtEq l r state
  | @ExprF.distinctBV _ width names _ => finish .distinctBV state [width] names
  | .dtSelect field _ record => unary .dtSelect record state [] [field]

private def internExpr {ty : Ty} (expr : Expr lang ty) (state : InternState lang) :
    Ref lang ty × InternState lang :=
  internExprK expr state fun ref state => (ref, state)

private structure ProgramState (lang : Language) where
  intern : InternState lang := {}
  declarations : Array String := #[]
  declarationNames : Array String := #[]
  assertions : Array Nat := #[]

private partial def lowerCommands : Smt lang Unit → ProgramState lang → ProgramState lang
  | .pure (), state => state
  | .bind (@Cmd.declareConst _ name ty supported) f, state =>
      lowerCommands (f (@ExprF.var lang name ty supported)) {
        state with
        declarations := state.declarations.push s!"(declare-const {name} {ty})"
        declarationNames := state.declarationNames.push name
      }
  | .bind (@Cmd.declareDatatypeConstOf _ name decl supported) f, state =>
      letI : Language.HasDatatype lang := supported
      lowerCommands (f (.var name (Ty.datatype decl))) {
        state with
        declarations := state.declarations.push
          s!"(declare-const {name} {Ty.datatype decl})"
        declarationNames := state.declarationNames.push name
      }
  | .bind (.assert expr) f, state =>
      let (ref, intern) := internExpr expr state.intern
      lowerCommands (f ()) {
        state with
        intern
        assertions := state.assertions.push ref.id
      }

private def listGetD [Inhabited α] : List α → Nat → α
  | x :: _, 0 => x
  | _ :: xs, n + 1 => listGetD xs n
  | [], _ => default

private def isShareable : ExprOp → Bool
  | .var | .btrue | .bfalse | .bvLit => false
  | _ => true

private def isShared (state : InternState lang) (id : Nat) : Bool :=
  match state.nodes[id]?, state.uses[id]? with
  | some key, some uses => isShareable key.op && uses > 1
  | _, _ => false

private partial def freshName (sourceNames : Array String) (id : Nat) (salt : Nat := 0) :
    String :=
  let base := s!"__smtlibdsl_cse_{id}"
  let candidate := if salt == 0 then base else s!"{base}_{salt}"
  if sourceNames.contains candidate then freshName sourceNames id (salt + 1) else candidate

mutual

private partial def renderRef (state : InternState lang) (sourceNames : Array String)
    (id : Nat) : String :=
  if isShared state id then
    freshName sourceNames id
  else
    renderBody state sourceNames id

private partial def renderBody (state : InternState lang) (sourceNames : Array String)
    (id : Nat) : String :=
  match state.nodes[id]? with
  | none => s!"<invalid-cse-ref:{id}>"
  | some key =>
      let child (i : Nat) := renderRef state sourceNames (listGetD key.children i)
      let nat (i : Nat) := listGetD key.naturals i
      let str (i : Nat) := listGetD key.strings i
      match key.op with
      | .var => str 0
      | .btrue => "true"
      | .bfalse => "false"
      | .and => s!"(and {child 0} {child 1})"
      | .or => s!"(or {child 0} {child 1})"
      | .not => s!"(not {child 0})"
      | .imp => s!"(=> {child 0} {child 1})"
      | .boolEq => s!"(= {child 0} {child 1})"
      | .ite => s!"(ite {child 0} {child 1} {child 2})"
      | .bvLit => s!"(_ bv{nat 0} {nat 1})"
      | .bvAdd => s!"(bvadd {child 0} {child 1})"
      | .bvSub => s!"(bvsub {child 0} {child 1})"
      | .bvMul => s!"(bvmul {child 0} {child 1})"
      | .bvUDiv => s!"(bvudiv {child 0} {child 1})"
      | .bvSDiv => s!"(bvsdiv {child 0} {child 1})"
      | .bvURem => s!"(bvurem {child 0} {child 1})"
      | .bvSMod => s!"(bvsmod {child 0} {child 1})"
      | .bvSRem => s!"(bvsrem {child 0} {child 1})"
      | .bvNeg => s!"(bvneg {child 0})"
      | .bvAnd => s!"(bvand {child 0} {child 1})"
      | .bvOr => s!"(bvor {child 0} {child 1})"
      | .bvXor => s!"(bvxor {child 0} {child 1})"
      | .bvNot => s!"(bvnot {child 0})"
      | .bvNand => s!"(bvnand {child 0} {child 1})"
      | .bvNor => s!"(bvnor {child 0} {child 1})"
      | .bvXnor => s!"(bvxnor {child 0} {child 1})"
      | .bvShl => s!"(bvshl {child 0} {child 1})"
      | .bvLShr => s!"(bvlshr {child 0} {child 1})"
      | .bvAShr => s!"(bvashr {child 0} {child 1})"
      | .rotateLeft => s!"((_ rotate_left {nat 0}) {child 0})"
      | .rotateRight => s!"((_ rotate_right {nat 0}) {child 0})"
      | .bvEq => s!"(= {child 0} {child 1})"
      | .bvULt => s!"(bvult {child 0} {child 1})"
      | .bvULe => s!"(bvule {child 0} {child 1})"
      | .bvUGt => s!"(bvugt {child 0} {child 1})"
      | .bvUGe => s!"(bvuge {child 0} {child 1})"
      | .bvSLt => s!"(bvslt {child 0} {child 1})"
      | .bvSLe => s!"(bvsle {child 0} {child 1})"
      | .bvSGt => s!"(bvsgt {child 0} {child 1})"
      | .bvSGe => s!"(bvsge {child 0} {child 1})"
      | .bvComp => s!"(bvcomp {child 0} {child 1})"
      | .concat => s!"(concat {child 0} {child 1})"
      | .extract => s!"((_ extract {nat 0} {nat 1}) {child 0})"
      | .zeroExt => s!"((_ zero_extend {nat 0}) {child 0})"
      | .signExt => s!"((_ sign_extend {nat 0}) {child 0})"
      | .repeat => s!"((_ repeat {nat 0}) {child 0})"
      | .bvNegO => s!"(bvnego {child 0})"
      | .bvUAddO => s!"(bvuaddo {child 0} {child 1})"
      | .bvSAddO => s!"(bvsaddo {child 0} {child 1})"
      | .bvUMulO => s!"(bvumulo {child 0} {child 1})"
      | .bvSMulO => s!"(bvsmulo {child 0} {child 1})"
      | .mkArray =>
          match key.ty with
          | .array _ elem =>
              s!"((as const (Array (_ BitVec {nat 0}) {elem})) {child 0})"
          | _ => s!"<invalid-cse-array:{id}>"
      | .select => s!"(select {child 0} {child 1})"
      | .store => s!"(store {child 0} {child 1} {child 2})"
      | .arrEq => s!"(= {child 0} {child 1})"
      | .dtEq => s!"(= {child 0} {child 1})"
      | .distinctBV => s!"(distinct {String.intercalate " " key.strings})"
      | .dtSelect => s!"({str 0} {child 0})"

end

private def definition? (state : ProgramState lang) (id : Nat) : Option String :=
  if isShared state.intern id then
    match state.intern.nodes[id]? with
    | some key =>
        some s!"(define-fun {freshName state.declarationNames id} () {key.ty} \
          {renderBody state.intern state.declarationNames id})"
    | none => none
  else
    none

/-- Compile commands using collision-safe, type-indexed CSE. -/
def compileCommandsWithCSEReport (smt : Smt lang Unit) : CompiledCommands :=
  let state := lowerCommands smt {}
  let definitions := (List.range state.intern.nodes.size).filterMap (definition? state)
  let assertions := state.assertions.toList.map fun id =>
    s!"(assert {renderRef state.intern state.declarationNames id})"
  let lines := state.declarations.toList ++ definitions ++ assertions
  let unique := state.intern.nodes.size
  let shared := definitions.length
  {
    text := String.intercalate "\n" lines
    stats := {
      occurrences := state.intern.occurrences
      uniqueNodes := unique
      reusedOccurrences := state.intern.occurrences - unique
      sharedNodes := shared
      emittedDefinitions := shared
    }
  }

/-- Compile only the declaration/assertion body with CSE enabled. -/
def compileCommandsWithCSE (smt : Smt lang Unit) : String :=
  (compileCommandsWithCSEReport smt).text

end Compiler

end SmtLibDsl.SMT
