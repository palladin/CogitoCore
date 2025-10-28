import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Tasks.Solutions
import Lean.Data.Json

open CogitoCore.ARC.Definitions
open Lean

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

def parseExamplesArray (j : Json) : Except String (List Example) := do
  let arr ← j.getArr?
  let exs ← arr.mapM parseExample
  pure exs.toList

def parseTask (taskName : String) (root : Json) : Except String Task := do
  let trainJson ← root.getObjVal? "train"
  let testJson ← root.getObjVal? "test"
  let train ← parseExamplesArray trainJson
  let test ← parseExamplesArray testJson
  pure { name := taskName, trainExamples := train, testExamples := test }

def loadTask (taskName : String) : IO (Except String Task) := do
  let path := s!"data/training/{taskName}.json"
  try
    let contents ← IO.FS.readFile path
    match Json.parse contents with
    | .ok json =>
        pure <| parseTask taskName json
    | .error err =>
        pure <| .error s!"failed to parse {path}: {err}"
  catch e =>
    pure <| .error s!"failed to read {path}: {e.toString}"

def evaluateExamples (label : String) (program : Program Grid Grid) (examples : List Example) : IO Unit := do
  if examples.isEmpty then
    IO.println s!"  No {label} examples."
  else
    let rec loop (idx : Nat) : List Example → IO Unit
    | [] => pure ()
    | ex :: rest =>
        match run program ex.input with
        | .error err => do
            IO.println s!"  {label} {idx + 1}: runtime error {err}"
            loop (idx + 1) rest
        | .ok actual => do
            if actual == ex.output then
              IO.println s!"  {label} {idx + 1}: passed"
            else
              IO.println s!"  {label} {idx + 1}: FAILED"
              IO.println s!"    expected: {reprStr ex.output}"
              IO.println s!"    actual:   {reprStr actual}"
            loop (idx + 1) rest
    loop 0 examples

def evaluateSolution (sol : Solution) : IO Unit := do
  IO.println s!"Evaluating task {sol.taskName}"
  match ← loadTask sol.taskName with
  | .error err =>
      IO.eprintln s!"  Error loading task: {err}"
  | .ok task => do
      evaluateExamples "Training" sol.program task.trainExamples
      evaluateExamples "Test" sol.program task.testExamples

def main : IO Unit := do
  for sol in solutions do
    evaluateSolution sol
  pure ()
