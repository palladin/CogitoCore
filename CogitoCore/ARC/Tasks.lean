import CogitoCore.ARC.Definitions

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Tasks


private def singletonVector {α : Type} (a : α) : Vector α 1 :=
  ⟨#[a], by rfl⟩

private def oneByOneGrid (value : Cell) : Grid 1 1 :=
  { cells := ⟨#[singletonVector value], by rfl⟩ }

private def oneByOneDims : InOutDim :=
  { inRows := 1
  , inCols := 1
  , outRows := 1
  , outCols := 1 }

/-- ------------------------------------------------------------------
    Identity task plumbing (single 1x1 grid example).
    ------------------------------------------------------------------ -/
def identityExample : Example oneByOneDims :=
  { input := oneByOneGrid .C5
  , output := oneByOneGrid .C5 }

def identityExamples : Examples [oneByOneDims] :=
  .cons identityExample .nil

def identityTask : Task [oneByOneDims] :=
  { name := "identity"
  , examples := identityExamples }


/-- ------------------------------------------------------------------
    Puzzle 017c7c7b (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

private def row3 (a b c : Cell) : Vector Cell 3 :=
  ⟨#[a, b, c], by rfl⟩

private def row9
    (a₀ a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ : Cell) : Vector Cell 9 :=
  ⟨#[a₀, a₁, a₂, a₃, a₄, a₅, a₆, a₇, a₈], by rfl⟩

private def row4 (a₀ a₁ a₂ a₃ : Cell) : Vector Cell 4 :=
  ⟨#[a₀, a₁, a₂, a₃], by rfl⟩

private def row5 (a₀ a₁ a₂ a₃ a₄ : Cell) : Vector Cell 5 :=
  ⟨#[a₀, a₁, a₂, a₃, a₄], by rfl⟩

private def row6 (a₀ a₁ a₂ a₃ a₄ a₅ : Cell) : Vector Cell 6 :=
  ⟨#[a₀, a₁, a₂, a₃, a₄, a₅], by rfl⟩

private def row8
    (a₀ a₁ a₂ a₃ a₄ a₅ a₆ a₇ : Cell) : Vector Cell 8 :=
  ⟨#[a₀, a₁, a₂, a₃, a₄, a₅, a₆, a₇], by rfl⟩

private def row10
    (a₀ a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ a₉ : Cell) : Vector Cell 10 :=
  ⟨#[a₀, a₁, a₂, a₃, a₄, a₅, a₆, a₇, a₈, a₉], by rfl⟩

private def puzzle017c7c7bDims : InOutDim :=
  { inRows := 6
  , inCols := 3
  , outRows := 9
  , outCols := 3 }

private def puzzle017c7c7bInput₁ : Grid 6 3 :=
  { cells :=
      ⟨#[ row3 .C0 .C1 .C0
        , row3 .C1 .C1 .C0
        , row3 .C0 .C1 .C0
        , row3 .C0 .C1 .C1
        , row3 .C0 .C1 .C0
        , row3 .C1 .C1 .C0 ]
      , by rfl⟩ }

private def puzzle017c7c7bOutput₁ : Grid 9 3 :=
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

private def puzzle017c7c7bInput₂ : Grid 6 3 :=
  { cells :=
      ⟨#[ row3 .C0 .C1 .C0
        , row3 .C1 .C0 .C1
        , row3 .C0 .C1 .C0
        , row3 .C1 .C0 .C1
        , row3 .C0 .C1 .C0
        , row3 .C1 .C0 .C1 ]
      , by rfl⟩ }

private def puzzle017c7c7bOutput₂ : Grid 9 3 :=
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

private def puzzle017c7c7bInput₃ : Grid 6 3 :=
  { cells :=
      ⟨#[ row3 .C0 .C1 .C0
        , row3 .C1 .C1 .C0
        , row3 .C0 .C1 .C0
        , row3 .C0 .C1 .C0
        , row3 .C1 .C1 .C0
        , row3 .C0 .C1 .C0 ]
      , by rfl⟩ }

private def puzzle017c7c7bOutput₃ : Grid 9 3 :=
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


/-- ------------------------------------------------------------------
    Puzzle 025d127b (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

private def puzzle025d127bDims₁ : InOutDim :=
  { inRows := 14
  , inCols := 9
  , outRows := 14
  , outCols := 9 }

private def puzzle025d127bDims₂ : InOutDim :=
  { inRows := 8
  , inCols := 9
  , outRows := 8
  , outCols := 9 }

private def puzzle025d127bInput₁ : Grid 14 9 :=
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

private def puzzle025d127bOutput₁ : Grid 14 9 :=
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

private def puzzle025d127bInput₂ : Grid 8 9 :=
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

private def puzzle025d127bOutput₂ : Grid 8 9 :=
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

def puzzle025d127bTask : Task [puzzle025d127bDims₁, puzzle025d127bDims₂] :=
  { name := "025d127b"
  , examples := puzzle025d127bExamples }


/-- ------------------------------------------------------------------
    Puzzle 08ed6ac7 (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

private def puzzle08ed6ac7Dims : InOutDim :=
  { inRows := 9
  , inCols := 9
  , outRows := 9
  , outCols := 9 }

private def puzzle08ed6ac7Input₁ : Grid 9 9 :=
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

private def puzzle08ed6ac7Output₁ : Grid 9 9 :=
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

private def puzzle08ed6ac7Input₂ : Grid 9 9 :=
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

private def puzzle08ed6ac7Output₂ : Grid 9 9 :=
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

def puzzle08ed6ac7Task : Task [puzzle08ed6ac7Dims, puzzle08ed6ac7Dims] :=
  { name := "08ed6ac7"
  , examples := puzzle08ed6ac7Examples }


/-- ------------------------------------------------------------------
    Puzzle 0d3d703e (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

private def puzzle0d3d703eDims : InOutDim :=
  { inRows := 3
  , inCols := 3
  , outRows := 3
  , outCols := 3 }

private def puzzle0d3d703eInput₁ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C3 .C1 .C2
        , row3 .C3 .C1 .C2
        , row3 .C3 .C1 .C2 ]
      , by rfl⟩ }

private def puzzle0d3d703eOutput₁ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C4 .C5 .C6
        , row3 .C4 .C5 .C6
        , row3 .C4 .C5 .C6 ]
      , by rfl⟩ }

private def puzzle0d3d703eInput₂ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C2 .C3 .C8
        , row3 .C2 .C3 .C8
        , row3 .C2 .C3 .C8 ]
      , by rfl⟩ }

private def puzzle0d3d703eOutput₂ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C6 .C4 .C9
        , row3 .C6 .C4 .C9
        , row3 .C6 .C4 .C9 ]
      , by rfl⟩ }

private def puzzle0d3d703eInput₃ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C5 .C8 .C6
        , row3 .C5 .C8 .C6
        , row3 .C5 .C8 .C6 ]
      , by rfl⟩ }

private def puzzle0d3d703eOutput₃ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C1 .C9 .C2
        , row3 .C1 .C9 .C2
        , row3 .C1 .C9 .C2 ]
      , by rfl⟩ }

private def puzzle0d3d703eInput₄ : Grid 3 3 :=
  { cells :=
      ⟨#[ row3 .C9 .C4 .C2
        , row3 .C9 .C4 .C2
        , row3 .C9 .C4 .C2 ]
      , by rfl⟩ }

private def puzzle0d3d703eOutput₄ : Grid 3 3 :=
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

def puzzle0d3d703eTask : Task [puzzle0d3d703eDims, puzzle0d3d703eDims, puzzle0d3d703eDims, puzzle0d3d703eDims] :=
  { name := "0d3d703e"
  , examples := puzzle0d3d703eExamples }


/-- ------------------------------------------------------------------
    Puzzle 10fcaaa3 (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

private def puzzle10fcaaa3Dims₁ : InOutDim :=
  { inRows := 2
  , inCols := 4
  , outRows := 4
  , outCols := 8 }

private def puzzle10fcaaa3Dims₂ : InOutDim :=
  { inRows := 3
  , inCols := 4
  , outRows := 6
  , outCols := 8 }

private def puzzle10fcaaa3Dims₃ : InOutDim :=
  { inRows := 5
  , inCols := 3
  , outRows := 10
  , outCols := 6 }

private def puzzle10fcaaa3Dims₄ : InOutDim :=
  { inRows := 4
  , inCols := 4
  , outRows := 8
  , outCols := 8 }

private def puzzle10fcaaa3Input₁ : Grid 2 4 :=
  { cells :=
      ⟨#[ row4 .C0 .C0 .C0 .C0
        , row4 .C0 .C5 .C0 .C0 ]
      , by rfl⟩ }

private def puzzle10fcaaa3Output₁ : Grid 4 8 :=
  { cells :=
      ⟨#[ row8 .C8 .C0 .C8 .C0 .C8 .C0 .C8 .C0
        , row8 .C0 .C5 .C0 .C0 .C0 .C5 .C0 .C0
        , row8 .C8 .C0 .C8 .C0 .C8 .C0 .C8 .C0
        , row8 .C0 .C5 .C0 .C0 .C0 .C5 .C0 .C0 ]
      , by rfl⟩ }

private def puzzle10fcaaa3Input₂ : Grid 3 4 :=
  { cells :=
      ⟨#[ row4 .C0 .C0 .C6 .C0
        , row4 .C0 .C0 .C0 .C0
        , row4 .C0 .C6 .C0 .C0 ]
      , by rfl⟩ }

private def puzzle10fcaaa3Output₂ : Grid 6 8 :=
  { cells :=
      ⟨#[ row8 .C0 .C0 .C6 .C0 .C0 .C0 .C6 .C0
        , row8 .C8 .C8 .C8 .C8 .C8 .C8 .C8 .C8
        , row8 .C0 .C6 .C0 .C8 .C0 .C6 .C0 .C8
        , row8 .C8 .C0 .C6 .C0 .C8 .C0 .C6 .C0
        , row8 .C8 .C8 .C8 .C8 .C8 .C8 .C8 .C8
        , row8 .C0 .C6 .C0 .C0 .C0 .C6 .C0 .C0 ]
      , by rfl⟩ }

private def puzzle10fcaaa3Input₃ : Grid 5 3 :=
  { cells :=
      ⟨#[ row3 .C0 .C0 .C0
        , row3 .C0 .C4 .C0
        , row3 .C0 .C0 .C0
        , row3 .C0 .C0 .C0
        , row3 .C4 .C0 .C0 ]
      , by rfl⟩ }

private def puzzle10fcaaa3Output₃ : Grid 10 6 :=
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

private def puzzle10fcaaa3Input₄ : Grid 4 4 :=
  { cells :=
      ⟨#[ row4 .C0 .C0 .C0 .C0
        , row4 .C0 .C2 .C0 .C0
        , row4 .C0 .C0 .C0 .C0
        , row4 .C0 .C0 .C0 .C0 ]
      , by rfl⟩ }

private def puzzle10fcaaa3Output₄ : Grid 8 8 :=
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

def puzzle10fcaaa3Task : Task [puzzle10fcaaa3Dims₁, puzzle10fcaaa3Dims₂, puzzle10fcaaa3Dims₃, puzzle10fcaaa3Dims₄] :=
  { name := "10fcaaa3"
  , examples := puzzle10fcaaa3Examples }


/-- ------------------------------------------------------------------
    Puzzle 11852cab (Easy) training set encoded as Lean grids.
    ------------------------------------------------------------------ -/

private def puzzle11852cabDims : InOutDim :=
  { inRows := 10
  , inCols := 10
  , outRows := 10
  , outCols := 10 }

private def puzzle11852cabInput₁ : Grid 10 10 :=
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

private def puzzle11852cabOutput₁ : Grid 10 10 :=
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

private def puzzle11852cabInput₂ : Grid 10 10 :=
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

private def puzzle11852cabOutput₂ : Grid 10 10 :=
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

private def puzzle11852cabInput₃ : Grid 10 10 :=
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

private def puzzle11852cabOutput₃ : Grid 10 10 :=
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

def puzzle11852cabTask : Task [puzzle11852cabDims, puzzle11852cabDims, puzzle11852cabDims] :=
  { name := "11852cab"
  , examples := puzzle11852cabExamples }


end CogitoCore.ARC.Tasks
