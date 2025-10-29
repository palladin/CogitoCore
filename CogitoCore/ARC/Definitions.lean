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

abbrev Runner α := Except String α × List String

instance : Monad Runner where
  pure x := (Except.ok x, [])
  bind r f :=
    match r with
    | (Except.error msg, logs) => (Except.error msg, logs)
    | (Except.ok v, logs1) =>
        let (res, logs2) := f v
        (res, logs1 ++ logs2)

-- Named transformation that maps one grid representation into another, possibly failing with a message.
structure Transform (α : Type) (β : Type) [Repr α] [Repr β] where
  name : String
  apply : α → Runner β

instance [Repr α] [Repr β] : Repr (Transform α β) where
  reprPrec t _ := t.name

-- Chains named transforms from an input grid to a desired output grid.
inductive Program : Type → Type → Type _ where
  | last : [Repr α] → [Repr ω] → Transform α ω → Program α ω
  | step : [Repr α] → [Repr β] → Transform α β → Program β ω → Program α ω

def reprProgram : Program α ω → Std.Format
  | Program.last t => s!"{t.name}"
  | Program.step t rest => s!"{t.name} |> {reprProgram rest}"

instance: Repr (Program α ω) where
  reprPrec p _ := reprProgram p

-- Executes a program by threading intermediate results through each transform, surfacing the first failure.
def run : Program α ω → α → Runner ω
  | Program.last t, input => t.apply input
  | Program.step t rest, input => do
      let mid ← t.apply input
      run rest mid

-- Solution is a pairing of a program with a task
structure Solution where
  program : Program Grid Grid
  taskName : String

end CogitoCore.ARC.Definitions
