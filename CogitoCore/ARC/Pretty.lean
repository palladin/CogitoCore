import CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Pretty

open CogitoCore.ARC.Definitions

def dumpGrid (label : String) (grid : Grid) : IO Unit := do
  IO.println s!"{label}\n{repr grid}"

private def enumerateList {α} : List α → Nat → List (Nat × α)
  | [], _ => []
  | x :: xs, idx => (idx, x) :: enumerateList xs (idx + 1)

private def enumerateArray {α} (arr : Array α) : List (Nat × α) :=
  enumerateList arr.toList 0

def gridDiffs (expected actual : Grid) : List (Nat × Nat × Cell × Cell) :=
  (enumerateArray expected).foldl
    (fun acc rowInfo =>
      match rowInfo with
      | (rowIdx, rowExpected) =>
          match actual[rowIdx]? with
          | none => acc
          | some rowActual =>
              (enumerateArray rowExpected).foldl
                (fun acc cellInfo =>
                  match cellInfo with
                  | (colIdx, cellExpected) =>
                      match rowActual[colIdx]? with
                      | none => acc
                      | some cellActual =>
                          if cellExpected == cellActual then
                            acc
                          else
                            (rowIdx, colIdx, cellExpected, cellActual) :: acc)
                acc)
    []

def printDiffs (diffs : List (Nat × Nat × Cell × Cell)) : IO Unit :=
  match diffs.reverse with
  | [] => IO.println "no differences"
  | entries =>
      for (rowIdx, colIdx, expected, actual) in entries do
        IO.println s!"row {rowIdx}, col {colIdx}: expected {repr expected}, actual {repr actual}"

end CogitoCore.ARC.Pretty
