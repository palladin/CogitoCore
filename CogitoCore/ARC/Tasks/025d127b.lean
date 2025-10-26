import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Tasks.Common

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Tasks

/-- ------------------------------------------------------------------
    Puzzle 025d127b (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

def puzzle025d127bDims₁ : InOutDim :=
  { inRows := 14
  , inCols := 9
  , outRows := 14
  , outCols := 9 }

def puzzle025d127bDims₂ : InOutDim :=
  { inRows := 8
  , inCols := 9
  , outRows := 8
  , outCols := 9 }

def puzzle025d127bInput₁ : Grid 14 9 :=
  { cells :=
      ⟨#[ row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C6 .C6 .C6 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C6 .C0 .C0 .C6 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C6 .C0 .C0 .C6 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C6 .C0 .C0 .C6 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C6 .C6 .C6 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C2 .C2 .C2 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C2 .C0 .C0 .C2 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C2 .C2 .C2 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 ]
      , by rfl⟩ }

def puzzle025d127bOutput₁ : Grid 14 9 :=
  { cells :=
      ⟨#[ row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C6 .C6 .C6 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C6 .C0 .C0 .C6 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C6 .C0 .C0 .C6 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C6 .C0 .C6 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C6 .C6 .C6 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C2 .C2 .C2 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C2 .C0 .C2 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C2 .C2 .C2 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 ]
      , by rfl⟩ }

def puzzle025d127bInput₂ : Grid 8 9 :=
  { cells :=
      ⟨#[ row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C8 .C8 .C8 .C8 .C8 .C0 .C0 .C0
        , row9 .C0 .C8 .C0 .C0 .C0 .C0 .C8 .C0 .C0
        , row9 .C0 .C0 .C8 .C0 .C0 .C0 .C0 .C8 .C0
        , row9 .C0 .C0 .C0 .C8 .C0 .C0 .C0 .C0 .C8
        , row9 .C0 .C0 .C0 .C0 .C8 .C8 .C8 .C8 .C8
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 ]
      , by rfl⟩ }

def puzzle025d127bOutput₂ : Grid 8 9 :=
  { cells :=
      ⟨#[ row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C8 .C8 .C8 .C8 .C8 .C0 .C0
        , row9 .C0 .C0 .C8 .C0 .C0 .C0 .C0 .C8 .C0
        , row9 .C0 .C0 .C0 .C8 .C0 .C0 .C0 .C0 .C8
        , row9 .C0 .C0 .C0 .C0 .C8 .C0 .C0 .C0 .C8
        , row9 .C0 .C0 .C0 .C0 .C8 .C8 .C8 .C8 .C8
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 ]
      , by rfl⟩ }

def puzzle025d127bExample₁ : Example puzzle025d127bDims₁ :=
  { input := puzzle025d127bInput₁
  , output := puzzle025d127bOutput₁ }

def puzzle025d127bExample₂ : Example puzzle025d127bDims₂ :=
  { input := puzzle025d127bInput₂
  , output := puzzle025d127bOutput₂ }

def puzzle025d127bExamples : Examples [puzzle025d127bDims₁, puzzle025d127bDims₂] :=
  .cons puzzle025d127bExample₁ <|
    .cons puzzle025d127bExample₂ .nil

/-- ARC task "025d127b" capturing two training pairs. -/
def puzzle025d127bTask : Task [puzzle025d127bDims₁, puzzle025d127bDims₂] :=
  { name := "025d127b"
  , examples := puzzle025d127bExamples }

end CogitoCore.ARC.Tasks
