import CogitoCore.ARC.Definitions

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Tasks

namespace d4a91cb9

inductive ConnectorPhase where
  | vertical
  | horizontal
  | done
  deriving Repr, BEq

structure ConnectorState where
  grid : Grid
  startColor : Cell
  targetColor : Cell
  pathColor : Cell
  startPos : Nat × Nat
  targetPos : Nat × Nat
  planned : Bool
  currentRow : Nat
  currentCol : Nat
  verticalIncrease : Bool
  verticalRemaining : Nat
  horizontalIncrease : Bool
  horizontalRemaining : Nat
  phase : ConnectorPhase
  pathCells : List (Nat × Nat)
  deriving Repr

private def gridSize (grid : Grid) : Nat × Nat :=
  let rows := grid.size
  let cols :=
    match grid[0]? with
    | some row => row.size
    | none => 0
  (rows, cols)

private def updateWorld (state : ConnectorState) : World ConnectorState :=
  { state := state
  , size := gridSize state.grid
  }

private def setCell (grid : Grid) (row col : Nat) (value : Cell) : Grid :=
  if row < grid.size then
    let currentRow := grid[row]!
    if col < currentRow.size then
      grid.set! row (currentRow.set! col value)
    else
      grid
  else
    grid

private def positionsOfColor (grid : Grid) (target : Cell) : List (Nat × Nat) :=
  let (acc, _) :=
    grid.foldl
      (fun (state : List (Nat × Nat) × Nat) row =>
        let (acc, rIdx) := state
        let (rowAcc, _) :=
          row.foldl
            (fun (colState : List (Nat × Nat) × Nat) cell =>
              let (acc, cIdx) := colState
              let acc := if cell == target then (rIdx, cIdx) :: acc else acc
              (acc, cIdx + 1))
            (acc, 0)
        (rowAcc, rIdx + 1))
      ([], 0)
  acc

private def findSingletonCell (grid : Grid) (target : Cell) : Except String (Nat × Nat) :=
  match positionsOfColor grid target with
  | [] => Except.error s!"missing cell of color {repr target}"
  | [pos] => Except.ok pos
  | _ => Except.error s!"multiple cells of color {repr target}"

private def absDiff (a b : Nat) : Nat :=
  if a ≤ b then b - a else a - b

private def stepForward (increase : Bool) (value : Nat) : Nat :=
  if increase then value + 1 else
    match value with
    | 0 => 0
    | Nat.succ k => k

private def isEndpoint (state : ConnectorState) (pos : Nat × Nat) : Bool :=
  decide (pos = state.startPos) || decide (pos = state.targetPos)

private def updatePhase (verticalRemaining horizontalRemaining : Nat) : ConnectorPhase :=
  if verticalRemaining > 0 then ConnectorPhase.vertical
  else if horizontalRemaining > 0 then ConnectorPhase.horizontal
  else ConnectorPhase.done

private def planConnector : Transform (World ConnectorState) (World ConnectorState) :=
  { name := "plan connector"
  , apply := fun world =>
      let state := world.state
      let grid := state.grid
      match findSingletonCell grid state.startColor with
      | Except.error msg => (Except.error msg, [])
      | Except.ok startPos =>
        match findSingletonCell grid state.targetColor with
        | Except.error msg => (Except.error msg, [])
        | Except.ok targetPos =>
            let startRow := startPos.fst
            let startCol := startPos.snd
            let targetRow := targetPos.fst
            let targetCol := targetPos.snd
            let verticalRemaining := absDiff startRow targetRow
            let horizontalRemaining := absDiff startCol targetCol
            let newState : ConnectorState :=
              { state with
                  startPos := startPos
                  targetPos := targetPos
                  planned := true
                  currentRow := startRow
                  currentCol := startCol
                  verticalIncrease := startRow ≤ targetRow
                  verticalRemaining := verticalRemaining
                  horizontalIncrease := startCol ≤ targetCol
                  horizontalRemaining := horizontalRemaining
                  phase := updatePhase verticalRemaining horizontalRemaining
                  pathCells := []
              }
            let msg :=
              s!"planned connector ({repr state.pathColor}) vertical steps = {verticalRemaining}, horizontal steps = {horizontalRemaining}"
            (Except.ok (updateWorld newState), [toString msg])
  }

private def drawNextVerticalFrame : Transform (World ConnectorState) (World ConnectorState) :=
  { name := "vertical frame"
  , apply := fun world =>
      let state := world.state
      if ¬ state.planned then
        (Except.ok world, ["vertical frame idle (unplanned)"])
      else
        match state.phase with
        | ConnectorPhase.vertical =>
            match state.verticalRemaining with
            | 0 =>
                let newState :=
                  { state with phase := updatePhase 0 state.horizontalRemaining }
                (Except.ok (updateWorld newState), ["vertical phase complete"])
            | Nat.succ remaining =>
                let nextRow := stepForward state.verticalIncrease state.currentRow
                let nextCell := (nextRow, state.currentCol)
                let paint := !isEndpoint state nextCell
                let updatedGrid := if paint then setCell state.grid nextRow state.currentCol state.pathColor else state.grid
                let newState :=
                  { state with
                      grid := updatedGrid
                      currentRow := nextRow
                      verticalRemaining := remaining
                      phase := updatePhase remaining state.horizontalRemaining
                      pathCells := if paint then nextCell :: state.pathCells else state.pathCells
                  }
                (Except.ok (updateWorld newState), [s!"vertical frame drew {repr nextCell}"])
        | _ => (Except.ok world, ["vertical frame idle"])
  }

private def drawNextHorizontalFrame : Transform (World ConnectorState) (World ConnectorState) :=
  { name := "horizontal frame"
  , apply := fun world =>
      let state := world.state
      if ¬ state.planned then
        (Except.ok world, ["horizontal frame idle (unplanned)"])
      else
        match state.phase with
        | ConnectorPhase.horizontal =>
            match state.horizontalRemaining with
            | 0 =>
                let newState :=
                  { state with phase := ConnectorPhase.done }
                (Except.ok (updateWorld newState), ["horizontal phase complete"])
            | Nat.succ remaining =>
                let nextCol := stepForward state.horizontalIncrease state.currentCol
                let nextCell := (state.currentRow, nextCol)
                let paint := !isEndpoint state nextCell
                let updatedGrid := if paint then setCell state.grid state.currentRow nextCol state.pathColor else state.grid
                let newState :=
                  { state with
                      grid := updatedGrid
                      currentCol := nextCol
                      horizontalRemaining := remaining
                      phase := updatePhase state.verticalRemaining remaining
                      pathCells := if paint then nextCell :: state.pathCells else state.pathCells
                  }
                (Except.ok (updateWorld newState), [s!"horizontal frame drew {repr nextCell}"])
        | _ => (Except.ok world, ["horizontal frame idle"])
  }

private def finalizeConnector : Transform (World ConnectorState) (World ConnectorState) :=
  { name := "finalize connector"
  , apply := fun world =>
      let total := world.state.pathCells.length
      (Except.ok world, [s!"connector complete across {total} frames"])
  }

private def repeatWorldTransform
    (count : Nat)
    (t : Transform (World ConnectorState) (World ConnectorState))
    (tail : Pipeline (World ConnectorState) (World ConnectorState)) :
    Pipeline (World ConnectorState) (World ConnectorState) :=
  match count with
  | 0 => tail
  | Nat.succ n => Pipeline.step t (repeatWorldTransform n t tail)

def connectSingletonAnimated
    (verticalFrames horizontalFrames : Nat) : Pipeline (World ConnectorState) (World ConnectorState) :=
  let tail := repeatWorldTransform horizontalFrames drawNextHorizontalFrame (Pipeline.last finalizeConnector)
  let worldPipeline := repeatWorldTransform verticalFrames drawNextVerticalFrame tail
  Pipeline.step planConnector worldPipeline

end d4a91cb9

open d4a91cb9

def puzzled4a91cb9Solution : Solution :=
  let startColor := Cell.C8
  let targetColor := Cell.C2
  let pathColor := Cell.C4
  let initialStateFromGrid (grid : Grid) : ConnectorState :=
    { grid := grid
    , startColor := startColor
    , targetColor := targetColor
    , pathColor := pathColor
    , startPos := (0, 0)
    , targetPos := (0, 0)
    , planned := false
    , currentRow := 0
    , currentCol := 0
    , verticalIncrease := true
    , verticalRemaining := 0
    , horizontalIncrease := true
    , horizontalRemaining := 0
    , phase := ConnectorPhase.vertical
    , pathCells := []
    }
  { σ := ConnectorState
  , toGrid := fun world => world.state.grid
  , toWorld := fun grid => updateWorld (initialStateFromGrid grid)
  , pipeline := connectSingletonAnimated 30 30
  , taskName := "d4a91cb9"
  }

end CogitoCore.ARC.Tasks
