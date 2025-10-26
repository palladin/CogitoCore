import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Tasks

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Tasks
namespace CogitoCore.ARC.Programs


private def gridIdentityTransform : Transform (Grid rows cols) (Grid rows cols) :=
  { name := s!"grid-id-{rows}x{cols}"
  , apply := id }

def identityWitness : { ps : Programs [oneByOneDims] // validateTask ps identityTask = true } :=
  ⟨.cons (.last gridIdentityTransform) .nil, by rfl⟩

end CogitoCore.ARC.Programs
