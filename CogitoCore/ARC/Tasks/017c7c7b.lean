import CogitoCore.ARC.Tasks.Common

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Tasks

/-- ------------------------------------------------------------------
    Puzzle 017c7c7b (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

def puzzle017c7c7bDims : InOutDim :=
  { inRows := 6
  , inCols := 3
  , outRows := 9
  , outCols := 3 }

def puzzle017c7c7bInput₁ : Grid 6 3 :=
  { cells :=
      ⟨#[ row3 .C0 .C1 .C0
        , row3 .C1 .C1 .C0
        , row3 .C0 .C1 .C0
        , row3 .C0 .C1 .C1
        , row3 .C0 .C1 .C0
        , row3 .C1 .C1 .C0 ]
      , by rfl⟩ }

def puzzle017c7c7bOutput₁ : Grid 9 3 :=
  { cells :=
      ⟨#[ row3 .C0 .C2 .C0
        , row3 .C2 .C2 .C0
        , row3 .C0 .C2 .C0
        , row3 .C0 .C2 .C2
        , row3 .C0 .C2 .C0
        , row3 .C2 .C2 .C0
        , row3 .C0 .C2 .C0
        , row3 .C0 .C2 .C2
        , row3 .C0 .C2 .C0 ]
      , by rfl⟩ }

def puzzle017c7c7bInput₂ : Grid 6 3 :=
  { cells :=
      ⟨#[ row3 .C0 .C1 .C0
        , row3 .C1 .C0 .C1
        , row3 .C0 .C1 .C0
        , row3 .C1 .C0 .C1
        , row3 .C0 .C1 .C0
        , row3 .C1 .C0 .C1 ]
      , by rfl⟩ }

def puzzle017c7c7bOutput₂ : Grid 9 3 :=
  { cells :=
      ⟨#[ row3 .C0 .C2 .C0
        , row3 .C2 .C0 .C2
        , row3 .C0 .C2 .C0
        , row3 .C2 .C0 .C2
        , row3 .C0 .C2 .C0
        , row3 .C2 .C0 .C2
        , row3 .C0 .C2 .C0
        , row3 .C2 .C0 .C2
        , row3 .C0 .C2 .C0 ]
      , by rfl⟩ }

def puzzle017c7c7bInput₃ : Grid 6 3 :=
  { cells :=
      ⟨#[ row3 .C0 .C1 .C0
        , row3 .C1 .C1 .C0
        , row3 .C0 .C1 .C0
        , row3 .C0 .C1 .C0
        , row3 .C1 .C1 .C0
        , row3 .C0 .C1 .C0 ]
      , by rfl⟩ }

def puzzle017c7c7bOutput₃ : Grid 9 3 :=
  { cells :=
      ⟨#[ row3 .C0 .C2 .C0
        , row3 .C2 .C2 .C0
        , row3 .C0 .C2 .C0
        , row3 .C0 .C2 .C0
        , row3 .C2 .C2 .C0
        , row3 .C0 .C2 .C0
        , row3 .C0 .C2 .C0
        , row3 .C2 .C2 .C0
        , row3 .C0 .C2 .C0 ]
      , by rfl⟩ }

def puzzle017c7c7bExample₁ : Example puzzle017c7c7bDims :=
  { input := puzzle017c7c7bInput₁
  , output := puzzle017c7c7bOutput₁ }

def puzzle017c7c7bExample₂ : Example puzzle017c7c7bDims :=
  { input := puzzle017c7c7bInput₂
  , output := puzzle017c7c7bOutput₂ }

def puzzle017c7c7bExample₃ : Example puzzle017c7c7bDims :=
  { input := puzzle017c7c7bInput₃
  , output := puzzle017c7c7bOutput₃ }

def puzzle017c7c7bExamples : Examples [puzzle017c7c7bDims, puzzle017c7c7bDims, puzzle017c7c7bDims] :=
  .cons puzzle017c7c7bExample₁ <|
    .cons puzzle017c7c7bExample₂ <|
      .cons puzzle017c7c7bExample₃ .nil

def puzzle017c7c7bTask : Task [puzzle017c7c7bDims, puzzle017c7c7bDims, puzzle017c7c7bDims] :=
  { name := "017c7c7b"
  , examples := puzzle017c7c7bExamples }

end CogitoCore.ARC.Tasks
