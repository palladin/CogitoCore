import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

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
  { taskName := "0d3d703e"
  , program := puzzle0d3d703eProgram }


end CogitoCore.ARC.Tasks
