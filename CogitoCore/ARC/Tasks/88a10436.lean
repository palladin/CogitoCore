import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzle88a10436Program : Program Grid Grid :=
  Program.last copyShapeToAnchorTransform

def puzzle88a10436Solution : Solution :=
  { taskName := "88a10436"
  , program := puzzle88a10436Program }

end CogitoCore.ARC.Tasks
