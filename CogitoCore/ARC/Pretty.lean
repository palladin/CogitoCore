import CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Pretty

open CogitoCore.ARC.Definitions

def cellToNat : Cell → Nat
  | Cell.C0 => 0
  | Cell.C1 => 1
  | Cell.C2 => 2
  | Cell.C3 => 3
  | Cell.C4 => 4
  | Cell.C5 => 5
  | Cell.C6 => 6
  | Cell.C7 => 7
  | Cell.C8 => 8
  | Cell.C9 => 9

def dumpGrid (label : String) (grid : Grid) : IO Unit := do
  IO.println label
  for row in grid do
    let rowVals := row.toList.map (fun cell => cellToNat cell)
    IO.println s!"  {rowVals}"

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
        IO.println s!"row {rowIdx}, col {colIdx}: expected {cellToNat expected}, actual {cellToNat actual}"

end CogitoCore.ARC.Pretty
