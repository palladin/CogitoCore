import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Tasks.Common

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Tasks

/-- ------------------------------------------------------------------
    Puzzle 08ed6ac7 (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

def puzzle08ed6ac7Dims : InOutDim :=
  { inRows := 9
  , inCols := 9
  , outRows := 9
  , outCols := 9 }

def puzzle08ed6ac7Input₁ : Grid 9 9 :=
  { cells :=
      ⟨#[ row9 .C0 .C0 .C0 .C0 .C0 .C5 .C0 .C0 .C0
        , row9 .C0 .C5 .C0 .C0 .C0 .C5 .C0 .C0 .C0
        , row9 .C0 .C5 .C0 .C0 .C0 .C5 .C0 .C0 .C0
        , row9 .C0 .C5 .C0 .C5 .C0 .C5 .C0 .C0 .C0
        , row9 .C0 .C5 .C0 .C5 .C0 .C5 .C0 .C0 .C0
        , row9 .C0 .C5 .C0 .C5 .C0 .C5 .C0 .C0 .C0
        , row9 .C0 .C5 .C0 .C5 .C0 .C5 .C0 .C5 .C0
        , row9 .C0 .C5 .C0 .C5 .C0 .C5 .C0 .C5 .C0
        , row9 .C0 .C5 .C0 .C5 .C0 .C5 .C0 .C5 .C0 ]
      , by rfl⟩ }

def puzzle08ed6ac7Output₁ : Grid 9 9 :=
  { cells :=
      ⟨#[ row9 .C0 .C0 .C0 .C0 .C0 .C1 .C0 .C0 .C0
        , row9 .C0 .C2 .C0 .C0 .C0 .C1 .C0 .C0 .C0
        , row9 .C0 .C2 .C0 .C0 .C0 .C1 .C0 .C0 .C0
        , row9 .C0 .C2 .C0 .C3 .C0 .C1 .C0 .C0 .C0
        , row9 .C0 .C2 .C0 .C3 .C0 .C1 .C0 .C0 .C0
        , row9 .C0 .C2 .C0 .C3 .C0 .C1 .C0 .C0 .C0
        , row9 .C0 .C2 .C0 .C3 .C0 .C1 .C0 .C4 .C0
        , row9 .C0 .C2 .C0 .C3 .C0 .C1 .C0 .C4 .C0
        , row9 .C0 .C2 .C0 .C3 .C0 .C1 .C0 .C4 .C0 ]
      , by rfl⟩ }

def puzzle08ed6ac7Input₂ : Grid 9 9 :=
  { cells :=
      ⟨#[ row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C5 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C5 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C5 .C0
        , row9 .C0 .C0 .C0 .C5 .C0 .C0 .C0 .C5 .C0
        , row9 .C0 .C0 .C0 .C5 .C0 .C5 .C0 .C5 .C0
        , row9 .C0 .C0 .C0 .C5 .C0 .C5 .C0 .C5 .C0
        , row9 .C0 .C5 .C0 .C5 .C0 .C5 .C0 .C5 .C0
        , row9 .C0 .C5 .C0 .C5 .C0 .C5 .C0 .C5 .C0 ]
      , by rfl⟩ }

def puzzle08ed6ac7Output₂ : Grid 9 9 :=
  { cells :=
      ⟨#[ row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C1 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C1 .C0
        , row9 .C0 .C0 .C0 .C0 .C0 .C0 .C0 .C1 .C0
        , row9 .C0 .C0 .C0 .C2 .C0 .C0 .C0 .C1 .C0
        , row9 .C0 .C0 .C0 .C2 .C0 .C3 .C0 .C1 .C0
        , row9 .C0 .C0 .C0 .C2 .C0 .C3 .C0 .C1 .C0
        , row9 .C0 .C4 .C0 .C2 .C0 .C3 .C0 .C1 .C0
        , row9 .C0 .C4 .C0 .C2 .C0 .C3 .C0 .C1 .C0 ]
      , by rfl⟩ }

def puzzle08ed6ac7Example₁ : Example puzzle08ed6ac7Dims :=
  { input := puzzle08ed6ac7Input₁
  , output := puzzle08ed6ac7Output₁ }

def puzzle08ed6ac7Example₂ : Example puzzle08ed6ac7Dims :=
  { input := puzzle08ed6ac7Input₂
  , output := puzzle08ed6ac7Output₂ }

def puzzle08ed6ac7Examples : Examples [puzzle08ed6ac7Dims, puzzle08ed6ac7Dims] :=
  .cons puzzle08ed6ac7Example₁ <|
    .cons puzzle08ed6ac7Example₂ .nil

/-- ARC task "08ed6ac7" encoding two training pairs. -/
def puzzle08ed6ac7Task : Task [puzzle08ed6ac7Dims, puzzle08ed6ac7Dims] :=
  { name := "08ed6ac7"
  , examples := puzzle08ed6ac7Examples }

end CogitoCore.ARC.Tasks
