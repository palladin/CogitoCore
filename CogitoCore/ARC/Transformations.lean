import CogitoCore.ARC.Definitions

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Transformations

private instance : Inhabited Cell := ⟨Cell.C0⟩
private instance : Inhabited (Array Cell) := ⟨#[]⟩

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

private def setCell (grid : Grid) (row col : Nat) (value : Cell) : Grid :=
  if row < grid.size then
  let currentRow := grid[row]!
    if col < currentRow.size then
      grid.set! row (currentRow.set! col value)
    else
      grid
  else
    grid

private def fillColumnBetween
    (grid : Grid) (col : Nat) (rowStart rowEnd : Nat)
    (startPos targetPos : Nat × Nat) (pathColor : Cell) : Grid :=
  let lower := Nat.min rowStart rowEnd
  let upper := Nat.max rowStart rowEnd
  if lower ≤ upper then
    let steps := upper - lower + 1
    let rec loop : Nat → Nat → Grid → Grid
      | 0, _, g => g
      | Nat.succ remaining, r, g =>
          let g :=
            if (r = startPos.fst ∧ col = startPos.snd) ∨ (r = targetPos.fst ∧ col = targetPos.snd) then
              g
            else
              setCell g r col pathColor
          loop remaining (r + 1) g
    loop steps lower grid
  else
    grid

private def fillRowBetween
    (grid : Grid) (row : Nat) (colStart colEnd : Nat)
    (startPos targetPos : Nat × Nat) (pathColor : Cell) : Grid :=
  let lower := Nat.min colStart colEnd
  let upper := Nat.max colStart colEnd
  if lower ≤ upper then
    let steps := upper - lower + 1
    let rec loop : Nat → Nat → Grid → Grid
      | 0, _, g => g
      | Nat.succ remaining, c, g =>
          let g :=
            if (row = startPos.fst ∧ c = startPos.snd) ∨ (row = targetPos.fst ∧ c = targetPos.snd) then
              g
            else
              setCell g row c pathColor
          loop remaining (c + 1) g
    loop steps lower grid
  else
    grid

def connectSingletonColors
    (startColor targetColor pathColor : Cell) : Transform Grid Grid :=
  { name := s!"connect {repr startColor} to {repr targetColor} with {repr pathColor}"
  , apply := fun grid =>
      match findSingletonCell grid startColor with
      | Except.error msg => (Except.error msg, [])
      | Except.ok startPos =>
        match findSingletonCell grid targetColor with
        | Except.error msg => (Except.error msg, [])
        | Except.ok targetPos =>
          let grid := fillColumnBetween grid startPos.snd startPos.fst targetPos.fst startPos targetPos pathColor
          let grid := fillRowBetween grid targetPos.fst startPos.snd targetPos.snd startPos targetPos pathColor
          (Except.ok grid, [])
  }


end CogitoCore.ARC.Transformations
