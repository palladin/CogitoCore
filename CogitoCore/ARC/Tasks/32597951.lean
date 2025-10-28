import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzle32597951Program : Program Grid Grid :=
  Program.last (recolorAdjacentCellsTransform Cell.C1 Cell.C8 Cell.C3)

 def puzzle32597951Solution : Solution :=
  { taskName := "32597951"
  , program := puzzle32597951Program }

end CogitoCore.ARC.Tasks
