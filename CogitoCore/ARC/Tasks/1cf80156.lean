import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzle1cf80156Program : Program Grid Grid :=
  Program.last cropBoundingBoxTransform

def puzzle1cf80156Solution : Solution :=
  { taskName := "1cf80156"
  , program := puzzle1cf80156Program }

end CogitoCore.ARC.Tasks
