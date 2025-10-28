import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzlec444b776Program : Program Grid Grid :=
  Program.last propagateAcrossSeparatorsTransform

def puzzlec444b776Solution : Solution :=
  { taskName := "c444b776"
  , program := puzzlec444b776Program }

end CogitoCore.ARC.Tasks
