import CogitoCore.ARC.Definitions

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Tasks

namespace d4a91cb9

private instance : Inhabited Cell := ⟨Cell.C0⟩
private instance : Inhabited (Array Cell) := ⟨#[]⟩

inductive ConnectorPhase where
  | vertical
  | horizontal
  | done
  deriving Repr, BEq

structure ConnectorPlanState where
  startPos : Nat × Nat
  targetPos : Nat × Nat
  pathColor : Cell
  currentRow : Nat
  currentCol : Nat
  verticalIncrease : Bool
  verticalRemaining : Nat
  horizontalIncrease : Bool
  horizontalRemaining : Nat
  phase : ConnectorPhase
  pathCells : List (Nat × Nat)
  startEntity : Entity
  targetEntity : Entity
  deriving Repr

private def setCell (grid : Grid) (row col : Nat) (value : Cell) : Grid :=
  if row < grid.size then
    let currentRow := grid[row]!
    if col < currentRow.size then
      grid.set! row (currentRow.set! col value)
    else
      grid
  else
    grid

private def buildEntityForCells (cells : List (Nat × Nat)) (color : Cell) : Option Entity :=
  match cells with
  | [] => none
  | (r, c) :: rest =>
      let init := (r, r, c, c)
      let (minRow, maxRow, minCol, maxCol) :=
        rest.foldl
          (fun acc pos =>
            let (minR, maxR, minC, maxC) := acc
            let (row, col) := pos
            (Nat.min minR row, Nat.max maxR row, Nat.min minC col, Nat.max maxC col))
          init
      let height := maxRow - minRow + 1
      let width := maxCol - minCol + 1
      let emptyRow := Array.replicate width Cell.C0
      let baseGrid : Grid := Array.replicate height emptyRow
      let filledGrid :=
        cells.foldl
          (fun g (row, col) =>
            let localRow := row - minRow
            let localCol := col - minCol
            setCell g localRow localCol color)
          baseGrid
      some
        { grid := filledGrid
        , location := (minRow, minCol)
        , parts := []
        , background := []
        }

private def singletonEntity (pos : Nat × Nat) (color : Cell) : Entity :=
  match buildEntityForCells [pos] color with
  | some entity => entity
  | none =>
      { grid := #[]
      , location := pos
      , parts := []
      , background := []
      }

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

private def isEndpoint (state : ConnectorPlanState) (pos : Nat × Nat) : Bool :=
  decide (pos = state.startPos) || decide (pos = state.targetPos)

private def entitiesFromState (state : ConnectorPlanState) : List Entity :=
  match buildEntityForCells state.pathCells.reverse state.pathColor with
  | some pathEntity => pathEntity :: state.startEntity :: [state.targetEntity]
  | none => [state.startEntity, state.targetEntity]

private def updatePhase (verticalRemaining horizontalRemaining : Nat) : ConnectorPhase :=
  if verticalRemaining > 0 then ConnectorPhase.vertical
  else if horizontalRemaining > 0 then ConnectorPhase.horizontal
  else ConnectorPhase.done

def buildSingletonConnectorWorld
    (startColor targetColor pathColor : Cell) : Transform Grid (World ConnectorPlanState) :=
  { name := s!"plan connector {repr startColor}→{repr targetColor}"
  , apply := fun grid =>
      match findSingletonCell grid startColor with
      | Except.error msg => (Except.error msg, [])
      | Except.ok startPos =>
        match findSingletonCell grid targetColor with
        | Except.error msg => (Except.error msg, [])
        | Except.ok targetPos =>
            let startRow := startPos.fst
            let startCol := startPos.snd
            let targetRow := targetPos.fst
            let targetCol := targetPos.snd
            let rowDiff := absDiff startRow targetRow
            let colDiff := absDiff startCol targetCol
            let horizontalRemaining := colDiff
            let verticalRemaining := rowDiff
            let verticalIncrease := startRow ≤ targetRow
            let horizontalIncrease := startCol ≤ targetCol
            let startEntity := singletonEntity startPos startColor
            let targetEntity := singletonEntity targetPos targetColor
            let phase := updatePhase verticalRemaining horizontalRemaining
            let state : ConnectorPlanState :=
              { startPos := startPos
              , targetPos := targetPos
              , pathColor := pathColor
              , currentRow := startRow
              , currentCol := startCol
              , verticalIncrease := verticalIncrease
              , verticalRemaining := verticalRemaining
              , horizontalIncrease := horizontalIncrease
              , horizontalRemaining := horizontalRemaining
              , phase := phase
              , pathCells := []
              , startEntity := startEntity
              , targetEntity := targetEntity
              }
            let world : World ConnectorPlanState :=
              { state := state
              , grid := grid
              , entities := entitiesFromState state
              , background := []
              }
            let msg :=
              s!"planned connector ({repr pathColor}) vertical steps = {verticalRemaining}, horizontal steps = {horizontalRemaining}"
            (Except.ok world, [toString msg])
  }

def drawNextVerticalFrame : Transform (World ConnectorPlanState) (World ConnectorPlanState) :=
  { name := "vertical frame"
  , apply := fun world =>
      let state := world.state
      match state.phase with
      | ConnectorPhase.vertical =>
          match state.verticalRemaining with
          | 0 =>
              let newState :=
                { state with phase := updatePhase 0 state.horizontalRemaining }
              let updatedWorld : World ConnectorPlanState :=
                { world with
                    state := newState
                    , entities := entitiesFromState newState
                }
              (Except.ok updatedWorld, ["vertical phase complete"])
          | Nat.succ remaining =>
              let nextRow := stepForward state.verticalIncrease state.currentRow
              let nextCell := (nextRow, state.currentCol)
              let paint := !isEndpoint state nextCell
              let updatedGrid := if paint then setCell world.grid nextRow state.currentCol state.pathColor else world.grid
              let newPathCells := if paint then nextCell :: state.pathCells else state.pathCells
              let newPhase := updatePhase remaining state.horizontalRemaining
              let newState :=
                { state with
                    currentRow := nextRow
                    verticalRemaining := remaining
                    phase := newPhase
                    pathCells := newPathCells
                }
              let updatedWorld : World ConnectorPlanState :=
                { world with
                    grid := updatedGrid
                    state := newState
                    entities := entitiesFromState newState
                }
              (Except.ok updatedWorld, [s!"vertical frame drew {repr nextCell}"])
      | _ =>
          let updatedWorld : World ConnectorPlanState :=
            { world with entities := entitiesFromState state }
          (Except.ok updatedWorld, ["vertical frame idle"])
  }

def drawNextHorizontalFrame : Transform (World ConnectorPlanState) (World ConnectorPlanState) :=
  { name := "horizontal frame"
  , apply := fun world =>
      let state := world.state
      match state.phase with
      | ConnectorPhase.horizontal =>
          match state.horizontalRemaining with
          | 0 =>
              let newState :=
                { state with phase := ConnectorPhase.done }
              let updatedWorld : World ConnectorPlanState :=
                { world with
                    state := newState
                    entities := entitiesFromState newState
                }
              (Except.ok updatedWorld, ["horizontal phase complete"])
          | Nat.succ remaining =>
              let nextCol := stepForward state.horizontalIncrease state.currentCol
              let nextCell := (state.currentRow, nextCol)
              let paint := !isEndpoint state nextCell
              let updatedGrid := if paint then setCell world.grid state.currentRow nextCol state.pathColor else world.grid
              let newPathCells := if paint then nextCell :: state.pathCells else state.pathCells
              let newPhase := updatePhase state.verticalRemaining remaining
              let newState :=
                { state with
                    currentCol := nextCol
                    horizontalRemaining := remaining
                    phase := newPhase
                    pathCells := newPathCells
                }
              let updatedWorld : World ConnectorPlanState :=
                { world with
                    grid := updatedGrid
                    state := newState
                    entities := entitiesFromState newState
                }
              (Except.ok updatedWorld, [s!"horizontal frame drew {repr nextCell}"])
      | _ =>
          let updatedWorld : World ConnectorPlanState :=
            { world with entities := entitiesFromState state }
          (Except.ok updatedWorld, ["horizontal frame idle"])
  }

def connectorWorldToGrid : Transform (World ConnectorPlanState) Grid :=
  { name := "emit connector grid"
  , apply := fun world =>
      let total := world.state.pathCells.length
      (Except.ok world.grid, [s!"connector complete across {total} frames"])
  }

private def repeatWorldTransform
    {ω : Type}
    [Repr (World ConnectorPlanState)]
    (count : Nat)
    (t : Transform (World ConnectorPlanState) (World ConnectorPlanState))
    (tail : Pipeline (World ConnectorPlanState) ω) : Pipeline (World ConnectorPlanState) ω :=
  match count with
  | 0 => tail
  | Nat.succ n => Pipeline.step t (repeatWorldTransform n t tail)

def connectSingletonAnimated
    (startColor targetColor pathColor : Cell)
    (verticalFrames horizontalFrames : Nat) : Pipeline Grid Grid :=
  let tail := repeatWorldTransform horizontalFrames drawNextHorizontalFrame (Pipeline.last connectorWorldToGrid)
  let worldPipeline := repeatWorldTransform verticalFrames drawNextVerticalFrame tail
  Pipeline.step (buildSingletonConnectorWorld startColor targetColor pathColor) worldPipeline

end d4a91cb9

open d4a91cb9

def puzzled4a91cb9Solution : Solution :=
  { taskName := "d4a91cb9"
  , pipeline :=
    connectSingletonAnimated Cell.C8 Cell.C2 Cell.C4 30 30
  }

end CogitoCore.ARC.Tasks
