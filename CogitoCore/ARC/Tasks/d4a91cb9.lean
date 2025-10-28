import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def puzzled4a91cb9Program : Program Grid Grid :=
  Program.last connectEightToTwoPathTransform

def puzzled4a91cb9Solution : Solution :=
  { taskName := "d4a91cb9"
  , program := puzzled4a91cb9Program }

end CogitoCore.ARC.Tasks
