import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzle1f876c06Program : Program Grid Grid :=
  Program.last fillDiagonalSegmentsTransform

def puzzle1f876c06Solution : Solution :=
  { taskName := "1f876c06"
  , program := puzzle1f876c06Program }

end CogitoCore.ARC.Tasks
