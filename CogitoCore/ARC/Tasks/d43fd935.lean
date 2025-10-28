import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzled43fd935Program : Program Grid Grid :=
  Program.last connectToUniformBlockTransform

def puzzled43fd935Solution : Solution :=
  { taskName := "d43fd935"
  , program := puzzled43fd935Program }

end CogitoCore.ARC.Tasks
