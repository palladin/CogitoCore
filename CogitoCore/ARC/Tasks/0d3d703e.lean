import CogitoCore.ARC.Definitions

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Tasks

/-- ------------------------------------------------------------------
    Puzzle 0d3d703e (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

def puzzle0d3d703eInput₁ : Grid :=
  { cells := #[#[.C3, .C1, .C2], #[.C3, .C1, .C2], #[.C3, .C1, .C2]] }

def puzzle0d3d703eOutput₁ : Grid :=
  { cells := #[#[.C4, .C5, .C6], #[.C4, .C5, .C6], #[.C4, .C5, .C6]] }

def puzzle0d3d703eInput₂ : Grid :=
  { cells := #[#[.C2, .C3, .C8], #[.C2, .C3, .C8], #[.C2, .C3, .C8]] }

def puzzle0d3d703eOutput₂ : Grid :=
  { cells := #[#[.C6, .C4, .C9], #[.C6, .C4, .C9], #[.C6, .C4, .C9]] }

def puzzle0d3d703eInput₃ : Grid :=
  { cells := #[#[.C5, .C8, .C6], #[.C5, .C8, .C6], #[.C5, .C8, .C6]] }

def puzzle0d3d703eOutput₃ : Grid :=
  { cells := #[#[.C1, .C9, .C2], #[.C1, .C9, .C2], #[.C1, .C9, .C2]] }

def puzzle0d3d703eInput₄ : Grid :=
  { cells := #[#[.C9, .C4, .C2], #[.C9, .C4, .C2], #[.C9, .C4, .C2]] }

def puzzle0d3d703eOutput₄ : Grid :=
  { cells := #[#[.C8, .C3, .C6], #[.C8, .C3, .C6], #[.C8, .C3, .C6]] }

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
  , puzzle0d3d703eExample₄ ]

/-- ARC task "0d3d703e" encoding four training pairs. -/
def puzzle0d3d703eTask : Task :=
  { name := "0d3d703e"
  , examples := puzzle0d3d703eExamples }

end CogitoCore.ARC.Tasks
