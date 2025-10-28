import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzleb2862040Program : Program Grid Grid :=
  Program.last (recolorCyclicComponentsTransform Cell.C1 Cell.C8)

 def puzzleb2862040Solution : Solution :=
  { taskName := "b2862040"
  , program := puzzleb2862040Program }

end CogitoCore.ARC.Tasks
