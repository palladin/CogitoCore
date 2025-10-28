import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzle7b7f7511Program : Program Grid Grid :=
  Program.last fundamentalTileTransform

def puzzle7b7f7511Solution : Solution :=
  { taskName := "7b7f7511"
  , program := puzzle7b7f7511Program }

end CogitoCore.ARC.Tasks
