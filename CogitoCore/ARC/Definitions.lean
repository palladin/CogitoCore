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


-- Rectangular grid stored as nested arrays.
abbrev Grid := Array (Array Cell)

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

-- Named transformation that maps one grid representation into another, possibly failing with a message.
structure Transform (α : Type) (β : Type) where
  name : String
  apply : α → Except String β

instance : Repr (Transform α β) where
  reprPrec t _ := t.name

-- Chains named transforms from an input grid to a desired output grid.
inductive Program : Type → Type → Type _ where
  | last : Transform α ω → Program α ω
  | step : Transform α β → Program β ω → Program α ω

-- Executes a program by threading intermediate results through each transform, surfacing the first failure.
def run : Program α ω → α → Except String ω
  | .last t => t.apply
  | .step t rest =>
      fun input => do
        let mid ← t.apply input
        run rest mid

-- Solution is a pairing of a program with a task
structure Solution where
  program : Program Grid Grid
  taskName : String

end CogitoCore.ARC.Definitions
