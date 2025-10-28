import CogitoCore.ARC.Definitions

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Transformations

def mapGridCellsTransform (f : Cell → Cell) : Transform Grid Grid :=
  { name := "map-grid-cells"
  , apply := fun grid => pure <| grid.map fun row => row.map f }

def recolorGridTransform (f : Cell → Cell) : Transform Grid Grid :=
  { name := "recolor-grid"
  , apply := fun grid => (mapGridCellsTransform f).apply grid }

def gridIdentityTransform : Transform Grid Grid :=
  { name := "grid-id"
  , apply := fun input => pure input }

end CogitoCore.ARC.Transformations
