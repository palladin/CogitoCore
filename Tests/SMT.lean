/-
  SmtLibDsl - SMT DSL Tests
  Unit tests for the BitVector SMT-LIB DSL
-/
import LSpec
import SmtLibDsl.SMT
import Examples.ProgramSynthesis.Imp.Syntax
import Examples.ProgramSynthesis.Imp.Parser
import Examples.ProgramSynthesis.Imp.Compiler

open SmtLibDsl
open SmtLibDsl.SMT
open LSpec
open ProgramSynthesis.Imp

private def compileTestExpr (e : Expr .all ty) : String :=
  compileExpr e

-- Test compileExpr for various expression types
def compileExprTests : TestSeq :=
  group "compileExpr" $
    -- Literals
    test "btrue" (compileTestExpr Expr.btrue = "true") $
    test "bfalse" (compileTestExpr Expr.bfalse = "false") $
    test "bvLit" (compileTestExpr (bv 42 8) = "(_ bv42 8)") $
    test "bvLit 16-bit" (compileTestExpr (bv 255 16) = "(_ bv255 16)") $
    -- Variables
    test "var bool" (compileTestExpr (Expr.var "x" Ty.bool) = "x") $
    test "var bv8" (compileTestExpr (Expr.var "y" (Ty.bitVec 8)) = "y") $
    -- Boolean operations
    test "and" (compileTestExpr (Expr.and Expr.btrue Expr.bfalse) = "(and true false)") $
    test "or" (compileTestExpr (Expr.or Expr.btrue Expr.bfalse) = "(or true false)") $
    test "not" (compileTestExpr (Expr.not Expr.btrue) = "(not true)") $
    test "bool equality" (compileTestExpr (Expr.btrue =. Expr.bfalse) = "(= true false)") $
    test "imp" (compileTestExpr (Expr.imp Expr.btrue Expr.bfalse) = "(=> true false)") $
    -- BitVector arithmetic
    test "bvAdd" (compileTestExpr (Expr.bvAdd (bv 1 8) (bv 2 8)) = "(bvadd (_ bv1 8) (_ bv2 8))") $
    test "bvSub" (compileTestExpr (Expr.bvSub (bv 5 8) (bv 3 8)) = "(bvsub (_ bv5 8) (_ bv3 8))") $
    test "bvMul" (compileTestExpr (Expr.bvMul (bv 2 8) (bv 3 8)) = "(bvmul (_ bv2 8) (_ bv3 8))") $
    test "bvNeg" (compileTestExpr (Expr.bvNeg (bv 5 8)) = "(bvneg (_ bv5 8))") $
    test "bvUDiv" (compileTestExpr (Expr.bvUDiv (bv 10 8) (bv 2 8)) = "(bvudiv (_ bv10 8) (_ bv2 8))") $
    test "bvSDiv" (compileTestExpr (Expr.bvSDiv (bv 10 8) (bv 2 8)) = "(bvsdiv (_ bv10 8) (_ bv2 8))") $
    test "bvURem" (compileTestExpr (Expr.bvURem (bv 10 8) (bv 3 8)) = "(bvurem (_ bv10 8) (_ bv3 8))") $
    test "bvSMod" (compileTestExpr (Expr.bvSMod (bv 10 8) (bv 3 8)) = "(bvsmod (_ bv10 8) (_ bv3 8))") $
    test "bvSRem" (compileTestExpr (Expr.bvSRem (bv 10 8) (bv 3 8)) = "(bvsrem (_ bv10 8) (_ bv3 8))") $
    -- Bitwise operations
    test "bvAnd" (compileTestExpr (Expr.bvAnd (bv 0xFF 8) (bv 0x0F 8)) = "(bvand (_ bv255 8) (_ bv15 8))") $
    test "bvOr" (compileTestExpr (Expr.bvOr (bv 0xF0 8) (bv 0x0F 8)) = "(bvor (_ bv240 8) (_ bv15 8))") $
    test "bvXor" (compileTestExpr (Expr.bvXor (bv 0xFF 8) (bv 0x0F 8)) = "(bvxor (_ bv255 8) (_ bv15 8))") $
    test "bvNot" (compileTestExpr (Expr.bvNot (bv 0 8)) = "(bvnot (_ bv0 8))") $
    test "bvNand" (compileTestExpr (Expr.bvNand (bv 1 8) (bv 2 8)) = "(bvnand (_ bv1 8) (_ bv2 8))") $
    test "bvNor" (compileTestExpr (Expr.bvNor (bv 1 8) (bv 2 8)) = "(bvnor (_ bv1 8) (_ bv2 8))") $
    test "bvXnor" (compileTestExpr (Expr.bvXnor (bv 1 8) (bv 2 8)) = "(bvxnor (_ bv1 8) (_ bv2 8))") $
    -- Shifts
    test "bvShl" (compileTestExpr (Expr.bvShl (bv 1 8) (bv 2 8)) = "(bvshl (_ bv1 8) (_ bv2 8))") $
    test "bvLShr" (compileTestExpr (Expr.bvLShr (bv 8 8) (bv 2 8)) = "(bvlshr (_ bv8 8) (_ bv2 8))") $
    test "bvAShr" (compileTestExpr (Expr.bvAShr (bv 8 8) (bv 2 8)) = "(bvashr (_ bv8 8) (_ bv2 8))") $
    test "rotateLeft" (compileTestExpr (Expr.rotateLeft 2 (bv 1 8)) = "((_ rotate_left 2) (_ bv1 8))") $
    test "rotateRight" (compileTestExpr (Expr.rotateRight 2 (bv 1 8)) = "((_ rotate_right 2) (_ bv1 8))") $
    -- Comparisons
    test "bvEq" (compileTestExpr (Expr.bvEq (bv 5 8) (bv 5 8)) = "(= (_ bv5 8) (_ bv5 8))") $
    test "bvULt" (compileTestExpr (Expr.bvULt (bv 1 8) (bv 2 8)) = "(bvult (_ bv1 8) (_ bv2 8))") $
    test "bvULe" (compileTestExpr (Expr.bvULe (bv 1 8) (bv 2 8)) = "(bvule (_ bv1 8) (_ bv2 8))") $
    test "bvUGt" (compileTestExpr (Expr.bvUGt (bv 2 8) (bv 1 8)) = "(bvugt (_ bv2 8) (_ bv1 8))") $
    test "bvUGe" (compileTestExpr (Expr.bvUGe (bv 2 8) (bv 1 8)) = "(bvuge (_ bv2 8) (_ bv1 8))") $
    test "bvSLt" (compileTestExpr (Expr.bvSLt (bv 1 8) (bv 2 8)) = "(bvslt (_ bv1 8) (_ bv2 8))") $
    test "bvSLe" (compileTestExpr (Expr.bvSLe (bv 1 8) (bv 2 8)) = "(bvsle (_ bv1 8) (_ bv2 8))") $
    test "bvSGt" (compileTestExpr (Expr.bvSGt (bv 2 8) (bv 1 8)) = "(bvsgt (_ bv2 8) (_ bv1 8))") $
    test "bvSGe" (compileTestExpr (Expr.bvSGe (bv 2 8) (bv 1 8)) = "(bvsge (_ bv2 8) (_ bv1 8))") $
    test "bvComp" (compileTestExpr (Expr.bvComp (bv 5 8) (bv 5 8)) = "(bvcomp (_ bv5 8) (_ bv5 8))") $
    -- Width-changing
    test "concat" (compileTestExpr (Expr.concat (bv 1 4) (bv 2 4)) = "(concat (_ bv1 4) (_ bv2 4))") $
    test "extract" (compileTestExpr (Expr.extract 7 4 (bv 255 8)) = "((_ extract 7 4) (_ bv255 8))") $
    test "zeroExt" (compileTestExpr (Expr.zeroExt 8 (bv 255 8)) = "((_ zero_extend 8) (_ bv255 8))") $
    test "signExt" (compileTestExpr (Expr.signExt 8 (bv 255 8)) = "((_ sign_extend 8) (_ bv255 8))") $
    test "repeat" (compileTestExpr (Expr.repeat 4 (bv 1 8)) = "((_ repeat 4) (_ bv1 8))") $
    -- Overflow predicates
    test "bvNegO" (compileTestExpr (Expr.bvNegO (bv 128 8)) = "(bvnego (_ bv128 8))") $
    test "bvUAddO" (compileTestExpr (Expr.bvUAddO (bv 200 8) (bv 100 8)) = "(bvuaddo (_ bv200 8) (_ bv100 8))") $
    test "bvSAddO" (compileTestExpr (Expr.bvSAddO (bv 100 8) (bv 100 8)) = "(bvsaddo (_ bv100 8) (_ bv100 8))") $
    test "bvUMulO" (compileTestExpr (Expr.bvUMulO (bv 20 8) (bv 20 8)) = "(bvumulo (_ bv20 8) (_ bv20 8))") $
    test "bvSMulO" (compileTestExpr (Expr.bvSMulO (bv 20 8) (bv 20 8)) = "(bvsmulo (_ bv20 8) (_ bv20 8))") $
    -- Distinct constraint
    test "distinctBV" (compileTestExpr (Expr.distinctBV 8 ["x", "y", "z"]) = "(distinct x y z)") $
    -- Datatype selectors
    test "datatype selector safe" (
      let point : DatatypeDecl := {
        name := "Point"
        constructor := "mkPoint"
        fields := [
          { name := "x", ty := Ty.bitVec 8 },
          { name := "y", ty := Ty.bitVec 8 }
        ]
      }
      let p : Expr .all (Ty.datatype point) := Expr.var "p" (Ty.datatype point)
      let xField : DatatypeFieldRef point :=
        point.fieldByName "x" (by simp [point, DatatypeDecl.fieldNames])
      compileTestExpr (selectField xField p) = "(x p)"
    ) $
    test "nested const array" (
      let inner : Expr .all (Ty.array 4 (Ty.bitVec 8)) := constArray 4 (Ty.bitVec 8) (bv 0 8)
      let outer : Expr .all (Ty.array 8 (Ty.array 4 (Ty.bitVec 8))) := constArray 8 (Ty.array 4 (Ty.bitVec 8)) inner
      compileTestExpr outer =
        "((as const (Array (_ BitVec 8) (Array (_ BitVec 4) (_ BitVec 8)))) ((as const (Array (_ BitVec 4) (_ BitVec 8))) (_ bv0 8)))"
    )

-- Test Ty ToString
def tyTests : TestSeq :=
  group "Ty.toString" $
    test "bool" (toString Ty.bool = "Bool") $
    test "bitVec 8" (toString (Ty.bitVec 8) = "(_ BitVec 8)") $
    test "bitVec 32" (toString (Ty.bitVec 32) = "(_ BitVec 32)") $
    test "datatype" (
      let point : DatatypeDecl := {
        name := "Point"
        constructor := "mkPoint"
        fields := [
          { name := "x", ty := Ty.bitVec 8 },
          { name := "y", ty := Ty.bitVec 8 }
        ]
      }
      toString (Ty.datatype point) = "Point"
    ) $
    test "fieldByName (static)" (
      let point : DatatypeDecl := {
        name := "Point"
        constructor := "mkPoint"
        fields := [
          { name := "x", ty := Ty.bitVec 8 },
          { name := "y", ty := Ty.bitVec 8 }
        ]
      }
      let xField := point.fieldByName "x" (by simp [point, DatatypeDecl.fieldNames])
      xField.field.name == "x"
    ) $
    test "array of array" (toString (Ty.array 8 (Ty.array 4 (Ty.bitVec 8))) = "(Array (_ BitVec 8) (Array (_ BitVec 4) (_ BitVec 8)))") $
    test "parse array value as typed array" (
      let raw := "((as const (Array (_ BitVec 8) (_ BitVec 8))) #x00)"
      let parsed := Ty.parseArray? 8 (Ty.bitVec 8) raw
      (parsed.map (fun v => Ty.showValue (Ty.array 8 (Ty.bitVec 8)) v == "const(0)")).getD false
    ) $
    test "parse datatype value as recursive tree" (
      let raw := "(mkPoint #x03 #x04)"
      let point : DatatypeDecl := {
        name := "Point"
        constructor := "mkPoint"
        fields := [
          { name := "x", ty := Ty.bitVec 8 },
          { name := "y", ty := Ty.bitVec 8 }
        ]
      }
      let parsed : Option (DatatypeValueOf point) := Ty.parse (Ty.datatype point) raw
      parsed.isSome
    ) $
    test "parse datatype value and extract typed field" (
      let point : DatatypeDecl := {
        name := "Point"
        constructor := "mkPoint"
        fields := [
          { name := "x", ty := Ty.bitVec 8 },
          { name := "y", ty := Ty.bitVec 8 }
        ]
      }
      let xField : DatatypeFieldRef point :=
        point.fieldByName "x" (by simp [point, DatatypeDecl.fieldNames])
      let parsed := point.parseValue "(mkPoint #x03 #x04)"
      let ok : Bool :=
        match parsed with
        | some p =>
          match p.getField xField with
          | .ok x => x.toNat == 3
          | .error _ => false
        | none => false
      ok
    ) $
    test "datatype pretty print shows constructor and fields" (
      let point : DatatypeDecl := {
        name := "Point"
        constructor := "mkPoint"
        fields := [
          { name := "x", ty := Ty.bitVec 8 },
          { name := "y", ty := Ty.bitVec 8 }
        ]
      }
      let parsed : Option (DatatypeValueOf point) := Ty.parse (Ty.datatype point) "(mkPoint #x03 #x04)"
      let ok : Bool :=
        match parsed with
        | some v => toString v == "mkPoint{x: 3, y: 4}"
        | none => false
      ok
    ) $
    test "parse nested datatype and extract nested typed field" (
      let inner : DatatypeDecl := {
        name := "Inner"
        constructor := "mkInner"
        fields := [
          { name := "x", ty := Ty.bitVec 8 },
          { name := "y", ty := Ty.bitVec 8 }
        ]
      }
      let outer : DatatypeDecl := {
        name := "Outer"
        constructor := "mkOuter"
        fields := [
          { name := "inner", ty := Ty.datatype inner },
          { name := "tag", ty := Ty.bitVec 8 }
        ]
      }
      let outerInnerField : DatatypeFieldRef outer :=
        outer.fieldByName "inner" (by simp [outer, inner, DatatypeDecl.fieldNames])
      let innerXField : DatatypeFieldRef inner :=
        inner.fieldByName "x" (by simp [inner, DatatypeDecl.fieldNames])
      let parsed := outer.parseValue "(mkOuter (mkInner #x03 #x04) #x09)"
      let ok : Bool :=
        match parsed with
        | some outerVal =>
          match outerVal.getField outerInnerField with
          | .ok innerVal =>
            match innerVal.getField innerXField with
            | .ok x => x.toNat == 3
            | .error _ => false
          | .error _ => false
        | none => false
      ok
    )

-- Test compileCmd
def compileCmdTests : TestSeq :=
  group "compileCmd" $
    test "declareConst" (
      (compileCmd (Cmd.declareConst "x" (Ty.bitVec 8) : Cmd .bv _)).2 =
        "(declare-const x (_ BitVec 8))")

-- Test full program compilation
def compileTests : TestSeq :=
  group "compile" $
    test "Boolean-only language" (
      let prog : Smt .bool Unit := do
        let flag ← declareBool "flag"
        assert flag
      compile prog = "(set-logic QF_UF)\n(declare-const flag Bool)\n(assert flag)\n(check-sat)\n(get-model)"
    ) $
    test "simple program" (
      let prog : Smt .bv Unit := do
        let x ← declareBV "x" 8
        assert (x =. bv 5 8)
      compile prog = "(set-logic QF_BV)\n(declare-const x (_ BitVec 8))\n(assert (= x (_ bv5 8)))\n(check-sat)\n(get-model)"
    ) $
    test "datatype program safe" (
      let point : DatatypeDecl := {
        name := "Point"
        constructor := "mkPoint"
        fields := [
          { name := "x", ty := Ty.bitVec 8 },
          { name := "y", ty := Ty.bitVec 8 }
        ]
      }
      let xField : DatatypeFieldRef point :=
        point.fieldByName "x" (by simp [point, DatatypeDecl.fieldNames])
      let prog : Smt .all Unit := do
        let p ← declareDatatypeConstOf "p" point
        assert (selectField xField p =. bv 3 8)
      compile prog = "(set-logic ALL)\n(declare-datatype Point ((mkPoint (x (_ BitVec 8)) (y (_ BitVec 8)))))\n(declare-const p Point)\n(assert (= (x p) (_ bv3 8)))\n(check-sat)\n(get-model)"
    ) $
    test "datatype program safe explicit declaration" (
      let point : DatatypeDecl := {
        name := "Point"
        constructor := "mkPoint"
        fields := [
          { name := "x", ty := Ty.bitVec 8 },
          { name := "y", ty := Ty.bitVec 8 }
        ]
      }
      let xField : DatatypeFieldRef point :=
        point.fieldByName "x" (by simp [point, DatatypeDecl.fieldNames])
      let prog : Smt .all Unit := do
        let p ← declareDatatypeConstOf "p" point
        assert (selectField xField p =. bv 3 8)
      compile prog = "(set-logic ALL)\n(declare-datatype Point ((mkPoint (x (_ BitVec 8)) (y (_ BitVec 8)))))\n(declare-const p Point)\n(assert (= (x p) (_ bv3 8)))\n(check-sat)\n(get-model)"
    ) $
    test "datatype program safe implicit declaration" (
      let point : DatatypeDecl := {
        name := "Point"
        constructor := "mkPoint"
        fields := [
          { name := "x", ty := Ty.bitVec 8 },
          { name := "y", ty := Ty.bitVec 8 }
        ]
      }
      let xField : DatatypeFieldRef point :=
        point.fieldByName "x" (by simp [point, DatatypeDecl.fieldNames])
      let prog : Smt .all Unit := do
        let p ← declareDatatypeConstOf "p" point
        assert (selectField xField p =. bv 3 8)
      compile prog = "(set-logic ALL)\n(declare-datatype Point ((mkPoint (x (_ BitVec 8)) (y (_ BitVec 8)))))\n(declare-const p Point)\n(assert (= (x p) (_ bv3 8)))\n(check-sat)\n(get-model)"
    ) $
    test "nested datatype program safe" (
      let inner : DatatypeDecl := {
        name := "Inner"
        constructor := "mkInner"
        fields := [
          { name := "x", ty := Ty.bitVec 8 },
          { name := "y", ty := Ty.bitVec 8 }
        ]
      }
      let outer : DatatypeDecl := {
        name := "Outer"
        constructor := "mkOuter"
        fields := [
          { name := "inner", ty := Ty.datatype inner },
          { name := "tag", ty := Ty.bitVec 8 }
        ]
      }
      let outerInnerField : DatatypeFieldRef outer :=
        outer.fieldByName "inner" (by simp [outer, inner, DatatypeDecl.fieldNames])
      let innerXField : DatatypeFieldRef inner :=
        inner.fieldByName "x" (by simp [inner, DatatypeDecl.fieldNames])
      let prog : Smt .all Unit := do
        let o ← declareDatatypeConstOf "o" outer
        let i := selectField outerInnerField o
        assert (selectField innerXField i =. bv 5 8)
      compile prog = "(set-logic ALL)\n(declare-datatype Inner ((mkInner (x (_ BitVec 8)) (y (_ BitVec 8)))))\n(declare-datatype Outer ((mkOuter (inner Inner) (tag (_ BitVec 8)))))\n(declare-const o Outer)\n(assert (= (x (inner o)) (_ bv5 8)))\n(check-sat)\n(get-model)"
    ) $
    test "nested array program" (
      let prog : Smt .abv Unit := do
        let a ← declareArray "a" 8 (Ty.array 4 (Ty.bitVec 8))
        let i ← declareBV "i" 8
        let j ← declareBV "j" 4
        let row := selectArr a i
        let cell := selectArr row j
        assert (cell =. bv 3 8)
      compile prog = "(set-logic QF_ABV)\n(declare-const a (Array (_ BitVec 8) (Array (_ BitVec 4) (_ BitVec 8))))\n(declare-const i (_ BitVec 8))\n(declare-const j (_ BitVec 4))\n(assert (= (select (select a i) j) (_ bv3 8)))\n(check-sat)\n(get-model)"
    )

def cnfMappingFixtureOk : Bool :=
  let vars : VarSchema := [("flag", Ty.bool), ("x", Ty.bitVec 2)]
  let output :=
    "(goals (goal __smtlibdsl_bool_0 __smtlibdsl_bit_1_0 (not __smtlibdsl_bit_1_1) :precision precise :depth 3))"
  match parseZ3CnfOutput vars output with
  | .error _ => false
  | .ok bridge =>
    bridge.modelBits.toList == [
      {
        source := .bool 0 "flag"
        proxy := "__smtlibdsl_bool_0"
        dimacsVar := 1
      },
      {
        source := .bit 1 "x" 2 0
        proxy := "__smtlibdsl_bit_1_0"
        dimacsVar := 2
      },
      {
        source := .bit 1 "x" 2 1
        proxy := "__smtlibdsl_bit_1_1"
        dimacsVar := 3
      }
    ] &&
    bridge.numVars == 3 &&
    bridge.numClauses == 3 &&
    (bridge.dimacs.splitOn "p cnf 3 3").length == 2

def checkedModelProgram : Smt .bv Unit := do
  let x ← declareBV "checked_x" 4
  let flag ← declareBool "checked_flag"
  assert (x =. bv 5 4)
  assert flag

def leanModelCheckerOk : Bool :=
  let good : Model checkedModelProgram.schema :=
    ⟨[("checked_x", "5"), ("checked_flag", "true")]⟩
  let bad : Model checkedModelProgram.schema :=
    ⟨[("checked_x", "4"), ("checked_flag", "true")]⟩
  let goodAccepted :=
    match checkBvModel checkedModelProgram good with
    | .ok () => true
    | .error _ => false
  let badRejected :=
    match checkBvModel checkedModelProgram bad with
    | .ok () => false
    | .error _ => true
  goodAccepted && badRejected

def cseProgram : Smt .bv Unit := do
  let x ← declareBV "cse_x" 8
  let shared : Expr .bv (Ty.bitVec 8) := x +. (bv 1 8 : Expr .bv (Ty.bitVec 8))
  assert (shared =. bv 2 8)
  assert (shared =. bv 3 8)

def cseSharingOk : Bool :=
  let report := Compiler.compileCommandsWithCSEReport cseProgram
  report.stats.occurrences == 10 &&
    report.stats.uniqueNodes == 7 &&
    report.stats.reusedOccurrences == 3 &&
    report.stats.sharedNodes == 1 &&
    report.text.contains "(define-fun __smtlibdsl_cse_2 () (_ BitVec 8) (bvadd cse_x (_ bv1 8)))" &&
    report.text.contains "(assert (= __smtlibdsl_cse_2 (_ bv2 8)))" &&
    report.text.contains "(assert (= __smtlibdsl_cse_2 (_ bv3 8)))"

/-- Force every expression key into one hash bucket and verify that structural
equality, rather than the fingerprint alone, selects the dependent value. -/
def cseHashCollisionOk : Bool :=
  letI : Hashable (Compiler.ExprKey .bv) := ⟨fun _ => 0⟩
  let lhs : Compiler.ExprKey .bv := {
    ty := .bool
    op := .and
    children := [1, 2]
  }
  let rhs : Compiler.ExprKey .bv := {
    ty := .bool
    op := .or
    children := [1, 2]
  }
  let memo : Compiler.ExpressionMemo .bv := {}
  let memo := memo.insert lhs (⟨11⟩ : Compiler.Ref .bv lhs.ty)
  let memo := memo.insert rhs (⟨22⟩ : Compiler.Ref .bv rhs.ty)
  match memo.get? lhs, memo.get? rhs with
  | some l, some r => l.id == 11 && r.id == 22
  | _, _ => false

def cseTests : TestSeq :=
  group "type-indexed CSE" $
    test "shares repeated expressions once" (cseSharingOk = true) $
    test "hash collisions still use structural equality" (cseHashCollisionOk = true)

/-- A capability-polymorphic BV fragment composes in both `.bv` and `.abv`
programs, while array commands remain unavailable in `.bv`. -/
def reusableBvFragment [Language.HasBV lang] : Smt lang Unit := do
  let x ← declareBV "fragment_x" 4
  assert (x <.ᵤ bv 10 4)

def composedAbvProgram : Smt .abv Unit := do
  reusableBvFragment
  let memory ← declareArray "fragment_memory" 4 (Ty.bitVec 4)
  assert (selectArr memory (bv 0 4) =. bv 3 4)

theorem arraysAreUnavailableInBv (capability : Language.HasArray .bv) : False := by
  cases capability.proof

def languageCompositionOk : Bool :=
  let script := compile composedAbvProgram
  (script.splitOn "(set-logic QF_ABV)").length == 2 &&
    (script.splitOn "(declare-const fragment_x (_ BitVec 4))").length == 2 &&
    (script.splitOn "(declare-const fragment_memory (Array (_ BitVec 4) (_ BitVec 4)))").length == 2

def backendAbstractionOk : Bool :=
  (Solver.z3 : Solver .bool).name == "Z3" &&
    (Solver.cvc5 : Solver .all).name == "cvc5" &&
    (Solver.kissat : Solver .bv).name.endsWith "Kissat" &&
    (Solver.cadical : Solver .bv).name.endsWith "CaDiCaL"

def cnfTests : TestSeq :=
  group "CNF bridge" $
    test "preserves Boolean and LSB-first bit mappings" (cnfMappingFixtureOk = true) $
    test "Lean checker accepts only satisfying decoded models" (leanModelCheckerOk = true) $
    test "capability-polymorphic BV fragments compose in ABV" (languageCompositionOk = true) $
    test "all SMT, CNF, and SAT implementations use generic interfaces" (backendAbstractionOk = true)

def cnfIntegrationProgram : Smt .bv Unit := do
  let x ← declareBV "integration_x" 4
  let flag ← declareBool "integration_flag"
  assert (x =. bv 5 4)
  assert flag

def cnfUnsatIntegrationProgram : Smt .bv Unit := do
  let x ← declareBV "unsat_x" 4
  assert (x =. bv 1 4)
  assert (x =. bv 2 4)

private def timeoutProbeArtifact : CnfArtifact := {
  dimacs := "p cnf 1 1\n1 0\n"
  atoms := #["timeout_probe"]
  clauses := #[#[1]]
  modelBits := #[]
}

private structure TimeoutProbeLowerer
private structure TimeoutProbeSat

private instance : CnfLowerer TimeoutProbeLowerer where
  name _ := "timeout probe lowerer"
  check _ := pure (.ok "timeout probe lowerer")
  lower _ _ := pure (.ok timeoutProbeArtifact)

private instance : SatBackend TimeoutProbeSat where
  name _ := "timeout probe SAT"
  check _ := pure (.ok "timeout probe SAT")
  run _ artifact config :=
    SmtLibDsl.DimacsCli.runWithArgs "timeout probe" "/bin/sh"
      #["-c", "sleep 1"] artifact config

def runSatTimeoutIntegration : IO (Except String Unit) := do
  let solver : Solver .bv :=
    Solver.ofCnf TimeoutProbeLowerer.mk TimeoutProbeSat.mk
  match ← solve solver cnfIntegrationProgram { timeout := some 25 } with
  | .unknown "timeout (25ms)" => return .ok ()
  | result =>
    return .error s!"expected the SAT process to time out through SolveConfig, got {result}"

def backendBoolProgram : Smt .bool Unit := do
  let flag ← declareBool "backend_flag"
  assert flag

def backendAbvProgram : Smt .abv Unit := do
  let memory ← declareArray "backend_memory" 4 (Ty.bitVec 8)
  assert (selectArr memory (bv 0 4) =. bv 3 8)

def backendPoint : DatatypeDecl := {
  name := "BackendPoint"
  constructor := "mkBackendPoint"
  fields := [
    { name := "backend_x", ty := Ty.bitVec 8 },
    { name := "backend_y", ty := Ty.bitVec 8 }
  ]
}

def backendPointX : DatatypeFieldRef backendPoint :=
  backendPoint.fieldByName "backend_x" (by
    simp [backendPoint, DatatypeDecl.fieldNames])

def backendAllProgram : Smt .all Unit := do
  let point ← declareDatatypeConstOf "backend_point" backendPoint
  assert (selectField backendPointX point =. bv 7 8)

def runSmtBackendIntegration : IO (Except String Unit) := do
  match ← checkSolver (.cvc5 : Solver .bool) with
  | .error reason =>
    IO.println s!"cvc5 integration skipped: {reason}"
    return .ok ()
  | .ok version =>
    let boolResult ← solve .cvc5 backendBoolProgram
    let boolModel ←
      match boolResult with
      | .sat model => pure model
      | result => return .error s!"expected SAT from cvc5/.bool, got {result}"
    match boolModel.get "backend_flag" .bool with
    | .ok true => pure ()
    | _ => return .error "cvc5 Boolean model did not satisfy the query"

    let z3Result ← solve .z3 cnfIntegrationProgram
    let cvc5Result ← solve .cvc5 cnfIntegrationProgram
    if !SmtLibDsl.sameSatStatus z3Result cvc5Result then
      return .error s!"Z3/cvc5 status mismatch: {z3Result} versus {cvc5Result}"
    let z3Model ←
      match z3Result with
      | .sat model => pure model
      | result => return .error s!"expected SAT from Z3/.bv, got {result}"
    let cvc5Model ←
      match cvc5Result with
      | .sat model => pure model
      | result => return .error s!"expected SAT from cvc5/.bv, got {result}"
    match checkBvModel cnfIntegrationProgram z3Model,
        checkBvModel cnfIntegrationProgram cvc5Model with
    | .ok (), .ok () => pure ()
    | _, _ =>
      return .error "a direct SMT bit-vector model failed Lean replay"

    let z3Unsat ← solve .z3 cnfUnsatIntegrationProgram
    let cvc5Unsat ← solve .cvc5 cnfUnsatIntegrationProgram
    match z3Unsat, cvc5Unsat with
    | .unsat, .unsat => pure ()
    | lhs, rhs =>
      return .error s!"expected UNSAT from Z3 and cvc5, got {lhs} and {rhs}"

    let abvResult ← solve .cvc5 backendAbvProgram
    let abvModel ←
      match abvResult with
      | .sat model => pure model
      | result => return .error s!"expected SAT from cvc5/.abv, got {result}"
    match abvModel.get "backend_memory" (Ty.array 4 (Ty.bitVec 8)) with
    | .ok _ => pure ()
    | .error error => return .error s!"failed to decode cvc5 array model: {error}"

    let allResult ← solve .cvc5 backendAllProgram
    let allModel ←
      match allResult with
      | .sat model => pure model
      | result => return .error s!"expected SAT from cvc5/.all, got {result}"
    let point ←
      match allModel.get "backend_point" (Ty.datatype backendPoint) with
      | .ok point => pure point
      | .error error => return .error s!"failed to decode cvc5 datatype model: {error}"
    match point.getField backendPointX with
    | .ok x =>
      if x.toNat != 7 then
        return .error s!"cvc5 datatype model has backend_x={x.toNat}, expected 7"
    | .error error =>
      return .error s!"failed to read cvc5 datatype field: {error}"

    IO.println s!"SMT backends: Z3 and {version} agree"
    return .ok ()

def runCnfIntegration : IO (Except String Unit) := do
  let bridged ← bridgeToCnf cnfIntegrationProgram
  let bridge ←
    match bridged with
    | .ok bridge => pure bridge
    | .error error => return .error error
  let expectedSources := [
    SmtLibDsl.SMT.SourceBit.bit 0 "integration_x" 4 0,
    SmtLibDsl.SMT.SourceBit.bit 0 "integration_x" 4 1,
    SmtLibDsl.SMT.SourceBit.bit 0 "integration_x" 4 2,
    SmtLibDsl.SMT.SourceBit.bit 0 "integration_x" 4 3,
    SmtLibDsl.SMT.SourceBit.bool 1 "integration_flag"
  ]
  if bridge.modelBits.toList.map ModelBitMapping.source != expectedSources then
    return .error s!"unexpected source-bit mapping: {repr bridge.modelBits}"
  match ← checkSolver (.kissat : Solver .bv) with
  | .error reason =>
    IO.println s!"CNF integration skipped: {reason}"
    return .ok ()
  | .ok _ =>
    let z3Result ← solve .z3 cnfIntegrationProgram
    let kissatResult ← solve .kissat cnfIntegrationProgram
    if !SmtLibDsl.sameSatStatus z3Result kissatResult then
      return .error s!"Z3/Kissat status mismatch: {z3Result} versus {kissatResult}"
    let satValidation : Except String Unit :=
      match z3Result, kissatResult with
      | .sat z3Model, .sat kissatModel =>
        match z3Model.get "integration_x" (.bitVec 4),
            kissatModel.get "integration_x" (.bitVec 4) with
        | .ok z3X, .ok kissatX =>
          if z3X.toNat == 5 && kissatX.toNat == 5 then .ok ()
          else .error "decoded integration model has the wrong bit-vector value"
        | _, _ => .error "integration model is missing integration_x"
      | _, _ =>
        .error s!"expected SAT from both solvers, got {z3Result} and {kissatResult}"
    if let .error error := satValidation then
      return .error error
    let z3Unsat ← solve .z3 cnfUnsatIntegrationProgram
    let kissatUnsat ← solve .kissat cnfUnsatIntegrationProgram
    match z3Unsat, kissatUnsat with
    | .unsat, .unsat => return .ok ()
    | _, _ =>
      return .error s!"expected UNSAT from both solvers, got {z3Unsat} and {kissatUnsat}"

def runCadicalIntegration : IO (Except String Unit) := do
  match ← checkSolver (.cadical : Solver .bv) with
  | .error reason =>
    IO.println s!"CaDiCaL integration skipped: {reason}"
    return .ok ()
  | .ok version =>
    let z3Result ← solve .z3 cnfIntegrationProgram
    let cadicalResult ← solve .cadical cnfIntegrationProgram
    if !SmtLibDsl.sameSatStatus z3Result cadicalResult then
      return .error s!"Z3/CaDiCaL status mismatch: {z3Result} versus {cadicalResult}"
    match cadicalResult with
    | .sat model =>
      match model.get "integration_x" (.bitVec 4) with
      | .ok x =>
        if x.toNat != 5 then
          return .error s!"CaDiCaL decoded integration_x={x.toNat}, expected 5"
      | .error error => return .error error
    | result => return .error s!"expected SAT from CaDiCaL, got {result}"
    let z3Unsat ← solve .z3 cnfUnsatIntegrationProgram
    let cadicalUnsat ← solve .cadical cnfUnsatIntegrationProgram
    match z3Unsat, cadicalUnsat with
    | .unsat, .unsat =>
      IO.println s!"CaDiCaL {version}: SAT/UNSAT and Lean model replay passed"
      return .ok ()
    | lhs, rhs =>
      return .error s!"expected UNSAT from Z3 and CaDiCaL, got {lhs} and {rhs}"

def impTokenizeOk : Bool :=
  match tokenize "x := 1; skip" with
  | .ok tokens => tokens == [
      .ident "x", .assign, .natLit 1, .semi, .kwSkip
    ]
  | .error _ => false

def impParseArithmeticOk : Bool :=
  match parseProgram "x := 1 + 2 * 3" with
  | .ok stmt =>
    stmt == Stmt.assign "x" (AExpr.add (AExpr.const 1) (AExpr.mul (AExpr.const 2) (AExpr.const 3)))
  | .error _ => false

def impParseIfOk : Bool :=
  match parseProgram "if x < y then { z := x + 1 } else { z := y - 1 }" with
  | .ok stmt =>
    stmt == Stmt.ite
      (BExpr.lt (AExpr.var "x") (AExpr.var "y"))
      (Stmt.assign "z" (AExpr.add (AExpr.var "x") (AExpr.const 1)))
      (Stmt.assign "z" (AExpr.sub (AExpr.var "y") (AExpr.const 1)))
  | .error _ => false

def impInterpreterOk : Bool :=
  match parseProgram "x := x + 1; if x < y then { z := x * 2 } else { z := y - x }" with
  | .ok program =>
    let finalEnv := evalStmt [("x", 4), ("y", 5), ("z", 0)] program
    lookupEnvD finalEnv "z" 0 == 0
  | .error _ => false

def impCompilerShapeOk : Bool :=
  match parseProgram "x := x + 1; if x < y then { z := x * 2 } else { z := y - x }" with
  | .ok program =>
    let script := compile (compiledProgram program)
    let hasIte := List.length (String.splitOn script "(ite ") > 1
    let hasInput := List.length (String.splitOn script "(declare-const x (_ BitVec 8))") > 1
    let hasZeroInit := List.length (String.splitOn script "(assert (= x (_ bv0 8)))") > 1
    let hasSsa := List.length (String.splitOn script "(declare-const ssa_") > 1
    let noOut := List.length (String.splitOn script "(declare-const out_") == 1
    hasIte && hasInput && hasZeroInit && hasSsa && noOut
  | .error _ => false

def impTests : TestSeq :=
  group "imp" $
    test "tokenize assignment and skip" (impTokenizeOk = true) $
    test "parse precedence in arithmetic" (impParseArithmeticOk = true) $
    test "parse if with blocks" (impParseIfOk = true) $
    test "interpreter computes sample program" (impInterpreterOk = true) $
    test "compiler emits SSA and ite" (impCompilerShapeOk = true)

-- All tests
def allTests : TestSeq :=
  tyTests ++ compileExprTests ++ compileCmdTests ++ compileTests ++ cnfTests ++
    cseTests ++ impTests

-- Main entry point for running tests
def main : IO UInt32 := do
  match ← runSatTimeoutIntegration with
  | .error error =>
    IO.eprintln s!"SAT timeout integration failed: {error}"
    return 1
  | .ok () => pure ()
  match ← runSmtBackendIntegration with
  | .error error =>
    IO.eprintln s!"SMT backend integration failed: {error}"
    return 1
  | .ok () => pure ()
  match ← runCnfIntegration with
  | .error error =>
    IO.eprintln s!"CNF integration failed: {error}"
    return 1
  | .ok () => pure ()
  match ← runCadicalIntegration with
  | .error error =>
    IO.eprintln s!"CaDiCaL integration failed: {error}"
    return 1
  | .ok () => pure ()
  let (success, msg) := allTests.run
  if success then
    IO.println msg
    return 0
  else
    IO.eprintln msg
    return 1
