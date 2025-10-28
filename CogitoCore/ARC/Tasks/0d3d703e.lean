import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

/-- ------------------------------------------------------------------
    Puzzle 0d3d703e (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

def puzzle0d3d703eInput₁ : Grid :=
  #[#[.C3, .C1, .C2], #[.C3, .C1, .C2], #[.C3, .C1, .C2]]

def puzzle0d3d703eOutput₁ : Grid :=
  #[#[.C4, .C5, .C6], #[.C4, .C5, .C6], #[.C4, .C5, .C6]]

def puzzle0d3d703eInput₂ : Grid :=
  #[#[.C2, .C3, .C8], #[.C2, .C3, .C8], #[.C2, .C3, .C8]]

def puzzle0d3d703eOutput₂ : Grid :=
  #[#[.C6, .C4, .C9], #[.C6, .C4, .C9], #[.C6, .C4, .C9]]

def puzzle0d3d703eInput₃ : Grid :=
  #[#[.C5, .C8, .C6], #[.C5, .C8, .C6], #[.C5, .C8, .C6]]

def puzzle0d3d703eOutput₃ : Grid :=
  #[#[.C1, .C9, .C2], #[.C1, .C9, .C2], #[.C1, .C9, .C2]]

def puzzle0d3d703eInput₄ : Grid :=
  #[#[.C9, .C4, .C2], #[.C9, .C4, .C2], #[.C9, .C4, .C2]]

def puzzle0d3d703eOutput₄ : Grid :=
  #[#[.C8, .C3, .C6], #[.C8, .C3, .C6], #[.C8, .C3, .C6]]

def puzzle0d3d703eExample₁ : Example :=
  { input := puzzle0d3d703eInput₁
  , output := puzzle0d3d703eOutput₁ }

def puzzle0d3d703eExample₂ : Example :=
  { input := puzzle0d3d703eInput₂
  , output := puzzle0d3d703eOutput₂ }

def puzzle0d3d703eExample₃ : Example :=
  { input := puzzle0d3d703eInput₃
  , output := puzzle0d3d703eOutput₃ }

def puzzle0d3d703eExample₄ : Example :=
  { input := puzzle0d3d703eInput₄
  , output := puzzle0d3d703eOutput₄ }

def puzzle0d3d703eExamples : List Example :=
  [ puzzle0d3d703eExample₁
  , puzzle0d3d703eExample₂
  , puzzle0d3d703eExample₃
  , puzzle0d3d703eExample₄
  ]

/-- ARC task "0d3d703e" encoding four training pairs. -/
def puzzle0d3d703eTask : Task :=
  { name := "0d3d703e"
  , examples := puzzle0d3d703eExamples }

private def puzzle0d3d703eRecolor : Cell → Cell
  | .C0 => .C0
  | .C1 => .C5
  | .C2 => .C6
  | .C3 => .C4
  | .C4 => .C3
  | .C5 => .C1
  | .C6 => .C2
  | .C7 => .C7
  | .C8 => .C9
  | .C9 => .C8

def puzzle0d3d703eProgram : Program Grid Grid :=
  Program.last (mapGridCellsTransform puzzle0d3d703eRecolor)

def puzzle0d3d703eSolution : Solution :=
  { task := puzzle0d3d703eTask
  , program := puzzle0d3d703eProgram
  , isValid := by rfl }


end CogitoCore.ARC.Tasks
