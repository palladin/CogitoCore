import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzlebd4472b8Program : Program Grid Grid :=
  Program.last repeatPatternRowsTransform

def puzzlebd4472b8Solution : Solution :=
  { taskName := "bd4472b8"
  , program := puzzlebd4472b8Program }

end CogitoCore.ARC.Tasks
