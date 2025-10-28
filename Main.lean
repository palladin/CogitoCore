import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Tasks.«0d3d703e»
import Lean.Data.Json

open CogitoCore.ARC.Definitions
open Lean

def solutions : List Solution :=
  [ CogitoCore.ARC.Tasks.puzzle0d3d703eSolution
  ]

def cellOfNat? : Nat → Except String Cell
  | 0 => .ok .C0
  | 1 => .ok .C1
  | 2 => .ok .C2
  | 3 => .ok .C3
  | 4 => .ok .C4
  | 5 => .ok .C5
  | 6 => .ok .C6
  | 7 => .ok .C7
  | 8 => .ok .C8
  | 9 => .ok .C9
  | n => .error s!"unsupported cell value {n}"

def parseCell (j : Json) : Except String Cell := do
  let n ← j.getNat?
  cellOfNat? n

def parseRow (j : Json) : Except String (Array Cell) := do
  let arr ← j.getArr?
  arr.mapM parseCell

def parseGrid (j : Json) : Except String Grid := do
  let rows ← j.getArr?
  let cells ← rows.mapM parseRow
  pure cells

def parseExample (j : Json) : Except String Example := do
  let inputJson ← j.getObjVal? "input"
  let outputJson ← j.getObjVal? "output"
  let input ← parseGrid inputJson
  let output ← parseGrid outputJson
  pure { input := input, output := output }

def parseExamples (root : Json) (field : String) : Except String (List Example) := do
  let arrJson ← root.getObjVal? field
  let arr ← arrJson.getArr?
  let exs ← arr.mapM parseExample
  pure exs.toList

def loadTestExamples (taskName : String) : IO (Except String (List Example)) := do
  let path := s!"data/training/{taskName}.json"
  try
    let contents ← IO.FS.readFile path
    match Json.parse contents with
    | .ok json =>
        pure <| parseExamples json "test"
    | .error err =>
        pure <| .error s!"failed to parse {path}: {err}"
  catch e =>
    pure <| .error s!"failed to read {path}: {e.toString}"

def evaluateSolution (sol : Solution) : IO Unit := do
  IO.println s!"Evaluating task {sol.task.name}"
  match ← loadTestExamples sol.task.name with
  | .error err =>
      IO.eprintln s!"  Error loading tests: {err}"
  | .ok tests =>
      if tests.isEmpty then
        IO.println "  No test cases available."
      else
        let rec go (idx : Nat) : List Example → IO Unit
        | [] => pure ()
        | ex :: rest =>
            match run sol.program ex.input with
            | .error err => do
                IO.println s!"  Test {idx + 1}: runtime error {err}"
                go (idx + 1) rest
            | .ok actual => do
                if actual == ex.output then
                  IO.println s!"  Test {idx + 1}: passed"
                else
                  IO.println s!"  Test {idx + 1}: FAILED"
                  IO.println s!"    expected: {reprStr ex.output}"
                  IO.println s!"    actual:   {reprStr actual}"
                go (idx + 1) rest
        go 0 tests

def main : IO Unit := do
  for sol in solutions do
    evaluateSolution sol
  pure ()
