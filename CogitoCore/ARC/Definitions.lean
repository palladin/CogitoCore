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


-- Rectangular grid with fixed dimensions enforced at the type level.
structure Grid (rows : Nat) (cols : Nat) where
  cells : Vector (Vector Cell cols) rows
  deriving Repr, BEq

-- Captures the input/output dimensions for a single ARC mission instance.
structure InOutDim where
  inRows : Nat
  inCols : Nat
  outRows : Nat
  outCols : Nat

-- Bundles the concrete grids for one training example.
structure Example (dim : InOutDim) where
  input : Grid dim.inRows dim.inCols
  output : Grid dim.outRows dim.outCols
  deriving Repr

-- Aligns example payloads with their dimension witness list.
inductive Examples : List InOutDim → Type where
  | nil : Examples []
  | cons : Example d → Examples ds → Examples (d :: ds)

-- Full task containing the mission name and its paired training examples.
structure Task (dims : List InOutDim) where
  name : String
  examples : Examples dims

-- Named transformation that maps one grid representation into another.
structure Transform (α : Type) (β : Type) where
  name : String
  apply : α → β

instance : Repr (Transform α β) where
  reprPrec t _ := t.name

-- Chains named transforms from an input grid to a desired output grid.
inductive Program : Type → Type → Type _ where
  | last : Transform α ω → Program α ω
  | step : Transform α β → Program β ω → Program α ω

-- Collection of programs aligned with a dimension witness list.
inductive Programs : List InOutDim → Type _ where
  | nil : Programs []
  | cons : Program (Grid d.inRows d.inCols) (Grid d.outRows d.outCols) → Programs ds → Programs (d :: ds)

-- Executes a program by threading the intermediate grids through each transform.
def run : Program α ω → α → ω
  | .last t => t.apply
  | .step t rest =>
      fun input =>
        let mid := t.apply input
        run rest mid

def validateExample {d : InOutDim} (prog : Program (Grid d.inRows d.inCols) (Grid d.outRows d.outCols)) (ex : Example d) : Bool :=
  let output := run prog ex.input
  output == ex.output

-- Validates a solution candidate by checking each program against its paired example.
def validateTask (progs : Programs dims) (task : Task dims) : Bool :=
  all progs task.examples (fun prog ex => validateExample prog ex)
  where
    all {ds : List InOutDim} : Programs ds → Examples ds → ({d : InOutDim} → Program (Grid d.inRows d.inCols) (Grid d.outRows d.outCols) → Example d → Bool) → Bool
    | .nil, .nil, _ => true
    | .cons prog restProgs, .cons ex restExs, f =>
        f prog ex && all restProgs restExs f

-- Certified pairing of programs with a task, together with the validation proof.
structure Solution (dims : List InOutDim) where
  programs : Programs dims
  task : Task dims
  isValid : validateTask programs task = true


end CogitoCore.ARC.Definitions
