import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Tasks.Common

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Tasks

/-- ------------------------------------------------------------------
    Puzzle 10fcaaa3 (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

def puzzle10fcaaa3Dims₁ : InOutDim :=
  { inRows := 2
  , inCols := 4
  , outRows := 4
  , outCols := 8 }

def puzzle10fcaaa3Dims₂ : InOutDim :=
  { inRows := 3
  , inCols := 4
  , outRows := 6
  , outCols := 8 }

def puzzle10fcaaa3Dims₃ : InOutDim :=
  { inRows := 5
  , inCols := 3
  , outRows := 10
  , outCols := 6 }

def puzzle10fcaaa3Dims₄ : InOutDim :=
  { inRows := 4
  , inCols := 4
  , outRows := 8
  , outCols := 8 }

def puzzle10fcaaa3Input₁ : Grid 2 4 :=
  { cells :=
      ⟨#[ row4 .C0 .C0 .C0 .C0
        , row4 .C0 .C5 .C0 .C0 ]
      , by rfl⟩ }

def puzzle10fcaaa3Output₁ : Grid 4 8 :=
  { cells :=
      ⟨#[ row8 .C8 .C0 .C8 .C0 .C8 .C0 .C8 .C0
        , row8 .C0 .C5 .C0 .C0 .C0 .C5 .C0 .C0
        , row8 .C8 .C0 .C8 .C0 .C8 .C0 .C8 .C0
        , row8 .C0 .C5 .C0 .C0 .C0 .C5 .C0 .C0 ]
      , by rfl⟩ }

def puzzle10fcaaa3Input₂ : Grid 3 4 :=
  { cells :=
      ⟨#[ row4 .C0 .C0 .C6 .C0
        , row4 .C0 .C0 .C0 .C0
        , row4 .C0 .C6 .C0 .C0 ]
      , by rfl⟩ }

def puzzle10fcaaa3Output₂ : Grid 6 8 :=
  { cells :=
      ⟨#[ row8 .C0 .C0 .C6 .C0 .C0 .C0 .C6 .C0
        , row8 .C8 .C8 .C8 .C8 .C8 .C8 .C8 .C8
        , row8 .C0 .C6 .C0 .C8 .C0 .C6 .C0 .C8
        , row8 .C8 .C0 .C6 .C0 .C8 .C0 .C6 .C0
        , row8 .C8 .C8 .C8 .C8 .C8 .C8 .C8 .C8
        , row8 .C0 .C6 .C0 .C0 .C0 .C6 .C0 .C0 ]
      , by rfl⟩ }

def puzzle10fcaaa3Input₃ : Grid 5 3 :=
  { cells :=
      ⟨#[ row3 .C0 .C0 .C0
        , row3 .C0 .C4 .C0
        , row3 .C0 .C0 .C0
        , row3 .C0 .C0 .C0
        , row3 .C4 .C0 .C0 ]
      , by rfl⟩ }

def puzzle10fcaaa3Output₃ : Grid 10 6 :=
  { cells :=
      ⟨#[ row6 .C8 .C0 .C8 .C8 .C0 .C8
        , row6 .C0 .C4 .C0 .C0 .C4 .C0
        , row6 .C8 .C0 .C8 .C8 .C0 .C8
        , row6 .C0 .C8 .C8 .C0 .C8 .C0
        , row6 .C4 .C0 .C0 .C4 .C0 .C0
        , row6 .C8 .C8 .C8 .C8 .C8 .C8
        , row6 .C0 .C4 .C0 .C0 .C4 .C0
        , row6 .C8 .C0 .C8 .C8 .C0 .C8
        , row6 .C0 .C8 .C8 .C0 .C8 .C0
        , row6 .C4 .C0 .C0 .C4 .C0 .C0 ]
      , by rfl⟩ }

def puzzle10fcaaa3Input₄ : Grid 4 4 :=
  { cells :=
      ⟨#[ row4 .C0 .C0 .C0 .C0
        , row4 .C0 .C2 .C0 .C0
        , row4 .C0 .C0 .C0 .C0
        , row4 .C0 .C0 .C0 .C0 ]
      , by rfl⟩ }

def puzzle10fcaaa3Output₄ : Grid 8 8 :=
  { cells :=
      ⟨#[ row8 .C8 .C0 .C8 .C0 .C8 .C0 .C8 .C0
        , row8 .C0 .C2 .C0 .C0 .C0 .C2 .C0 .C0
        , row8 .C8 .C0 .C8 .C0 .C8 .C0 .C8 .C0
        , row8 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row8 .C8 .C0 .C8 .C0 .C8 .C0 .C8 .C0
        , row8 .C0 .C2 .C0 .C0 .C0 .C2 .C0 .C0
        , row8 .C8 .C0 .C8 .C0 .C8 .C0 .C8 .C0
        , row8 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 ]
      , by rfl⟩ }

def puzzle10fcaaa3Example₁ : Example puzzle10fcaaa3Dims₁ :=
  { input := puzzle10fcaaa3Input₁
  , output := puzzle10fcaaa3Output₁ }

def puzzle10fcaaa3Example₂ : Example puzzle10fcaaa3Dims₂ :=
  { input := puzzle10fcaaa3Input₂
  , output := puzzle10fcaaa3Output₂ }

def puzzle10fcaaa3Example₃ : Example puzzle10fcaaa3Dims₃ :=
  { input := puzzle10fcaaa3Input₃
  , output := puzzle10fcaaa3Output₃ }

def puzzle10fcaaa3Example₄ : Example puzzle10fcaaa3Dims₄ :=
  { input := puzzle10fcaaa3Input₄
  , output := puzzle10fcaaa3Output₄ }

def puzzle10fcaaa3Examples : Examples [puzzle10fcaaa3Dims₁, puzzle10fcaaa3Dims₂, puzzle10fcaaa3Dims₃, puzzle10fcaaa3Dims₄] :=
  .cons puzzle10fcaaa3Example₁ <|
    .cons puzzle10fcaaa3Example₂ <|
      .cons puzzle10fcaaa3Example₃ <|
        .cons puzzle10fcaaa3Example₄ .nil

/-- ARC task "10fcaaa3" encoding four training pairs. -/
def puzzle10fcaaa3Task : Task [puzzle10fcaaa3Dims₁, puzzle10fcaaa3Dims₂, puzzle10fcaaa3Dims₃, puzzle10fcaaa3Dims₄] :=
  { name := "10fcaaa3"
  , examples := puzzle10fcaaa3Examples }

end CogitoCore.ARC.Tasks
