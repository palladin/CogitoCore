import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzle11852cabProgram : Program Grid Grid :=
  Program.last mirrorBoundingBoxSymmetryTransform

def puzzle11852cabSolution : Solution :=
  { taskName := "11852cab"
  , program := puzzle11852cabProgram }

end CogitoCore.ARC.Tasks
