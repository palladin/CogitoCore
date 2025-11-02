import CogitoCore.ARC.Definitions

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Tasks

/-- Helper to compute an inclusive range between two natural numbers in ascending order. -/
private def inclusiveRange (a b : Nat) : List Nat :=
  let low := Nat.min a b
  let high := Nat.max a b
  (List.range (high - low + 1)).map (fun offset => low + offset)

/-- Locate the first occurrence of a cell value within a row, if present. -/
private def findInRow? (row : Array Cell) (target : Cell) : Option Nat :=
  let rec loop (cells : List Cell) (idx : Nat) : Option Nat :=
    match cells with
    | [] => none
    | cell :: rest =>
        if cell == target then
          some idx
        else
          loop rest (idx + 1)
  loop row.toList 0

/-- Locate the coordinates of the first occurrence of a cell value within a grid, if present. -/
private def findCoord? (grid : Grid) (target : Cell) : Option (Nat × Nat) :=
  let rec loop (rows : List (Array Cell)) (rowIdx : Nat) : Option (Nat × Nat) :=
    match rows with
    | [] => none
    | row :: rest =>
        match findInRow? row target with
        | some colIdx => some (rowIdx, colIdx)
        | none => loop rest (rowIdx + 1)
  loop grid.toList 0

/-- Safely set a cell within the grid, leaving it unchanged if the coordinates are out of bounds. -/
private def setCell (grid : Grid) (row col : Nat) (value : Cell) : Grid :=
  if hRow : row < grid.size then
    let rowFin : Fin grid.size := ⟨row, hRow⟩
    let currentRow := grid[rowFin]
    if hCol : col < currentRow.size then
      let colFin : Fin currentRow.size := ⟨col, hCol⟩
      let updatedRow := currentRow.set colFin value
      grid.set rowFin updatedRow
    else
      grid
  else
    grid

/-- Paint a list of coordinates with the provided cell value. -/
private def paintCells (grid : Grid) (coords : List (Nat × Nat)) (value : Cell) : Grid :=
  coords.foldl
    (fun acc coord =>
      let (row, col) := coord
      setCell acc row col value)
    grid

/-- Compute the size of a grid as (height, width). -/
private def gridSize (grid : Grid) : Nat × Nat :=
  let height := grid.size
  let width :=
    if h : 0 < height then
      let rowFin : Fin grid.size := ⟨0, h⟩
      let firstRow := grid[rowFin]
      firstRow.size
    else
      0
  (height, width)

/-- Enumerate the interior coordinates of the L-shaped path connecting the 8 to the 2. -/
private def pathBetween (input : Grid) : List (Nat × Nat) :=
  match findCoord? input Cell.C8, findCoord? input Cell.C2 with
  | some start, some goal =>
      let (startRow, startCol) := start
      let (goalRow, goalCol) := goal
      let vertical := (inclusiveRange startRow goalRow).map (fun r => (r, startCol))
      let horizontal := (inclusiveRange startCol goalCol).map (fun c => (goalRow, c))
      let rawCoords := vertical ++ horizontal
      let coords := rawCoords.filter fun coord =>
        let isStart : Bool := decide (coord = start)
        let isGoal : Bool := decide (coord = goal)
        !(isStart || isGoal)
      coords.eraseDups
  | _, _ => []

structure PathState where
  base : Grid
  painted : List (Nat × Nat)
  remaining : List (Nat × Nat)
  tick : Nat

instance : Repr PathState where
  reprPrec state _ :=
    let formatCoord (coord : Nat × Nat) : String :=
      let (row, col) := coord
      s!"({row}, {col})"
    let nextCoord :=
      match state.remaining with
      | [] => "none"
      | coord :: _ => formatCoord coord
    let lastPainted :=
      match state.painted.reverse with
      | [] => "none"
      | coord :: _ => formatCoord coord
    let paintedCount := state.painted.length
    let remainingCount := state.remaining.length
    let header :=
      Std.Format.text
        s!"tick={state.tick} | lastPainted={lastPainted} | nextPaint={nextCoord} | painted={paintedCount} | remaining={remainingCount}"
    let grid := Std.Format.text <|
      toString (repr (paintCells state.base state.painted Cell.C4))
    header ++ Std.Format.line ++ grid

def puzzled4a91cb9Solution : Solution :=
  { σ := PathState
  , stateRepr := inferInstance
  , toGrid := fun world =>
      paintCells world.state.base world.state.painted Cell.C4
  , toWorld := fun input =>
      let size := gridSize input
      let path := pathBetween input
      { state := { base := input, painted := [], remaining := path, tick := 0 }
        , size := size }
  , stepTransform := fun world =>
      match world.state.remaining with
      | [] => Result.Done
      | (row, col) :: rest =>
          let nextState : PathState :=
            { base := world.state.base
            , painted := world.state.painted ++ [(row, col)]
            , remaining := rest
            , tick := world.state.tick + 1 }
          let nextWorld : World PathState := { state := nextState, size := world.size }
          Result.Next nextWorld
  , taskName := "d4a91cb9" }

end CogitoCore.ARC.Tasks
