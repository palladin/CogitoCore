import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzle6f8cd79bProgram : Program Grid Grid :=
  Program.last (frameBorderTransform Cell.C8)

def puzzle6f8cd79bSolution : Solution :=
  { taskName := "6f8cd79b"
  , program := puzzle6f8cd79bProgram }

end CogitoCore.ARC.Tasks
