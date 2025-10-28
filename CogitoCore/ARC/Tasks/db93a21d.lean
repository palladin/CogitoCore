import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

/-- Program for ARC task db93a21d.
This task adds borders around 9-blocks and connects them with lines. -/
def puzzledb93a21dProgram : Program Grid Grid :=
  Program.last addBordersAndConnectBlocksTransform

/-- Registered solution entry for ARC task db93a21d. -/
def puzzledb93a21dSolution : Solution :=
  { taskName := "db93a21d"
  , program := puzzledb93a21dProgram }

end CogitoCore.ARC.Tasks
