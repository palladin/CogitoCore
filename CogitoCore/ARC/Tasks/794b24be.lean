import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

/-- Program for ARC task 794b24be.
This task counts cells with value 1 and places that many 2s in a specific pattern:
positions (0,0), (0,1), (0,2), (1,1) in order. -/
def puzzle794b24beProgram : Program Grid Grid :=
  Program.last countOnesAndPlaceTwosTransform

/-- Registered solution entry for ARC task 794b24be. -/
def puzzle794b24beSolution : Solution :=
  { taskName := "794b24be"
  , program := puzzle794b24beProgram }

end CogitoCore.ARC.Tasks
