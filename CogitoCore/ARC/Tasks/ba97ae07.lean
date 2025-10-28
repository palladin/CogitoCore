import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzleba97ae07Program : Program Grid Grid :=
  Program.last alignCrossSegmentsTransform

def puzzleba97ae07Solution : Solution :=
  { taskName := "ba97ae07"
  , program := puzzleba97ae07Program }

end CogitoCore.ARC.Tasks
