import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Tasks.Common

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Tasks

/-- ------------------------------------------------------------------
    Puzzle 0d3d703e (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

def puzzle0d3d703eDims : InOutDim :=
  { inRows := 3
  , inCols := 3
  , outRows := 3
  , outCols := 3 }

def puzzle0d3d703eInput₁ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C3 .C1 .C2
        , row3 .C3 .C1 .C2
        , row3 .C3 .C1 .C2 ]
      , by rfl⟩ }

def puzzle0d3d703eOutput₁ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C4 .C5 .C6
        , row3 .C4 .C5 .C6
        , row3 .C4 .C5 .C6 ]
      , by rfl⟩ }

def puzzle0d3d703eInput₂ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C2 .C3 .C8
        , row3 .C2 .C3 .C8
        , row3 .C2 .C3 .C8 ]
      , by rfl⟩ }

def puzzle0d3d703eOutput₂ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C6 .C4 .C9
        , row3 .C6 .C4 .C9
        , row3 .C6 .C4 .C9 ]
      , by rfl⟩ }

def puzzle0d3d703eInput₃ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C5 .C8 .C6
        , row3 .C5 .C8 .C6
        , row3 .C5 .C8 .C6 ]
      , by rfl⟩ }

def puzzle0d3d703eOutput₃ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C1 .C9 .C2
        , row3 .C1 .C9 .C2
        , row3 .C1 .C9 .C2 ]
      , by rfl⟩ }

def puzzle0d3d703eInput₄ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C9 .C4 .C2
        , row3 .C9 .C4 .C2
        , row3 .C9 .C4 .C2 ]
      , by rfl⟩ }

def puzzle0d3d703eOutput₄ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C8 .C3 .C6
        , row3 .C8 .C3 .C6
        , row3 .C8 .C3 .C6 ]
      , by rfl⟩ }

def puzzle0d3d703eExample₁ : Example puzzle0d3d703eDims :=
  { input := puzzle0d3d703eInput₁
  , output := puzzle0d3d703eOutput₁ }

def puzzle0d3d703eExample₂ : Example puzzle0d3d703eDims :=
  { input := puzzle0d3d703eInput₂
  , output := puzzle0d3d703eOutput₂ }

def puzzle0d3d703eExample₃ : Example puzzle0d3d703eDims :=
  { input := puzzle0d3d703eInput₃
  , output := puzzle0d3d703eOutput₃ }

def puzzle0d3d703eExample₄ : Example puzzle0d3d703eDims :=
  { input := puzzle0d3d703eInput₄
  , output := puzzle0d3d703eOutput₄ }

def puzzle0d3d703eExamples : Examples [puzzle0d3d703eDims, puzzle0d3d703eDims, puzzle0d3d703eDims, puzzle0d3d703eDims] :=
  .cons puzzle0d3d703eExample₁ <|
    .cons puzzle0d3d703eExample₂ <|
      .cons puzzle0d3d703eExample₃ <|
        .cons puzzle0d3d703eExample₄ .nil

/-- ARC task "0d3d703e" encoding four training pairs. -/
def puzzle0d3d703eTask : Task [puzzle0d3d703eDims, puzzle0d3d703eDims, puzzle0d3d703eDims, puzzle0d3d703eDims] :=
  { name := "0d3d703e"
  , examples := puzzle0d3d703eExamples }

end CogitoCore.ARC.Tasks
