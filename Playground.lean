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
def pointXField : DatatypeFieldRef PointDecl := {
  field := { name := "x", ty := Ty.bitVec 8 }
  inDecl := by simp [PointDecl]
}

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
    match model.get "x" (Ty.bitVec 8) with
    | some (x : BitVec 8) =>
      IO.println s!"  x as Nat: {x.toNat}"
    | none =>
      IO.println "  could not decode x from model"
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
    match model.get "a" (Ty.array 8 (Ty.bitVec 8)) with
    | some (arr : ArrayValue 8 (BitVec 8)) =>
      IO.println s!"  a typed value: {Ty.showValue (Ty.array 8 (Ty.bitVec 8)) arr}"
    | none => IO.println "  could not decode a from model"
    match model.get "i" (Ty.bitVec 8) with
    | some (i : BitVec 8) => IO.println s!"  i as Nat: {i.toNat}"
    | none => IO.println "  could not decode i from model"
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

/-- 4) Datatype with string selector API. -/
def datatypeSimple : Smt Unit := do
  let p ← declareDatatypeConstOf "p" PointDecl
  assert (selectField "x" (Ty.bitVec 8) p =. bv 3 8)

#eval compile datatypeSimple
#eval solve datatypeSimple

/-- 5) Datatype with dependent-safe selector API. -/
def datatypeSafe : Smt Unit := do
  let p ← declareDatatypeConstOf "p" PointDecl
  assert (selectFieldSafe pointXField p =. bv 3 8)

#eval compile datatypeSafe
#eval solve datatypeSafe

/-- 6) Show typed model extraction for bitvectors and SExpr values. -/
def inspectModel : IO Unit := do
  let result ← solve datatypeSafe
  match result with
  | .sat model =>
    IO.println "SAT model:"
    IO.println (toString model)
    IO.println "\nTyped lookups:"
    match model.getDatatype "p" PointDecl with
    | some (pVal : DatatypeValueOf PointDecl) => IO.println s!"  p typed with PointDecl: {pVal}"
    | none => IO.println "  p typed with PointDecl: <decode failed>"
  | .unsat =>
    IO.println "UNSAT"
  | .unknown reason =>
    IO.println s!"UNKNOWN: {reason}"

#eval inspectModel

end Playground
