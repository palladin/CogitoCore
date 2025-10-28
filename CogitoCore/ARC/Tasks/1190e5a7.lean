import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzle1190e5a7Program : Program Grid Grid :=
  Program.last compressSeparatorsTransform

def puzzle1190e5a7Solution : Solution :=
  { taskName := "1190e5a7"
  , program := puzzle1190e5a7Program }

end CogitoCore.ARC.Tasks
