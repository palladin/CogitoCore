import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

/-- Build a length-one vector holding the provided element. -/
def singletonVector {α : Type} (a : α) : Vector α 1 :=
  ⟨#[a], by rfl⟩

/-- Construct a `1 × 1` grid whose sole cell stores `value`. -/
def oneByOneGrid (value : Cell) : Grid 1 1 :=
  { cells := ⟨#[singletonVector value], by rfl⟩ }

/-- Dimensions for the simple identity task. -/
def oneByOneDims : InOutDim :=
  { inRows := 1
  , inCols := 1
  , outRows := 1
  , outCols := 1 }

/-- Example illustrating the identity task on a `1 × 1` grid. -/
def identityExample : Example oneByOneDims :=
  { input := oneByOneGrid .C5
  , output := oneByOneGrid .C5 }

/-- Wrapper giving a single example list for the identity task. -/
def identityExamples : Examples [oneByOneDims] :=
  .cons identityExample .nil

/-- Simple identity ARC task mirroring its input. -/
def identityTask : Task [oneByOneDims] :=
  { name := "identity"
  , examples := identityExamples }

def identitySolution : Solution :=
  { dims := [oneByOneDims]
  , task := identityTask
  , programs := .cons (.last gridIdentityTransform) .nil
  , isValid := by rfl }

end CogitoCore.ARC.Tasks
