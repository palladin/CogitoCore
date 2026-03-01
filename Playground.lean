import SmtLibDsl

open SmtLibDsl.SMT

namespace Playground

/-- Datatype used by datatype examples below. -/
def PointDecl : DatatypeDecl := {
  name := "Point"
  constructor := "mkPoint"
  fields := [
    { name := "x", ty := Ty.bitVec 8 },
    { name := "y", ty := Ty.bitVec 8 }
  ]
}

/-- Proof-carrying handle for field `x`. -/
def pointXField : DatatypeFieldRef PointDecl :=
  PointDecl.fieldByName "x" (by simp [PointDecl, DatatypeDecl.fieldNames])

/-- Inner datatype for nested-datatype examples below. -/
def InnerDecl : DatatypeDecl := {
  name := "Inner"
  constructor := "mkInner"
  fields := [
    { name := "x", ty := Ty.bitVec 8 },
    { name := "y", ty := Ty.bitVec 8 }
  ]
}

/-- Outer datatype with a field that contains `Inner`. -/
def OuterDecl : DatatypeDecl := {
  name := "Outer"
  constructor := "mkOuter"
  fields := [
    { name := "inner", ty := Ty.datatype InnerDecl },
    { name := "tag", ty := Ty.bitVec 8 }
  ]
}

/-- Proof-carrying handle for field `inner` on `OuterDecl`. -/
def outerInnerField : DatatypeFieldRef OuterDecl :=
  OuterDecl.fieldByName "inner" (by simp [OuterDecl, InnerDecl, DatatypeDecl.fieldNames])

/-- Proof-carrying handle for field `x` on `InnerDecl`. -/
def innerXField : DatatypeFieldRef InnerDecl :=
  InnerDecl.fieldByName "x" (by simp [InnerDecl, DatatypeDecl.fieldNames])

/-- 1) Basic bitvector example. -/
def basicBV : Smt Unit := do
  let x ← declareBV "x" 8
  assert (x +. bv 1 8 =. bv 10 8)

/-- Solve `basicBV` and extract `x` as a typed Lean value. -/
def inspectBasicBV : IO Unit := do
  let result ← solve basicBV
  match result with
  | .sat model =>
    IO.println "basicBV: SAT"
    let extract : Except String (BitVec 8) := do
      let x : BitVec 8 ← model.get "x" (Ty.bitVec 8)
      pure x
    match extract with
    | .ok x =>
      IO.println s!"  x as Nat: {x.toNat}"
    | .error err =>
      IO.println s!"  could not decode x from model: {err}"
  | .unsat =>
    IO.println "basicBV: UNSAT"
  | .unknown reason =>
    IO.println s!"basicBV: UNKNOWN ({reason})"

#eval compile basicBV
#eval inspectBasicBV

/-- 2) Arrays (read/write) example. -/
def arrays : Smt Unit := do
  let a ← declareArray "a" 8 (Ty.bitVec 8)
  let i ← declareBV "i" 8
  let a' := storeArr a i (bv 7 8)
  assert (selectArr a' i =. bv 7 8)

/-- Solve `arrays` and extract the array model value as SExpr. -/
def inspectArrays : IO Unit := do
  let result ← solve arrays
  match result with
  | .sat model =>
    IO.println "arrays: SAT"
    let extract : Except String (ArrayValue 8 (BitVec 8) × BitVec 8) := do
      let arr : ArrayValue 8 (BitVec 8) ← model.get "a" (Ty.array 8 (Ty.bitVec 8))
      let i : BitVec 8 ← model.get "i" (Ty.bitVec 8)
      pure (arr, i)
    match extract with
    | .ok (arr, i) =>
      IO.println s!"  a typed value: {Ty.showValue (Ty.array 8 (Ty.bitVec 8)) arr}"
      IO.println s!"  i as Nat: {i.toNat}"
    | .error err =>
      IO.println s!"  could not decode arrays model values: {err}"
  | .unsat =>
    IO.println "arrays: UNSAT"
  | .unknown reason =>
    IO.println s!"arrays: UNKNOWN ({reason})"

#eval compile arrays
#eval inspectArrays

/-- 3) Nested arrays (array of arrays). -/
def nestedArrays : Smt Unit := do
  let grid ← declareArray "grid" 8 (Ty.array 4 (Ty.bitVec 8))
  let i ← declareBV "i" 8
  let j ← declareBV "j" 4
  let row := selectArr grid i
  let cell := selectArr row j
  assert (cell =. bv 3 8)

#eval compile nestedArrays
#eval solve nestedArrays

/-- 4) Datatype selected with a field handle. -/
def datatypeSimple : Smt Unit := do
  let p ← declareDatatypeConstOf "p" PointDecl
  assert (selectField pointXField p =. bv 3 8)

#eval compile datatypeSimple
#eval solve datatypeSimple

/-- 5) Datatype containing another datatype, selected by field handles. -/
def datatypeNested : Smt Unit := do
  let o ← declareDatatypeConstOf "o" OuterDecl
  let inner := selectField outerInnerField o
  assert (selectField innerXField inner =. bv 5 8)

#eval compile datatypeNested
#eval solve datatypeNested

/-- 6) Show typed model extraction for bitvectors and SExpr values. -/
def inspectModel : IO Unit := do
  let result ← solve datatypeSimple
  match result with
  | .sat model =>
    IO.println "SAT model:"
    IO.println (toString model)
    IO.println "\nTyped lookups:"
    let extract : Except String (DatatypeValueOf PointDecl × BitVec 8) := do
      let pVal : DatatypeValueOf PointDecl ← model.get "p" (Ty.datatype PointDecl)
      let x : BitVec 8 ← pVal.getField pointXField
      pure (pVal, x)
    match extract with
    | .ok (pVal, x) =>
      IO.println s!"  p typed with PointDecl: {(show DatatypeValueOf PointDecl from pVal)}"
      IO.println s!"  p.x via pointXField: {x.toNat}"
    | .error err =>
      IO.println s!"  p typed with PointDecl: <decode failed: {err}>"
  | .unsat =>
    IO.println "UNSAT"
  | .unknown reason =>
    IO.println s!"UNKNOWN: {reason}"

#eval inspectModel

/-- 7) Solve nested datatype example and extract nested `x` via field refs. -/
def inspectNestedModel : IO Unit := do
  let result ← solve datatypeNested
  match result with
  | .sat model =>
    IO.println "nested datatype: SAT"
    let extract : Except String (DatatypeValueOf OuterDecl × BitVec 8) := do
      let oVal : DatatypeValueOf OuterDecl ← model.get "o" (Ty.datatype OuterDecl)
      let innerVal : DatatypeValueOf InnerDecl ← oVal.getField outerInnerField
      let x : BitVec 8 ← innerVal.getField innerXField
      pure (oVal, x)
    match extract with
    | .ok (oVal, x) =>
      IO.println s!"  o typed with OuterDecl: {(show DatatypeValueOf OuterDecl from oVal)}"
      IO.println s!"  o.inner.x via field refs: {x.toNat}"
    | .error err =>
      IO.println s!"  nested extraction failed: {err}"
  | .unsat =>
    IO.println "nested datatype: UNSAT"
  | .unknown reason =>
    IO.println s!"nested datatype: UNKNOWN ({reason})"

#eval inspectNestedModel

end Playground
