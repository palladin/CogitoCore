import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzled0f5fe59Program : Program Grid Grid :=
  Program.last (componentsToDiagonalTransform Cell.C8)

def puzzled0f5fe59Solution : Solution :=
  { taskName := "d0f5fe59"
  , program := puzzled0f5fe59Program }

end CogitoCore.ARC.Tasks
