import CogitoCore.ARC.Definitions

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Transformations

def mapGridCellsTransform (f : Cell → Cell) : Transform Grid Grid :=
  { name := "map-grid-cells"
  , apply := fun grid => pure <| grid.map fun row => row.map f }

def gridIdentityTransform : Transform Grid Grid :=
  { name := "grid-id"
  , apply := fun input => pure input }

private def shiftRowRight (row : Array Cell) : Array Cell :=
  let width := row.size
  let rec loop (indices : List Nat) (acc : Array Cell) : Array Cell :=
    match indices with
    | [] => acc
    | idx :: rest =>
        let acc :=
          match row[idx]? with
          | none => acc
          | some cell =>
              if cell == Cell.C0 then
                acc
              else
                let target := idx + 1
                if target < width then
                  acc.set! target cell
                else
                  acc
        loop rest acc
  loop (List.range width) (Array.replicate width Cell.C0)

/-- Shift all non-zero cells one step to the right, ignoring any pixels that would fall off the edge. -/
def shiftNonZeroRightTransform : Transform Grid Grid :=
  { name := "shift-nonzero-right"
  , apply := fun grid => pure <| grid.map shiftRowRight }

end CogitoCore.ARC.Transformations
