import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Tasks.Common

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Tasks

/-- ------------------------------------------------------------------
    Puzzle 11852cab (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

def puzzle11852cabDims : InOutDim :=
  { inRows := 10
  , inCols := 10
  , outRows := 10
  , outCols := 10 }

def puzzle11852cabInput₁ : Grid 10 10 :=
  { cells :=
      ⟨#[ row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C3 .C0 .C8 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C2 .C0 .C2 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C8 .C0 .C3 .C0 .C8 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C2 .C0 .C2 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C8 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 ]
      , by rfl⟩ }

def puzzle11852cabOutput₁ : Grid 10 10 :=
  { cells :=
      ⟨#[ row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C3 .C0 .C8 .C0 .C3 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C2 .C0 .C2 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C8 .C0 .C3 .C0 .C8 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C2 .C0 .C2 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C3 .C0 .C8 .C0 .C3 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 ]
      , by rfl⟩ }

def puzzle11852cabInput₂ : Grid 10 10 :=
  { cells :=
      ⟨#[ row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C2 .C0 .C3 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C4 .C0 .C4 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C3 .C0 .C4 .C0 .C3 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C4 .C0 .C4 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C3 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 ]
      , by rfl⟩ }

def puzzle11852cabOutput₂ : Grid 10 10 :=
  { cells :=
      ⟨#[ row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C2 .C0 .C3 .C0 .C2 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C4 .C0 .C4 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C3 .C0 .C4 .C0 .C3 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C4 .C0 .C4 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C2 .C0 .C3 .C0 .C2 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 ]
      , by rfl⟩ }

def puzzle11852cabInput₃ : Grid 10 10 :=
  { cells :=
      ⟨#[ row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C8 .C0 .C8 .C0 .C8 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C4 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C8 .C0 .C1 .C0 .C8 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C8 .C0 .C8 .C0 .C8 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 ]
      , by rfl⟩ }

def puzzle11852cabOutput₃ : Grid 10 10 :=
  { cells :=
      ⟨#[ row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C8 .C0 .C8 .C0 .C8 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C4 .C0 .C4 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C8 .C0 .C1 .C0 .C8 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C4 .C0 .C4 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C8 .C0 .C8 .C0 .C8 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row10 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 ]
      , by rfl⟩ }

def puzzle11852cabExample₁ : Example puzzle11852cabDims :=
  { input := puzzle11852cabInput₁
  , output := puzzle11852cabOutput₁ }

def puzzle11852cabExample₂ : Example puzzle11852cabDims :=
  { input := puzzle11852cabInput₂
  , output := puzzle11852cabOutput₂ }

def puzzle11852cabExample₃ : Example puzzle11852cabDims :=
  { input := puzzle11852cabInput₃
  , output := puzzle11852cabOutput₃ }

def puzzle11852cabExamples : Examples [puzzle11852cabDims, puzzle11852cabDims, puzzle11852cabDims] :=
  .cons puzzle11852cabExample₁ <|
    .cons puzzle11852cabExample₂ <|
      .cons puzzle11852cabExample₃ .nil

/-- ARC task "11852cab" encoding three training pairs. -/
def puzzle11852cabTask : Task [puzzle11852cabDims, puzzle11852cabDims, puzzle11852cabDims] :=
  { name := "11852cab"
  , examples := puzzle11852cabExamples }

end CogitoCore.ARC.Tasks
