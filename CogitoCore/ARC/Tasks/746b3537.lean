import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzle746b3537Program : Program Grid Grid :=
  Program.step removeConsecutiveDuplicateColumnsTransform
    (Program.last removeConsecutiveDuplicateRowsTransform)

def puzzle746b3537Solution : Solution :=
  { taskName := "746b3537"
  , program := puzzle746b3537Program }

end CogitoCore.ARC.Tasks
