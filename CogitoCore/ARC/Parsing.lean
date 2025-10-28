import CogitoCore.ARC.Definitions
import Lean.Data.Json

namespace CogitoCore.ARC.Parsing

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

private def parseExamplesArray (j : Json) : Except String (List Example) := do
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

end CogitoCore.ARC.Parsing
