/-!
Core types describing ARC-style grids, tasks, and solutions.
These definitions stay lightweight so downstream reasoning layers can re-use them.
-/

namespace CogitoCore.ARC.Definitions

-- Enumerates the canonical ARC color palette used to encode cell values.
inductive Cell where
  | C0
  | C1
  | C2
  | C3
  | C4
  | C5
  | C6
  | C7
  | C8
  | C9
  deriving Repr, BEq

instance : Repr Cell where
  reprPrec c _ :=
    match c with
    | Cell.C0 => "0"
    | Cell.C1 => "1"
    | Cell.C2 => "2"
    | Cell.C3 => "3"
    | Cell.C4 => "4"
    | Cell.C5 => "5"
    | Cell.C6 => "6"
    | Cell.C7 => "7"
    | Cell.C8 => "8"
    | Cell.C9 => "9"

-- Rectangular grid stored as nested arrays.
abbrev Grid := Array (Array Cell)

instance : Repr Grid where
  reprPrec g _ :=
    let rows := g.toList.map (fun row => row.toList.map (fun c => toString (repr c)))
    let rowStrs := rows.map (fun r => s!"[{", ".intercalate r}]")
    s!"[{"\n ".intercalate rowStrs}]"

-- Bundles the concrete grids for one training example.
structure Example where
  input : Grid
  output : Grid
  deriving Repr

-- Full task containing the mission name and its paired training examples.
structure Task where
  name : String
  trainExamples : List Example
  testExamples : List Example
  deriving Repr

-- Exception-aware runner that accumulates log messages.
abbrev Runner α := Except String α × List String

instance : Monad Runner where
  pure x := (Except.ok x, [])
  bind r f :=
    match r with
    | (Except.error msg, logs) => (Except.error msg, logs)
    | (Except.ok v, logs1) =>
        let (res, logs2) := f v
        (res, logs1 ++ logs2)

-- Write a message to the runner log.
def writeToLog (msg : Std.Format) : Runner Unit :=
  (pure (), [toString msg])

-- Named transformation that maps one grid representation into another, possibly failing with a message.
structure Transform (α : Type) (β : Type) [Repr α] [Repr β] where
  name : String
  apply : α → Runner β

instance [Repr α] [Repr β] : Repr (Transform α β) where
  reprPrec t _ := t.name

-- Chains named transforms from an input grid to a desired output grid.
inductive Pipeline : Type → Type → Type _ where
  | last : [Repr α] → [Repr ω] → Transform α ω → Pipeline α ω
  | step : [Repr α] → [Repr β] → Transform α β → Pipeline β ω → Pipeline α ω

def reprPipeline : Pipeline α ω → Std.Format
  | Pipeline.last t => s!"{t.name}"
  | Pipeline.step t rest => s!"{t.name} |> {reprPipeline rest}"

instance: Repr (Pipeline α ω) where
  reprPrec p _ := reprPipeline p

-- Executes a pipeline by threading intermediate results through each transform, surfacing the first failure.
def run : Pipeline α ω → α → Runner ω
  | Pipeline.last t, input => t.apply input
  | Pipeline.step t rest, input => do
      let mid ← t.apply input
      writeToLog <| repr mid
      run rest mid

-- Solution is a pairing of a pipeline with a task
structure Solution where
  pipeline : Pipeline Grid Grid
  taskName : String

-- Entity represents an object in the grid with a location, sub-parts, and background cells.
structure Entity where
  grid : Grid
  location : (Nat × Nat)
  parts : List Entity
  background : List Cell
  deriving Repr

-- World encapsulates the state of the ARC grid along with auxiliary state information.
structure World (σ : Type) where
  state : σ
  grid : Grid
  entities : List Entity
  background : List Cell
  deriving Repr

end CogitoCore.ARC.Definitions
