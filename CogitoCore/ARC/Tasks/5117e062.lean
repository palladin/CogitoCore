import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzle5117e062Program : Program Grid Grid :=
  Program.last extractEightNeighborhoodTransform

def puzzle5117e062Solution : Solution :=
  { taskName := "5117e062"
  , program := puzzle5117e062Program }

end CogitoCore.ARC.Tasks
