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


-- Abstract world representation parameterized by an internal state type.
structure World (σ : Type) where
  state : σ
  size : Nat × Nat

inductive Result (σ : Type) where
  | Done
  | Next (world : World σ)

-- Solution is a pairing of a pipeline with a task
structure Solution where
  σ : Type
  stateRepr : Repr σ
  toGrid : World σ → Grid
  toWorld : Grid → World σ
  stepTransform : World σ → Result σ
  taskName : String

-- Executes a pipeline by threading intermediate results through each transform, surfacing the first failure.
def run [stateRepr : Repr σ] (fuel : Nat) (stepTransform : World σ → Result σ) (world : World σ) : Runner (World σ) :=
  let rec loop (fuel : Nat) (world : World σ) : Runner (World σ) :=
    match fuel with
    | 0 => do
        writeToLog s!"last state = {repr world.state}"
        let msg := s!"fuel exhausted before completion"
        (Except.error msg, [])
    | Nat.succ fuel' =>
        match stepTransform world with
        | Result.Done => do
          writeToLog s!"Stepped to new world with state = {repr world.state}"
          pure world
        | Result.Next nextWorld => do
          writeToLog s!"Stepped to new world with state = {repr nextWorld.state}"
          loop fuel' nextWorld
  loop fuel world

-- Evaluates the solution pipeline on a given input grid, producing the output grid.
def runSolution (fuel : Nat) (solution : Solution) (input : Grid) : Runner Grid := do
  writeToLog s!"Running solution for input = {repr input}"
  let startWorld := solution.toWorld input
  let stateRepr : Repr solution.σ := solution.stateRepr
  let finalWorld ← run (stateRepr := stateRepr) fuel solution.stepTransform startWorld
  let output := solution.toGrid finalWorld
  writeToLog s!"output = {repr output}"
  pure output


end CogitoCore.ARC.Definitions
